# DILIGO DMS - Data Architecture

## Distribution Management System - Database Design

**Version:** 1.1
**Last Updated:** 2026-02-03

---

## 1. Overview

This document describes the data architecture for DILIGO DMS, including the logical data model, physical database schema, and data flow patterns.

### Technology Choice

| Aspect | Details |
|--------|---------|
| **RDBMS** | PostgreSQL 16 |
| **ORM** | Entity Framework Core 8 (Npgsql) |
| **Migration** | EF Core Migrations |
| **Free Tier** | Supabase Free (500MB), Neon Free (512MB), or self-hosted |

---

## 2. Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    ENTITY RELATIONSHIP DIAGRAM                              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐            │
│  │   Distributor    │         │      User        │         │      Role        │            │
│  │   (NPP)          │◄───────►│                  │◄───────►│                  │            │
│  │                  │   1:N   │  - UserId        │   N:1   │  - RoleId        │            │
│  │  - DistributorId │         │  - DistributorId │         │  - RoleName      │            │
│  │  - Name          │         │  - Username      │         │  - Permissions   │            │
│  │  - TaxCode       │         │  - PasswordHash  │         │                  │            │
│  │  - Region        │         │  - RoleId        │         └──────────────────┘            │
│  └────────┬─────────┘         │  - EmployeeCode  │                                         │
│           │                   │  - FullName      │                                         │
│           │ 1:N               │  - Phone         │                                         │
│           │                   └────────┬─────────┘                                         │
│           │                            │                                                    │
│           │                            │ 1:N (NVBH)                                        │
│           ▼                            │                                                    │
│  ┌──────────────────┐                  │                                                    │
│  │     Route        │                  │                                                    │
│  │                  │                  │                                                    │
│  │  - RouteId       │                  │                                                    │
│  │  - RouteName     │◄─────────────────┘                                                    │
│  │  - DistributorId │   N:1                                                                │
│  │  - AssignedUserId│                                                                       │
│  │  - DayOfWeek     │                                                                       │
│  └────────┬─────────┘                                                                       │
│           │                                                                                 │
│           │ 1:N                                                                             │
│           ▼                                                                                 │
│  ┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐            │
│  │    Customer      │◄───────►│      Visit       │────────►│   VisitPhoto     │            │
│  │                  │   1:N   │                  │   1:N   │                  │            │
│  │  - CustomerId    │         │  - VisitId       │         │  - PhotoId       │            │
│  │  - CustomerCode  │         │  - CustomerId    │         │  - VisitId       │            │
│  │  - Name          │         │  - UserId        │         │  - AlbumType     │            │
│  │  - Phone         │         │  - CheckInTime   │         │  - ImageUrl      │            │
│  │  - Address       │         │  - CheckOutTime  │         │  - Latitude      │            │
│  │  - Latitude      │         │  - Latitude      │         │  - Longitude     │            │
│  │  - Longitude     │         │  - Longitude     │         │  - CreatedAt     │            │
│  │  - CustomerGroup │         │  - VisitType     │         └──────────────────┘            │
│  │  - CustomerType  │         │  - HasOrder      │                                         │
│  │  - Channel       │         │  - Notes         │                                         │
│  │  - RouteId       │         └────────┬─────────┘                                         │
│  │  - CreditLimit   │                  │                                                    │
│  │  - Balance       │                  │                                                    │
│  └────────┬─────────┘                  │                                                    │
│           │                            │                                                    │
│           │ 1:N                        │ 1:1 (optional)                                     │
│           ▼                            ▼                                                    │
│  ┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐            │
│  │      Order       │◄────────│                  │────────►│  OrderDetail     │            │
│  │                  │         │                  │   1:N   │                  │            │
│  │  - OrderId       │         │                  │         │  - DetailId      │            │
│  │  - OrderNumber   │         │                  │         │  - OrderId       │            │
│  │  - CustomerId    │         │                  │         │  - ProductId     │            │
│  │  - UserId        │         │                  │         │  - Quantity      │            │
│  │  - VisitId       │◄────────┘                  │         │  - UnitPrice     │            │
│  │  - OrderDate     │                            │         │  - Discount      │            │
│  │  - Status        │                            │         │  - Amount        │            │
│  │  - TotalAmount   │                            │         │  - PromotionId   │            │
│  │  - ApprovedBy    │                            │         └─────────┬────────┘            │
│  │  - ApprovedAt    │                            │                   │                     │
│  └────────┬─────────┘                            │                   │ N:1                 │
│           │                                      │                   ▼                     │
│           │ 1:1                                  │         ┌──────────────────┐            │
│           ▼                                      │         │     Product      │            │
│  ┌──────────────────┐                            │         │                  │            │
│  │  SalesInvoice    │                            │         │  - ProductId     │            │
│  │                  │                            │         │  - ProductCode   │            │
│  │  - InvoiceId     │                            │         │  - Name          │            │
│  │  - OrderId       │                            │         │  - Brand         │            │
│  │  - InvoiceNumber │                            │         │  - Category      │            │
│  │  - InvoiceDate   │                            │         │  - UnitName      │            │
│  │  - TotalAmount   │                            │         │  - SubUnitName   │            │
│  │  - Status        │                            │         │  - ConversionRate│            │
│  └────────┬─────────┘                            │         │  - CostPrice     │            │
│           │                                      │         │  - SellingPrice  │            │
│           │ 1:N                                  │         │  - VAT           │            │
│           ▼                                      │         │  - ImageUrl      │            │
│  ┌──────────────────┐                            │         │  - Status        │            │
│  │ StockMovement    │◄───────────────────────────┘         └────────┬─────────┘            │
│  │                  │                                               │                      │
│  │  - MovementId    │                                               │ N:1                  │
│  │  - MovementType  │                                               ▼                      │
│  │  - ProductId     │                                      ┌──────────────────┐            │
│  │  - WarehouseId   │                                      │   Promotion      │            │
│  │  - Quantity      │                                      │                  │            │
│  │  - ReferenceId   │                                      │  - PromotionId   │            │
│  │  - ReferenceType │                                      │  - Name          │            │
│  │  - CreatedBy     │                                      │  - Type          │            │
│  │  - CreatedAt     │                                      │  - StartDate     │            │
│  └──────────────────┘                                      │  - EndDate       │            │
│                                                            │  - DiscountType  │            │
│                                                            │  - DiscountValue │            │
│                                                            │  - Conditions    │            │
│  ┌──────────────────┐         ┌──────────────────┐         └──────────────────┘            │
│  │   Attendance     │         │ LocationHistory  │                                         │
│  │                  │         │                  │                                         │
│  │  - AttendanceId  │         │  - LocationId    │                                         │
│  │  - UserId        │         │  - UserId        │                                         │
│  │  - Date          │         │  - Latitude      │                                         │
│  │  - ClockInTime   │         │  - Longitude     │                                         │
│  │  - ClockInLat    │         │  - RecordedAt    │                                         │
│  │  - ClockInLong   │         │  - BatteryLevel  │                                         │
│  │  - ClockOutTime  │         │  - IsMoving      │                                         │
│  │  - ClockOutLat   │         │  - Accuracy      │                                         │
│  │  - ClockOutLong  │         │                  │                                         │
│  └──────────────────┘         └──────────────────┘                                         │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Table Definitions

### 3.1 Core Master Data

#### Distributors (NPP)

```sql
CREATE TABLE Distributors (
    DistributorId       UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorCode     VARCHAR(20)         NOT NULL UNIQUE,
    Name                VARCHAR(200)        NOT NULL,
    DistributorType     VARCHAR(50)         NOT NULL, -- 'NPP', 'DaiLy', 'TongThau'
    TaxCode             VARCHAR(20)         NULL,
    DistributorGroup    VARCHAR(10)         NOT NULL, -- 'A', 'B', 'C', 'D'
    Channel             VARCHAR(10)         NOT NULL, -- 'GT', 'MT'
    Region              VARCHAR(100)        NOT NULL,
    Province            VARCHAR(100)        NOT NULL,
    Address             VARCHAR(500)        NOT NULL,
    ContactPerson       VARCHAR(100)        NULL,
    Phone               VARCHAR(20)         NOT NULL,
    Email               VARCHAR(100)        NULL,
    BankName            VARCHAR(100)        NULL,
    BankAccount         VARCHAR(50)         NULL,
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Active', -- 'Active', 'Inactive'
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UpdatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_Distributors_Region ON Distributors(Region);
CREATE INDEX IX_Distributors_Status ON Distributors(Status);
```

#### Users

```sql
CREATE TABLE Roles (
    RoleId              SERIAL              PRIMARY KEY,
    RoleName            VARCHAR(50)         NOT NULL UNIQUE, -- 'NVBH', 'GSBH', 'ASM', 'RSM', 'AdminNPP'
    Description         VARCHAR(200)        NULL,
    Permissions         JSONB               NULL -- JSON array of permissions
);

CREATE TABLE Users (
    UserId              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    RoleId              INT                 NOT NULL REFERENCES Roles(RoleId),
    Username            VARCHAR(50)         NOT NULL UNIQUE,
    PasswordHash        VARCHAR(256)        NOT NULL,
    EmployeeCode        VARCHAR(20)         NOT NULL,
    FullName            VARCHAR(100)        NOT NULL,
    Phone               VARCHAR(20)         NULL,
    Email               VARCHAR(100)        NULL,
    SupervisorId        UUID                NULL REFERENCES Users(UserId),
    DeviceToken         VARCHAR(500)        NULL, -- FCM token
    LastLoginAt         TIMESTAMPTZ         NULL,
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Active',
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UpdatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_Users_DistributorId ON Users(DistributorId);
CREATE INDEX IX_Users_RoleId ON Users(RoleId);
CREATE INDEX IX_Users_SupervisorId ON Users(SupervisorId);
```

#### Customers

```sql
CREATE TABLE Customers (
    CustomerId          UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    CustomerCode        VARCHAR(20)         NOT NULL,
    Name                VARCHAR(200)        NOT NULL,
    Phone               VARCHAR(20)         NOT NULL,
    ContactPerson       VARCHAR(100)        NULL,
    CustomerGroup       VARCHAR(10)         NOT NULL, -- 'A', 'B', 'C', 'D', 'E'
    CustomerType        VARCHAR(50)         NOT NULL, -- 'TapHoa', 'HieuThuoc', 'MyPham', etc.
    Channel             VARCHAR(10)         NOT NULL, -- 'GT', 'MT'
    Latitude            DECIMAL(10,7)       NOT NULL,
    Longitude           DECIMAL(10,7)       NOT NULL,
    Address             VARCHAR(500)        NOT NULL,
    Region              VARCHAR(100)        NOT NULL,
    CreditLimit         DECIMAL(18,2)       NULL,
    CurrentBalance      DECIMAL(18,2)       NOT NULL DEFAULT 0,
    ImageUrl            VARCHAR(500)        NULL,
    Notes               TEXT                NULL,
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Active',
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UpdatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT UQ_Customer_Code UNIQUE (DistributorId, CustomerCode)
);

CREATE INDEX IX_Customers_DistributorId ON Customers(DistributorId);
CREATE INDEX IX_Customers_CustomerGroup ON Customers(CustomerGroup);
CREATE INDEX IX_Customers_CustomerType ON Customers(CustomerType);
CREATE INDEX IX_Customers_Location ON Customers(Latitude, Longitude);
```

#### Products

```sql
CREATE TABLE Products (
    ProductId           UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    ProductCode         VARCHAR(20)         NOT NULL,
    Name                VARCHAR(200)        NOT NULL,
    Brand               VARCHAR(100)        NOT NULL,
    Category            VARCHAR(100)        NOT NULL,
    Supplier            VARCHAR(100)        NULL,
    UnitName            VARCHAR(50)         NOT NULL, -- Main unit (Thùng)
    SubUnitName         VARCHAR(50)         NOT NULL, -- Sub unit (Lon)
    ConversionRate      INT                 NOT NULL DEFAULT 1, -- How many sub-units in main unit
    CostPrice           DECIMAL(18,2)       NOT NULL,
    CostPriceSub        DECIMAL(18,2)       NOT NULL,
    SellingPrice        DECIMAL(18,2)       NOT NULL,
    SellingPriceSub     DECIMAL(18,2)       NOT NULL,
    VAT                 DECIMAL(5,2)        NOT NULL DEFAULT 0,
    ImageUrl            VARCHAR(500)        NULL,
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Active',
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UpdatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT UQ_Product_Code UNIQUE (DistributorId, ProductCode)
);

CREATE INDEX IX_Products_DistributorId ON Products(DistributorId);
CREATE INDEX IX_Products_Brand ON Products(Brand);
CREATE INDEX IX_Products_Category ON Products(Category);

-- Full-text search index for product search
CREATE INDEX IX_Products_Search ON Products USING GIN (to_tsvector('simple', Name || ' ' || Brand || ' ' || Category));
```

### 3.2 Operational Data

#### Routes

```sql
CREATE TABLE Routes (
    RouteId             UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    RouteCode           VARCHAR(20)         NOT NULL,
    RouteName           VARCHAR(100)        NOT NULL,
    AssignedUserId      UUID                NOT NULL REFERENCES Users(UserId),
    DayOfWeek           INT                 NOT NULL, -- 0=Sunday, 1=Monday, etc.
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Active',
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UpdatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE TABLE RouteCustomers (
    RouteCustomerId     UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    RouteId             UUID                NOT NULL REFERENCES Routes(RouteId),
    CustomerId          UUID                NOT NULL REFERENCES Customers(CustomerId),
    VisitOrder          INT                 NOT NULL,

    CONSTRAINT UQ_Route_Customer UNIQUE (RouteId, CustomerId)
);

CREATE INDEX IX_Routes_AssignedUser ON Routes(AssignedUserId, DayOfWeek);
```

#### Visits

```sql
CREATE TABLE Visits (
    VisitId             UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    CustomerId          UUID                NOT NULL REFERENCES Customers(CustomerId),
    UserId              UUID                NOT NULL REFERENCES Users(UserId),
    RouteId             UUID                NULL REFERENCES Routes(RouteId),
    VisitDate           DATE                NOT NULL,
    CheckInTime         TIMESTAMPTZ         NOT NULL,
    CheckInLatitude     DECIMAL(10,7)       NOT NULL,
    CheckInLongitude    DECIMAL(10,7)       NOT NULL,
    CheckInDistance     INT                 NULL, -- Distance from customer location in meters
    CheckOutTime        TIMESTAMPTZ         NULL,
    CheckOutLatitude    DECIMAL(10,7)       NULL,
    CheckOutLongitude   DECIMAL(10,7)       NULL,
    VisitType           VARCHAR(20)         NOT NULL, -- 'InRoute', 'OutOfRoute'
    VisitResult         VARCHAR(20)         NOT NULL, -- 'HasOrder', 'NoOrder', 'Closed', 'OwnerAway'
    HasPhotos           BOOLEAN             NOT NULL DEFAULT FALSE,
    Notes               TEXT                NULL,
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UpdatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_Visits_Customer ON Visits(CustomerId, VisitDate DESC);
CREATE INDEX IX_Visits_User ON Visits(UserId, VisitDate DESC);
CREATE INDEX IX_Visits_Date ON Visits(VisitDate);
```

#### Visit Photos

```sql
CREATE TABLE VisitPhotos (
    PhotoId             UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    VisitId             UUID                NOT NULL REFERENCES Visits(VisitId),
    AlbumType           VARCHAR(50)         NOT NULL, -- 'TrungBay', 'MatTien', 'POSM', etc.
    ImageUrl            VARCHAR(500)        NOT NULL,
    ThumbnailUrl        VARCHAR(500)        NULL,
    Latitude            DECIMAL(10,7)       NOT NULL,
    Longitude           DECIMAL(10,7)       NOT NULL,
    CapturedAt          TIMESTAMPTZ         NOT NULL,
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_VisitPhotos_Visit ON VisitPhotos(VisitId);
CREATE INDEX IX_VisitPhotos_Album ON VisitPhotos(AlbumType, CapturedAt DESC);
```

#### Orders

```sql
CREATE TABLE Orders (
    OrderId             UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    OrderNumber         VARCHAR(20)         NOT NULL UNIQUE,
    CustomerId          UUID                NOT NULL REFERENCES Customers(CustomerId),
    UserId              UUID                NOT NULL REFERENCES Users(UserId),
    VisitId             UUID                NULL REFERENCES Visits(VisitId),
    OrderDate           TIMESTAMPTZ         NOT NULL,
    Status              VARCHAR(20)         NOT NULL, -- 'Draft', 'Pending', 'Approved', 'Rejected', 'Delivered'
    SubTotal            DECIMAL(18,2)       NOT NULL,
    DiscountAmount      DECIMAL(18,2)       NOT NULL DEFAULT 0,
    TaxAmount           DECIMAL(18,2)       NOT NULL DEFAULT 0,
    TotalAmount         DECIMAL(18,2)       NOT NULL,
    Notes               TEXT                NULL,
    ApprovedBy          UUID                NULL REFERENCES Users(UserId),
    ApprovedAt          TIMESTAMPTZ         NULL,
    RejectionReason     VARCHAR(500)        NULL,
    SyncStatus          VARCHAR(20)         NOT NULL DEFAULT 'Synced', -- 'Pending', 'Synced', 'Failed'
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    UpdatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_Orders_Customer ON Orders(CustomerId, OrderDate DESC);
CREATE INDEX IX_Orders_User ON Orders(UserId, OrderDate DESC);
CREATE INDEX IX_Orders_Status ON Orders(Status, OrderDate DESC);
CREATE INDEX IX_Orders_Distributor ON Orders(DistributorId, OrderDate DESC);
```

#### Order Details

```sql
CREATE TABLE OrderDetails (
    DetailId            UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    OrderId             UUID                NOT NULL REFERENCES Orders(OrderId) ON DELETE CASCADE,
    ProductId           UUID                NOT NULL REFERENCES Products(ProductId),
    Quantity            INT                 NOT NULL,
    UnitType            VARCHAR(10)         NOT NULL, -- 'Main', 'Sub'
    UnitPrice           DECIMAL(18,2)       NOT NULL,
    DiscountPercent     DECIMAL(5,2)        NOT NULL DEFAULT 0,
    DiscountAmount      DECIMAL(18,2)       NOT NULL DEFAULT 0,
    TaxAmount           DECIMAL(18,2)       NOT NULL DEFAULT 0,
    LineTotal           DECIMAL(18,2)       NOT NULL,
    PromotionId         UUID                NULL REFERENCES Promotions(PromotionId),
    Notes               VARCHAR(200)        NULL
);

CREATE INDEX IX_OrderDetails_Order ON OrderDetails(OrderId);
CREATE INDEX IX_OrderDetails_Product ON OrderDetails(ProductId);
```

### 3.3 Inventory & Finance

#### Warehouses

```sql
CREATE TABLE Warehouses (
    WarehouseId         UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    WarehouseCode       VARCHAR(20)         NOT NULL,
    Name                VARCHAR(100)        NOT NULL,
    Address             VARCHAR(500)        NULL,
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Active',
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE TABLE ProductStock (
    StockId             UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    WarehouseId         UUID                NOT NULL REFERENCES Warehouses(WarehouseId),
    ProductId           UUID                NOT NULL REFERENCES Products(ProductId),
    Quantity            INT                 NOT NULL DEFAULT 0,
    ReservedQuantity    INT                 NOT NULL DEFAULT 0, -- For pending orders
    LastUpdated         TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT UQ_Product_Warehouse UNIQUE (WarehouseId, ProductId)
);
```

#### Stock Movements

```sql
CREATE TABLE StockMovements (
    MovementId          UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    MovementNumber      VARCHAR(20)         NOT NULL,
    MovementType        VARCHAR(20)         NOT NULL, -- 'StockIn', 'StockOut', 'Transfer', 'Return', 'Adjustment'
    WarehouseId         UUID                NOT NULL REFERENCES Warehouses(WarehouseId),
    ToWarehouseId       UUID                NULL REFERENCES Warehouses(WarehouseId), -- For transfers
    ReferenceType       VARCHAR(50)         NULL, -- 'SalesInvoice', 'PurchaseOrder', 'Manual'
    ReferenceId         UUID                NULL,
    Notes               VARCHAR(500)        NULL,
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Draft',
    CreatedBy           UUID                NOT NULL REFERENCES Users(UserId),
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    ApprovedBy          UUID                NULL REFERENCES Users(UserId),
    ApprovedAt          TIMESTAMPTZ         NULL
);

CREATE TABLE StockMovementDetails (
    DetailId            UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    MovementId          UUID                NOT NULL REFERENCES StockMovements(MovementId) ON DELETE CASCADE,
    ProductId           UUID                NOT NULL REFERENCES Products(ProductId),
    Quantity            INT                 NOT NULL,
    UnitType            VARCHAR(10)         NOT NULL,
    Notes               VARCHAR(200)        NULL
);
```

#### Receivables

```sql
CREATE TABLE CustomerTransactions (
    TransactionId       UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    CustomerId          UUID                NOT NULL REFERENCES Customers(CustomerId),
    TransactionType     VARCHAR(20)         NOT NULL, -- 'Invoice', 'Payment', 'Adjustment', 'Refund'
    ReferenceType       VARCHAR(50)         NULL,
    ReferenceId         UUID                NULL,
    Amount              DECIMAL(18,2)       NOT NULL, -- Positive for debit, negative for credit
    BalanceBefore       DECIMAL(18,2)       NOT NULL,
    BalanceAfter        DECIMAL(18,2)       NOT NULL,
    Notes               VARCHAR(500)        NULL,
    CreatedBy           UUID                NOT NULL REFERENCES Users(UserId),
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_CustomerTransactions_Customer ON CustomerTransactions(CustomerId, CreatedAt DESC);
```

### 3.4 Promotions

```sql
CREATE TABLE Promotions (
    PromotionId         UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    DistributorId       UUID                NOT NULL REFERENCES Distributors(DistributorId),
    PromotionCode       VARCHAR(20)         NOT NULL,
    Name                VARCHAR(200)        NOT NULL,
    Description         TEXT                NULL,
    PromotionType       VARCHAR(50)         NOT NULL, -- 'PercentDiscount', 'FixedDiscount', 'BuyXGetY', 'GiftItem'
    StartDate           DATE                NOT NULL,
    EndDate             DATE                NOT NULL,
    MinQuantity         INT                 NULL,
    MinAmount           DECIMAL(18,2)       NULL,
    DiscountPercent     DECIMAL(5,2)        NULL,
    DiscountAmount      DECIMAL(18,2)       NULL,
    MaxDiscount         DECIMAL(18,2)       NULL,
    ApplicableProducts  JSONB               NULL, -- JSON array of ProductIds
    ApplicableCustomers JSONB               NULL, -- JSON: {"types": [], "groups": []}
    Status              VARCHAR(20)         NOT NULL DEFAULT 'Active',
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_Promotions_Distributor_Date ON Promotions(DistributorId, StartDate, EndDate);
CREATE INDEX IX_Promotions_ApplicableProducts ON Promotions USING GIN (ApplicableProducts);
CREATE INDEX IX_Promotions_ApplicableCustomers ON Promotions USING GIN (ApplicableCustomers);
```

### 3.5 Monitoring & Tracking

#### Attendance

```sql
CREATE TABLE Attendance (
    AttendanceId        UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    UserId              UUID                NOT NULL REFERENCES Users(UserId),
    AttendanceDate      DATE                NOT NULL,
    ClockInTime         TIMESTAMPTZ         NULL,
    ClockInLatitude     DECIMAL(10,7)       NULL,
    ClockInLongitude    DECIMAL(10,7)       NULL,
    ClockOutTime        TIMESTAMPTZ         NULL,
    ClockOutLatitude    DECIMAL(10,7)       NULL,
    ClockOutLongitude   DECIMAL(10,7)       NULL,
    WorkingMinutes      INT                 NULL,
    Notes               VARCHAR(500)        NULL,
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT UQ_User_Date UNIQUE (UserId, AttendanceDate)
);

CREATE INDEX IX_Attendance_User ON Attendance(UserId, AttendanceDate DESC);
```

#### Location History

```sql
CREATE TABLE LocationHistory (
    LocationId          BIGSERIAL           PRIMARY KEY,
    UserId              UUID                NOT NULL REFERENCES Users(UserId),
    Latitude            DECIMAL(10,7)       NOT NULL,
    Longitude           DECIMAL(10,7)       NOT NULL,
    Accuracy            REAL                NULL,
    BatteryLevel        INT                 NULL,
    IsMoving            BOOLEAN             NULL,
    RecordedAt          TIMESTAMPTZ         NOT NULL,
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_LocationHistory_User_Time ON LocationHistory(UserId, RecordedAt DESC);

-- Partitioning by month for large datasets (optional)
-- Consider auto-deletion of records older than 90 days
```

### 3.6 Audit & Sync

```sql
CREATE TABLE AuditLogs (
    AuditId             BIGSERIAL           PRIMARY KEY,
    UserId              UUID                NULL,
    Action              VARCHAR(50)         NOT NULL, -- 'Create', 'Update', 'Delete', 'Login', etc.
    EntityType          VARCHAR(100)        NOT NULL,
    EntityId            VARCHAR(100)        NULL,
    OldValues           JSONB               NULL,
    NewValues           JSONB               NULL,
    IpAddress           VARCHAR(50)         NULL,
    UserAgent           VARCHAR(500)        NULL,
    CreatedAt           TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX IX_AuditLogs_Entity ON AuditLogs(EntityType, EntityId);
CREATE INDEX IX_AuditLogs_User ON AuditLogs(UserId, CreatedAt DESC);

CREATE TABLE SyncMetadata (
    SyncId              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    EntityType          VARCHAR(100)        NOT NULL,
    EntityId            UUID                NOT NULL,
    LastModified        TIMESTAMPTZ         NOT NULL,
    Version             INT                 NOT NULL DEFAULT 1,

    CONSTRAINT UQ_Sync_Entity UNIQUE (EntityType, EntityId)
);

CREATE INDEX IX_SyncMetadata_Modified ON SyncMetadata(EntityType, LastModified);
```

---

## 4. Data Flow Diagrams

### 4.1 Order Processing Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              ORDER PROCESSING DATA FLOW                                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  1. CREATE ORDER (Mobile)                                                               │
│  ─────────────────────────                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐              │
│  │  Customer   │───►│   Order     │───►│ OrderDetail │───►│   Product   │              │
│  │  (lookup)   │    │  (insert)   │    │  (insert)   │    │  (lookup)   │              │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘              │
│                           │                   │                                         │
│                           │                   ▼                                         │
│                           │           ┌─────────────┐                                  │
│                           │           │  Promotion  │                                  │
│                           │           │  (lookup)   │                                  │
│                           │           └─────────────┘                                  │
│                           │                                                             │
│  2. APPROVE ORDER (Web)                                                                 │
│  ─────────────────────────                                                              │
│                           ▼                                                             │
│                    ┌─────────────┐                                                     │
│                    │   Order     │                                                     │
│                    │  (update    │                                                     │
│                    │   status)   │                                                     │
│                    └──────┬──────┘                                                     │
│                           │                                                             │
│  3. CREATE INVOICE                                                                      │
│  ─────────────────                                                                      │
│                           ▼                                                             │
│                    ┌─────────────┐    ┌─────────────┐                                  │
│                    │SalesInvoice │───►│ Customer    │                                  │
│                    │  (insert)   │    │(update bal) │                                  │
│                    └──────┬──────┘    └─────────────┘                                  │
│                           │                   │                                         │
│                           │                   ▼                                         │
│                           │           ┌─────────────┐                                  │
│                           │           │  Customer   │                                  │
│                           │           │ Transaction │                                  │
│                           │           │  (insert)   │                                  │
│                           │           └─────────────┘                                  │
│                           │                                                             │
│  4. STOCK OUT                                                                           │
│  ────────────                                                                           │
│                           ▼                                                             │
│                    ┌─────────────┐    ┌─────────────┐                                  │
│                    │   Stock     │───►│ ProductStock│                                  │
│                    │  Movement   │    │  (update)   │                                  │
│                    │  (insert)   │    └─────────────┘                                  │
│                    └─────────────┘                                                     │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Mobile Sync Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              MOBILE SYNC DATA FLOW                                       │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  DOWNLOAD (Server → Mobile)                                                             │
│  ─────────────────────────                                                              │
│                                                                                         │
│  Server Tables                 API Response                Mobile SQLite                │
│  ─────────────                 ────────────                ─────────────                │
│                                                                                         │
│  ┌─────────────┐                                          ┌─────────────┐              │
│  │ Customers   │─────┐                                    │ customers   │              │
│  └─────────────┘     │                                    └─────────────┘              │
│  ┌─────────────┐     │         ┌─────────────┐           ┌─────────────┐              │
│  │ Products    │────►├────────►│  Delta Sync │──────────►│ products    │              │
│  └─────────────┘     │         │   Response  │           └─────────────┘              │
│  ┌─────────────┐     │         │   (JSON)    │           ┌─────────────┐              │
│  │ Promotions  │─────┘         └─────────────┘           │ promotions  │              │
│  └─────────────┘                                          └─────────────┘              │
│  ┌─────────────┐                                          ┌─────────────┐              │
│  │SyncMetadata │───────────────────────────────────────►  │sync_metadata│              │
│  └─────────────┘                                          └─────────────┘              │
│                                                                                         │
│  UPLOAD (Mobile → Server)                                                               │
│  ────────────────────────                                                               │
│                                                                                         │
│  Mobile SQLite                 API Request                 Server Tables               │
│  ─────────────                 ───────────                 ─────────────               │
│                                                                                         │
│  ┌─────────────┐                                          ┌─────────────┐              │
│  │pending_orders│─────┐                                   │   Orders    │              │
│  └─────────────┘      │                                   └─────────────┘              │
│  ┌─────────────┐      │        ┌─────────────┐           ┌─────────────┐              │
│  │pending_visits│────►├───────►│  Sync Upload│──────────►│   Visits    │              │
│  └─────────────┘      │        │   Request   │           └─────────────┘              │
│  ┌─────────────┐      │        │   (JSON)    │           ┌─────────────┐              │
│  │pending_photos│─────┘        └─────────────┘           │ VisitPhotos │              │
│  └─────────────┘                                          └─────────────┘              │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Indexing Strategy

### 5.1 Primary Query Patterns

| Query Pattern | Tables | Index |
|--------------|--------|-------|
| Customer by route | Customers, RouteCustomers | IX_RouteCustomers_Route |
| Orders by status | Orders | IX_Orders_Status |
| Visits by user & date | Visits | IX_Visits_User |
| Products by category | Products | IX_Products_Category |
| Location history | LocationHistory | IX_LocationHistory_User_Time |
| Sync delta queries | SyncMetadata | IX_SyncMetadata_Modified |
| Product search | Products | IX_Products_Search (GIN) |
| Promotion conditions | Promotions | IX_Promotions_ApplicableProducts (GIN) |

### 5.2 Performance Considerations

- Use covering indexes for frequently accessed columns
- Partition LocationHistory by month (if exceeding free tier limits)
- Archive data older than 1 year to separate tables
- Use JSONB GIN indexes for flexible querying of JSON data
- Consider partial indexes for common filter conditions

---

## 6. Data Retention Policy

| Data Type | Retention Period | Action |
|-----------|------------------|--------|
| **Location History** | 90 days | Auto-delete via pg_cron or scheduled function |
| **Audit Logs** | 1 year | Archive to cold storage |
| **Visit Photos** | 1 year | Move to archive tier |
| **Orders** | 5 years | Retain for compliance |
| **Master Data** | Indefinite | Soft delete only |

### Auto-Cleanup Function

```sql
-- Create cleanup function
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
    -- Delete location history older than 90 days
    DELETE FROM LocationHistory WHERE RecordedAt < NOW() - INTERVAL '90 days';

    -- Delete audit logs older than 1 year
    DELETE FROM AuditLogs WHERE CreatedAt < NOW() - INTERVAL '1 year';

    -- Vacuum to reclaim space
    VACUUM ANALYZE LocationHistory;
    VACUUM ANALYZE AuditLogs;
END;
$$ LANGUAGE plpgsql;

-- Schedule with pg_cron (if available) or external scheduler
-- SELECT cron.schedule('weekly-cleanup', '0 3 * * 0', 'SELECT cleanup_old_data()');
```

---

## 7. Related Documents

- [05-API-DESIGN.md](05-API-DESIGN.md) - API specifications
- [07-SECURITY-ARCHITECTURE.md](07-SECURITY-ARCHITECTURE.md) - Data security
- [adr/ADR-003-postgresql.md](adr/ADR-003-postgresql.md) - Database decision
