# ADR-002: .NET 8 for API Backend

## Status

Accepted

## Date

2026-02-02

## Context

DMS VIPPro requires a robust backend API to serve the mobile and web applications. The API must handle authentication, business logic, real-time features, and database operations. We need to select a technology stack that balances performance, developer productivity, and cost.

## Decision Drivers

- **Specification requirement**: .NET was specified as the API technology
- **PostgreSQL integration**: Excellent support via Npgsql/EF Core
- **Free tier hosting**: Must run efficiently on Azure App Service F1
- **Real-time features**: SignalR support for GPS monitoring
- **Enterprise readiness**: Security, reliability, scalability
- **Team skills**: Alignment with available development expertise

## Considered Options

### 1. .NET 8 (ASP.NET Core)
- Latest LTS version
- Native Azure integration
- SignalR for real-time
- Entity Framework Core for ORM
- Minimal APIs for performance

### 2. Node.js (Express/Fastify)
- Fast development
- Large ecosystem
- Good PostgreSQL integration via drivers
- TypeScript adds type safety

### 3. Java (Spring Boot)
- Enterprise-grade
- Strong PostgreSQL support via JDBC
- More memory usage
- Higher Azure costs

### 4. Python (FastAPI)
- Rapid development
- Good for prototyping
- Not ideal for high-concurrency
- SQLAlchemy for ORM

## Decision

**We will use .NET 8 with ASP.NET Core Web API.**

### Rationale

1. **Requirement Alignment**: .NET was specified as the backend technology, making this a direct fit.

2. **PostgreSQL Integration**: Entity Framework Core with Npgsql provides excellent PostgreSQL support with migrations, LINQ queries, and performance optimization.

3. **Azure Optimization**: .NET 8 runs efficiently on Azure App Service F1 with minimal cold start times due to NativeAOT improvements.

4. **SignalR**: Built-in real-time communication framework, perfect for GPS monitoring dashboards.

5. **Performance**: .NET 8 consistently ranks among the fastest frameworks in TechEmpower benchmarks.

6. **Security**: Built-in security features including Identity, JWT authentication, and data protection APIs.

7. **Tooling**: Visual Studio, VS Code, and Rider provide excellent development experience.

## Architecture Approach

```
┌─────────────────────────────────────────────────────────────────┐
│                    .NET 8 WEB API STRUCTURE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  VIPProDMS.Api/                   (Presentation Layer)          │
│  ├── Controllers/                 REST API endpoints            │
│  ├── Hubs/                        SignalR hubs                  │
│  ├── Middleware/                  Custom middleware             │
│  └── Program.cs                   Application entry             │
│                                                                 │
│  VIPProDMS.Application/           (Application Layer)           │
│  ├── Services/                    Business logic                │
│  ├── DTOs/                        Data transfer objects         │
│  └── Validators/                  FluentValidation rules        │
│                                                                 │
│  VIPProDMS.Domain/                (Domain Layer)                │
│  ├── Entities/                    Domain models                 │
│  ├── Enums/                       Enumerations                  │
│  └── Interfaces/                  Repository contracts          │
│                                                                 │
│  VIPProDMS.Infrastructure/        (Infrastructure Layer)        │
│  ├── Data/                        EF Core context, migrations   │
│  ├── Repositories/                Repository implementations    │
│  └── Services/                    External service integrations │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Technologies

| Component | Technology |
|-----------|------------|
| **Framework** | ASP.NET Core 8 |
| **ORM** | Entity Framework Core 8 |
| **Validation** | FluentValidation |
| **Mapping** | Mapster or AutoMapper |
| **Authentication** | JWT Bearer + Microsoft.AspNetCore.Identity |
| **Real-time** | SignalR |
| **API Docs** | Swagger/OpenAPI (Swashbuckle) |
| **Logging** | Serilog + Application Insights |
| **Testing** | xUnit + Moq + FluentAssertions |

## Consequences

### Positive

- Excellent PostgreSQL support via Npgsql with great performance
- SignalR for seamless real-time features
- Strong typing reduces runtime errors
- Excellent Azure integration and free tier support
- Comprehensive security framework
- Active community and Microsoft support
- Great IDE tooling

### Negative

- Steeper learning curve than Node.js
- Larger deployment size than Go or Rust
- Memory usage higher than some alternatives
- Less flexible than dynamic languages

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Cold start on F1 tier | High | Medium | Minimize startup, use health pings |
| Memory constraints | Medium | Medium | Optimize queries, use response caching |
| Complex async patterns | Low | Low | Follow best practices, use analyzers |

## References

- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [.NET 8 Performance Improvements](https://devblogs.microsoft.com/dotnet/performance-improvements-in-net-8/)
- [03-COMPONENT-ARCHITECTURE.md](../03-COMPONENT-ARCHITECTURE.md)
