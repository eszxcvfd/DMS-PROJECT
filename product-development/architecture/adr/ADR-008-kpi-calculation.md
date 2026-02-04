# ADR-008: KPI Calculation Strategy

## Status

**Accepted**

## Date

2026-02-04

## Context

DILIGO DMS needs to track and calculate multiple KPIs for sales representatives. The system must:

1. Support various KPI metrics (visits, orders, revenue, volume, SKUs, new customers)
2. Allow target assignment by period (monthly)
3. Calculate real-time progress and achievement
4. Support focus product KPIs
5. Aggregate KPIs at team/territory level
6. Handle partial months and mid-month target changes

### Key Challenges

- **Real-time vs. Batch**: Should KPIs be calculated on-demand or pre-computed?
- **Data Freshness**: How recent should the data be?
- **Performance**: Aggregations across many users/products can be slow
- **Flexibility**: Different distributors may have different KPI definitions

## Decision

We will implement a **hybrid calculation strategy** with:

1. **Real-time calculation** for individual user dashboards
2. **Materialized views** for team/aggregate reports
3. **Event-driven updates** for key metrics

### Calculation Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        KPI CALCULATION ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  EVENTS (Source Data)                                                       │
│  ────────────────────                                                       │
│  Order Created → Updates: orders, revenue, volume, sku                     │
│  Visit Completed → Updates: visits, coverage                                │
│  Customer Created → Updates: newCustomers                                   │
│  Attendance Logged → Updates: workingHours                                  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     REAL-TIME LAYER                                  │   │
│  │                                                                      │   │
│  │   Individual KPI queries execute against live tables with indexes   │   │
│  │   Cached for 5 minutes to reduce load                               │   │
│  │                                                                      │   │
│  │   SELECT COUNT(*), SUM(amount) FROM orders                         │   │
│  │   WHERE user_id = ? AND order_date >= ? AND order_date <= ?        │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                   MATERIALIZED VIEW LAYER                            │   │
│  │                                                                      │   │
│  │   Refreshed every 15 minutes for aggregate reports                  │   │
│  │                                                                      │   │
│  │   kpi_daily_summary (user_id, date, visits, orders, revenue...)    │   │
│  │   kpi_monthly_summary (user_id, month, ...)                         │   │
│  │   kpi_team_summary (unit_id, month, ...)                            │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Database Design

```sql
-- Daily KPI snapshot (materialized, refreshed periodically)
CREATE TABLE kpi_daily_snapshots (
    snapshot_id     UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(user_id),
    snapshot_date   DATE NOT NULL,

    -- Metrics
    visit_count     INT NOT NULL DEFAULT 0,
    unique_customers_visited INT NOT NULL DEFAULT 0,
    order_count     INT NOT NULL DEFAULT 0,
    presales_orders INT NOT NULL DEFAULT 0,
    vansales_orders INT NOT NULL DEFAULT 0,
    gross_revenue   DECIMAL(18,2) NOT NULL DEFAULT 0,
    net_revenue     DECIMAL(18,2) NOT NULL DEFAULT 0,
    volume          INT NOT NULL DEFAULT 0,
    sku_count       INT NOT NULL DEFAULT 0,
    working_hours   DECIMAL(5,2) NOT NULL DEFAULT 0,
    new_customers   INT NOT NULL DEFAULT 0,

    -- Metadata
    calculated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_kpi_daily UNIQUE (user_id, snapshot_date)
);

CREATE INDEX ix_kpi_daily_user_date ON kpi_daily_snapshots(user_id, snapshot_date DESC);
CREATE INDEX ix_kpi_daily_date ON kpi_daily_snapshots(snapshot_date);

-- Function to calculate daily KPIs
CREATE OR REPLACE FUNCTION calculate_daily_kpi(p_user_id UUID, p_date DATE)
RETURNS TABLE (
    visit_count INT,
    unique_customers_visited INT,
    order_count INT,
    gross_revenue DECIMAL,
    volume INT,
    sku_count INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*)::INT FROM visits
         WHERE user_id = p_user_id AND visit_date = p_date) as visit_count,

        (SELECT COUNT(DISTINCT customer_id)::INT FROM visits
         WHERE user_id = p_user_id AND visit_date = p_date) as unique_customers_visited,

        (SELECT COUNT(*)::INT FROM orders
         WHERE user_id = p_user_id AND DATE(order_date) = p_date
         AND status != 'Rejected') as order_count,

        (SELECT COALESCE(SUM(total_amount), 0) FROM orders
         WHERE user_id = p_user_id AND DATE(order_date) = p_date
         AND status != 'Rejected') as gross_revenue,

        (SELECT COALESCE(SUM(od.quantity * p.conversion_rate), 0)::INT
         FROM orders o
         JOIN order_details od ON o.order_id = od.order_id
         JOIN products p ON od.product_id = p.product_id
         WHERE o.user_id = p_user_id AND DATE(o.order_date) = p_date
         AND o.status != 'Rejected') as volume,

        (SELECT COUNT(DISTINCT od.product_id)::INT
         FROM orders o
         JOIN order_details od ON o.order_id = od.order_id
         WHERE o.user_id = p_user_id AND DATE(o.order_date) = p_date
         AND o.status != 'Rejected') as sku_count;
END;
$$ LANGUAGE plpgsql;
```

### KPI Service Implementation

```csharp
public class KPIService : IKPIService
{
    private readonly IDbContext _db;
    private readonly IDistributedCache _cache;

    public async Task<KPIPerformance> GetPerformanceAsync(
        Guid userId,
        DateTime month,
        CancellationToken ct = default)
    {
        var cacheKey = $"kpi:performance:{userId}:{month:yyyy-MM}";

        // Try cache first
        var cached = await _cache.GetAsync<KPIPerformance>(cacheKey, ct);
        if (cached != null) return cached;

        // Get target
        var target = await _db.KPITargets
            .FirstOrDefaultAsync(t => t.UserId == userId && t.TargetMonth == month, ct);

        if (target == null)
            return new KPIPerformance { UserId = userId, TargetMonth = month };

        // Calculate actuals from daily snapshots
        var startDate = month;
        var endDate = month.AddMonths(1).AddDays(-1);

        var actuals = await _db.KPIDailySnapshots
            .Where(s => s.UserId == userId
                     && s.SnapshotDate >= startDate
                     && s.SnapshotDate <= endDate)
            .GroupBy(s => 1)
            .Select(g => new {
                VisitCount = g.Sum(s => s.VisitCount),
                OrderCount = g.Sum(s => s.OrderCount),
                GrossRevenue = g.Sum(s => s.GrossRevenue),
                Volume = g.Sum(s => s.Volume),
                SkuCount = g.Max(s => s.SkuCount), // Max unique SKUs any day
                NewCustomers = g.Sum(s => s.NewCustomers),
                WorkingHours = g.Sum(s => s.WorkingHours)
            })
            .FirstOrDefaultAsync(ct);

        var result = new KPIPerformance
        {
            UserId = userId,
            TargetMonth = month,
            Visits = new KPIMetric
            {
                Target = target.VisitTarget,
                Actual = actuals?.VisitCount ?? 0,
                Achievement = CalculateAchievement(actuals?.VisitCount ?? 0, target.VisitTarget),
                Trend = CalculateTrend(actuals?.VisitCount ?? 0, target.VisitTarget, month)
            },
            // ... other metrics
        };

        // Cache for 5 minutes
        await _cache.SetAsync(cacheKey, result, TimeSpan.FromMinutes(5), ct);

        return result;
    }

    private string CalculateTrend(int actual, int? target, DateTime month)
    {
        if (target == null || target == 0) return "no_target";

        var today = DateTime.Today;
        var daysInMonth = DateTime.DaysInMonth(month.Year, month.Month);
        var daysPassed = Math.Max(1, (today - month).Days + 1);

        if (today.Month != month.Month) daysPassed = daysInMonth;

        var expectedProgress = (double)daysPassed / daysInMonth;
        var actualProgress = (double)actual / target.Value;

        if (actualProgress >= expectedProgress * 1.1) return "ahead";
        if (actualProgress >= expectedProgress * 0.9) return "on_track";
        return "behind";
    }
}
```

## Consequences

### Positive

1. **Real-time individual dashboards**: Users see current progress immediately
2. **Performant aggregates**: Materialized views handle team/company reports
3. **Flexible**: Can add new KPI metrics without major changes
4. **Auditable**: Daily snapshots provide historical tracking

### Negative

1. **Storage overhead**: Storing daily snapshots uses more space
2. **Complexity**: Two-tier calculation requires maintenance
3. **Eventual consistency**: Team reports may lag by refresh interval

### Mitigations

1. **Partitioning**: Partition snapshots by month for efficient cleanup
2. **Monitoring**: Alert if refresh jobs fail
3. **Clear UX**: Show "last updated" timestamp on reports

## Related Decisions

- [ADR-003: PostgreSQL](ADR-003-postgresql.md) - Database choice affects calculation options
- [09-REPORTING-ARCHITECTURE.md](../09-REPORTING-ARCHITECTURE.md) - Report specifications

## References

- PRD-v2.md Section 6: KPI Management
