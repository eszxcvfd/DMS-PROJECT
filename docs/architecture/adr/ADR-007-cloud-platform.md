# ADR-007: Cloud Platform Selection

## Status
**Accepted** - 2026-02-02

## Context

We need to select a cloud platform to host the DILIGO DMS infrastructure that supports:
- Container orchestration for microservices
- SQL Server database hosting (managed)
- Redis caching
- Blob storage for images
- Real-time messaging (SignalR)
- CI/CD pipelines
- Monitoring and observability
- Geographic presence in Southeast Asia

Key considerations:
- SQL Server is mandatory (natural Azure affinity)
- Team expertise
- Cost optimization
- Enterprise support

## Decision

We will use **Microsoft Azure** as our primary cloud platform.

### Key Azure Services:
| Service | Purpose |
|---------|---------|
| Azure Kubernetes Service (AKS) | Container orchestration |
| Azure SQL Database | Managed SQL Server |
| Azure Cache for Redis | Distributed caching |
| Azure Blob Storage | File/image storage |
| Azure SignalR Service | Real-time scaling |
| Azure Service Bus | Message queuing |
| Azure API Management | API gateway |
| Azure DevOps | CI/CD pipelines |
| Azure Monitor + App Insights | Observability |
| Azure Key Vault | Secrets management |
| Azure Front Door + CDN | Global load balancing, CDN |

### Deployment Region:
- **Primary**: Southeast Asia (Singapore)
- **DR**: East Asia (Hong Kong)

## Consequences

### Positive
- **SQL Server synergy**: Best-in-class SQL Server support
- **.NET optimization**: Native integration with .NET ecosystem
- **SignalR scaling**: Azure SignalR Service scales WebSocket connections
- **Regional presence**: Data centers in Singapore (close to Vietnam)
- **Enterprise support**: Microsoft enterprise support available
- **Hybrid options**: Azure Arc for future on-premises needs
- **Security compliance**: SOC2, ISO 27001, etc.
- **Cost tools**: Azure Cost Management, Reserved Instances

### Negative
- **Vendor lock-in**: Deep Azure dependencies
- **Cost**: Premium pricing compared to some alternatives
- **Complexity**: Many services to learn and configure
- **Vietnam latency**: No Azure region in Vietnam (Singapore closest)

### Risks
- **Cost overruns**: Cloud costs can escalate
- **Mitigation**: Regular cost reviews, Reserved Instances, auto-scaling

## Alternatives Considered

### Amazon Web Services (AWS)
- **Pros**:
  - Largest market share
  - Most services available
  - Strong Vietnam adoption
- **Cons**:
  - SQL Server support less integrated
  - No native SignalR equivalent
  - Requires more third-party tools for .NET
- **Decision**: Viable but Azure has better .NET/SQL Server integration

### Google Cloud Platform (GCP)
- **Pros**:
  - Strong Kubernetes (GKE)
  - Good pricing
  - Excellent networking
- **Cons**:
  - Weakest SQL Server support
  - Smaller enterprise presence in Vietnam
  - Less .NET tooling
- **Decision**: Rejected for SQL Server requirement

### On-Premises / Colocation
- **Pros**:
  - Full control
  - Predictable costs
  - Local data residency
- **Cons**:
  - High CapEx
  - Operational burden
  - Limited scalability
  - No managed services
- **Decision**: Rejected for operational complexity

### Hybrid (On-prem + Cloud)
- **Pros**:
  - Balance of control and scalability
- **Cons**:
  - Complexity of two environments
  - Connectivity requirements
- **Decision**: Consider for future if data residency required

## Cost Estimation

| Service | Configuration | Monthly Cost (USD) |
|---------|--------------|-------------------|
| AKS (5 nodes D8s_v4) | 8 vCPU, 32 GB each | $1,200 |
| Azure SQL (GP Gen5 4 vCore) | Zone redundant | $800 |
| Azure Cache for Redis (P1) | 6 GB | $200 |
| Blob Storage (100 GB) | LRS + CDN | $50 |
| SignalR Service | Standard | $100 |
| Service Bus | Standard | $50 |
| API Management | Developer | $50 |
| App Insights | 10 GB/month | $50 |
| Key Vault | Standard | $10 |
| Front Door | Standard | $40 |
| DevOps | 5 users | $150 |
| **Total** | | **~$2,700/month** |

*Note: Costs can be reduced 30-40% with Reserved Instances*

## Networking Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Azure Front Door                          │
│                    (Global Load Balancer + WAF)                  │
└─────────────────────────────────────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
        ┌─────────────────────┐     ┌─────────────────────┐
        │   Southeast Asia    │     │     East Asia       │
        │    (Primary)        │     │      (DR)           │
        │                     │     │                     │
        │  ┌───────────────┐  │     │  ┌───────────────┐  │
        │  │     AKS       │  │     │  │   AKS (Warm)  │  │
        │  └───────────────┘  │     │  └───────────────┘  │
        │                     │     │                     │
        │  ┌───────────────┐  │     │  ┌───────────────┐  │
        │  │  SQL Primary  │◄─┼─AG──┼─►│ SQL Secondary │  │
        │  └───────────────┘  │     │  └───────────────┘  │
        │                     │     │                     │
        │  ┌───────────────┐  │     │  ┌───────────────┐  │
        │  │  Blob (GRS)   │◄─┼─────┼─►│  Blob (GRS)   │  │
        │  └───────────────┘  │     │  └───────────────┘  │
        └─────────────────────┘     └─────────────────────┘
```

## Security Configuration

### Network Security
- Virtual Network for AKS with subnet isolation
- Network Security Groups (NSG) for traffic filtering
- Private endpoints for SQL, Redis, Storage
- WAF policies on Front Door

### Identity & Access
- Azure AD for team authentication
- Managed Identities for service-to-service auth
- RBAC for resource access control
- Key Vault for secrets management

## References

- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [Azure Regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/)
