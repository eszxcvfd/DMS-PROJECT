# ADR-003: PostgreSQL for Database

## Status

Accepted

## Date

2026-02-03

## Context

DMS VIPPro requires a reliable database to store master data, transactions, and operational data. The database must support complex queries, transactions, and scale to handle 1000+ concurrent users.

## Decision Drivers

- **Open Source**: No licensing costs, community-driven development
- **.NET Integration**: Excellent support with Npgsql and EF Core
- **Free tier availability**: Neon Free (512MB), Supabase Free (500MB), or self-hosted
- **Transactional integrity**: ACID compliance required
- **Reporting needs**: Complex analytical queries
- **Advanced features**: JSONB, full-text search, extensions

## Considered Options

### 1. PostgreSQL (Neon/Supabase/Self-hosted)
- Open source, no licensing
- Neon free tier (512MB) or Supabase free tier (500MB)
- Advanced features (JSONB, PostGIS, full-text search)
- Strong community and ecosystem
- Excellent EF Core support via Npgsql

### 2. SQL Server (Azure SQL)
- Proprietary Microsoft technology
- Azure SQL Free tier (32GB)
- Strong enterprise features
- Vendor lock-in

### 3. MySQL (Azure Database)
- Open source
- Wide adoption
- Basic free tier
- Less advanced features than PostgreSQL

### 4. SQLite (Embedded)
- Zero cost, no server
- Limited concurrency
- Good for development
- Not suitable for production

## Decision

**We will use PostgreSQL via Neon Free tier or self-hosted.**

### Rationale

1. **Open Source**: PostgreSQL is fully open source with no licensing costs and no vendor lock-in.

2. **Free Tier Options**:
    - Neon Free: 512MB storage, 3GB data transfer, branching
    - Supabase Free: 500MB storage, 2GB bandwidth
    - Railway/Render: PostgreSQL with free tier credits

3. **EF Core Integration**: Npgsql provider for Entity Framework Core has excellent feature parity and performance.

4. **Advanced Features**:
   - JSONB for flexible schema storage (permissions, settings)
   - Full-text search for product/customer search
   - PostGIS extension for geospatial queries (GPS coordinates)
   - Array types for storing lists
   - Rich data types (UUID, INET, etc.)

5. **Performance**: PostgreSQL excels at complex queries and concurrent operations.

## PostgreSQL Free Tier Options

| Provider | Storage | Bandwidth | Features |
|----------|---------|-----------|----------|
| **Neon** | 512 MB | 3 GB | Serverless, branching |
| **Supabase** | 500 MB | 2 GB | Auth, Storage, Edge Functions |
| **Railway** | $5 credits | Shared | Easy deployment |
| **Render** | 1 GB | Shared | 90-day expiry on free |

## Optimization Strategies

```sql
-- 1. Efficient Indexing
CREATE INDEX IX_Visits_UserDate ON Visits(UserId, VisitDate DESC)
INCLUDE (CheckInTime, CheckOutTime, VisitResult);

-- 2. Use JSONB for flexible data
CREATE INDEX IX_Promotions_Conditions ON Promotions USING GIN (Conditions);

-- 3. Full-text search index
CREATE INDEX IX_Products_Search ON Products USING GIN (to_tsvector('simple', Name || ' ' || Brand));

-- 4. Automatic Data Cleanup
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
    DELETE FROM LocationHistory WHERE RecordedAt < NOW() - INTERVAL '90 days';
    DELETE FROM AuditLogs WHERE CreatedAt < NOW() - INTERVAL '1 year';
END;
$$ LANGUAGE plpgsql;

-- Schedule with pg_cron or external scheduler
-- SELECT cron.schedule('cleanup', '0 3 * * 0', 'SELECT cleanup_old_data()');
```

## Connection Configuration

```csharp
// appsettings.json optimized for PostgreSQL (Neon example)
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=ep-xxxxx.us-east-2.aws.neon.tech;Port=5432;Database=neondb;Username=...;Password=...;SSL Mode=Require;Trust Server Certificate=true;Pooling=true;Maximum Pool Size=20;"
  }
}

// DbContext configuration
services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString, npgsqlOptions =>
    {
        npgsqlOptions.EnableRetryOnFailure(maxRetryCount: 5, maxRetryDelay: TimeSpan.FromSeconds(30), errorCodesToAdd: null);
        npgsqlOptions.CommandTimeout(30);
        npgsqlOptions.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery);
    }));
```

## Consequences

### Positive

- No licensing costs (open source)
- Excellent .NET/EF Core integration via Npgsql
- Advanced features (JSONB, full-text search, PostGIS)
- Strong community support
- Multiple free tier hosting options
- No vendor lock-in
- Better suited for complex queries

### Negative

- Smaller free tier storage compared to Azure SQL (500MB vs 32GB)
- Less enterprise support compared to commercial databases
- May need to manage backups on self-hosted deployments
- Learning curve if team is SQL Server-focused

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Storage limit reached | Medium | High | Archive old data, use efficient data types |
| Connection limits | Low | Medium | Implement connection pooling (PgBouncer) |
| Free tier sunset | Low | Medium | Data can be migrated to any PostgreSQL host |
| Performance issues | Low | Low | Optimize queries, add proper indexes |

## Migration Path

If free tier limits are exceeded, upgrade options:

| Provider | Price | Storage | Features |
|----------|-------|---------|----------|
| Supabase Free | $0 | 500 MB | Basic features |
| Supabase Pro | $25/mo | 8 GB | Daily backups, 7-day log retention |
| Neon Scale | $19/mo | 10 GB | Autoscaling, branching |
| Self-hosted | VPS cost | Unlimited | Full control |

## PostgreSQL vs SQL Server Syntax Differences

| Feature | SQL Server | PostgreSQL |
|---------|------------|------------|
| Auto-increment | `IDENTITY(1,1)` | `SERIAL` or `GENERATED ALWAYS AS IDENTITY` |
| UUID default | `NEWID()` | `gen_random_uuid()` |
| Current timestamp | `GETUTCDATE()` | `NOW()` or `CURRENT_TIMESTAMP` |
| String concat | `+` | `\|\|` |
| Top N rows | `TOP N` | `LIMIT N` |
| Boolean | `BIT` | `BOOLEAN` |
| Date add | `DATEADD(DAY, -90, GETUTCDATE())` | `NOW() - INTERVAL '90 days'` |

## References

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Npgsql - .NET PostgreSQL Provider](https://www.npgsql.org/)
- [Supabase Documentation](https://supabase.com/docs)
- [EF Core PostgreSQL Provider](https://www.npgsql.org/efcore/)
- [04-DATA-ARCHITECTURE.md](../04-DATA-ARCHITECTURE.md)
