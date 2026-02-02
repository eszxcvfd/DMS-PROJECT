# DILIGO DMS - Architecture Overview

## Document Information
| Field | Value |
|-------|-------|
| **Document Version** | 1.0 |
| **Created Date** | 2026-02-02 |
| **Last Updated** | 2026-02-02 |
| **Status** | Draft |
| **Architecture Style** | Microservices-based, Event-driven |

---

## 1. Executive Summary

DILIGO DMS (Distribution Management System) is a comprehensive software solution designed to digitize and optimize the distribution management process for DILIGO. The system consists of a mobile application for field sales representatives and a web application for supervisors and administrators.

### Key Architecture Decisions
- **Mobile Platform**: Native Android using Kotlin with MVVM architecture
- **Backend API**: .NET 8 Web API with Clean Architecture
- **Database**: SQL Server 2022 with Entity Framework Core
- **Web Frontend**: Angular 17 with NgRx state management
- **Real-time Communication**: SignalR for live tracking
- **Cloud Platform**: Azure Cloud Services

---

## 2. Architecture Documentation Index

| Document | Description | Status |
|----------|-------------|--------|
| [01-SYSTEM-CONTEXT.md](./01-SYSTEM-CONTEXT.md) | C4 Level 1 - System Context | Draft |
| [02-CONTAINER-ARCHITECTURE.md](./02-CONTAINER-ARCHITECTURE.md) | C4 Level 2 - Container View | Draft |
| [03-COMPONENT-ARCHITECTURE.md](./03-COMPONENT-ARCHITECTURE.md) | C4 Level 3 - Component View | Draft |
| [04-DATA-ARCHITECTURE.md](./04-DATA-ARCHITECTURE.md) | Database Schema & Data Flow | Draft |
| [05-SECURITY-ARCHITECTURE.md](./05-SECURITY-ARCHITECTURE.md) | Security Design | Draft |
| [06-DEPLOYMENT-ARCHITECTURE.md](./06-DEPLOYMENT-ARCHITECTURE.md) | Infrastructure & Deployment | Draft |
| [ADR/](./adr/) | Architecture Decision Records | Draft |

---

## 3. Technology Stack

### 3.1 Mobile Application (Android)
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Language | Kotlin | 1.9.x | Primary language |
| UI Framework | Jetpack Compose | 1.5.x | Modern declarative UI |
| Architecture | MVVM + Clean Architecture | - | Code organization |
| DI | Hilt | 2.48 | Dependency Injection |
| Navigation | Navigation Compose | 2.7.x | Screen navigation |
| Networking | Retrofit + OkHttp | 2.9.x | API communication |
| Local DB | Room | 2.6.x | Offline storage |
| Maps | Google Maps SDK | 18.x | Location & mapping |
| Image Loading | Coil | 2.5.x | Image handling |
| Background | WorkManager | 2.9.x | Background sync |

### 3.2 Backend API (.NET)
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Framework | .NET | 8.0 LTS | Core framework |
| API | ASP.NET Core Web API | 8.0 | REST API |
| ORM | Entity Framework Core | 8.0 | Database access |
| Real-time | SignalR | 8.0 | WebSocket communication |
| Validation | FluentValidation | 11.x | Input validation |
| Mapping | AutoMapper | 13.x | Object mapping |
| Logging | Serilog | 3.x | Structured logging |
| Auth | JWT + Identity | 8.0 | Authentication |
| Caching | Redis | 7.x | Distributed cache |
| Message Queue | Azure Service Bus | - | Async messaging |

### 3.3 Database
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| RDBMS | SQL Server | 2022 | Primary database |
| Full-text Search | SQL Server FTS | 2022 | Search functionality |
| Backup | SQL Server Always On | 2022 | High availability |

### 3.4 Web Frontend
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Framework | Angular | 17.x | SPA framework |
| State Management | NgRx | 17.x | Redux pattern |
| UI Components | Angular Material | 17.x | Material Design |
| Maps | Leaflet/OpenLayers | 1.9.x | Mapping |
| Charts | Chart.js / ngx-charts | 4.x | Data visualization |
| HTTP | Angular HttpClient | 17.x | API calls |
| Auth | @auth0/angular-jwt | 5.x | JWT handling |

### 3.5 Infrastructure & DevOps
| Component | Technology | Purpose |
|-----------|------------|---------|
| Cloud | Azure | Hosting platform |
| Container | Docker | Containerization |
| Orchestration | Azure Kubernetes Service | Container orchestration |
| CI/CD | Azure DevOps | Build & deploy pipeline |
| CDN | Azure CDN | Static content delivery |
| Storage | Azure Blob Storage | File storage |
| Monitoring | Azure Application Insights | APM & logging |
| API Gateway | Azure API Management | API gateway |

---

## 4. Quality Attributes

### 4.1 Performance Requirements
| Metric | Target | Measurement |
|--------|--------|-------------|
| Web Response Time | < 3 seconds | 95th percentile |
| Mobile Check-in/out | < 2 seconds | 95th percentile |
| Concurrent Users | 1000+ | Simultaneous connections |
| Mobile App Startup | < 5 seconds | Cold start |
| Data Sync Interval | 5 minutes | Background sync |
| API Throughput | 1000 RPS | Per server instance |

### 4.2 Availability Requirements
| Metric | Target |
|--------|--------|
| System Uptime | 99.5% |
| RTO (Recovery Time Objective) | < 4 hours |
| RPO (Recovery Point Objective) | < 1 hour |
| Backup Frequency | Daily |
| Offline Mode Support | Full support |

### 4.3 Scalability Requirements
| Aspect | Approach |
|--------|----------|
| Horizontal Scaling | Auto-scale based on CPU/Memory |
| Database Scaling | Read replicas + connection pooling |
| Static Assets | CDN distribution |
| File Storage | Azure Blob with geo-replication |

### 4.4 Security Requirements
| Requirement | Implementation |
|-------------|----------------|
| Authentication | JWT tokens with refresh |
| Authorization | Role-based (RBAC) |
| Data Encryption | TLS 1.3 in transit, AES-256 at rest |
| Session Management | 30-minute timeout |
| Audit Logging | All user actions logged |
| API Security | Rate limiting, API keys |

---

## 5. System Boundaries

### 5.1 In Scope
- Mobile application for field sales (NVBH)
- Web application for supervisors and administrators
- Backend API services
- Real-time tracking and monitoring
- Offline data synchronization
- Reporting and analytics
- Integration with external systems (Excel export for Oracle ERP)

### 5.2 Out of Scope
- Full ERP integration (only Excel export)
- HR management
- Detailed financial accounting
- E-commerce / Direct-to-consumer sales

---

## 6. Key Architectural Patterns

### 6.1 Clean Architecture (.NET Backend)
```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│              (Controllers, SignalR Hubs)                │
├─────────────────────────────────────────────────────────┤
│                   Application Layer                      │
│        (Use Cases, DTOs, Interfaces, Validators)        │
├─────────────────────────────────────────────────────────┤
│                     Domain Layer                         │
│          (Entities, Value Objects, Domain Events)       │
├─────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                    │
│      (EF Core, External Services, Repositories)         │
└─────────────────────────────────────────────────────────┘
```

### 6.2 MVVM + Clean Architecture (Android)
```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│           (Compose UI, ViewModels, States)              │
├─────────────────────────────────────────────────────────┤
│                     Domain Layer                         │
│        (Use Cases, Repository Interfaces, Models)       │
├─────────────────────────────────────────────────────────┤
│                      Data Layer                          │
│     (Repositories, Remote Data Sources, Local DB)       │
└─────────────────────────────────────────────────────────┘
```

### 6.3 Event-Driven Communication
```
┌─────────┐     ┌──────────────┐     ┌─────────┐
│ Service │────►│ Service Bus  │────►│ Service │
│    A    │     │   (Events)   │     │    B    │
└─────────┘     └──────────────┘     └─────────┘
```

---

## 7. Cross-Cutting Concerns

| Concern | Solution |
|---------|----------|
| Logging | Serilog + Application Insights |
| Caching | Redis distributed cache |
| Exception Handling | Global exception middleware |
| Validation | FluentValidation |
| API Versioning | URL-based versioning (v1, v2) |
| Health Checks | ASP.NET Core Health Checks |
| Rate Limiting | ASP.NET Core Rate Limiting |
| Compression | Response compression middleware |

---

## 8. Integration Points

| External System | Integration Method | Purpose |
|-----------------|-------------------|---------|
| Google Maps | REST API | Geocoding, routing |
| Firebase | FCM | Push notifications |
| Azure AD B2C | OAuth 2.0 | Optional SSO |
| Oracle ERP | Excel Export | Financial data sync |
| SMS Gateway | REST API | OTP, notifications |

---

## 9. Glossary

| Term | Definition |
|------|------------|
| DMS | Distribution Management System |
| NVBH | Nhân viên bán hàng (Sales Representative) |
| GSBH/SS | Giám sát bán hàng (Sales Supervisor) |
| ASM | Area Sales Manager |
| RSM | Regional Sales Manager |
| NPP | Nhà phân phối (Distributor) |
| GT | General Trade (Traditional channel) |
| MT | Modern Trade |
| SKU | Stock Keeping Unit |
| XNT | Xuất nhập tồn (Inventory movement) |

---

## 10. Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-02 | Architecture Team | Initial version |
