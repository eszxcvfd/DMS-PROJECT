# DILIGO DMS - Deployment Architecture

## Distribution Management System - Free Tier Deployment Guide

**Version:** 1.0
**Last Updated:** 2026-02-03

---

## 1. Overview

This document describes deployment options optimized for **minimal cost** while maintaining production-grade reliability. The architecture leverages free tiers from major cloud providers.

### Cost Summary

| Component | Provider | Free Tier Limits | Monthly Cost |
|-----------|----------|------------------|--------------|
| **API Server** | Azure App Service F1 | 60 min CPU/day, 1GB RAM | **$0** |
| **Database** | Neon Free | 512MB storage, PostgreSQL | **$0** |
| **Web App** | Vercel Free | 100GB bandwidth, serverless | **$0** |
| **Blob Storage** | Azure Blob | 5GB storage, 20K operations | **$0** |
| **Push Notifications** | Firebase FCM | Unlimited | **$0** |
| **Monitoring** | Application Insights | 5GB/month ingestion | **$0** |
| **Android App** | Google Play | One-time $25 registration | **$25 (one-time)** |
| **Domain** | Cloudflare (optional) | Free DNS | **$0-12/year** |

**Total Monthly Cost: $0** (after one-time Play Store fee)

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                          FREE TIER DEPLOYMENT ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│                              INTERNET                                                       │
│                                 │                                                           │
│         ┌───────────────────────┼───────────────────────┐                                  │
│         │                       │                       │                                  │
│         ▼                       ▼                       ▼                                  │
│  ┌─────────────┐        ┌─────────────┐        ┌─────────────┐                            │
│  │   Android   │        │   Vercel    │        │  Firebase   │                            │
│  │    Device   │        │  (Web App)  │        │    FCM      │                            │
│  │             │        │             │        │             │                            │
│  │  - APK      │        │  - React    │        │  - Push     │                            │
│  │  - Play     │        │  - Free     │        │  - Free     │                            │
│  │    Store    │        │  - Edge     │        │             │                            │
│  └──────┬──────┘        └──────┬──────┘        └─────────────┘                            │
│         │                      │                      ▲                                    │
│         │    HTTPS             │   HTTPS              │                                    │
│         │                      │                      │                                    │
│         └──────────────┬───────┘                      │                                    │
│                        │                              │                                    │
│                        ▼                              │                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                         AZURE FREE TIER                                              │  │
│  │                                                                                      │  │
│  │  ┌─────────────────────┐        ┌─────────────────────┐                             │  │
│  │  │  Azure App Service  │        │  Application        │                             │  │
│  │  │       (F1 Free)     │◄──────►│  Insights (Free)    │                             │  │
│  │  │                     │        │                     │                             │  │
│  │  │  - .NET 8 API       │        │  - 5GB/month        │                             │  │
│  │  │  - 1GB RAM          │        │  - 90 day retention │                             │  │
│  │  │  - 60 CPU min/day   │        │                     │                             │  │
│  │  │  - Always On: OFF   │        │                     │                             │  │
│  │  │  - Auto-sleep       │        └─────────────────────┘                             │  │
│  │  └──────────┬──────────┘                                                             │  │
│  │             │                                                                        │  │
│  │             │                                                                        │  │
│  │      ┌──────┴──────┐                                                                 │  │
│  │      │             │                                                                 │  │
│  │      ▼             ▼                                                                 │  │
│  │  ┌─────────────┐  ┌─────────────┐                                                   │  │
│  │  │ Neon        │  │ Azure Blob  │                                                   │  │
│  │  │  (Free)     │  │  (Free)     │                                                   │  │
│  │  │             │  │             │                                                   │  │
│  │  │ - 512MB     │  │ - 5GB       │                                                   │  │
│  │  │ - PostgreSQL│  │ - 20K ops   │                                                   │  │
│  │  │ - Auth/API  │  │ - Images    │                                                   │  │
│  │  └─────────────┘  └─────────────┘                                                   │  │
│  │                                                                                      │  │
│  └──────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                             │
│  ALTERNATIVE OPTIONS (if Azure limits exceeded)                                            │
│  ──────────────────────────────────────────────                                            │
│                                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                       │
│  │  Railway    │  │ Render.com  │  │ Supabase    │  │ Cloudflare  │                       │
│  │  (API Alt)  │  │ (API Alt)   │  │ (DB Alt)    │  │   R2        │                       │
│  │             │  │             │  │             │  │             │                       │
│  │ - $5 free   │  │ - 750 hrs   │  │ - 500MB     │  │ - 10GB free │                       │
│  │   credits   │  │   free/mo   │  │   free      │  │ - No egress │                       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘                       │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Primary Deployment (Azure Free Tier)

### 3.1 Azure App Service (API)

**Service Tier:** F1 Free

| Specification | Value |
|--------------|-------|
| **CPU** | 60 minutes/day (shared) |
| **Memory** | 1 GB RAM |
| **Storage** | 1 GB |
| **Bandwidth** | 165 MB/day |
| **Custom Domain** | Not supported (use *.azurewebsites.net) |
| **SSL** | Free managed certificate |
| **Always On** | Disabled (cold start after 20 min idle) |

**Deployment Configuration:**

```yaml
# azure-pipelines.yml or GitHub Actions
name: Deploy API

on:
  push:
    branches: [main]
    paths: ['src/api/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Publish
        run: |
          dotnet publish src/api/DiligoDMS.Api.csproj \
            -c Release \
            -o ./publish \
            --self-contained false

      - name: Deploy to Azure
        uses: azure/webapps-deploy@v3
        with:
          app-name: 'diligo-dms-api'
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
          package: ./publish
```

**App Settings:**

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "@Microsoft.KeyVault(SecretUri=...)"
  },
  "Jwt": {
    "Key": "@Microsoft.KeyVault(SecretUri=...)",
    "Issuer": "diligo-dms",
    "Audience": "diligo-dms-clients",
    "ExpirationMinutes": 1440
  },
  "Azure": {
    "BlobStorage": {
      "ConnectionString": "@Microsoft.KeyVault(SecretUri=...)",
      "ContainerName": "images"
    }
  },
  "Firebase": {
    "ProjectId": "diligo-dms",
    "CredentialsPath": "/home/site/wwwroot/firebase-credentials.json"
  }
}
```

**Cold Start Mitigation:**

```csharp
// Program.cs - Optimize for cold starts
var builder = WebApplication.CreateBuilder(args);

// Use minimal APIs where possible for faster startup
builder.Services.AddEndpointsApiExplorer();

// Lazy load heavy services
builder.Services.AddSingleton<IFirebaseService>(sp =>
    new Lazy<FirebaseService>(() => new FirebaseService(sp)).Value);

// Reduce startup logging
builder.Logging.SetMinimumLevel(LogLevel.Warning);
```

### 3.2 Neon PostgreSQL Database (Free Tier)

**Service Tier:** Free

| Specification | Value |
|--------------|-------|
| **Storage** | 512 MB |
| **Database** | PostgreSQL 15 |
| **Data Transfer** | 3 GB/month |
| **Compute** | 191 hours/month |
| **Autoscaling** | Scale to zero |
| **Branching** | Supported |

**Connection String:**

```
Host=ep-xxxx.neon.tech;Database=neondb;Username=...;Password=...;SSL Mode=Require;Trust Server Certificate=true
```

**Optimization for Free Tier:**

```sql
-- Create efficient indexes for common queries
CREATE INDEX IX_Visits_UserDate ON Visits(UserId, VisitDate DESC)
INCLUDE (CheckInTime, CheckOutTime, VisitResult);

-- Use JSONB for flexible data storage
CREATE INDEX IX_Promotions_Conditions ON Promotions USING GIN (ApplicableProducts);

-- Auto-cleanup old data (run weekly via pg_cron or external scheduler)
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
    -- Delete location history older than 90 days
    DELETE FROM LocationHistory
    WHERE RecordedAt < NOW() - INTERVAL '90 days';

    -- Delete audit logs older than 1 year
    DELETE FROM AuditLogs
    WHERE CreatedAt < NOW() - INTERVAL '1 year';
END;
$$ LANGUAGE plpgsql;
```

### 3.3 Azure Blob Storage

**Tier:** General Purpose v2 (Free includes 5GB)

**Container Structure:**

```
diligo-dms-storage/
├── products/           # Product images
│   └── {productId}.jpg
├── visits/             # Visit photos
│   └── {year}/{month}/{day}/{visitId}/
│       └── {photoId}.jpg
├── customers/          # Customer shop photos
│   └── {customerId}.jpg
└── documents/          # Reports, exports
    └── {year}/{month}/
```

**Access Pattern (SAS Tokens):**

```csharp
public class BlobStorageService : IBlobStorageService
{
    public async Task<string> GetSecureUrl(string blobPath, TimeSpan validFor)
    {
        var blobClient = _containerClient.GetBlobClient(blobPath);

        var sasBuilder = new BlobSasBuilder
        {
            BlobContainerName = _containerName,
            BlobName = blobPath,
            Resource = "b",
            ExpiresOn = DateTimeOffset.UtcNow.Add(validFor)
        };
        sasBuilder.SetPermissions(BlobSasPermissions.Read);

        return blobClient.GenerateSasUri(sasBuilder).ToString();
    }
}
```

### 3.4 Vercel (Web Frontend)

**Tier:** Hobby (Free)

| Specification | Value |
|--------------|-------|
| **Bandwidth** | 100 GB/month |
| **Builds** | 6000 minutes/month |
| **Serverless** | 100 GB-hours/month |
| **Edge** | Global CDN |
| **Custom Domain** | Supported |
| **SSL** | Free auto-renewal |

**Deployment:**

```json
// vercel.json
{
  "framework": "vite",
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Access-Control-Allow-Origin", "value": "*" }
      ]
    }
  ],
  "env": {
    "VITE_API_URL": "@api-url"
  }
}
```

**Environment Variables:**

```bash
VITE_API_URL=https://diligo-dms-api.azurewebsites.net
VITE_SIGNALR_URL=https://diligo-dms-api.azurewebsites.net/hubs/monitoring
VITE_GOOGLE_MAPS_KEY=AIza...
```

---

## 4. Alternative Free Tier Options

### 4.1 Railway (API Alternative)

**When to use:** If Azure F1 limits are exceeded

| Specification | Value |
|--------------|-------|
| **Free Credits** | $5/month |
| **Memory** | 512 MB - 8 GB |
| **CPU** | Shared |
| **Sleep** | After 30 min inactive |

**Deployment:**

```toml
# railway.toml
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
startCommand = "dotnet DiligoDMS.Api.dll"
healthcheckPath = "/health"
healthcheckTimeout = 30
restartPolicyType = "ON_FAILURE"
```

### 4.2 Neon (Database Alternative)

**When to use:** Alternative PostgreSQL hosting with serverless features

| Specification | Value |
|--------------|-------|
| **Storage** | 512 MB |
| **Compute** | 191 hours/month |
| **Branching** | Database branching for dev/test |
| **Autoscaling** | Scale to zero when idle |

### 4.3 Railway (Database Alternative)

**When to use:** Need more storage or compute

| Specification | Value |
|--------------|-------|
| **Credits** | $5/month free |
| **PostgreSQL** | Included |
| **Storage** | Pay as you go |
| **Networking** | Private networking |

### 4.4 Cloudflare R2 (Storage Alternative)

**When to use:** Need more storage or lower egress costs

| Specification | Value |
|--------------|-------|
| **Storage** | 10 GB |
| **Operations** | 1M Class A, 10M Class B |
| **Egress** | Free (no egress charges) |

---

## 5. Deployment Pipeline

### 5.1 CI/CD Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              CI/CD PIPELINE                                              │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐           │
│  │   GitHub    │     │   GitHub    │     │   Deploy    │     │  Production │           │
│  │   Commit    │────►│   Actions   │────►│   Stage     │────►│             │           │
│  └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘           │
│                             │                                                           │
│                    ┌────────┴────────┐                                                  │
│                    │                 │                                                  │
│                    ▼                 ▼                                                  │
│             ┌─────────────┐   ┌─────────────┐                                          │
│             │  Build API  │   │  Build Web  │                                          │
│             │  (.NET 8)   │   │  (Vite)     │                                          │
│             └──────┬──────┘   └──────┬──────┘                                          │
│                    │                 │                                                  │
│                    ▼                 ▼                                                  │
│             ┌─────────────┐   ┌─────────────┐                                          │
│             │   Run       │   │   Run       │                                          │
│             │   Tests     │   │   Tests     │                                          │
│             └──────┬──────┘   └──────┬──────┘                                          │
│                    │                 │                                                  │
│                    ▼                 ▼                                                  │
│             ┌─────────────┐   ┌─────────────┐                                          │
│             │  Deploy to  │   │  Deploy to  │                                          │
│             │ Azure App   │   │   Vercel    │                                          │
│             │  Service    │   │             │                                          │
│             └─────────────┘   └─────────────┘                                          │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy DILIGO DMS

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  # Build and test API
  api:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: src/api
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Restore
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore -c Release

      - name: Test
        run: dotnet test --no-build -c Release --verbosity normal

      - name: Publish
        if: github.ref == 'refs/heads/main'
        run: dotnet publish -c Release -o ./publish

      - name: Deploy to Azure
        if: github.ref == 'refs/heads/main'
        uses: azure/webapps-deploy@v3
        with:
          app-name: 'diligo-dms-api'
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
          package: src/api/publish

  # Build and deploy web app
  web:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: src/web
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: src/web/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          VITE_API_URL: ${{ secrets.API_URL }}

      - name: Deploy to Vercel
        if: github.ref == 'refs/heads/main'
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: src/web
```

### 5.3 Android App Deployment

```yaml
# .github/workflows/android.yml
name: Build Android APK

on:
  push:
    branches: [main]
    paths: ['src/android/**']
  release:
    types: [published]

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: src/android
    steps:
      - uses: actions/checkout@v4

      - name: Setup JDK
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v3

      - name: Build Debug APK
        run: ./gradlew assembleDebug

      - name: Build Release APK
        if: github.event_name == 'release'
        run: ./gradlew assembleRelease
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: apk
          path: src/android/app/build/outputs/apk/

      - name: Upload to Play Store
        if: github.event_name == 'release'
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.diligo.dms
          releaseFiles: src/android/app/build/outputs/apk/release/*.apk
          track: internal
```

---

## 6. Monitoring & Health Checks

### 6.1 Application Insights (Free Tier)

**Limits:** 5 GB/month ingestion, 90 days retention

```csharp
// Program.cs
builder.Services.AddApplicationInsightsTelemetry(options =>
{
    options.EnableAdaptiveSampling = true; // Reduce data volume
    options.EnableDependencyTrackingTelemetryModule = false; // Reduce noise
});

// Configure sampling to stay under free tier
builder.Services.Configure<TelemetryConfiguration>(config =>
{
    var builder = config.DefaultTelemetrySink.TelemetryProcessorChainBuilder;
    builder.UseAdaptiveSampling(maxTelemetryItemsPerSecond: 5);
    builder.Build();
});
```

### 6.2 Health Checks

```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "database")
    .AddAzureBlobStorage(blobConnectionString, name: "storage")
    .AddCheck("api", () => HealthCheckResult.Healthy("API is running"));

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});
```

### 6.3 Uptime Monitoring (Free Options)

| Service | Free Tier |
|---------|-----------|
| **UptimeRobot** | 50 monitors, 5-min interval |
| **Freshping** | 50 monitors, 1-min interval |
| **Uptime Kuma** | Self-hosted, unlimited |

---

## 7. Scaling Strategy

### 7.1 When to Upgrade

| Signal | Threshold | Action |
|--------|-----------|--------|
| CPU minutes exhausted | >90% of 60 min/day | Upgrade to B1 Basic |
| Database API requests | >1.5M/month | Optimize queries or upgrade |
| Database storage limit | >400MB | Archive old data or upgrade |
| Response times degraded | >5 sec avg | Add caching, optimize queries |
| Concurrent users | >50 active | Upgrade to B1 or use SignalR Azure |

### 7.2 Upgrade Path

```
FREE TIER              BASIC TIER             STANDARD TIER
─────────              ──────────             ─────────────
Azure F1 ($0)    ───►  Azure B1 ($13/mo) ───► Azure S1 ($73/mo)
Neon Free     ───►  Neon Pro ($19/mo)  ───► Self-hosted
Vercel Hobby     ───►  Vercel Pro ($20) ───► Vercel Team
```

---

## 8. Disaster Recovery

### 8.1 Backup Strategy

| Component | Backup Method | Frequency | Retention |
|-----------|---------------|-----------|-----------|
| **PostgreSQL** | Neon automated | Daily | 30 days |
| **Blob Storage** | Soft delete | On delete | 7 days |
| **App Code** | Git repository | On commit | Indefinite |
| **Secrets** | Key Vault (manual) | On change | Indefinite |

### 8.2 Recovery Procedures

```bash
# Restore database from Supabase backup (via dashboard or CLI)
# Supabase provides point-in-time recovery via dashboard

# For self-hosted PostgreSQL:
pg_restore -h localhost -U postgres -d diligo_dms backup.dump

# Restore blob from soft delete
az storage blob undelete \
  --container-name images \
  --name "visits/2026/02/01/photo.jpg" \
  --account-name diligostorage
```

---

## 9. Security Considerations

### 9.1 Network Security

```
┌─────────────────────────────────────────────────────────────────┐
│                    NETWORK SECURITY                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INTERNET                                                       │
│     │                                                           │
│     │  HTTPS (TLS 1.3)                                         │
│     ▼                                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  AZURE FIREWALL                          │   │
│  │   - IP whitelist (optional)                              │   │
│  │   - Rate limiting (API Management)                       │   │
│  │   - DDoS protection (basic)                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│     │                                                           │
│     ▼                                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  APP SERVICE                             │   │
│  │   - Managed identity                                     │   │
│  │   - TLS enforcement                                      │   │
│  │   - Authentication middleware                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│     │                                                           │
│     │  Private endpoint (upgrade)                              │
│     ▼                                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  POSTGRESQL DATABASE                        │   │
│  │   - Connection via SSL                                      │   │
│  │   - Row Level Security (RLS)                                │   │
│  │   - Encryption at rest                                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2 Secrets Management

Free tier approach (Azure App Service Configuration):

```csharp
// Use environment variables with @Microsoft.KeyVault reference
// Or use User Secrets for local development
builder.Configuration.AddUserSecrets<Program>();
builder.Configuration.AddEnvironmentVariables();
```

---

## 10. Related Documents

- [07-SECURITY-ARCHITECTURE.md](07-SECURITY-ARCHITECTURE.md) - Security details
- [adr/ADR-003-postgresql.md](adr/ADR-003-postgresql.md) - Database decision
- [adr/ADR-004-neon-free-tier.md](adr/ADR-004-neon-free-tier.md) - Database and Deployment hosting decision
