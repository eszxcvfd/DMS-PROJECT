# DILIGO DMS - Architecture Overview

## Distribution Management System

**Version:** 1.0
**Last Updated:** 2026-02-03
**Status:** Draft

---

## 1. Executive Summary

DILIGO DMS (Distribution Management System) is a comprehensive solution for managing distribution networks, field sales monitoring, and optimizing the order-to-delivery process nationwide. This document provides a high-level overview of the system architecture designed to meet the requirements outlined in the PRD.

### Technology Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Mobile App** | Kotlin (Android) | Native performance, modern language, offline support |
| **Web Frontend** | React/Next.js or Blazor | Modern SPA, responsive design |
| **API Backend** | .NET 8 (ASP.NET Core) | Enterprise-grade, cross-platform, high performance |
| **Database** | PostgreSQL | Open source, excellent .NET integration via Npgsql |
| **Deployment** | Free tier cloud services | Cost-effective, scalable |

---

## 2. Architecture Principles

### 2.1 Design Principles

1. **Mobile-First**: Optimize for field sales reps using smartphones
2. **Offline-First**: Support disconnected scenarios with data synchronization
3. **Separation of Concerns**: Clear boundaries between presentation, business logic, and data
4. **API-First**: All functionality exposed through well-defined REST APIs
5. **Security by Design**: Authentication, authorization, and data protection built-in
6. **Cost-Effective**: Leverage free tier services for deployment

### 2.2 Quality Attributes

| Attribute | Target | Strategy |
|-----------|--------|----------|
| **Performance** | Web < 3s, Mobile < 2s | Caching, CDN, optimized queries |
| **Availability** | 99.5% uptime | Health monitoring, auto-restart |
| **Scalability** | 1000+ concurrent users | Horizontal scaling, connection pooling |
| **Security** | RBAC, TLS, audit logs | JWT tokens, HTTPS, SQL parameterization |
| **Maintainability** | Clean code, documentation | SOLID principles, automated testing |

---

## 3. C4 Model Overview

This architecture follows the C4 Model for visualization:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         C4 MODEL HIERARCHY                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Level 1: System Context                                           │
│  ├── Shows DILIGO DMS and its external actors/systems              │
│  │                                                                  │
│  Level 2: Container Diagram                                        │
│  ├── Shows major containers: Mobile App, Web App, API, Database   │
│  │                                                                  │
│  Level 3: Component Diagram                                        │
│  ├── Shows components within each container                        │
│  │                                                                  │
│  Level 4: Code (Optional)                                          │
│  └── Class diagrams for critical components                        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 4. Documentation Index

| Document | Description |
|----------|-------------|
| [01-SYSTEM-CONTEXT.md](01-SYSTEM-CONTEXT.md) | C4 Level 1 - System Context Diagram |
| [02-CONTAINER-ARCHITECTURE.md](02-CONTAINER-ARCHITECTURE.md) | C4 Level 2 - Container Architecture |
| [03-COMPONENT-ARCHITECTURE.md](03-COMPONENT-ARCHITECTURE.md) | C4 Level 3 - Component Details |
| [04-DATA-ARCHITECTURE.md](04-DATA-ARCHITECTURE.md) | Database Design & Data Flow |
| [05-API-DESIGN.md](05-API-DESIGN.md) | REST API Specifications |
| [06-DEPLOYMENT-ARCHITECTURE.md](06-DEPLOYMENT-ARCHITECTURE.md) | Deployment & Infrastructure |
| [07-SECURITY-ARCHITECTURE.md](07-SECURITY-ARCHITECTURE.md) | Security Design |
| [08-MOBILE-ARCHITECTURE.md](08-MOBILE-ARCHITECTURE.md) | Android App Architecture |
| [adr/](adr/) | Architecture Decision Records |

---

## 5. High-Level System View

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DILIGO DMS ECOSYSTEM                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│    ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                 │
│    │   NVBH      │     │  GSBH/SS    │     │  ASM/RSM    │                 │
│    │ Sales Rep   │     │ Supervisor  │     │  Managers   │                 │
│    └──────┬──────┘     └──────┬──────┘     └──────┬──────┘                 │
│           │                   │                   │                         │
│           ▼                   ▼                   ▼                         │
│    ┌─────────────┐     ┌─────────────────────────────────┐                 │
│    │  Android    │     │         Web Application         │                 │
│    │  Mobile App │     │     (React/Blazor + HTTPS)      │                 │
│    │  (Kotlin)   │     └───────────────┬─────────────────┘                 │
│    └──────┬──────┘                     │                                    │
│           │                            │                                    │
│           └──────────────┬─────────────┘                                    │
│                          │                                                  │
│                          ▼                                                  │
│           ┌─────────────────────────────────┐                              │
│           │       .NET 8 REST API           │                              │
│           │      (ASP.NET Core Web API)     │                              │
│           └───────────────┬─────────────────┘                              │
│                           │                                                 │
│                           ▼                                                 │
│           ┌─────────────────────────────────┐                              │
│           │        PostgreSQL Database         │                              │
│           │      (Neon / Supabase / Local)      │                              │
│           └─────────────────────────────────┘                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Mobile Platform** | Kotlin (Android only) | Target user base, cost-effective |
| **Backend Framework** | .NET 8 | Enterprise support, performance, ecosystem |
| **Database** | PostgreSQL | Open source, Supabase/Neon free tier |
| **API Style** | REST + JSON | Simplicity, wide support, mobile-friendly |
| **Authentication** | JWT Bearer Tokens | Stateless, mobile-friendly |
| **Offline Sync** | SQLite + Sync Service | Reliable offline operation |

For detailed rationale, see [ADR documents](adr/).

---

## 7. Cross-Cutting Concerns

### 7.1 Logging & Monitoring
- Application Insights (free tier) for telemetry
- Structured logging with Serilog
- Health check endpoints

### 7.2 Error Handling
- Global exception handling middleware
- Standardized error response format
- Mobile-friendly error messages

### 7.3 Caching
- Response caching for read-heavy endpoints
- Redis (optional) for distributed scenarios
- Mobile-side caching with Room/SQLite

### 7.4 Localization
- Vietnamese as primary language
- UTF-8 encoding throughout
- Date/time in Vietnam timezone (UTC+7)

---

## 8. Integration Points

| System | Integration Type | Purpose |
|--------|-----------------|---------|
| **Oracle ERP** | Excel Export | Financial data exchange |
| **Google Maps API** | REST API | GPS coordinates, mapping |
| **Push Notifications** | Firebase FCM | Mobile notifications |
| **Email Service** | SMTP | Alerts and reports |

---

## 9. Deployment Strategy

**Free Tier Deployment Options:**

| Component | Primary Option | Alternative |
|-----------|---------------|-------------|
| **API Server** | Azure App Service (F1 Free) | Railway.app Free |
| **Database** | Neon Free (PostgreSQL) | Supabase Free |
| **Web App** | Vercel Free | Cloudflare Pages |
| **File Storage** | Azure Blob (5GB free) | Cloudflare R2 |
| **Mobile App** | Google Play Console ($25 one-time) | Direct APK |

See [06-DEPLOYMENT-ARCHITECTURE.md](06-DEPLOYMENT-ARCHITECTURE.md) for details.

---

## 10. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-02 | Architecture Team | Initial version |

---

**Next Steps:**
1. Review and approve architecture design
2. Set up development environment
3. Create detailed component specifications
4. Begin Phase 1 implementation
