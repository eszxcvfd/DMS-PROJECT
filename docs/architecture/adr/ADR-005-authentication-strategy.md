# ADR-005: Authentication Strategy

## Status
**Accepted** - 2026-02-02

## Context

We need to implement authentication for both mobile and web applications that supports:
- Username/password authentication
- Session management with token refresh
- Role-based access control
- Secure token storage
- Support for offline mode (mobile)
- Protection against common attacks

Key requirements:
- Stateless API authentication
- Short-lived access tokens
- Secure refresh mechanism
- Multi-device support
- Revocation capability

## Decision

We will use **JWT (JSON Web Tokens)** with a **short-lived access token + refresh token** pattern.

### Token Strategy:
- **Access Token**: 15-minute expiry, JWT format
- **Refresh Token**: 7-day expiry, opaque token stored in Redis
- **Signing Algorithm**: RS256 (asymmetric)

### Implementation:
- **Backend**: ASP.NET Core Identity + custom JWT generation
- **Mobile**: Encrypted storage with EncryptedSharedPreferences
- **Web**: HTTP-only cookie for refresh token, memory for access token

## Consequences

### Positive
- **Stateless**: Access tokens can be verified without database calls
- **Scalable**: No server-side session storage needed
- **Secure refresh**: Opaque refresh tokens allow revocation
- **Offline support**: Mobile can store tokens for offline access
- **Cross-platform**: Standard JWT works across all clients
- **Fine-grained**: Claims enable detailed authorization

### Negative
- **Token revocation**: Cannot immediately revoke access tokens (wait 15 min)
- **Token size**: JWT larger than session ID
- **Complexity**: Two-token system requires careful implementation

### Risks
- **Token theft**: Stolen tokens can be used until expiry
- **Mitigation**: Short expiry, device binding, anomaly detection

## Token Specifications

### Access Token (JWT)
```json
{
  "header": {
    "alg": "RS256",
    "typ": "JWT",
    "kid": "key-2026-01"
  },
  "payload": {
    "sub": "550e8400-e29b-41d4-a716-446655440000",
    "iss": "https://api.diligo-dms.com",
    "aud": "diligo-dms",
    "iat": 1706889600,
    "exp": 1706890500,
    "jti": "unique-token-id",
    "role": "NVBH",
    "distributorId": "distributor-uuid",
    "supervisorId": "supervisor-uuid",
    "permissions": ["orders.create", "visits.create"],
    "deviceId": "device-fingerprint"
  }
}
```

### Refresh Token (Redis)
```json
{
  "key": "refresh:user-uuid:device-uuid",
  "value": {
    "tokenId": "random-uuid",
    "userId": "user-uuid",
    "deviceId": "device-fingerprint",
    "issuedAt": "2026-02-02T10:00:00Z",
    "expiresAt": "2026-02-09T10:00:00Z",
    "lastUsedAt": "2026-02-02T10:15:00Z"
  },
  "ttl": 604800
}
```

## Alternatives Considered

### Session-based Authentication
- **Pros**: Simple, immediate revocation
- **Cons**:
  - Requires server-side storage
  - Scaling challenges
  - Not ideal for mobile offline
- **Decision**: Rejected for scalability

### OAuth 2.0 with External Provider
- **Pros**: Delegated auth, SSO support
- **Cons**:
  - Overkill for internal app
  - Additional infrastructure
  - External dependency
- **Decision**: Considered for future SSO

### Paseto (Platform-Agnostic Security Tokens)
- **Pros**: Simpler than JWT, better defaults
- **Cons**:
  - Less library support
  - Less familiar to developers
  - Smaller ecosystem
- **Decision**: Rejected for ecosystem maturity

### Access Token Only (Long-lived)
- **Pros**: Simpler implementation
- **Cons**:
  - Security risk if token stolen
  - No revocation without blacklist
- **Decision**: Rejected for security

## Implementation

### Backend Token Service
```csharp
public class TokenService : ITokenService
{
    private readonly JwtSecurityTokenHandler _tokenHandler = new();
    private readonly RsaSecurityKey _signingKey;
    private readonly IDistributedCache _cache;

    public async Task<TokenResponse> GenerateTokensAsync(User user, string deviceId)
    {
        var accessToken = GenerateAccessToken(user, deviceId);
        var refreshToken = await GenerateRefreshTokenAsync(user.Id, deviceId);

        return new TokenResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken.TokenId,
            ExpiresIn = 900, // 15 minutes
            TokenType = "Bearer"
        };
    }

    private string GenerateAccessToken(User user, string deviceId)
    {
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new("role", user.Role.ToString()),
            new("distributorId", user.DistributorId.ToString()),
            new("deviceId", deviceId)
        };

        // Add permissions based on role
        foreach (var permission in GetPermissionsForRole(user.Role))
        {
            claims.Add(new Claim("permissions", permission));
        }

        var token = new JwtSecurityToken(
            issuer: "https://api.diligo-dms.com",
            audience: "diligo-dms",
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(15),
            signingCredentials: new SigningCredentials(_signingKey, SecurityAlgorithms.RsaSha256)
        );

        return _tokenHandler.WriteToken(token);
    }

    private async Task<RefreshToken> GenerateRefreshTokenAsync(Guid userId, string deviceId)
    {
        var refreshToken = new RefreshToken
        {
            TokenId = Guid.NewGuid().ToString(),
            UserId = userId,
            DeviceId = deviceId,
            IssuedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7)
        };

        var key = $"refresh:{userId}:{deviceId}";
        await _cache.SetStringAsync(key,
            JsonSerializer.Serialize(refreshToken),
            new DistributedCacheEntryOptions
            {
                AbsoluteExpiration = refreshToken.ExpiresAt
            });

        return refreshToken;
    }

    public async Task<TokenResponse?> RefreshTokensAsync(string refreshTokenId, string deviceId)
    {
        // Find and validate refresh token
        var key = await FindRefreshTokenKeyAsync(refreshTokenId);
        if (key == null) return null;

        var refreshToken = await GetRefreshTokenAsync(key);
        if (refreshToken == null || refreshToken.DeviceId != deviceId)
            return null;

        if (refreshToken.ExpiresAt < DateTime.UtcNow)
        {
            await _cache.RemoveAsync(key);
            return null;
        }

        // Get user and generate new tokens
        var user = await _userRepository.GetByIdAsync(refreshToken.UserId);
        if (user == null || user.Status != UserStatus.Active)
            return null;

        // Revoke old refresh token
        await _cache.RemoveAsync(key);

        // Generate new token pair
        return await GenerateTokensAsync(user, deviceId);
    }

    public async Task RevokeAllTokensAsync(Guid userId)
    {
        // Remove all refresh tokens for user
        var pattern = $"refresh:{userId}:*";
        // Scan and delete all matching keys
        await _cache.RemoveByPatternAsync(pattern);
    }
}
```

### Mobile Token Storage (Android)
```kotlin
class SecureTokenStorage @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val encryptedPrefs = EncryptedSharedPreferences.create(
        context,
        "auth_tokens",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun saveTokens(accessToken: String, refreshToken: String) {
        encryptedPrefs.edit()
            .putString(KEY_ACCESS_TOKEN, accessToken)
            .putString(KEY_REFRESH_TOKEN, refreshToken)
            .putLong(KEY_ACCESS_TOKEN_EXPIRY, extractExpiry(accessToken))
            .apply()
    }

    fun getAccessToken(): String? {
        val expiry = encryptedPrefs.getLong(KEY_ACCESS_TOKEN_EXPIRY, 0)
        if (System.currentTimeMillis() / 1000 > expiry - 60) {
            // Token expired or expiring soon
            return null
        }
        return encryptedPrefs.getString(KEY_ACCESS_TOKEN, null)
    }

    fun getRefreshToken(): String? =
        encryptedPrefs.getString(KEY_REFRESH_TOKEN, null)

    fun clearTokens() {
        encryptedPrefs.edit().clear().apply()
    }

    private fun extractExpiry(token: String): Long {
        val parts = token.split(".")
        val payload = String(Base64.decode(parts[1], Base64.URL_SAFE))
        val json = JSONObject(payload)
        return json.getLong("exp")
    }

    companion object {
        private const val KEY_ACCESS_TOKEN = "access_token"
        private const val KEY_REFRESH_TOKEN = "refresh_token"
        private const val KEY_ACCESS_TOKEN_EXPIRY = "access_token_expiry"
    }
}
```

### Web Token Handling (Angular)
```typescript
@Injectable({ providedIn: 'root' })
export class AuthService {
  private accessToken: string | null = null;

  constructor(
    private http: HttpClient,
    private router: Router
  ) {}

  login(credentials: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>('/api/v1/auth/login', credentials, {
      withCredentials: true // For refresh token cookie
    }).pipe(
      tap(response => {
        this.accessToken = response.accessToken;
        this.scheduleTokenRefresh(response.expiresIn);
      })
    );
  }

  getAccessToken(): string | null {
    return this.accessToken;
  }

  refreshToken(): Observable<LoginResponse> {
    return this.http.post<LoginResponse>('/api/v1/auth/refresh', {}, {
      withCredentials: true
    }).pipe(
      tap(response => {
        this.accessToken = response.accessToken;
        this.scheduleTokenRefresh(response.expiresIn);
      }),
      catchError(() => {
        this.logout();
        return EMPTY;
      })
    );
  }

  private scheduleTokenRefresh(expiresIn: number): void {
    // Refresh 1 minute before expiry
    const refreshIn = (expiresIn - 60) * 1000;
    timer(refreshIn).pipe(
      switchMap(() => this.refreshToken())
    ).subscribe();
  }

  logout(): void {
    this.accessToken = null;
    this.http.post('/api/v1/auth/logout', {}, { withCredentials: true })
      .subscribe(() => this.router.navigate(['/login']));
  }
}
```

## Security Considerations

| Threat | Mitigation |
|--------|------------|
| Token theft | Short expiry (15 min), device binding |
| XSS | HTTP-only cookies, CSP headers |
| CSRF | SameSite cookies, CSRF tokens |
| Brute force | Rate limiting, account lockout |
| Replay attacks | JTI (JWT ID) tracking |
| Token leakage | HTTPS only, secure storage |

## References

- [RFC 7519 - JSON Web Token](https://tools.ietf.org/html/rfc7519)
- [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_Cheat_Sheet.html)
- [ASP.NET Core JWT Authentication](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/jwt)
