# Architecture Decision Records (ADRs)

## DILIGO DMS - Architecture Decision Log

**Last Updated:** 2026-02-03

---

## What are ADRs?

Architecture Decision Records (ADRs) are documents that capture important architectural decisions made during the development of a software project. Each ADR describes:

- **Context**: What is the issue we're facing?
- **Decision**: What have we decided to do?
- **Consequences**: What are the results of this decision?

---

## ADR Index

| ID | Title | Status | Date |
|----|-------|--------|------|
| [ADR-001](ADR-001-android-only.md) | Android-Only Mobile Platform | Accepted | 2026-02-02 |
| [ADR-002](ADR-002-dotnet-api.md) | .NET 8 for API Backend | Accepted | 2026-02-02 |
| [ADR-003](ADR-003-postgresql.md) | PostgreSQL for Database | Accepted | 2026-02-03 |
| [ADR-004](ADR-004-azure-free-tier.md) | Azure Free Tier for Deployment | Accepted | 2026-02-02 |
| [ADR-005](ADR-005-jwt-auth.md) | JWT for Authentication | Accepted | 2026-02-02 |
| [ADR-006](ADR-006-offline-first-mobile.md) | Offline-First Mobile Architecture | Accepted | 2026-02-02 |
| [ADR-007](ADR-007-react-web-frontend.md) | React for Web Frontend | Proposed | 2026-02-02 |
| [ADR-008](ADR-008-signalr-realtime.md) | SignalR for Real-time Features | Accepted | 2026-02-02 |

---

## ADR Template

When creating a new ADR, use the following template:

```markdown
# ADR-XXX: [Title]

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]

## Context

[Describe the context and problem statement]

## Decision Drivers

- [Driver 1]
- [Driver 2]
- [Driver 3]

## Considered Options

1. **[Option 1]**: [Brief description]
2. **[Option 2]**: [Brief description]
3. **[Option 3]**: [Brief description]

## Decision

[State the decision and rationale]

## Consequences

### Positive
- [Positive consequence 1]
- [Positive consequence 2]

### Negative
- [Negative consequence 1]
- [Negative consequence 2]

### Risks
- [Risk 1]: [Mitigation]

## References

- [Link to related documentation]
```

---

## Decision Status Legend

| Status | Meaning |
|--------|---------|
| **Proposed** | Under discussion, not yet approved |
| **Accepted** | Approved and in effect |
| **Deprecated** | No longer recommended, but still in use |
| **Superseded** | Replaced by a newer decision |

---

## How to Propose New Decisions

1. Create a new ADR file following the template
2. Add entry to this README
3. Submit for review
4. After approval, update status to "Accepted"
