# ADR-005: JWT for Authentication

## Status

Accepted

## Date

2026-02-02

## Context

DMS VIPPro needs a secure authentication mechanism that works across mobile and web applications. The solution must support offline mobile scenarios, multiple device sessions, and role-based access control.

## Decision Drivers

- **Mobile compatibility**: Must work with Android app (no cookies)
- **Offline support**: Token-based validation without server roundtrip
- **Stateless API**: Scalable without session storage
- **Security**: Protect against common attacks
- **Session management**: Support multiple devices, revocation

## Considered Options

### 1. JWT Bearer Tokens
- Stateless validation
- Mobile-friendly
- Contains user claims
- Short-lived access tokens + refresh tokens

### 2. Session-Based (Cookies)
- Simple implementation
- Not ideal for mobile
- Requires session storage
- CSRF protection needed

### 3. OAuth 2.0 / OpenID Connect
- Industry standard
- Complex setup
- External identity provider
- Overkill for internal users

### 4. API Keys
- Simple to implement
- No user context
- Difficult to revoke
- Not suitable for user auth

## Decision

**We will use JWT Bearer Tokens with short-lived access tokens and longer-lived refresh tokens.**

### Token Strategy

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              JWT TOKEN STRATEGY                                          │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  ACCESS TOKEN                                                                           │
│  ────────────                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐                   │
│  │  Lifetime: 24 hours                                              │                   │
│  │  Storage: Mobile - EncryptedSharedPreferences                    │                   │
│  │           Web - Memory (not localStorage)                        │                   │
│  │  Contains: UserId, Role, DistributorId, Permissions              │                   │
│  │  Validation: Signature + Expiry (no DB lookup)                   │                   │
│  └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                         │
│  REFRESH TOKEN                                                                          │
│  ─────────────                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐                   │
│  │  Lifetime: 30 days                                               │                   │
│  │  Storage: Mobile - EncryptedSharedPreferences                    │                   │
│  │           Web - HttpOnly Secure Cookie                           │                   │
│  │  Contains: Random token ID (stored in database)                  │                   │
│  │  Validation: Database lookup, device binding                     │                   │
│  │  Rotation: New refresh token issued on use                       │                   │
│  └─────────────────────────────────────────────────────────────────┘                   │
│                                                                                         │
│  AUTHENTICATION FLOW                                                                    │
│  ───────────────────                                                                    │
│                                                                                         │
│  1. Login                                                                               │
│     User ──[username/password]──► API ──[validate]──► Issue tokens                     │
│                                                                                         │
│  2. API Request                                                                         │
│     Client ──[Bearer accessToken]──► API ──[validate JWT]──► Response                  │
│                                                                                         │
│  3. Token Refresh (when access token expires)                                           │
│     Client ──[refreshToken]──► API ──[validate in DB]──► New tokens                    │
│                                                                                         │
│  4. Logout                                                                              │
│     Client ──[refreshToken]──► API ──[revoke in DB]──► Success                         │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Rationale

1. **Mobile Compatibility**: JWT in Authorization header works perfectly with Android apps. No cookie handling needed.

2. **Offline Validation**: Access token claims allow basic authorization checks without network (role, permissions).

3. **Stateless API**: No session storage needed. Horizontal scaling is simple.

4. **Refresh Token Security**: Stored in database for revocation capability. Device binding prevents token theft.

5. **24-Hour Access Token**: Balance between security (shorter) and user experience (fewer refreshes). Offline mobile users won't need to re-authenticate frequently.

## Implementation

### JWT Configuration

```csharp
// Program.cs
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = configuration["Jwt:Issuer"],
            ValidAudience = configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!)),
            ClockSkew = TimeSpan.Zero
        };

        // SignalR authentication
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                {
                    context.Token = accessToken;
                }
                return Task.CompletedTask;
            }
        };
    });
```

### Access Token Claims

```json
{
  "sub": "user-guid",
  "username": "nvbh001",
  "name": "Nguyen Van A",
  "role": "NVBH",
  "distributorId": "distributor-guid",
  "permissions": ["visit:create", "order:create", "customer:read"],
  "deviceId": "device-fingerprint",
  "iat": 1738454400,
  "exp": 1738540800,
  "iss": "VIPPro-dms",
  "aud": "VIPPro-dms-clients"
}
```

### Refresh Token Storage

```sql
CREATE TABLE RefreshTokens (
    TokenId         UNIQUEIDENTIFIER    PRIMARY KEY,
    UserId          UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    TokenHash       NVARCHAR(256)       NOT NULL,
    DeviceId        NVARCHAR(256)       NOT NULL,
    DeviceName      NVARCHAR(100)       NULL,
    IsRevoked       BIT                 NOT NULL DEFAULT 0,
    CreatedAt       DATETIME2           NOT NULL,
    ExpiresAt       DATETIME2           NOT NULL,
    RevokedAt       DATETIME2           NULL
);
```

## Security Measures

| Threat | Mitigation |
|--------|------------|
| Token theft | Short expiry (24h), device binding |
| Refresh token theft | DB revocation, rotation on use |
| Brute force | Rate limiting, account lockout |
| Token in URL | Use Authorization header only |
| XSS (web) | Store in memory, not localStorage |
| MITM | HTTPS only, certificate pinning (mobile) |

## Consequences

### Positive

- Works seamlessly on mobile and web
- Stateless validation for most requests
- Contains user claims for authorization
- Revocable via refresh token
- Industry standard, well-understood
- SignalR compatible

### Negative

- Access token cannot be revoked before expiry
- Token size larger than session ID
- Clock skew can cause issues
- Secret key must be protected

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Key compromise | Low | Critical | Key rotation procedure, secure storage |
| Token theft | Low | High | Short expiry, device binding, HTTPS |
| Algorithm confusion | Low | Critical | Specify algorithm explicitly |

## References

- [JWT Introduction](https://jwt.io/introduction)
- [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_Cheat_Sheet.html)
- [07-SECURITY-ARCHITECTURE.md](../07-SECURITY-ARCHITECTURE.md)
