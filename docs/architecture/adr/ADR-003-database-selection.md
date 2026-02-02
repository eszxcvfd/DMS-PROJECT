# ADR-003: Database Selection

## Status
**Accepted** - 2026-02-02

## Context

We need to select a primary database for the DILIGO DMS that will store:
- Master data (customers, products, distributors)
- Transactional data (orders, visits, inventory)
- Location tracking data (high volume)
- Audit logs and history

Key requirements:
- **SQL Server mandatory** (per stakeholder requirement)
- ACID compliance for transactions
- Support for 1000+ concurrent users
- Complex reporting and analytics
- Geographic queries (for location data)
- High availability and disaster recovery

## Decision

We will use **Microsoft SQL Server 2022 Enterprise** as our primary database, deployed as **Azure SQL Database** in production.

### Specific Features to Utilize:
- **Temporal Tables** - For audit history
- **Full-Text Search** - For product/customer search
- **JSON Support** - For flexible metadata
- **Table Partitioning** - For location/visit tables
- **Always On Availability Groups** - For HA/DR
- **Query Store** - For performance monitoring
- **Columnstore Indexes** - For analytics queries

### Deployment:
- **Azure SQL Database** - General Purpose tier, Gen5, 4 vCores
- **Zone Redundant** - High availability within region
- **Geo-replication** - Cross-region DR

## Consequences

### Positive
- **Stakeholder requirement**: Meets mandatory SQL Server requirement
- **EF Core integration**: First-class support in Entity Framework Core
- **Enterprise features**: Temporal tables, partitioning, columnstore for our needs
- **Azure integration**: Seamless Azure SQL managed service
- **Familiar technology**: Common in enterprise, easier to find talent
- **Robust tooling**: SQL Server Management Studio, Azure Data Studio
- **BI integration**: Easy Power BI, SSRS integration for reporting

### Negative
- **Cost**: SQL Server licensing/Azure SQL costs higher than open-source alternatives
- **Vendor lock-in**: Microsoft ecosystem dependency
- **Limited JSON capabilities**: Less flexible than document databases

### Risks
- **Data growth**: Location data may grow rapidly
- **Mitigation**: Table partitioning + archival strategy
- **Cost management**: Monitor DTU/vCore usage, right-size regularly

## Alternatives Considered

### PostgreSQL
- **Pros**: Open-source, excellent spatial support (PostGIS), JSON/JSONB
- **Cons**:
  - Not allowed per stakeholder requirement
  - Less familiar to enterprise teams in Vietnam
- **Decision**: Rejected due to mandatory SQL Server requirement

### MySQL
- **Pros**: Open-source, widely used
- **Cons**:
  - Not allowed per stakeholder requirement
  - Weaker enterprise features compared to SQL Server
- **Decision**: Rejected due to mandatory SQL Server requirement

### MongoDB
- **Pros**: Flexible schema, good for location data
- **Cons**:
  - Not relational - doesn't meet requirement
  - Complex transactions compared to SQL
  - Different paradigm requires retraining
- **Decision**: Rejected - RDBMS required

### SQL Server + Azure Cosmos DB (Hybrid)
- **Pros**: Best of both worlds, Cosmos for high-volume location data
- **Cons**:
  - Added complexity
  - Multiple data stores to manage
  - Higher cost
- **Decision**: Considered for future, start with SQL Server only

## Implementation Notes

### Azure SQL Database Configuration
```bicep
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: 'DiligoDMS'
  location: 'southeastasia'
  sku: {
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
    capacity: 4
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 107374182400 // 100 GB
    zoneRedundant: true
    readScale: 'Enabled'
    highAvailabilityReplicaCount: 1
  }
}
```

### Entity Framework Core Configuration
```csharp
services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.EnableRetryOnFailure(
            maxRetryCount: 5,
            maxRetryDelay: TimeSpan.FromSeconds(30),
            errorNumbersToAdd: null);
        sqlOptions.CommandTimeout(30);
        sqlOptions.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery);
    });
});
```

### Table Partitioning for Location Data
```sql
-- Partition by month
CREATE PARTITION FUNCTION PF_Locations (DATETIME2)
AS RANGE RIGHT FOR VALUES (
    '2026-01-01', '2026-02-01', '2026-03-01',
    '2026-04-01', '2026-05-01', '2026-06-01',
    '2026-07-01', '2026-08-01', '2026-09-01',
    '2026-10-01', '2026-11-01', '2026-12-01'
);

CREATE PARTITION SCHEME PS_Locations
AS PARTITION PF_Locations ALL TO ([PRIMARY]);

CREATE TABLE dbo.Locations (
    Id BIGINT IDENTITY(1,1),
    UserId UNIQUEIDENTIFIER NOT NULL,
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    RecordedAt DATETIME2 NOT NULL,
    -- ...
) ON PS_Locations(RecordedAt);
```

### Temporal Tables for Audit
```sql
CREATE TABLE dbo.Customers (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    Code NVARCHAR(20) NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    -- ... other columns
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.CustomersHistory));
```

## Scaling Strategy

| Data Volume | Strategy |
|-------------|----------|
| < 100 GB | Single database, no partitioning |
| 100 GB - 500 GB | Partitioning for large tables |
| 500 GB - 2 TB | Read replicas for reporting |
| > 2 TB | Consider sharding by distributor |

## Cost Estimation

| Configuration | Monthly Cost (USD) |
|---------------|-------------------|
| GP Gen5 4 vCore | ~$500 |
| Zone Redundant | +$250 |
| Geo-replication | +$500 |
| Backup storage (100 GB) | ~$50 |
| **Total** | **~$1,300** |

## References

- [Azure SQL Database Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/)
- [SQL Server 2022 Features](https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2022)
- [EF Core SQL Server Provider](https://learn.microsoft.com/en-us/ef/core/providers/sql-server/)
