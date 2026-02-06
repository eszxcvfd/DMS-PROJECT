# ADR-009: Organization Hierarchy Design Pattern

## Status

**Accepted**

## Date

2026-02-04

## Context

DMS VIPPro needs to model a complex organizational hierarchy for FMCG distribution:

```text
VIPPro (Company)
└── BPTKH (Business Division)
    ├── GT Division (General Trade)
    │   ├── Miền Bắc Region
    │   │   ├── NPP Hà Nội 1
    │   │   │   ├── Team Đống Đa
    │   │   │   │   ├── GSBH Nguyen Van A
    │   │   │   │   │   ├── NVBH 1
    │   │   │   │   │   └── NVBH 2
    │   │   │   │   └── GSBH Tran Van B
    │   │   │   └── Team Cầu Giấy
    │   │   └── NPP Hà Nội 2
    │   └── Miền Nam Region
    │       ├── NPP Sài Gòn 1
    │       └── NPP Sài Gòn 2
    └── MT Division (Modern Trade)
        └── ...
```

### Requirements

1. **Flexible depth**: 4-8 levels depending on organization
2. **Multiple assignments**: User can belong to multiple units
3. **Inherited permissions**: Higher levels can view lower levels
4. **Efficient queries**: Fast ancestor/descendant lookups
5. **Data isolation**: NPPs only see their own data

## Decision

We will implement a **Materialized Path pattern** with supplementary adjacency list for the organizational hierarchy.

### Design Choice: Materialized Path

| Pattern | Pros | Cons |
| ------- | ---- | ---- |
| **Adjacency List** | Simple, easy updates | Slow for deep queries |
| **Nested Sets** | Fast reads | Complex writes, rebalancing |
| **Closure Table** | Fast all queries | Storage overhead |
| **Materialized Path** | Fast reads, simple writes | Path string limits |

We chose **Materialized Path** because:
- Hierarchy is relatively shallow (< 10 levels)
- Reads are much more frequent than writes
- Path updates are rare (reorganization is infrequent)
- Simple to implement and debug

### Database Schema

```sql
-- Organization Units with materialized path
CREATE TABLE organization_units (
    unit_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    distributor_id  UUID NULL REFERENCES distributors(distributor_id),
    unit_code       VARCHAR(20) NOT NULL,
    unit_name       VARCHAR(100) NOT NULL,
    parent_unit_id  UUID NULL REFERENCES organization_units(unit_id),

    -- Materialized path: e.g., "1.2.5.12"
    -- Each segment is the unit's position among siblings
    hierarchy_path  VARCHAR(500) NOT NULL,

    -- Denormalized for filtering
    level           INT NOT NULL DEFAULT 0,
    is_supervisor_unit BOOLEAN NOT NULL DEFAULT FALSE,
    is_sales_group  BOOLEAN NOT NULL DEFAULT FALSE,

    status          VARCHAR(20) NOT NULL DEFAULT 'Active',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX ix_org_units_parent ON organization_units(parent_unit_id);
CREATE INDEX ix_org_units_path ON organization_units(hierarchy_path);
CREATE INDEX ix_org_units_path_pattern ON organization_units(hierarchy_path varchar_pattern_ops);
CREATE INDEX ix_org_units_distributor ON organization_units(distributor_id);

-- User to Organization Unit mapping (many-to-many)
CREATE TABLE user_organization_units (
    user_org_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(user_id),
    unit_id         UUID NOT NULL REFERENCES organization_units(unit_id),
    is_primary      BOOLEAN NOT NULL DEFAULT TRUE,
    role_in_unit    VARCHAR(50) NULL, -- e.g., 'Manager', 'Member'

    CONSTRAINT uq_user_unit UNIQUE (user_id, unit_id)
);

CREATE INDEX ix_user_org_user ON user_organization_units(user_id);
CREATE INDEX ix_user_org_unit ON user_organization_units(unit_id);
```

### Query Patterns

```sql
-- 1. Get all descendants of a unit (including self)
SELECT * FROM organization_units
WHERE hierarchy_path LIKE (
    SELECT hierarchy_path || '%'
    FROM organization_units
    WHERE unit_id = :parentUnitId
);

-- 2. Get all ancestors of a unit
WITH RECURSIVE ancestors AS (
    SELECT * FROM organization_units WHERE unit_id = :unitId
    UNION ALL
    SELECT ou.* FROM organization_units ou
    INNER JOIN ancestors a ON ou.unit_id = a.parent_unit_id
)
SELECT * FROM ancestors ORDER BY level;

-- 3. Get all users under a manager (through org hierarchy)
SELECT DISTINCT u.*
FROM users u
INNER JOIN user_organization_units uou ON u.user_id = uou.user_id
INNER JOIN organization_units ou ON uou.unit_id = ou.unit_id
WHERE ou.hierarchy_path LIKE (
    SELECT hierarchy_path || '%'
    FROM organization_units ou2
    INNER JOIN user_organization_units uou2 ON ou2.unit_id = uou2.unit_id
    WHERE uou2.user_id = :managerId
    LIMIT 1
);

-- 4. Get users' effective distributor (for data isolation)
SELECT DISTINCT d.*
FROM distributors d
INNER JOIN organization_units ou ON ou.distributor_id = d.distributor_id
INNER JOIN user_organization_units uou ON uou.unit_id = ou.unit_id
WHERE uou.user_id = :userId;
```

### Path Management Functions

```sql
-- Function to generate hierarchy path
CREATE OR REPLACE FUNCTION generate_hierarchy_path(p_parent_unit_id UUID)
RETURNS VARCHAR AS $$
DECLARE
    v_parent_path VARCHAR;
    v_sibling_count INT;
BEGIN
    IF p_parent_unit_id IS NULL THEN
        -- Root level
        SELECT COUNT(*) + 1 INTO v_sibling_count
        FROM organization_units WHERE parent_unit_id IS NULL;
        RETURN v_sibling_count::VARCHAR;
    ELSE
        SELECT hierarchy_path INTO v_parent_path
        FROM organization_units WHERE unit_id = p_parent_unit_id;

        SELECT COUNT(*) + 1 INTO v_sibling_count
        FROM organization_units WHERE parent_unit_id = p_parent_unit_id;

        RETURN v_parent_path || '.' || v_sibling_count::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate path on insert
CREATE OR REPLACE FUNCTION before_insert_org_unit()
RETURNS TRIGGER AS $$
BEGIN
    NEW.hierarchy_path := generate_hierarchy_path(NEW.parent_unit_id);
    NEW.level := CASE
        WHEN NEW.parent_unit_id IS NULL THEN 0
        ELSE (SELECT level + 1 FROM organization_units WHERE unit_id = NEW.parent_unit_id)
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_insert_org_unit
BEFORE INSERT ON organization_units
FOR EACH ROW EXECUTE FUNCTION before_insert_org_unit();
```

### Service Implementation

```csharp
public class OrganizationService : IOrganizationService
{
    public async Task<List<OrganizationUnit>> GetDescendantsAsync(
        Guid unitId,
        bool includeSelf = true,
        CancellationToken ct = default)
    {
        var unit = await _db.OrganizationUnits
            .FirstOrDefaultAsync(u => u.UnitId == unitId, ct);

        if (unit == null) return new List<OrganizationUnit>();

        var query = _db.OrganizationUnits
            .Where(u => u.HierarchyPath.StartsWith(unit.HierarchyPath));

        if (!includeSelf)
            query = query.Where(u => u.UnitId != unitId);

        return await query.OrderBy(u => u.HierarchyPath).ToListAsync(ct);
    }

    public async Task<List<User>> GetSubordinatesAsync(
        Guid managerId,
        CancellationToken ct = default)
    {
        // Get manager's units
        var managerUnits = await _db.UserOrganizationUnits
            .Where(uou => uou.UserId == managerId)
            .Select(uou => uou.Unit.HierarchyPath)
            .ToListAsync(ct);

        // Get all users under those units
        return await _db.Users
            .Where(u => _db.UserOrganizationUnits
                .Any(uou => uou.UserId == u.UserId
                    && managerUnits.Any(path => uou.Unit.HierarchyPath.StartsWith(path))))
            .ToListAsync(ct);
    }

    public async Task<bool> CanAccessDataAsync(
        Guid userId,
        Guid targetDistributorId,
        CancellationToken ct = default)
    {
        // Check if user's organization has access to the distributor
        return await _db.UserOrganizationUnits
            .Where(uou => uou.UserId == userId)
            .Select(uou => uou.Unit)
            .AnyAsync(u =>
                u.DistributorId == targetDistributorId ||
                _db.OrganizationUnits
                    .Any(child => child.HierarchyPath.StartsWith(u.HierarchyPath)
                               && child.DistributorId == targetDistributorId),
                ct);
    }
}
```

## Consequences

### Positive

1. **Fast descendant queries**: Single LIKE query, indexed
2. **Simple writes**: Just generate path on insert
3. **Readable**: Path is human-understandable
4. **Flexible depth**: No hard limit on hierarchy levels

### Negative

1. **Path updates on reorganization**: Moving subtree requires updating all descendants
2. **String-based comparisons**: Slightly less efficient than integer operations
3. **Path length limit**: Very deep hierarchies need longer paths

### Mitigations

1. **Reorganization job**: Background job to handle subtree moves
2. **Caching**: Cache frequently accessed hierarchies
3. **Path optimization**: Use shorter segment identifiers

## Related Decisions

- [ADR-005: JWT Auth](ADR-005-jwt-auth.md) - User claims include organization context
- [07-SECURITY-ARCHITECTURE.md](../07-SECURITY-ARCHITECTURE.md) - Data access control

## References

- PRD-v2.md Section 7: Organization Management
- Database Hierarchies comparison: https://www.slideshare.net/billkarwin/models-for-hierarchical-data
