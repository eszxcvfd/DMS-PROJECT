# DMS VIPPro - API Design

## Distribution Management System - REST API Specification

**Version:** 2.0
**Last Updated:** 2026-02-04
**PRD Reference:** PRD-v2.md (v2.3)
**Base URL:** `https://VIPPro-dms-api.azurewebsites.net/api`

---

## 1. Overview

This document describes the REST API design for DMS VIPPro, including endpoints, request/response formats, and authentication requirements.

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
      "name": "Sữa tắm VIPPro 500ml",
      "brand": "VIPPro",
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

#### Create Order (Pre-sales / Van-sales)

```http
POST /api/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "customerId": "770e8400-e29b-41d4-a716-446655440002",
  "visitId": "aa0e8400-e29b-41d4-a716-446655440005",
  "orderType": "PreSales",  // "PreSales" (default) | "VanSales" [v2.0]
  "vanSaleWarehouseId": null,  // [v2.0] Required if orderType = "VanSales"
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

// Van-sales example [v2.0]
{
  "customerId": "770e8400-e29b-41d4-a716-446655440002",
  "visitId": "aa0e8400-e29b-41d4-a716-446655440005",
  "orderType": "VanSales",
  "vanSaleWarehouseId": "wh0e8400-e29b-41d4-a716-446655440010",
  "items": [...],
  "paymentMethod": "Cash",  // [v2.0] "Cash", "Credit", "Transfer"
  "amountPaid": 5000000     // [v2.0] Actual payment collected
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
  "orderType": "PreSales",
  "status": "Pending",
  "items": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "productCode": "SP001",
      "productName": "Sữa tắm VIPPro 500ml",
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
  "totalAmount": 6820000,
  "vanSaleWarehouseId": null
}

// Van-sales Response [v2.0] - Status = "Delivered" immediately
{
  "orderId": "cc0e8400-e29b-41d4-a716-446655440008",
  "orderNumber": "VS-20260202-001",
  "orderType": "VanSales",
  "status": "Delivered",
  "vanSaleWarehouseId": "wh0e8400-e29b-41d4-a716-446655440010",
  "paymentInfo": {
    "method": "Cash",
    "totalAmount": 6820000,
    "amountPaid": 5000000,
    "remainingBalance": 1820000
  },
  "stockDeducted": true,
  ...
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
wss://VIPPro-dms-api.azurewebsites.net/hubs/monitoring?access_token={token}
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

### 3.9 Distributors API [v2.0 - GSBH Mobile]

> Cho phép GSBH tạo mới và quản lý NPP (Mở mới NPP)

#### List Distributors

```http
GET /api/distributors
Authorization: Bearer {token}

Query Parameters:
- page (int): Page number
- pageSize (int): Items per page
- search (string): Search by name or code
- status (string): Active/Inactive/Pending
- region (string): Filter by region
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "distributorId": "660e8400-e29b-41d4-a716-446655440001",
      "distributorCode": "NPP-SGN-001",
      "name": "NPP Sài Gòn",
      "ownerName": "Nguyễn Văn A",
      "phone": "0901234567",
      "email": "npp.saigon@example.com",
      "address": "123 Nguyễn Huệ, Q1, TP.HCM",
      "taxCode": "0123456789",
      "region": "Miền Nam",
      "status": "Active",
      "createdAt": "2026-01-15T00:00:00Z",
      "photoCount": 5
    }
  ],
  "pagination": {...}
}
```

#### Get Distributor by ID

```http
GET /api/distributors/{distributorId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "distributorId": "660e8400-e29b-41d4-a716-446655440001",
  "distributorCode": "NPP-SGN-001",
  "name": "NPP Sài Gòn",
  "ownerName": "Nguyễn Văn A",
  "phone": "0901234567",
  "email": "npp.saigon@example.com",
  "address": "123 Nguyễn Huệ, Q1, TP.HCM",
  "taxCode": "0123456789",
  "bankAccount": "1234567890",
  "bankName": "Vietcombank",
  "region": "Miền Nam",
  "latitude": 10.7769,
  "longitude": 106.7009,
  "status": "Active",
  "notes": "NPP lớn, uy tín",
  "photos": [
    {
      "photoId": "ph001",
      "photoType": "StoreFront",
      "imageUrl": "https://storage.blob.core.windows.net/distributors/...",
      "capturedAt": "2026-01-15T09:00:00Z"
    },
    {
      "photoId": "ph002",
      "photoType": "OwnerPhoto",
      "imageUrl": "..."
    },
    {
      "photoId": "ph003",
      "photoType": "MeetingPhoto",
      "imageUrl": "..."
    },
    {
      "photoId": "ph004",
      "photoType": "BusinessLicense",
      "imageUrl": "..."
    }
  ],
  "createdBy": "user-gsbh-001",
  "createdAt": "2026-01-15T00:00:00Z"
}
```

#### Create Distributor (Mở mới NPP)

```http
POST /api/distributors
Authorization: Bearer {token}
Content-Type: application/json

{
  "distributorCode": "NPP-SGN-002",
  "name": "NPP Bình Dương",
  "ownerName": "Trần Thị B",
  "phone": "0909876543",
  "email": "npp.binhduong@example.com",
  "address": "456 Đại lộ Bình Dương, TX. Thủ Dầu Một",
  "taxCode": "0987654321",
  "bankAccount": "9876543210",
  "bankName": "Techcombank",
  "region": "Miền Nam",
  "latitude": 10.9804,
  "longitude": 106.6519,
  "notes": "NPP mới, cần theo dõi"
}
```

**Response (201 Created):**
```json
{
  "distributorId": "660e8400-e29b-41d4-a716-446655440002",
  "distributorCode": "NPP-SGN-002",
  "status": "Pending",
  "message": "Distributor created successfully. Awaiting approval."
}
```

#### Upload Distributor Photo

```http
POST /api/distributors/{distributorId}/photos
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- photo: (file) Image file
- photoType: "StoreFront" | "OwnerPhoto" | "MeetingPhoto" | "BusinessLicense" | "TaxCertificate" | "Contract"
- latitude: 10.9804
- longitude: 106.6519
- notes: "Ảnh chụp mặt tiền cửa hàng"
```

**Response (201 Created):**
```json
{
  "photoId": "ph005",
  "photoType": "StoreFront",
  "imageUrl": "https://storage.blob.core.windows.net/distributors/2026/02/02/{distributorId}/ph005.jpg",
  "thumbnailUrl": "https://storage.blob.core.windows.net/distributors/2026/02/02/{distributorId}/ph005_thumb.jpg",
  "capturedAt": "2026-02-02T10:30:00Z"
}
```

#### Update Distributor

```http
PATCH /api/distributors/{distributorId}
Authorization: Bearer {token}
Content-Type: application/json

{
  "phone": "0901111111",
  "address": "789 Đường mới, Q2, TP.HCM",
  "notes": "Đã cập nhật thông tin liên hệ"
}
```

---

### 3.10 Routes Management API [v2.0 - GSBH Mobile]

> Quản lý tuyến bán hàng và phân khách hàng vào tuyến

#### List All Routes

```http
GET /api/routes
Authorization: Bearer {token}

Query Parameters:
- distributorId (guid): Filter by distributor
- dayOfWeek (int): 0=Sunday, 1=Monday, ...
- userId (guid): Filter by assigned user
- status (string): Active/Inactive
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "routeId": "990e8400-e29b-41d4-a716-446655440004",
      "routeCode": "T01-MON",
      "routeName": "Tuyến 1 - Thứ 2",
      "dayOfWeek": 1,
      "assignedUserId": "550e8400-e29b-41d4-a716-446655440000",
      "assignedUserName": "Nguyễn Văn A",
      "customerCount": 25,
      "status": "Active"
    }
  ]
}
```

#### Get Route by ID

```http
GET /api/routes/{routeId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "routeId": "990e8400-e29b-41d4-a716-446655440004",
  "routeCode": "T01-MON",
  "routeName": "Tuyến 1 - Thứ 2",
  "dayOfWeek": 1,
  "assignedUserId": "550e8400-e29b-41d4-a716-446655440000",
  "assignedUserName": "Nguyễn Văn A",
  "customers": [
    {
      "customerId": "770e8400-e29b-41d4-a716-446655440002",
      "customerCode": "KH001",
      "name": "Cửa hàng Minh Tâm",
      "visitOrder": 1,
      "address": "123 Nguyen Hue, Q1, TP.HCM"
    }
  ],
  "status": "Active"
}
```

#### Create Route

```http
POST /api/routes
Authorization: Bearer {token}
Content-Type: application/json

{
  "routeCode": "T03-WED",
  "routeName": "Tuyến 3 - Thứ 4",
  "dayOfWeek": 3,
  "assignedUserId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (201 Created):**
```json
{
  "routeId": "990e8400-e29b-41d4-a716-446655440010",
  "routeCode": "T03-WED",
  "routeName": "Tuyến 3 - Thứ 4",
  "status": "Active"
}
```

#### Update Route

```http
PUT /api/routes/{routeId}
Authorization: Bearer {token}
Content-Type: application/json

{
  "routeName": "Tuyến 3 - Thứ 4 (Cập nhật)",
  "assignedUserId": "550e8400-e29b-41d4-a716-446655440001"
}
```

#### Add Customers to Route

```http
POST /api/routes/{routeId}/customers
Authorization: Bearer {token}
Content-Type: application/json

{
  "customers": [
    {
      "customerId": "770e8400-e29b-41d4-a716-446655440002",
      "visitOrder": 1
    },
    {
      "customerId": "770e8400-e29b-41d4-a716-446655440003",
      "visitOrder": 2
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "routeId": "990e8400-e29b-41d4-a716-446655440010",
  "addedCount": 2,
  "totalCustomers": 5
}
```

#### Update Route Customer Order

```http
PATCH /api/routes/{routeId}/customers
Authorization: Bearer {token}
Content-Type: application/json

{
  "customers": [
    { "customerId": "...", "visitOrder": 1 },
    { "customerId": "...", "visitOrder": 2 }
  ]
}
```

#### Remove Customer from Route

```http
DELETE /api/routes/{routeId}/customers/{customerId}
Authorization: Bearer {token}
```

#### Import Routes from Excel

```http
POST /api/routes/import
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
- file: (file) Excel file (.xlsx)
- distributorId: guid
- overwrite: boolean (default: false)
```

**Response (200 OK):**
```json
{
  "success": true,
  "imported": {
    "routes": 5,
    "customers": 125
  },
  "errors": [
    {
      "row": 15,
      "error": "Customer code 'KH999' not found"
    }
  ]
}
```

**Excel Template Structure:**

| RouteCode | RouteName | DayOfWeek | CustomerCode | VisitOrder | AssignedUsername |
|-----------|-----------|-----------|--------------|------------|------------------|
| T01-MON   | Tuyến 1   | 1         | KH001        | 1          | nvbh001          |
| T01-MON   | Tuyến 1   | 1         | KH002        | 2          | nvbh001          |

---

### 3.11 KPI Assignment API [v2.0 - GSBH Mobile]

> Chia chỉ tiêu KPI cho nhân viên

#### List KPI Targets

```http
GET /api/kpi/targets
Authorization: Bearer {token}

Query Parameters:
- distributorId (guid): Filter by distributor
- userId (guid): Filter by user
- month (date): Target month (YYYY-MM-01)
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "kpiTargetId": "kpi001",
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "userName": "Nguyễn Văn A",
      "targetMonth": "2026-02-01",
      "visitTarget": 200,
      "newCustomerTarget": 10,
      "orderTarget": 150,
      "revenueTarget": 500000000,
      "netRevenueTarget": 450000000,
      "volumeTarget": 1000,
      "skuTarget": 50,
      "workingHoursTarget": 176,
      "productTargets": [
        {
          "productId": "880e8400-e29b-41d4-a716-446655440003",
          "productName": "Sữa tắm VIPPro 500ml",
          "quantityTarget": 100,
          "revenueTarget": 50000000
        }
      ],
      "effectiveFrom": "2026-02-01",
      "effectiveTo": "2026-02-28"
    }
  ]
}
```

#### Get KPI Target by ID

```http
GET /api/kpi/targets/{kpiTargetId}
Authorization: Bearer {token}
```

#### Create KPI Target (Chia KPI)

```http
POST /api/kpi/targets
Authorization: Bearer {token}
Content-Type: application/json

{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "targetMonth": "2026-02-01",
  "visitTarget": 200,
  "newCustomerTarget": 10,
  "orderTarget": 150,
  "revenueTarget": 500000000,
  "netRevenueTarget": 450000000,
  "volumeTarget": 1000,
  "skuTarget": 50,
  "workingHoursTarget": 176,
  "effectiveFrom": "2026-02-01",
  "effectiveTo": "2026-02-28"
}
```

**Response (201 Created):**
```json
{
  "kpiTargetId": "kpi002",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "targetMonth": "2026-02-01",
  "message": "KPI targets assigned successfully"
}
```

#### Add Product KPI Targets

```http
POST /api/kpi/targets/{kpiTargetId}/products
Authorization: Bearer {token}
Content-Type: application/json

{
  "products": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "quantityTarget": 100,
      "revenueTarget": 50000000
    },
    {
      "productId": "880e8400-e29b-41d4-a716-446655440004",
      "quantityTarget": 200
    }
  ]
}
```

#### Update KPI Target

```http
PUT /api/kpi/targets/{kpiTargetId}
Authorization: Bearer {token}
Content-Type: application/json

{
  "visitTarget": 220,
  "orderTarget": 160
}
```

#### Get KPI Performance

```http
GET /api/kpi/performance/{userId}
Authorization: Bearer {token}

Query Parameters:
- month (date): Target month (YYYY-MM-01)
```

**Response (200 OK):**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "userName": "Nguyễn Văn A",
  "targetMonth": "2026-02-01",
  "kpis": {
    "visits": {
      "target": 200,
      "actual": 85,
      "achievement": 42.5,
      "trend": "on_track"
    },
    "newCustomers": {
      "target": 10,
      "actual": 3,
      "achievement": 30.0,
      "trend": "behind"
    },
    "orders": {
      "target": 150,
      "actual": 62,
      "achievement": 41.3,
      "trend": "on_track"
    },
    "revenue": {
      "target": 500000000,
      "actual": 185000000,
      "achievement": 37.0,
      "trend": "behind"
    },
    "netRevenue": {
      "target": 450000000,
      "actual": 166500000,
      "achievement": 37.0
    },
    "volume": {
      "target": 1000,
      "actual": 420,
      "achievement": 42.0
    },
    "sku": {
      "target": 50,
      "actual": 35,
      "achievement": 70.0,
      "trend": "ahead"
    },
    "workingHours": {
      "target": 176,
      "actual": 72,
      "achievement": 40.9
    }
  },
  "productKpis": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "productName": "Sữa tắm VIPPro 500ml",
      "quantityTarget": 100,
      "quantityActual": 45,
      "achievement": 45.0
    }
  ],
  "asOfDate": "2026-02-10T23:59:59Z"
}
```

---

### 3.12 Display Scoring API [v2.0]

> Chấm điểm hình ảnh trưng bày VIP

#### List Display Scores

```http
GET /api/display-scores
Authorization: Bearer {token}

Query Parameters:
- distributorId (guid): Filter by distributor
- customerId (guid): Filter by customer
- capturedByUserId (guid): Filter by photographer (NVBH)
- scoredByUserId (guid): Filter by scorer
- isPending (boolean): true = chưa chấm, false = đã chấm
- fromDate (date): Start date
- toDate (date): End date
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "scoreId": "sc001",
      "visitId": "aa0e8400-e29b-41d4-a716-446655440005",
      "customerId": "770e8400-e29b-41d4-a716-446655440002",
      "customerName": "Cửa hàng Minh Tâm",
      "capturedByUserId": "550e8400-e29b-41d4-a716-446655440000",
      "capturedByUserName": "Nguyễn Văn A",
      "photoCount": 3,
      "uploadDate": "2026-02-02",
      "scoredByUserId": null,
      "scoredDate": null,
      "isPassed": null,
      "revenue": null,
      "photos": [
        {
          "photoId": "ph010",
          "imageUrl": "...",
          "thumbnailUrl": "..."
        }
      ]
    }
  ],
  "pagination": {...},
  "summary": {
    "totalPending": 15,
    "totalScored": 42,
    "passRate": 78.5
  }
}
```

#### Get Display Score Detail

```http
GET /api/display-scores/{scoreId}
Authorization: Bearer {token}
```

#### Score Display Photos (Chấm điểm)

```http
POST /api/display-scores/{scoreId}/score
Authorization: Bearer {token}
Content-Type: application/json

{
  "isPassed": true,
  "revenue": 15000000,
  "notes": "Trưng bày đạt chuẩn, vị trí tốt"
}
```

**Response (200 OK):**
```json
{
  "scoreId": "sc001",
  "scoredByUserId": "user-gsbh-001",
  "scoredDate": "2026-02-03",
  "isPassed": true,
  "message": "Display score recorded successfully"
}
```

#### Bulk Score Display Photos

```http
POST /api/display-scores/bulk-score
Authorization: Bearer {token}
Content-Type: application/json

{
  "scores": [
    {
      "scoreId": "sc001",
      "isPassed": true,
      "revenue": 15000000
    },
    {
      "scoreId": "sc002",
      "isPassed": false,
      "notes": "Không đạt - hình ảnh mờ"
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "processed": 2,
  "success": 2,
  "failed": 0
}
```

---

### 3.13 Inventory Transfer API [v2.0]

> Quản lý chuyển kho, đặc biệt cho Van-sale

#### List Warehouses

```http
GET /api/warehouses
Authorization: Bearer {token}

Query Parameters:
- distributorId (guid): Filter by distributor
- warehouseType (string): "Main" | "VanSale"
- assignedUserId (guid): Filter Van-sale warehouse by user
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "warehouseId": "wh001",
      "warehouseCode": "WH-MAIN-001",
      "name": "Kho chính NPP Sài Gòn",
      "warehouseType": "Main",
      "assignedUserId": null,
      "address": "123 Nguyễn Huệ, Q1",
      "status": "Active"
    },
    {
      "warehouseId": "wh002",
      "warehouseCode": "WH-VAN-001",
      "name": "Kho xe Nguyễn Văn A",
      "warehouseType": "VanSale",
      "assignedUserId": "550e8400-e29b-41d4-a716-446655440000",
      "assignedUserName": "Nguyễn Văn A",
      "status": "Active"
    }
  ]
}
```

#### Get Van-sale Stock

```http
GET /api/warehouses/{warehouseId}/stock
Authorization: Bearer {token}

Query Parameters:
- search (string): Search product name/code
- lowStock (boolean): Only show low stock items
```

**Response (200 OK):**
```json
{
  "warehouseId": "wh002",
  "warehouseName": "Kho xe Nguyễn Văn A",
  "products": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "productCode": "SP001",
      "productName": "Sữa tắm VIPPro 500ml",
      "quantity": 50,
      "reservedQuantity": 5,
      "availableQuantity": 45,
      "lastUpdated": "2026-02-02T08:00:00Z"
    }
  ],
  "totalProducts": 25,
  "totalQuantity": 500
}
```

#### Create Stock Transfer (Chuyển kho)

```http
POST /api/inventory/transfers
Authorization: Bearer {token}
Content-Type: application/json

{
  "sourceWarehouseId": "wh001",
  "destinationWarehouseId": "wh002",
  "transferType": "MainToVan",  // "MainToVan" | "VanToMain" | "MainToMain"
  "items": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "quantity": 100
    },
    {
      "productId": "880e8400-e29b-41d4-a716-446655440004",
      "quantity": 50
    }
  ],
  "notes": "Cấp hàng đầu tuần cho NVBH"
}
```

**Response (201 Created):**
```json
{
  "transferId": "tr001",
  "transferNumber": "CK-20260202-001",
  "sourceWarehouse": "Kho chính NPP Sài Gòn",
  "destinationWarehouse": "Kho xe Nguyễn Văn A",
  "status": "Completed",
  "items": [
    {
      "productId": "880e8400-e29b-41d4-a716-446655440003",
      "productName": "Sữa tắm VIPPro 500ml",
      "quantity": 100,
      "previousStock": 500,
      "newStock": 400
    }
  ],
  "totalItems": 2,
  "createdAt": "2026-02-02T07:30:00Z"
}
```

#### List Stock Transfers

```http
GET /api/inventory/transfers
Authorization: Bearer {token}

Query Parameters:
- warehouseId (guid): Source or destination warehouse
- transferType (string): Filter by type
- fromDate (date): Start date
- toDate (date): End date
```

#### Get Transfer by ID

```http
GET /api/inventory/transfers/{transferId}
Authorization: Bearer {token}
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
