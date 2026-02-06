# DMS VIPPro - Security Architecture

## Distribution Management System - Security Design

**Version:** 2.0
**Last Updated:** 2026-02-04
**PRD Reference:** PRD-v2.md (v2.3)

---

## 1. Overview

This document describes the security architecture for DMS VIPPro, covering authentication, authorization, data protection, and security best practices.

### Security Objectives

| Objective | Description |
|-----------|-------------|
| **Confidentiality** | Protect sensitive business data and PII |
| **Integrity** | Ensure data cannot be tampered with |
| **Availability** | 99.5% uptime target |
| **Accountability** | Audit trail for all user actions |
| **Compliance** | PDPA (Vietnam), basic security standards |

---

## 2. Security Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SECURITY ARCHITECTURE                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                              PERIMETER SECURITY                                       │  │
│  │                                                                                       │  │
│  │   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐             │  │
│  │   │    TLS 1.3  │   │    CORS     │   │    Rate     │   │    WAF      │             │  │
│  │   │   (HTTPS)   │   │   Policy    │   │  Limiting   │   │ (Optional)  │             │  │
│  │   └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘             │  │
│  └──────────────────────────────────────────────────────────────────────────────────────┘  │
│                                           │                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                            APPLICATION SECURITY                                       │  │
│  │                                        │                                              │  │
│  │   ┌─────────────────────────────────────────────────────────────────────────────┐    │  │
│  │   │                    AUTHENTICATION LAYER                                      │    │  │
│  │   │                                                                              │    │  │
│  │   │   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │    │  │
│  │   │   │   JWT       │   │   Refresh   │   │   Device    │                       │    │  │
│  │   │   │   Tokens    │   │   Tokens    │   │   Binding   │                       │    │  │
│  │   │   └─────────────┘   └─────────────┘   └─────────────┘                       │    │  │
│  │   └──────────────────────────────────────────────────────────────────────────────┘    │  │
│  │                                        │                                              │  │
│  │   ┌─────────────────────────────────────────────────────────────────────────────┐    │  │
│  │   │                    AUTHORIZATION LAYER                                       │    │  │
│  │   │                                                                              │    │  │
│  │   │   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │    │  │
│  │   │   │    RBAC     │   │   Resource  │   │   Data      │                       │    │  │
│  │   │   │   (Roles)   │   │   Policies  │   │   Filtering │                       │    │  │
│  │   │   └─────────────┘   └─────────────┘   └─────────────┘                       │    │  │
│  │   └──────────────────────────────────────────────────────────────────────────────┘    │  │
│  │                                        │                                              │  │
│  │   ┌─────────────────────────────────────────────────────────────────────────────┐    │  │
│  │   │                    INPUT VALIDATION                                          │    │  │
│  │   │                                                                              │    │  │
│  │   │   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │    │  │
│  │   │   │   Request   │   │    SQL      │   │    XSS      │                       │    │  │
│  │   │   │ Validation  │   │  Injection  │   │ Prevention  │                       │    │  │
│  │   │   │             │   │  Prevention │   │             │                       │    │  │
│  │   │   └─────────────┘   └─────────────┘   └─────────────┘                       │    │  │
│  │   └──────────────────────────────────────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────────────────────────────────────┘  │
│                                           │                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                              DATA SECURITY                                            │  │
│  │                                                                                       │  │
│  │   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐             │  │
│  │   │  Encryption │   │  Encryption │   │  Key        │   │   Audit     │             │  │
│  │   │  at Rest    │   │  in Transit │   │  Management │   │   Logging   │             │  │
│  │   │   (TDE)     │   │   (TLS)     │   │             │   │             │             │  │
│  │   └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘             │  │
│  └──────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Authentication

### 3.1 JWT Token Authentication

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              JWT AUTHENTICATION FLOW                                     │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  LOGIN FLOW                                                                             │
│  ──────────                                                                             │
│                                                                                         │
│  Mobile/Web          API Server            Database                                     │
│      │                   │                    │                                         │
│      │  POST /api/auth/login                  │                                         │
│      │  {username, password}                  │                                         │
│      │──────────────────►│                    │                                         │
│      │                   │                    │                                         │
│      │                   │  Validate user     │                                         │
│      │                   │───────────────────►│                                         │
│      │                   │◄───────────────────│                                         │
│      │                   │                    │                                         │
│      │                   │  Hash password     │                                         │
│      │                   │  Compare           │                                         │
│      │                   │                    │                                         │
│      │  {accessToken,    │                    │                                         │
│      │   refreshToken,   │                    │                                         │
│      │   expiresIn}      │                    │                                         │
│      │◄──────────────────│                    │                                         │
│      │                   │                    │                                         │
│                                                                                         │
│  AUTHENTICATED REQUEST                                                                  │
│  ─────────────────────                                                                  │
│                                                                                         │
│  Mobile/Web          API Server            Database                                     │
│      │                   │                    │                                         │
│      │  GET /api/orders                       │                                         │
│      │  Authorization: Bearer <token>         │                                         │
│      │──────────────────►│                    │                                         │
│      │                   │                    │                                         │
│      │                   │  Validate JWT      │                                         │
│      │                   │  - Check signature │                                         │
│      │                   │  - Check expiry    │                                         │
│      │                   │  - Extract claims  │                                         │
│      │                   │                    │                                         │
│      │                   │  Query with user   │                                         │
│      │                   │  context           │                                         │
│      │                   │───────────────────►│                                         │
│      │                   │◄───────────────────│                                         │
│      │                   │                    │                                         │
│      │  {orders: [...]} │                    │                                         │
│      │◄──────────────────│                    │                                         │
│      │                   │                    │                                         │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 JWT Token Structure

```json
// Access Token Payload
{
  "sub": "user-id-guid",
  "username": "nvbh001",
  "name": "Nguyen Van A",
  "role": "NVBH",
  "distributorId": "distributor-guid",
  "permissions": ["visit:create", "order:create", "customer:read"],
  "iat": 1738454400,
  "exp": 1738540800,
  "iss": "VIPPro-dms",
  "aud": "VIPPro-dms-clients"
}

// Refresh Token (stored in database)
{
  "tokenId": "refresh-token-guid",
  "userId": "user-guid",
  "deviceId": "device-fingerprint",
  "expiresAt": "2026-03-02T00:00:00Z",
  "isRevoked": false
}
```

### 3.3 Token Configuration

```csharp
// AuthService.cs
public class AuthService : IAuthService
{
    private readonly JwtSettings _jwtSettings;

    public AuthTokens GenerateTokens(User user)
    {
        var accessToken = GenerateAccessToken(user);
        var refreshToken = GenerateRefreshToken(user);

        return new AuthTokens
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresIn = _jwtSettings.AccessTokenExpirationMinutes * 60,
            TokenType = "Bearer"
        };
    }

    private string GenerateAccessToken(User user)
    {
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.UserId.ToString()),
            new Claim("username", user.Username),
            new Claim("name", user.FullName),
            new Claim("role", user.Role.RoleName),
            new Claim("distributorId", user.DistributorId.ToString()),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.Key));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _jwtSettings.Issuer,
            audience: _jwtSettings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_jwtSettings.AccessTokenExpirationMinutes),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

### 3.4 Password Security

```csharp
// Password hashing with Argon2
public class PasswordHasher : IPasswordHasher
{
    public string HashPassword(string password)
    {
        return Argon2.Hash(password, new Argon2Config
        {
            Type = Argon2Type.Argon2id,
            TimeCost = 3,
            MemoryCost = 65536,
            Parallelism = 4,
            HashLength = 32
        });
    }

    public bool VerifyPassword(string password, string hash)
    {
        return Argon2.Verify(hash, password);
    }
}
```

---

## 4. Authorization (RBAC)

### 4.1 Role Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              ROLE HIERARCHY                                              │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│                              ┌─────────────┐                                            │
│                              │    RSM      │                                            │
│                              │  (Regional) │                                            │
│                              └──────┬──────┘                                            │
│                                     │                                                   │
│                           ┌─────────┴─────────┐                                         │
│                           │                   │                                         │
│                     ┌─────┴─────┐       ┌─────┴─────┐                                   │
│                     │    ASM    │       │    ASM    │                                   │
│                     │  (Area)   │       │  (Area)   │                                   │
│                     └─────┬─────┘       └─────┬─────┘                                   │
│                           │                   │                                         │
│                  ┌────────┴────────┐    ┌────┴────┐                                    │
│                  │                 │    │         │                                    │
│            ┌─────┴─────┐     ┌─────┴────┴┐  ┌─────┴─────┐                              │
│            │   GSBH    │     │   GSBH    │  │   GSBH    │                              │
│            │(Supervisor)│     │(Supervisor)│  │(Supervisor)│                              │
│            └─────┬─────┘     └─────┬─────┘  └─────┬─────┘                              │
│                  │                 │              │                                     │
│         ┌────────┼────────┐        │              │                                     │
│         │        │        │        │              │                                     │
│    ┌────┴───┐┌───┴────┐┌──┴────┐ ┌─┴─────┐  ┌────┴───┐                                 │
│    │  NVBH  ││  NVBH  ││ NVBH  │ │ NVBH  │  │  NVBH  │                                 │
│    │(Sales) ││(Sales) ││(Sales)│ │(Sales)│  │(Sales) │                                 │
│    └────────┘└────────┘└───────┘ └───────┘  └────────┘                                 │
│                                                                                         │
│                                                                                         │
│            ┌───────────────┐                                                            │
│            │   Admin NPP   │  ← Separate role (Distributor Admin)                      │
│            │  (Parallel)   │                                                            │
│            └───────────────┘                                                            │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Permission Matrix

| Permission | NVBH | GSBH | ASM | RSM | Admin NPP |
|------------|------|------|-----|-----|-----------|
| **Visits** |
| visit:create | ✓ | ✓ | - | - | - |
| visit:read | Own | Team | Area | Region | All |
| visit:approve | - | ✓ | ✓ | ✓ | - |
| **Orders** |
| order:create | ✓ | ✓ | - | - | ✓ |
| order:read | Own | Team | Area | Region | All |
| order:approve | - | ✓ | ✓ | ✓ | ✓ |
| order:reject | - | ✓ | ✓ | ✓ | ✓ |
| **Customers** |
| customer:read | Route | Team | Area | Region | All |
| customer:create | ✓ | ✓ | ✓ | ✓ | ✓ |
| customer:update | ✓ | ✓ | ✓ | ✓ | ✓ |
| customer:delete | - | - | - | - | ✓ |
| **Products** |
| product:read | ✓ | ✓ | ✓ | ✓ | ✓ |
| product:manage | - | - | - | - | ✓ |
| **Inventory** |
| inventory:read | - | ✓ | ✓ | ✓ | ✓ |
| inventory:manage | - | - | - | - | ✓ |
| **Reports** |
| report:own | ✓ | ✓ | ✓ | ✓ | ✓ |
| report:team | - | ✓ | ✓ | ✓ | ✓ |
| report:area | - | - | ✓ | ✓ | ✓ |
| report:region | - | - | - | ✓ | ✓ |
| **Monitoring** |
| monitor:team | - | ✓ | ✓ | ✓ | - |
| monitor:area | - | - | ✓ | ✓ | - |
| monitor:region | - | - | - | ✓ | - |
| **Admin** |
| user:manage | - | - | - | - | ✓ |
| settings:manage | - | - | - | - | ✓ |

### 4.3 Authorization Implementation

```csharp
// Policy-based authorization
public static class AuthorizationPolicies
{
    public static void Configure(AuthorizationOptions options)
    {
        // Role-based policies
        options.AddPolicy("RequireNVBH", policy =>
            policy.RequireRole("NVBH", "GSBH", "ASM", "RSM", "AdminNPP"));

        options.AddPolicy("RequireGSBH", policy =>
            policy.RequireRole("GSBH", "ASM", "RSM"));

        options.AddPolicy("RequireASM", policy =>
            policy.RequireRole("ASM", "RSM"));

        options.AddPolicy("RequireAdmin", policy =>
            policy.RequireRole("AdminNPP"));

        // Permission-based policies
        options.AddPolicy("CanApproveOrders", policy =>
            policy.RequireAssertion(context =>
                context.User.HasClaim("permission", "order:approve")));

        options.AddPolicy("CanManageInventory", policy =>
            policy.RequireAssertion(context =>
                context.User.HasClaim("permission", "inventory:manage")));
    }
}

// Controller usage
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class OrdersController : ControllerBase
{
    [HttpPost("{id}/approve")]
    [Authorize(Policy = "CanApproveOrders")]
    public async Task<IActionResult> Approve(Guid id)
    {
        // Only users with order:approve permission can access
    }
}
```

### 4.4 Data-Level Authorization

```csharp
// Filter data based on user's scope
public class OrderQueryService : IOrderQueryService
{
    public async Task<IEnumerable<Order>> GetOrdersForUser(ClaimsPrincipal user)
    {
        var userId = user.GetUserId();
        var role = user.GetRole();
        var distributorId = user.GetDistributorId();

        IQueryable<Order> query = _context.Orders
            .Where(o => o.DistributorId == distributorId);

        switch (role)
        {
            case "NVBH":
                // Only own orders
                query = query.Where(o => o.UserId == userId);
                break;

            case "GSBH":
                // Team orders (subordinates)
                var teamUserIds = await GetSubordinateIds(userId);
                query = query.Where(o => teamUserIds.Contains(o.UserId));
                break;

            case "ASM":
                // Area orders
                var areaUserIds = await GetAreaUserIds(userId);
                query = query.Where(o => areaUserIds.Contains(o.UserId));
                break;

            case "RSM":
            case "AdminNPP":
                // All orders in distributor (no additional filter)
                break;
        }

        return await query.ToListAsync();
    }
}
```

---

## 5. Data Protection

### 5.1 Encryption

| Layer | Method | Details |
|-------|--------|---------|
| **In Transit** | TLS 1.3 | All HTTPS connections |
| **At Rest (DB)** | PostgreSQL encryption | Neon/Supabase/Provider encryption at rest |
| **At Rest (Blob)** | SSE | Azure Storage service encryption |
| **Passwords** | Argon2id | One-way hashing |
| **Sensitive Fields** | AES-256 | Phone numbers, addresses (optional) |

### 5.2 Sensitive Data Handling

```csharp
// Attribute for sensitive properties
[SensitiveData]
public string Phone { get; set; }

// Audit logging excludes sensitive data
public class AuditMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var body = await ReadBody(context.Request);

        // Redact sensitive fields before logging
        var sanitizedBody = SanitizeForLogging(body);

        _logger.LogInformation("Request: {Path} {Body}",
            context.Request.Path,
            sanitizedBody);

        await _next(context);
    }

    private string SanitizeForLogging(string json)
    {
        // Replace sensitive fields with [REDACTED]
        return Regex.Replace(json,
            @"""(password|phone|ssn|creditCard)""\s*:\s*""[^""]*""",
            @"""$1"":""[REDACTED]""",
            RegexOptions.IgnoreCase);
    }
}
```

### 5.3 PII Protection

| Data Type | Protection | Retention |
|-----------|------------|-----------|
| **Password** | Argon2id hash (never stored in plain) | N/A |
| **Phone** | Encrypted at rest | Until account deletion |
| **Address** | Encrypted at rest | Until account deletion |
| **GPS Coordinates** | Plain (operational need) | 90 days |
| **Visit Photos** | Plain (business need) | 1 year |
| **Audit Logs** | Plain (with user ID) | 1 year |

---

## 6. API Security

### 6.1 Rate Limiting

```csharp
// Program.cs
builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
    {
        return RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.User.Identity?.Name ?? context.Connection.RemoteIpAddress?.ToString() ?? "anonymous",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 10
            });
    });

    // Stricter limits for authentication endpoints
    options.AddPolicy("AuthLimit", context =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 5,
                Window = TimeSpan.FromMinutes(1)
            }));
});
```

### 6.2 CORS Policy

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("Production", policy =>
    {
        policy.WithOrigins(
            "https://VIPPro-dms.vercel.app",
            "https://VIPPro-dms.azurewebsites.net"
        )
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials();
    });

    options.AddPolicy("Development", policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});
```

### 6.3 Input Validation

```csharp
// FluentValidation for all requests
public class CreateOrderValidator : AbstractValidator<CreateOrderRequest>
{
    public CreateOrderValidator()
    {
        RuleFor(x => x.CustomerId)
            .NotEmpty()
            .WithMessage("Customer ID is required");

        RuleFor(x => x.Items)
            .NotEmpty()
            .WithMessage("Order must have at least one item");

        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.ProductId).NotEmpty();
            item.RuleFor(i => i.Quantity).GreaterThan(0).LessThanOrEqualTo(10000);
            item.RuleFor(i => i.UnitPrice).GreaterThan(0);
        });

        RuleFor(x => x.Notes)
            .MaximumLength(1000)
            .Must(NotContainScriptTags)
            .WithMessage("Invalid characters in notes");
    }

    private bool NotContainScriptTags(string input)
    {
        if (string.IsNullOrEmpty(input)) return true;
        return !Regex.IsMatch(input, @"<script|javascript:|on\w+=", RegexOptions.IgnoreCase);
    }
}
```

### 6.4 SQL Injection Prevention

```csharp
// Always use parameterized queries via EF Core
public async Task<Customer> GetCustomer(Guid id)
{
    // SAFE: EF Core parameterizes this
    return await _context.Customers
        .Where(c => c.CustomerId == id)
        .FirstOrDefaultAsync();
}

// NEVER do this:
// var sql = $"SELECT * FROM Customers WHERE Id = '{id}'"; // VULNERABLE!

// If raw SQL is needed, use parameters:
public async Task<List<Order>> SearchOrders(string searchTerm)
{
    return await _context.Orders
        .FromSqlRaw(
            "SELECT * FROM Orders WHERE OrderNumber LIKE @p0",
            $"%{searchTerm}%")
        .ToListAsync();
}
```

---

## 7. Mobile Security

### 7.1 Android App Security

```kotlin
// Certificate Pinning with OkHttp
val certificatePinner = CertificatePinner.Builder()
    .add("VIPPro-dms-api.azurewebsites.net", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .build()

val okHttpClient = OkHttpClient.Builder()
    .certificatePinner(certificatePinner)
    .build()

// Secure token storage with EncryptedSharedPreferences
private val sharedPrefs = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build(),
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

fun saveToken(token: String) {
    sharedPrefs.edit().putString("access_token", token).apply()
}

// ProGuard/R8 obfuscation
// proguard-rules.pro
-keep class com.VIPPro.dms.data.models.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
```

### 7.2 Offline Data Security

```kotlin
// Room database encryption with SQLCipher
val passphrase = SQLiteDatabase.getBytes("encryption_key".toCharArray())
val factory = SupportFactory(passphrase)

val database = Room.databaseBuilder(
    context,
    AppDatabase::class.java,
    "VIPPro_dms.db"
)
.openHelperFactory(factory)
.build()
```

---

## 8. Audit Logging

### 8.1 Audit Events

| Event Type | Data Captured |
|------------|---------------|
| **Login Success** | UserId, IP, UserAgent, Timestamp |
| **Login Failure** | Username (not password), IP, Reason |
| **Logout** | UserId, Timestamp |
| **Data Create** | UserId, EntityType, EntityId, NewValues |
| **Data Update** | UserId, EntityType, EntityId, OldValues, NewValues |
| **Data Delete** | UserId, EntityType, EntityId, OldValues |
| **Permission Denied** | UserId, Resource, Action |
| **Export Data** | UserId, ReportType, Filters |

### 8.2 Audit Service

```csharp
public class AuditService : IAuditService
{
    public async Task LogAsync(AuditEvent auditEvent)
    {
        var log = new AuditLog
        {
            UserId = auditEvent.UserId,
            Action = auditEvent.Action,
            EntityType = auditEvent.EntityType,
            EntityId = auditEvent.EntityId,
            OldValues = auditEvent.OldValues != null
                ? JsonSerializer.Serialize(auditEvent.OldValues)
                : null,
            NewValues = auditEvent.NewValues != null
                ? JsonSerializer.Serialize(auditEvent.NewValues)
                : null,
            IpAddress = auditEvent.IpAddress,
            UserAgent = auditEvent.UserAgent,
            CreatedAt = DateTime.UtcNow
        };

        _context.AuditLogs.Add(log);
        await _context.SaveChangesAsync();
    }
}

// Automatic audit logging via EF Core interceptor
public class AuditInterceptor : SaveChangesInterceptor
{
    public override async ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        var context = eventData.Context;
        if (context == null) return result;

        foreach (var entry in context.ChangeTracker.Entries()
            .Where(e => e.State == EntityState.Added ||
                       e.State == EntityState.Modified ||
                       e.State == EntityState.Deleted))
        {
            // Create audit log entry
            await _auditService.LogAsync(new AuditEvent
            {
                Action = entry.State.ToString(),
                EntityType = entry.Entity.GetType().Name,
                EntityId = GetEntityId(entry),
                OldValues = entry.State == EntityState.Modified
                    ? GetOriginalValues(entry) : null,
                NewValues = entry.State != EntityState.Deleted
                    ? GetCurrentValues(entry) : null
            });
        }

        return result;
    }
}
```

---

## 9. Security Monitoring

### 9.1 Alert Rules

| Alert | Trigger | Action |
|-------|---------|--------|
| **Brute Force** | 5 failed logins in 1 min | Block IP for 15 min |
| **Unusual Location** | Login from new country | Notify user, require verification |
| **Mass Export** | >1000 records exported | Alert admin |
| **Off-Hours Access** | Access 11PM-6AM | Log for review |
| **Privilege Escalation** | Role change | Notify security team |

### 9.2 Application Insights Alerts

```csharp
// Custom security events in Application Insights
public class SecurityTelemetry
{
    private readonly TelemetryClient _telemetry;

    public void TrackSecurityEvent(string eventName, Dictionary<string, string> properties)
    {
        _telemetry.TrackEvent($"Security:{eventName}", properties);
    }

    public void TrackLoginFailure(string username, string ipAddress, string reason)
    {
        TrackSecurityEvent("LoginFailure", new Dictionary<string, string>
        {
            ["Username"] = username,
            ["IpAddress"] = ipAddress,
            ["Reason"] = reason
        });
    }
}
```

---

## 10. Security Checklist

### 10.1 Pre-Deployment Checklist

- [ ] TLS 1.3 configured and enforced
- [ ] JWT secrets stored securely (Azure Key Vault / environment)
- [ ] SQL connection uses encrypted connection
- [ ] CORS policy restricts to known origins
- [ ] Rate limiting enabled
- [ ] Input validation on all endpoints
- [ ] Audit logging enabled
- [ ] Error messages don't leak sensitive info
- [ ] Debug mode disabled in production
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)

### 10.2 Ongoing Security Tasks

- [ ] Review audit logs weekly
- [ ] Update dependencies monthly (Dependabot)
- [ ] Security assessment quarterly
- [ ] Penetration testing annually
- [ ] Rotate JWT secrets every 6 months

---

## 11. Related Documents

- [06-DEPLOYMENT-ARCHITECTURE.md](06-DEPLOYMENT-ARCHITECTURE.md) - Infrastructure security
- [adr/ADR-005-jwt-auth.md](adr/ADR-005-jwt-auth.md) - Authentication decision
- [adr/ADR-006-offline-first-mobile.md](adr/ADR-006-offline-first-mobile.md) - Offline-first mobile architecture
- [adr/ADR-009-organization-hierarchy.md](adr/ADR-009-organization-hierarchy.md) - Organization hierarchy for data access control
