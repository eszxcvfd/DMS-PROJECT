# ADR-001: Backend Framework Selection

## Status
**Accepted** - 2026-02-02

## Context

We need to select a backend framework for the DILIGO DMS API that will handle:
- RESTful API endpoints for mobile and web clients
- Real-time communication for live tracking
- Background job processing
- Integration with SQL Server database
- High performance for 1000+ concurrent users

Key requirements:
- Strong SQL Server integration (mandatory)
- Enterprise-grade support and stability
- Real-time capabilities (WebSocket)
- Cross-platform deployment support
- Strong typing and maintainability

## Decision

We will use **.NET 8 (LTS)** with ASP.NET Core Web API as our backend framework.

### Specific Technologies:
- **ASP.NET Core Web API 8.0** - REST API
- **Entity Framework Core 8.0** - ORM for SQL Server
- **SignalR** - Real-time WebSocket communication
- **MediatR** - CQRS pattern implementation
- **FluentValidation** - Input validation
- **Serilog** - Structured logging

### Architecture Pattern:
- Clean Architecture (Domain-Driven Design)
- CQRS (Command Query Responsibility Segregation)

## Consequences

### Positive
- **Native SQL Server support**: EF Core has first-class SQL Server support with all advanced features (temporal tables, JSON columns, etc.)
- **SignalR built-in**: Native WebSocket support for real-time tracking without external dependencies
- **Performance**: .NET 8 offers excellent performance, ranking high in TechEmpower benchmarks
- **Long-term support**: .NET 8 is an LTS release with support until November 2026
- **Enterprise ecosystem**: Excellent Azure integration, strong enterprise adoption
- **Type safety**: C# provides strong typing reducing runtime errors
- **Mature tooling**: Visual Studio, Rider, extensive NuGet ecosystem

### Negative
- **Windows development preference**: While cross-platform, .NET development is often easier on Windows
- **Learning curve**: Team may need training if not familiar with .NET ecosystem
- **Memory footprint**: Higher than some alternatives (Go, Rust) though acceptable

### Risks
- **Vendor lock-in**: Microsoft ecosystem dependency
- **Mitigation**: Use abstraction layers, keep business logic framework-agnostic

## Alternatives Considered

### Node.js (Express/NestJS)
- **Pros**: JavaScript everywhere, fast development
- **Cons**:
  - Weaker SQL Server integration compared to EF Core
  - Less type safety (even with TypeScript)
  - Single-threaded (worker threads add complexity)
- **Decision**: Rejected due to weaker SQL Server support

### Java (Spring Boot)
- **Pros**: Enterprise standard, excellent ecosystem
- **Cons**:
  - Verbose compared to C#
  - Higher memory consumption
  - Slower startup times
- **Decision**: Could work, but .NET offers better SQL Server integration

### Go
- **Pros**: Excellent performance, low memory
- **Cons**:
  - Immature ORM ecosystem for SQL Server
  - Less enterprise tooling
  - Smaller talent pool in Vietnam
- **Decision**: Rejected due to SQL Server ORM limitations

### Python (FastAPI/Django)
- **Pros**: Rapid development, data science integration
- **Cons**:
  - Performance concerns at scale
  - Dynamic typing issues
  - GIL limitations for concurrent processing
- **Decision**: Rejected for enterprise API requirements

## Implementation Notes

### Project Structure
```
src/
├── Diligo.Api/                  # Presentation Layer
├── Diligo.Application/          # Application Layer
├── Diligo.Domain/               # Domain Layer
├── Diligo.Infrastructure/       # Infrastructure Layer
└── Diligo.Shared/               # Shared utilities
```

### Key Dependencies
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
<PackageReference Include="Microsoft.AspNetCore.SignalR" Version="8.0.0" />
<PackageReference Include="MediatR" Version="12.0.0" />
<PackageReference Include="FluentValidation" Version="11.0.0" />
<PackageReference Include="Serilog.AspNetCore" Version="8.0.0" />
<PackageReference Include="AutoMapper" Version="13.0.0" />
```

## References

- [.NET 8 Release Notes](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8)
- [ASP.NET Core Documentation](https://learn.microsoft.com/en-us/aspnet/core/)
- [Clean Architecture Template](https://github.com/jasontaylordev/CleanArchitecture)
