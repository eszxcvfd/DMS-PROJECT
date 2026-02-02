# DILIGO DMS - API Design

## Distribution Management System - REST API Specification

**Version:** 1.0
**Last Updated:** 2026-02-02
**Base URL:** `https://diligo-dms-api.azurewebsites.net/api`

---

## 1. Overview

This document describes the REST API design for DILIGO DMS, including endpoints, request/response formats, and authentication requirements.

### API Principles

| Principle | Implementation |
|-----------|----------------|
| **RESTful** | Resource-based URLs, HTTP methods |
| **JSON** | Request/response bodies in JSON |
| **Versioning** | URL path versioning (`/api/v1/`) |
| **Authentication** | JWT Bearer tokens |
| **Pagination** | Cursor-based for large datasets |
| **Error Handling** | Consistent error response format |

---

## 2. Authentication

### 2.1 Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "nvbh001",
  "password": "********"
}
```

**Response (200 OK):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4=",
  "expiresIn": 86400,
  "tokenType": "Bearer",
  "user": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "username": "nvbh001",
    "fullName": "Nguyen Van A",
    "role": "NVBH",
    "distributorId": "660e8400-e29b-41d4-a716-446655440001",
    "distributorName": "NPP Sai Gon"
  }
}
```

### 2.2 Refresh Token

```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4="
}
```

### 2.3 Logout

```http
POST /api/auth/logout
Authorization: Bearer {accessToken}

{
  "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4="
}
```

### 2.4 Using Access Token

All authenticated endpoints require:
```http
Authorization: Bearer {accessToken}
```

---

## 3. API Endpoints

### 3.1 Customers

#### List Customers

```http
GET /api/customers
Authorization: Bearer {token}

Query Parameters:
- page (int): Page number (default: 1)
- pageSize (int): Items per page (default: 20, max: 100)
- search (string): Search by name or code
- customerGroup (string): Filter by group (A/B/C/D/E)
- customerType (string): Filter by type
- routeId (guid): Filter by route
- status (string): Filter by status (Active/Inactive)
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "customerId": "770e8400-e29b-41d4-a716-446655440002",
      "customerCode": "KH001",
      "name": "Cửa hàng Minh Tâm",
      "phone": "0901234567",
      "contactPerson": "Nguyen Van B",
      "customerGroup": "A",
      "customerType": "TapHoa",
      "channel": "GT",
      "latitude": 10.7769,
      "longitude": 106.7009,
      "address": "123 Nguyen Hue, Q1, TP.HCM",
      "creditLimit": 50000000,
      "currentBalance": 12500000,
      "status": "Active"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "pageSize": 20,
    "totalItems": 156,
    "totalPages": 8
  }
}
```

#### Get Customer by ID

```http
GET /api/customers/{customerId}
Authorization: Bearer {token}
```

#### Create Customer

```http
POST /api/customers
Authorization: Bearer {token}
Content-Type: application/json

{
  "customerCode": "KH002",
  "name": "Cửa hàng ABC",
  "phone": "0909876543",
  "contactPerson": "Tran Thi C",
  "customerGroup": "B",
  "customerType": "HieuThuoc",
  "channel": "GT",
  "latitude": 10.7890,
  "longitude": 106.7123,
  "address": "456 Le Loi, Q1, TP.HCM",
  "creditLimit": 30000000
}
```

#### Update Customer

```http
PUT /api/customers/{customerId}
Authorization: Bearer {token}
Content-Type: application/json
```

### 3.2 Products

#### List Products

```http
GET /api/products
Authorization: Bearer {token}

Query Parameters:
- search (string): Search by name or code
- brand (string): Filter by brand
- category (string): Filter by category
- status (string): Active/Inactive
```

**Response:**
```json
{
  "data": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "productCode": "SP001",
      "name": "Sữa tắm Diligo 500ml",
      "brand": "Diligo",
      "category": "ChămSócCáNhân",
      "unitName": "Thùng",
      "subUnitName": "Chai",
      "conversionRate": 24,
      "sellingPrice": 1200000,
      "sellingPriceSub": 55000,
      "vat": 10,
      "imageUrl": "https://storage.blob.core.windows.net/products/SP001.jpg",
      "stockQuantity": 150,
      "status": "Active"
    }
  ]
}
```

### 3.3 Routes

#### Get Today's Route

```http
GET /api/routes/today
Authorization: Bearer {token}
```

**Response:**
```json
{
  "route": {
    "routeId": "990e8400-e29b-41d4-a716-446655440004",
    "routeCode": "T01-MON",
    "routeName": "Tuyến 1 - Thứ 2",
    "dayOfWeek": 1
  },
  "customers": [
    {
      "customerId": "770e8400-e29b-41d4-a716-446655440002",
      "customerCode": "KH001",
      "name": "Cửa hàng Minh Tâm",
      "visitOrder": 1,
      "latitude": 10.7769,
      "longitude": 106.7009,
      "address": "123 Nguyen Hue, Q1, TP.HCM",
      "lastVisitDate": "2026-01-30",
      "lastOrderDate": "2026-01-30",
      "currentBalance": 12500000
    }
  ],
  "summary": {
    "totalCustomers": 25,
    "visitedToday": 0,
    "ordersToday": 0
  }
}
```

### 3.4 Visits

#### Check-In

```http
POST /api/visits/check-in
Authorization: Bearer {token}
Content-Type: application/json

{
  "customerId": "770e8400-e29b-41d4-a716-446655440002",
  "latitude": 10.7770,
  "longitude": 106.7010,
  "visitType": "InRoute"
}
```

**Response (201 Created):**
```json
{
  "visitId": "aa0e8400-e29b-41d4-a716-446655440005",
  "customerId": "770e8400-e29b-41d4-a716-446655440002",
  "checkInTime": "2026-02-02T09:15:00Z",
  "checkInDistance": 15,
  "distanceWarning": false
}
```

#### Check-Out

```http
POST /api/visits/{visitId}/check-out
Authorization: Bearer {token}
Content-Type: application/json

{
  "latitude": 10.7770,
  "longitude": 106.7010,
  "visitResult": "HasOrder",
  "notes": "Đã đặt hàng 5 thùng sữa tắm"
}
```

#### Upload Visit Photo

```http
POST /api/visits/{visitId}/photos
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- photo: (file) Image file
- albumType: "TrungBay" | "MatTien" | "POSM"
- latitude: 10.7770
- longitude: 106.7010
```

**Response:**
```json
{
  "photoId": "bb0e8400-e29b-41d4-a716-446655440006",
  "imageUrl": "https://storage.blob.core.windows.net/visits/2026/02/02/{visitId}/{photoId}.jpg",
  "thumbnailUrl": "https://storage.blob.core.windows.net/visits/2026/02/02/{visitId}/{photoId}_thumb.jpg",
  "albumType": "TrungBay",
  "capturedAt": "2026-02-02T09:20:00Z"
}
```

### 3.5 Orders

#### Create Order

```http
POST /api/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "customerId": "770e8400-e29b-41d4-a716-446655440002",
  "visitId": "aa0e8400-e29b-41d4-a716-446655440005",
  "items": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "quantity": 5,
      "unitType": "Main"
    },
    {
      "productId": "880e8400-e29b-41d4-a716-446655440004",
      "quantity": 10,
      "unitType": "Sub"
    }
  ],
  "notes": "Giao trước 10h sáng"
}
```

**Response (201 Created):**
```json
{
  "orderId": "cc0e8400-e29b-41d4-a716-446655440007",
  "orderNumber": "DH-20260202-001",
  "customerId": "770e8400-e29b-41d4-a716-446655440002",
  "customerName": "Cửa hàng Minh Tâm",
  "orderDate": "2026-02-02T09:25:00Z",
  "status": "Pending",
  "items": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "productCode": "SP001",
      "productName": "Sữa tắm Diligo 500ml",
      "quantity": 5,
      "unitType": "Main",
      "unitPrice": 1200000,
      "discountPercent": 5,
      "discountAmount": 300000,
      "lineTotal": 5700000
    }
  ],
  "subTotal": 6500000,
  "discountAmount": 300000,
  "taxAmount": 620000,
  "totalAmount": 6820000
}
```

#### List Orders

```http
GET /api/orders
Authorization: Bearer {token}

Query Parameters:
- status (string): Pending/Approved/Rejected/Delivered
- fromDate (date): Start date
- toDate (date): End date
- customerId (guid): Filter by customer
```

#### Approve Order

```http
POST /api/orders/{orderId}/approve
Authorization: Bearer {token}
```

#### Reject Order

```http
POST /api/orders/{orderId}/reject
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "Hết hàng sản phẩm SP001"
}
```

### 3.6 Attendance

#### Clock In

```http
POST /api/attendance/clock-in
Authorization: Bearer {token}
Content-Type: application/json

{
  "latitude": 10.7769,
  "longitude": 106.7009
}
```

**Response:**
```json
{
  "attendanceId": "dd0e8400-e29b-41d4-a716-446655440008",
  "attendanceDate": "2026-02-02",
  "clockInTime": "2026-02-02T08:00:00Z",
  "clockInLocation": {
    "latitude": 10.7769,
    "longitude": 106.7009
  }
}
```

#### Clock Out

```http
POST /api/attendance/clock-out
Authorization: Bearer {token}
Content-Type: application/json

{
  "latitude": 10.7890,
  "longitude": 106.7123
}
```

### 3.7 Sync API

#### Delta Sync (Download)

```http
GET /api/sync/delta
Authorization: Bearer {token}

Query Parameters:
- since (datetime): Last sync timestamp (ISO 8601)
```

**Response:**
```json
{
  "serverTime": "2026-02-02T10:00:00Z",
  "customers": {
    "updated": [...],
    "deleted": ["guid1", "guid2"]
  },
  "products": {
    "updated": [...],
    "deleted": []
  },
  "routes": {
    "updated": [...],
    "deleted": []
  },
  "promotions": {
    "updated": [...],
    "deleted": []
  }
}
```

#### Upload Sync

```http
POST /api/sync/upload
Authorization: Bearer {token}
Content-Type: application/json

{
  "visits": [...],
  "orders": [...],
  "photos": [...],
  "locationHistory": [...]
}
```

**Response:**
```json
{
  "success": true,
  "visitMappings": {
    "local-id-1": "server-guid-1",
    "local-id-2": "server-guid-2"
  },
  "orderMappings": {...},
  "conflicts": [
    {
      "entityType": "Order",
      "localId": "local-id-3",
      "serverId": "server-guid-3",
      "resolution": "ServerWins",
      "serverVersion": {...}
    }
  ]
}
```

### 3.8 Monitoring (SignalR Hub)

#### Hub URL

```
wss://diligo-dms-api.azurewebsites.net/hubs/monitoring?access_token={token}
```

#### Subscribe to Location Updates

```javascript
// Client subscribes to location updates for their team
connection.invoke("JoinGroup", `Location_${distributorId}`);

// Receive location updates
connection.on("LocationUpdate", (data) => {
  // data: { userId, userName, latitude, longitude, timestamp, isMoving }
});
```

#### Subscribe to Order Notifications

```javascript
connection.invoke("JoinGroup", `Orders_${distributorId}`);

connection.on("NewOrder", (data) => {
  // data: { orderId, orderNumber, customerName, totalAmount }
});

connection.on("OrderStatusChanged", (data) => {
  // data: { orderId, orderNumber, oldStatus, newStatus }
});
```

---

## 4. Error Handling

### Standard Error Response

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Bad Request",
  "status": 400,
  "detail": "One or more validation errors occurred.",
  "traceId": "00-abc123-def456-00",
  "errors": {
    "CustomerCode": ["Customer code is required"],
    "Phone": ["Phone number format is invalid"]
  }
}
```

### HTTP Status Codes

| Code | Meaning | Use Case |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST (resource created) |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation errors |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate or constraint violation |
| 422 | Unprocessable Entity | Business rule violation |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

---

## 5. Rate Limiting

| Endpoint | Limit |
|----------|-------|
| `/api/auth/login` | 5 requests/minute per IP |
| `/api/sync/*` | 10 requests/minute per user |
| All other endpoints | 100 requests/minute per user |

**Rate Limit Headers:**
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1738454460
```

---

## 6. Versioning

API versioning via URL path:
```
/api/v1/customers
/api/v2/customers (future)
```

Deprecation header for old versions:
```http
Deprecation: true
Sunset: 2027-01-01
Link: </api/v2/customers>; rel="successor-version"
```

---

## 7. OpenAPI Specification

Full OpenAPI 3.0 specification available at:
```
GET /swagger/v1/swagger.json
```

Swagger UI:
```
GET /swagger
```

---

## 8. Related Documents

- [03-COMPONENT-ARCHITECTURE.md](03-COMPONENT-ARCHITECTURE.md) - Controller details
- [04-DATA-ARCHITECTURE.md](04-DATA-ARCHITECTURE.md) - Data models
- [07-SECURITY-ARCHITECTURE.md](07-SECURITY-ARCHITECTURE.md) - Authentication details
