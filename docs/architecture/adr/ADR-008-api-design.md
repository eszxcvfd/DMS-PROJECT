# ADR-008: API Design Strategy

## Status
**Accepted** - 2026-02-02

## Context

We need to design APIs for communication between:
- Mobile app ↔ Backend
- Web app ↔ Backend
- Real-time updates for location tracking and notifications

Key requirements:
- Support for offline-capable mobile app
- Real-time updates for live monitoring
- Consistent data contracts across platforms
- Versioning strategy for future updates
- Performance for batch operations

## Decision

We will implement a **hybrid API strategy**:
1. **REST API** for CRUD operations and standard requests
2. **SignalR** for real-time bidirectional communication
3. **Batch endpoints** for mobile sync operations

### API Design Principles:
- RESTful resource-oriented design
- JSON as primary data format
- URL-based versioning (`/api/v1/...`)
- OpenAPI (Swagger) specification
- Consistent error response format

## Consequences

### Positive
- **Familiar patterns**: REST is well understood by developers
- **Real-time capable**: SignalR handles live updates efficiently
- **Offline-friendly**: Batch endpoints optimize mobile sync
- **Tooling**: Swagger UI for documentation and testing
- **Cacheable**: HTTP caching for GET requests

### Negative
- **Two protocols**: Must maintain REST + SignalR
- **Over-fetching**: REST may return more data than needed
- **N+1 problem**: Related data requires multiple requests

### Mitigations
- Use field selection (`?fields=id,name`) for partial responses
- Provide dedicated aggregate endpoints for common patterns
- Include related data via query parameters (`?include=customer`)

## Alternatives Considered

### GraphQL
- **Pros**:
  - Flexible queries
  - No over-fetching
  - Single endpoint
- **Cons**:
  - Learning curve
  - Complex caching
  - Overkill for our use case
  - Less tooling in .NET
- **Decision**: Rejected for complexity

### gRPC
- **Pros**:
  - High performance
  - Strong typing
  - Bidirectional streaming
- **Cons**:
  - Browser support limited
  - Binary format less debuggable
  - Requires protobuf toolchain
- **Decision**: Consider for internal services in future

### REST + Server-Sent Events (SSE)
- **Pros**:
  - Simpler than SignalR
  - HTTP-native
- **Cons**:
  - Unidirectional only
  - No mobile SDK support as good as SignalR
- **Decision**: Rejected for bidirectional needs

## API Specifications

### Base URL Structure
```
Production:  https://api.diligo-dms.com/api/v1
Staging:     https://api-staging.diligo-dms.com/api/v1
Development: https://localhost:5001/api/v1
```

### Authentication
```http
Authorization: Bearer <access_token>
```

### Standard Response Format

**Success Response:**
```json
{
  "data": { ... },
  "meta": {
    "timestamp": "2026-02-02T10:00:00Z",
    "requestId": "abc-123"
  }
}
```

**Paginated Response:**
```json
{
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 10,
    "totalCount": 195
  },
  "meta": {
    "timestamp": "2026-02-02T10:00:00Z",
    "requestId": "abc-123"
  }
}
```

**Error Response:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "quantity",
        "message": "Quantity must be positive"
      }
    ]
  },
  "meta": {
    "timestamp": "2026-02-02T10:00:00Z",
    "requestId": "abc-123"
  }
}
```

### HTTP Status Codes

| Status | Usage |
|--------|-------|
| 200 OK | Successful GET, PUT, PATCH |
| 201 Created | Successful POST (resource created) |
| 204 No Content | Successful DELETE |
| 400 Bad Request | Validation error |
| 401 Unauthorized | Missing/invalid authentication |
| 403 Forbidden | Insufficient permissions |
| 404 Not Found | Resource doesn't exist |
| 409 Conflict | Concurrency conflict |
| 422 Unprocessable Entity | Business rule violation |
| 429 Too Many Requests | Rate limit exceeded |
| 500 Internal Server Error | Server error |

## Core API Endpoints

### Authentication
```http
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
POST /api/v1/auth/change-password
```

### Customers
```http
GET    /api/v1/customers              # List (paginated, filterable)
GET    /api/v1/customers/{id}         # Get by ID
POST   /api/v1/customers              # Create
PUT    /api/v1/customers/{id}         # Update
DELETE /api/v1/customers/{id}         # Soft delete
GET    /api/v1/customers/{id}/visits  # Customer visits
GET    /api/v1/customers/{id}/orders  # Customer orders
POST   /api/v1/customers/search       # Advanced search
```

### Orders
```http
GET    /api/v1/orders                 # List (paginated, filterable)
GET    /api/v1/orders/{id}            # Get by ID with lines
POST   /api/v1/orders                 # Create
PUT    /api/v1/orders/{id}            # Update (pending only)
POST   /api/v1/orders/{id}/approve    # Approve order
POST   /api/v1/orders/{id}/reject     # Reject order
```

### Visits
```http
GET    /api/v1/visits                 # List visits
POST   /api/v1/visits/check-in        # Start visit
POST   /api/v1/visits/{id}/check-out  # End visit
POST   /api/v1/visits/{id}/photos     # Upload photos
GET    /api/v1/visits/{id}/photos     # Get photos
```

### Locations (Real-time tracking)
```http
POST   /api/v1/locations              # Report locations (batch)
GET    /api/v1/locations/current      # Current locations of team
GET    /api/v1/locations/history/{userId}  # User location history
```

### Sync (Mobile batch operations)
```http
POST   /api/v1/sync/upload            # Batch upload orders, visits
GET    /api/v1/sync/master-data       # Get master data updates
POST   /api/v1/sync/photos            # Batch photo upload
GET    /api/v1/sync/status            # Sync status check
```

## Mobile Batch Sync Endpoint

### Upload Request
```http
POST /api/v1/sync/upload
Content-Type: application/json

{
  "deviceId": "device-uuid",
  "syncId": "sync-batch-uuid",
  "timestamp": "2026-02-02T10:00:00Z",
  "orders": [
    {
      "localId": "local-uuid-1",
      "customerId": "customer-uuid",
      "orderDate": "2026-02-02T09:00:00Z",
      "lines": [...]
    }
  ],
  "visits": [
    {
      "localId": "local-uuid-2",
      "customerId": "customer-uuid",
      "checkInTime": "2026-02-02T08:30:00Z",
      "checkInLatitude": 10.762622,
      "checkInLongitude": 106.660172
    }
  ],
  "locations": [
    {
      "latitude": 10.762622,
      "longitude": 106.660172,
      "recordedAt": "2026-02-02T09:15:00Z"
    }
  ]
}
```

### Upload Response
```json
{
  "syncId": "sync-batch-uuid",
  "results": {
    "orders": [
      { "localId": "local-uuid-1", "serverId": "server-uuid-1", "status": "created" }
    ],
    "visits": [
      { "localId": "local-uuid-2", "serverId": "server-uuid-2", "status": "created" }
    ],
    "locations": { "received": 5, "stored": 5 }
  },
  "errors": []
}
```

### Master Data Download
```http
GET /api/v1/sync/master-data?since=2026-02-01T00:00:00Z

Response:
{
  "syncTimestamp": "2026-02-02T10:00:00Z",
  "products": {
    "updated": [...],
    "deleted": ["id1", "id2"]
  },
  "customers": {
    "updated": [...],
    "deleted": []
  },
  "promotions": {
    "updated": [...],
    "deleted": []
  }
}
```

## SignalR Hubs

### DMS Hub (`/hubs/dms`)

**Server → Client Events:**
```typescript
interface IDmsHubClient {
  // Location updates
  LocationUpdated(location: LocationDto): void;
  LocationsUpdated(locations: LocationDto[]): void;

  // Order events
  OrderCreated(order: OrderSummaryDto): void;
  OrderStatusChanged(update: OrderStatusDto): void;

  // Visit events
  VisitStarted(visit: VisitSummaryDto): void;
  VisitCompleted(visit: VisitSummaryDto): void;

  // Notifications
  NotificationReceived(notification: NotificationDto): void;

  // Alerts
  AlertReceived(alert: AlertDto): void;
}
```

**Client → Server Methods:**
```typescript
interface IDmsHub {
  // Subscribe to updates
  JoinDistributorGroup(distributorId: string): Promise<void>;
  LeaveDistributorGroup(distributorId: string): Promise<void>;
  JoinUserUpdates(userId: string): Promise<void>;

  // Real-time location (alternative to REST batch)
  ReportLocation(location: LocationDto): Promise<void>;
}
```

### Connection Groups
```
distributor:{distributorId}     - All users in a distributor
supervisor:{supervisorId}       - Supervisor's team
user:{userId}                   - Individual user notifications
```

## API Versioning Strategy

### URL Versioning
```
/api/v1/customers
/api/v2/customers  (future)
```

### Version Lifecycle
1. **Active**: Current recommended version
2. **Deprecated**: Supported but discouraged (6-month warning)
3. **Retired**: No longer available

### Breaking Changes (require new version)
- Removing endpoints or fields
- Changing field types
- Changing authentication method
- Changing response structure

### Non-breaking Changes (same version)
- Adding optional fields
- Adding new endpoints
- Adding new optional query parameters
- Performance improvements

## References

- [REST API Design Best Practices](https://docs.microsoft.com/en-us/azure/architecture/best-practices/api-design)
- [ASP.NET Core SignalR](https://docs.microsoft.com/en-us/aspnet/core/signalr/introduction)
- [OpenAPI Specification](https://swagger.io/specification/)
