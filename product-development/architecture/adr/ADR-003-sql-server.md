# ADR-003: SQL Server for Database

## Status

Accepted

## Date

2026-02-02

## Context

DILIGO DMS requires a reliable database to store master data, transactions, and operational data. The database must support complex queries, transactions, and scale to handle 1000+ concurrent users.

## Decision Drivers

- **Specification requirement**: SQL Server was specified as the database
- **.NET Integration**: Optimal with Entity Framework Core
- **Free tier availability**: Azure SQL Free tier offers 32GB
- **Transactional integrity**: ACID compliance required
- **Reporting needs**: Complex analytical queries
- **Existing skills**: Team familiarity with SQL Server

## Considered Options

### 1. SQL Server (Azure SQL)
- Specified technology
- Excellent .NET integration
- Azure SQL Free tier (32GB)
- Strong enterprise features

### 2. PostgreSQL (Supabase/Azure)
- Open source, no licensing
- Supabase free tier (500MB)
- PostGIS for spatial queries
- Strong community

### 3. MySQL (Azure Database)
- Open source
- Wide adoption
- Basic free tier
- Less .NET tooling

### 4. SQLite (Embedded)
- Zero cost, no server
- Limited concurrency
- Good for development
- Not suitable for production

## Decision

**We will use SQL Server via Azure SQL Database Free tier.**

### Rationale

1. **Requirement Compliance**: SQL Server was specified as the database technology.

2. **Azure SQL Free Tier**: Offers 32GB storage and 100,000 vCore-seconds/month free, sufficient for MVP and early growth.

3. **EF Core Integration**: Entity Framework Core has first-class SQL Server support with full feature parity.

4. **Enterprise Features**:
   - Transparent Data Encryption (TDE) for security
   - Point-in-time restore for disaster recovery
   - Query Store for performance monitoring
   - Automatic tuning

5. **Spatial Data**: Built-in geography data types for GPS coordinates, though we'll use simple DECIMAL for simplicity.

## Azure SQL Free Tier Limits

| Limit | Value | Consideration |
|-------|-------|---------------|
| **Storage** | 32 GB | Sufficient for MVP; archive old data |
| **Compute** | 100K vCore-sec/month | ~27 hours of active queries |
| **Auto-pause** | After 1 hour idle | Cold start latency |
| **Max vCores** | 1 | Query performance limit |
| **Backup retention** | 7 days | Point-in-time restore |

## Optimization Strategies

```sql
-- 1. Efficient Indexing
CREATE INDEX IX_Visits_UserDate ON Visits(UserId, VisitDate DESC)
INCLUDE (CheckInTime, CheckOutTime, VisitResult);

-- 2. Data Compression
ALTER TABLE LocationHistory REBUILD WITH (DATA_COMPRESSION = PAGE);

-- 3. Automatic Data Cleanup
CREATE PROCEDURE sp_CleanupOldData AS
BEGIN
    DELETE FROM LocationHistory WHERE RecordedAt < DATEADD(DAY, -90, GETUTCDATE());
    DELETE FROM AuditLogs WHERE CreatedAt < DATEADD(YEAR, -1, GETUTCDATE());
END

-- 4. Query Store for Monitoring
ALTER DATABASE [diligo-dms-db] SET QUERY_STORE = ON;
```

## Connection Configuration

```csharp
// appsettings.json optimized for free tier
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:diligo-dms.database.windows.net,1433;Database=diligo-dms-db;User ID=app_user;Password=...;Encrypt=True;Connection Timeout=30;Max Pool Size=10;"
  }
}

// DbContext configuration
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.EnableRetryOnFailure(maxRetryCount: 5, maxRetryDelay: TimeSpan.FromSeconds(30), errorNumbersToAdd: null);
        sqlOptions.CommandTimeout(30);
    }));
```

## Consequences

### Positive

- Direct requirement compliance
- Excellent .NET/EF Core integration
- 32GB free storage is generous
- Enterprise security features included
- Automatic backups and restore
- Azure portal management
- Familiar SQL syntax

### Negative

- Vendor lock-in to Microsoft/Azure
- Free tier has auto-pause (cold starts)
- 100K vCore-seconds limit requires optimization
- More expensive if scaling beyond free tier
- Less flexible than PostgreSQL for some use cases

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Exceeding vCore limit | Medium | High | Optimize queries, add caching |
| Storage limit reached | Low | Medium | Archive old data, compress tables |
| Auto-pause latency | High | Low | Health ping to keep alive during business hours |
| Cold start after pause | High | Medium | Implement connection retry logic |

## Migration Path

If limits are exceeded, upgrade options:

| Tier | Price | Storage | Compute |
|------|-------|---------|---------|
| Free | $0 | 32 GB | 100K vCore-sec |
| Basic (DTU) | ~$5/mo | 2 GB | 5 DTUs |
| Standard S0 | ~$15/mo | 250 GB | 10 DTUs |
| General Purpose | ~$35/mo | 32 GB | 1 vCore |

## References

- [Azure SQL Database Free Tier](https://learn.microsoft.com/azure/azure-sql/database/free-offer)
- [EF Core SQL Server Provider](https://docs.microsoft.com/ef/core/providers/sql-server/)
- [04-DATA-ARCHITECTURE.md](../04-DATA-ARCHITECTURE.md)
