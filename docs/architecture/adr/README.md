# Architecture Decision Records (ADR) Index

## Overview

This directory contains Architecture Decision Records (ADRs) for the DILIGO DMS project. ADRs document significant architectural decisions, their context, and rationale.

## ADR Template

Each ADR follows this structure:

```markdown
# ADR-XXX: Title

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
What is the issue that we're seeing that is motivating this decision?

## Decision
What is the change that we're proposing and/or doing?

## Consequences
What becomes easier or more difficult because of this change?

## Alternatives Considered
What other options were evaluated?
```

---

## ADR Index

| ID | Title | Status | Date |
|----|-------|--------|------|
| [ADR-001](./ADR-001-backend-framework.md) | Backend Framework Selection (.NET 8) | Accepted | 2026-02-02 |
| [ADR-002](./ADR-002-mobile-platform.md) | Mobile Platform Selection (Kotlin/Android) | Accepted | 2026-02-02 |
| [ADR-003](./ADR-003-database-selection.md) | Database Selection (SQL Server) | Accepted | 2026-02-02 |
| [ADR-004](./ADR-004-frontend-framework.md) | Frontend Framework Selection (Angular) | Accepted | 2026-02-02 |
| [ADR-005](./ADR-005-authentication-strategy.md) | Authentication Strategy (JWT) | Accepted | 2026-02-02 |
| [ADR-006](./ADR-006-offline-sync-strategy.md) | Offline Sync Strategy | Accepted | 2026-02-02 |
| [ADR-007](./ADR-007-cloud-platform.md) | Cloud Platform Selection (Azure) | Accepted | 2026-02-02 |
| [ADR-008](./ADR-008-api-design.md) | API Design (REST + SignalR) | Accepted | 2026-02-02 |

---

## Decision Categories

### Technology Stack
- ADR-001: Backend Framework
- ADR-002: Mobile Platform
- ADR-003: Database Selection
- ADR-004: Frontend Framework

### Architecture Patterns
- ADR-005: Authentication Strategy
- ADR-006: Offline Sync Strategy
- ADR-008: API Design

### Infrastructure
- ADR-007: Cloud Platform

---

## Contributing

When creating a new ADR:

1. Copy the template
2. Assign the next sequential number
3. Fill in all sections
4. Submit for review
5. Update this index when accepted

## Review Process

1. Author creates ADR with status "Proposed"
2. Tech lead reviews within 5 business days
3. Team discusses in architecture meeting
4. Status updated to "Accepted" or "Rejected"
5. Implementation can proceed
