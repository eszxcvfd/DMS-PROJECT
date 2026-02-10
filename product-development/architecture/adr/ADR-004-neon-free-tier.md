# ADR-004: Neon Free Tier for Hosting and Deployment

## Status

Accepted

## Date

2026-02-02

## Context

DMS VIPPro needs to be deployed to a production environment. The primary constraint is **minimal to zero ongoing cost** while maintaining acceptable performance and reliability for a DMS system.

## Decision Drivers

- **Budget constraint**: Free tier deployment is mandatory
- **PostgreSQL database**: Use Neon or Supabase free tier
- **Reliability**: 99.5% uptime target
- **Scalability**: Path to scale when needed
- **Integration**: Seamless with .NET ecosystem
- **Maintenance**: Low operational overhead

## Considered Options

### 1. Azure Free Tier (Primary)

- Azure App Service F1: 60 CPU minutes/day, 1GB RAM (for API)
- Cloudinary: Free Plan (25 credits/month - approx 25GB managed storage or 25GB net bandwidth)
- Azure SQL Free: 32GB, 100K vCore-sec (not using - see ADR-003)

**We will use Neon and Azure App Service as the primary deployment platform, with Cloudinary for media storage.**

### 2. Neon Serverless Postgres (Database)

- $5 free credits/month
- PostgreSQL 500MB
- Good PostgreSQL hosting option
- Easy deployment

### 3. Render.com
- 750 hours free/month
- PostgreSQL 1GB
- Good PostgreSQL hosting option
- Auto-sleep after 15 min

### 4. Oracle Cloud Free Tier
- 2 AMD VMs always free
- 20GB block storage
- Good for self-hosted PostgreSQL
- Complex setup

### 5. Self-Hosted (VPS)
- Full control
- Requires maintenance
- No free tier (min ~$5/month)
- Security responsibility

## Decision

**We will use Neon and Azure Free Tiers as the primary deployment platform.**

### Rationale

1. **PostgreSQL via Neon**: We use Neon Free tier for PostgreSQL database (512MB) as decided in ADR-003.

2. **Integrated Ecosystem**: Azure App Service + Neon PostgreSQL + Cloudinary work well together.


3. **.NET Optimization**: Azure App Service is optimized for .NET applications with minimal configuration.

4. **Application Insights**: Free monitoring and diagnostics included.

5. **Upgrade Path**: Easy scaling to paid tiers without architecture changes.

6. **Security**: Enterprise-grade security, encryption, and compliance built-in.

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              AZURE FREE TIER DEPLOYMENT                                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│                    ┌─────────────────────────────────────────────────┐                 │
│                    │           Azure Resource Group                  │                 │
│                    │           "VIPPro-dms-rg"                       │                 │
│                    │                                                 │                 │
│                    │   ┌─────────────────────────────────────────┐  │                 │
│                    │   │  Azure App Service (F1 Free)            │  │                 │
│                    │   │ Neon            │       │ Cloudinary      ││                 │

│                    │   │ (PostgreSQL)    │       │ (Free 5GB)      ││                 │
│                    │   │                 │       │                 ││                 │
│                    │   │ - 512MB storage │       │ - Product images││                 │
│                    │   │ - PostgreSQL 15 │       │ - Visit photos  ││                 │
│                    │   │ - Serverless    │       │                 ││                 │
│                    │   └─────────────────┘       └─────────────────┘│                 │
│                    │                                                 │                 │
│                    │   ┌─────────────────────────────────────────┐  │                 │
│                    │   │  Application Insights (Free 5GB/mo)     │  │                 │
│                    │   │  - Logging, Metrics, Traces              │  │                 │
│                    │   └─────────────────────────────────────────┘  │                 │
│                    │                                                 │                 │
│                    └─────────────────────────────────────────────────┘                 │
│                                                                                         │
│                    ┌─────────────────────────────────────────────────┐                 │
│                    │           Vercel (Free Tier)                    │                 │
│                    │                                                 │                 │
│                    │   - React Web App                               │                 │
│                    │   - 100GB bandwidth/month                       │                 │
│                    │   - Global Edge CDN                             │                 │
│                    │   - Free SSL                                    │                 │
│                    │                                                 │                 │
│                    └─────────────────────────────────────────────────┘                 │
│                                                                                         │
│                    ┌─────────────────────────────────────────────────┐                 │
│                    │           Firebase (Free Tier)                  │                 │
│                    │                                                 │                 │
│                    │   - FCM Push Notifications (Unlimited)          │                 │
│                    │                                                 │                 │
│                    └─────────────────────────────────────────────────┘                 │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

## Cost Summary

| Component | Provider | Free Tier Limit | Monthly Cost |
|-----------|----------|-----------------|--------------|
| API Server | Azure App Service F1 | 60 CPU min/day, 1GB | **$0** |
| Database | Neon Free | 512MB PostgreSQL | **$0** |
| Web App | Vercel Hobby | 100GB bandwidth | **$0** |
| Media Storage | Cloudinary | 25 Credits (approx 25GB) | **$0** |
| Push Notifications | Firebase FCM | Unlimited | **$0** |
| Monitoring | Application Insights | 5GB/month | **$0** |
| **Total** | | | **$0/month** |


## Limitations & Mitigations

| Limitation | Impact | Mitigation |
|------------|--------|------------|
| 60 CPU min/day | May run out during peak | Optimize queries, cache responses |
| Auto-sleep after 20 min | Cold start latency (15-30s) | Health ping to keep alive 8AM-8PM |
| 1GB RAM | Memory constraints | Stream large responses, paginate |
| No custom domain (F1) | Less professional URL | Use Cloudflare as reverse proxy |
| 512MB database limit (Neon) | May fill up | Archive old data, optimize storage |

## Consequences

### Positive

- Zero ongoing cost for MVP
- Production-grade security included
- Easy upgrade path when needed
- Integrated monitoring and logging
- Managed infrastructure (no server maintenance)
- Automatic SSL certificates
- Global CDN for web app (Vercel)

### Negative

- Cold start latency after idle
- CPU/memory constraints
- No custom domain on F1 tier
- Auto-pause on database
- Limited to Azure ecosystem

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Exceeding CPU quota | Medium | High | Implement caching, optimize queries |
| Database auto-pause latency | High | Medium | Connection retry logic, keep-alive ping |
| Storage limits reached | Low | Medium | Implement data archival strategy |
| Scaling pressure | Medium | Medium | Monitor usage, budget for B1 upgrade |

## Upgrade Path

When free tier limits are exceeded:

| Upgrade | Trigger | Cost Increase |
|---------|---------|---------------|
| App Service B1 | CPU/memory limits | +$13/month |
| Neon Scale | Storage >512MB or more compute | +$19/month |
| Supabase Pro | Alternative if need more features | +$25/month |
| Vercel Pro | Bandwidth >100GB | +$20/month |

## References

- [Azure Free Services](https://azure.microsoft.com/free/)
- [Azure App Service Pricing](https://azure.microsoft.com/pricing/details/app-service/)
- [06-DEPLOYMENT-ARCHITECTURE.md](../06-DEPLOYMENT-ARCHITECTURE.md)
