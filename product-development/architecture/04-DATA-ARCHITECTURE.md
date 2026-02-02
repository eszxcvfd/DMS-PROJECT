# DILIGO DMS - Data Architecture

## Distribution Management System - Database Design

**Version:** 1.0
**Last Updated:** 2026-02-02

---

## 1. Overview

This document describes the data architecture for DILIGO DMS, including the logical data model, physical database schema, and data flow patterns.

### Technology Choice

| Aspect | Details |
|--------|---------|
| **RDBMS** | SQL Server 2022 / Azure SQL |
| **ORM** | Entity Framework Core 8 |
| **Migration** | EF Core Migrations |
| **Free Tier** | Azure SQL Free (32GB limit) or SQL Server Express (10GB) |

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
    DistributorId       UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorCode     NVARCHAR(20)        NOT NULL UNIQUE,
    Name                NVARCHAR(200)       NOT NULL,
    DistributorType     NVARCHAR(50)        NOT NULL, -- 'NPP', 'DaiLy', 'TongThau'
    TaxCode             NVARCHAR(20)        NULL,
    DistributorGroup    NVARCHAR(10)        NOT NULL, -- 'A', 'B', 'C', 'D'
    Channel             NVARCHAR(10)        NOT NULL, -- 'GT', 'MT'
    Region              NVARCHAR(100)       NOT NULL,
    Province            NVARCHAR(100)       NOT NULL,
    Address             NVARCHAR(500)       NOT NULL,
    ContactPerson       NVARCHAR(100)       NULL,
    Phone               NVARCHAR(20)        NOT NULL,
    Email               NVARCHAR(100)       NULL,
    BankName            NVARCHAR(100)       NULL,
    BankAccount         NVARCHAR(50)        NULL,
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Active', -- 'Active', 'Inactive'
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_Distributors_Region ON Distributors(Region);
CREATE INDEX IX_Distributors_Status ON Distributors(Status);
```

#### Users

```sql
CREATE TABLE Roles (
    RoleId              INT                 PRIMARY KEY IDENTITY(1,1),
    RoleName            NVARCHAR(50)        NOT NULL UNIQUE, -- 'NVBH', 'GSBH', 'ASM', 'RSM', 'AdminNPP'
    Description         NVARCHAR(200)       NULL,
    Permissions         NVARCHAR(MAX)       NULL -- JSON array of permissions
);

CREATE TABLE Users (
    UserId              UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    RoleId              INT                 NOT NULL REFERENCES Roles(RoleId),
    Username            NVARCHAR(50)        NOT NULL UNIQUE,
    PasswordHash        NVARCHAR(256)       NOT NULL,
    EmployeeCode        NVARCHAR(20)        NOT NULL,
    FullName            NVARCHAR(100)       NOT NULL,
    Phone               NVARCHAR(20)        NULL,
    Email               NVARCHAR(100)       NULL,
    SupervisorId        UNIQUEIDENTIFIER    NULL REFERENCES Users(UserId),
    DeviceToken         NVARCHAR(500)       NULL, -- FCM token
    LastLoginAt         DATETIME2           NULL,
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Active',
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_Users_DistributorId ON Users(DistributorId);
CREATE INDEX IX_Users_RoleId ON Users(RoleId);
CREATE INDEX IX_Users_SupervisorId ON Users(SupervisorId);
```

#### Customers

```sql
CREATE TABLE Customers (
    CustomerId          UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    CustomerCode        NVARCHAR(20)        NOT NULL,
    Name                NVARCHAR(200)       NOT NULL,
    Phone               NVARCHAR(20)        NOT NULL,
    ContactPerson       NVARCHAR(100)       NULL,
    CustomerGroup       NVARCHAR(10)        NOT NULL, -- 'A', 'B', 'C', 'D', 'E'
    CustomerType        NVARCHAR(50)        NOT NULL, -- 'TapHoa', 'HieuThuoc', 'MyPham', etc.
    Channel             NVARCHAR(10)        NOT NULL, -- 'GT', 'MT'
    Latitude            DECIMAL(10,7)       NOT NULL,
    Longitude           DECIMAL(10,7)       NOT NULL,
    Address             NVARCHAR(500)       NOT NULL,
    Region              NVARCHAR(100)       NOT NULL,
    CreditLimit         DECIMAL(18,2)       NULL,
    CurrentBalance      DECIMAL(18,2)       NOT NULL DEFAULT 0,
    ImageUrl            NVARCHAR(500)       NULL,
    Notes               NVARCHAR(MAX)       NULL,
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Active',
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_Customer_Code UNIQUE (DistributorId, CustomerCode)
);

CREATE INDEX IX_Customers_DistributorId ON Customers(DistributorId);
CREATE INDEX IX_Customers_CustomerGroup ON Customers(CustomerGroup);
CREATE INDEX IX_Customers_CustomerType ON Customers(CustomerType);
CREATE SPATIAL INDEX IX_Customers_Location ON Customers(Latitude, Longitude);
```

#### Products

```sql
CREATE TABLE Products (
    ProductId           UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    ProductCode         NVARCHAR(20)        NOT NULL,
    Name                NVARCHAR(200)       NOT NULL,
    Brand               NVARCHAR(100)       NOT NULL,
    Category            NVARCHAR(100)       NOT NULL,
    Supplier            NVARCHAR(100)       NULL,
    UnitName            NVARCHAR(50)        NOT NULL, -- Main unit (Thùng)
    SubUnitName         NVARCHAR(50)        NOT NULL, -- Sub unit (Lon)
    ConversionRate      INT                 NOT NULL DEFAULT 1, -- How many sub-units in main unit
    CostPrice           DECIMAL(18,2)       NOT NULL,
    CostPriceSub        DECIMAL(18,2)       NOT NULL,
    SellingPrice        DECIMAL(18,2)       NOT NULL,
    SellingPriceSub     DECIMAL(18,2)       NOT NULL,
    VAT                 DECIMAL(5,2)        NOT NULL DEFAULT 0,
    ImageUrl            NVARCHAR(500)       NULL,
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Active',
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_Product_Code UNIQUE (DistributorId, ProductCode)
);

CREATE INDEX IX_Products_DistributorId ON Products(DistributorId);
CREATE INDEX IX_Products_Brand ON Products(Brand);
CREATE INDEX IX_Products_Category ON Products(Category);
```

### 3.2 Operational Data

#### Routes

```sql
CREATE TABLE Routes (
    RouteId             UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    RouteCode           NVARCHAR(20)        NOT NULL,
    RouteName           NVARCHAR(100)       NOT NULL,
    AssignedUserId      UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    DayOfWeek           INT                 NOT NULL, -- 0=Sunday, 1=Monday, etc.
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Active',
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE RouteCustomers (
    RouteCustomerId     UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    RouteId             UNIQUEIDENTIFIER    NOT NULL REFERENCES Routes(RouteId),
    CustomerId          UNIQUEIDENTIFIER    NOT NULL REFERENCES Customers(CustomerId),
    VisitOrder          INT                 NOT NULL,

    CONSTRAINT UQ_Route_Customer UNIQUE (RouteId, CustomerId)
);

CREATE INDEX IX_Routes_AssignedUser ON Routes(AssignedUserId, DayOfWeek);
```

#### Visits

```sql
CREATE TABLE Visits (
    VisitId             UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    CustomerId          UNIQUEIDENTIFIER    NOT NULL REFERENCES Customers(CustomerId),
    UserId              UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    RouteId             UNIQUEIDENTIFIER    NULL REFERENCES Routes(RouteId),
    VisitDate           DATE                NOT NULL,
    CheckInTime         DATETIME2           NOT NULL,
    CheckInLatitude     DECIMAL(10,7)       NOT NULL,
    CheckInLongitude    DECIMAL(10,7)       NOT NULL,
    CheckInDistance     INT                 NULL, -- Distance from customer location in meters
    CheckOutTime        DATETIME2           NULL,
    CheckOutLatitude    DECIMAL(10,7)       NULL,
    CheckOutLongitude   DECIMAL(10,7)       NULL,
    VisitType           NVARCHAR(20)        NOT NULL, -- 'InRoute', 'OutOfRoute'
    VisitResult         NVARCHAR(20)        NOT NULL, -- 'HasOrder', 'NoOrder', 'Closed', 'OwnerAway'
    HasPhotos           BIT                 NOT NULL DEFAULT 0,
    Notes               NVARCHAR(MAX)       NULL,
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_Visits_Customer ON Visits(CustomerId, VisitDate DESC);
CREATE INDEX IX_Visits_User ON Visits(UserId, VisitDate DESC);
CREATE INDEX IX_Visits_Date ON Visits(VisitDate);
```

#### Visit Photos

```sql
CREATE TABLE VisitPhotos (
    PhotoId             UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    VisitId             UNIQUEIDENTIFIER    NOT NULL REFERENCES Visits(VisitId),
    AlbumType           NVARCHAR(50)        NOT NULL, -- 'TrungBay', 'MatTien', 'POSM', etc.
    ImageUrl            NVARCHAR(500)       NOT NULL,
    ThumbnailUrl        NVARCHAR(500)       NULL,
    Latitude            DECIMAL(10,7)       NOT NULL,
    Longitude           DECIMAL(10,7)       NOT NULL,
    CapturedAt          DATETIME2           NOT NULL,
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_VisitPhotos_Visit ON VisitPhotos(VisitId);
CREATE INDEX IX_VisitPhotos_Album ON VisitPhotos(AlbumType, CapturedAt DESC);
```

#### Orders

```sql
CREATE TABLE Orders (
    OrderId             UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    OrderNumber         NVARCHAR(20)        NOT NULL UNIQUE,
    CustomerId          UNIQUEIDENTIFIER    NOT NULL REFERENCES Customers(CustomerId),
    UserId              UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    VisitId             UNIQUEIDENTIFIER    NULL REFERENCES Visits(VisitId),
    OrderDate           DATETIME2           NOT NULL,
    Status              NVARCHAR(20)        NOT NULL, -- 'Draft', 'Pending', 'Approved', 'Rejected', 'Delivered'
    SubTotal            DECIMAL(18,2)       NOT NULL,
    DiscountAmount      DECIMAL(18,2)       NOT NULL DEFAULT 0,
    TaxAmount           DECIMAL(18,2)       NOT NULL DEFAULT 0,
    TotalAmount         DECIMAL(18,2)       NOT NULL,
    Notes               NVARCHAR(MAX)       NULL,
    ApprovedBy          UNIQUEIDENTIFIER    NULL REFERENCES Users(UserId),
    ApprovedAt          DATETIME2           NULL,
    RejectionReason     NVARCHAR(500)       NULL,
    SyncStatus          NVARCHAR(20)        NOT NULL DEFAULT 'Synced', -- 'Pending', 'Synced', 'Failed'
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_Orders_Customer ON Orders(CustomerId, OrderDate DESC);
CREATE INDEX IX_Orders_User ON Orders(UserId, OrderDate DESC);
CREATE INDEX IX_Orders_Status ON Orders(Status, OrderDate DESC);
CREATE INDEX IX_Orders_Distributor ON Orders(DistributorId, OrderDate DESC);
```

#### Order Details

```sql
CREATE TABLE OrderDetails (
    DetailId            UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    OrderId             UNIQUEIDENTIFIER    NOT NULL REFERENCES Orders(OrderId) ON DELETE CASCADE,
    ProductId           UNIQUEIDENTIFIER    NOT NULL REFERENCES Products(ProductId),
    Quantity            INT                 NOT NULL,
    UnitType            NVARCHAR(10)        NOT NULL, -- 'Main', 'Sub'
    UnitPrice           DECIMAL(18,2)       NOT NULL,
    DiscountPercent     DECIMAL(5,2)        NOT NULL DEFAULT 0,
    DiscountAmount      DECIMAL(18,2)       NOT NULL DEFAULT 0,
    TaxAmount           DECIMAL(18,2)       NOT NULL DEFAULT 0,
    LineTotal           DECIMAL(18,2)       NOT NULL,
    PromotionId         UNIQUEIDENTIFIER    NULL REFERENCES Promotions(PromotionId),
    Notes               NVARCHAR(200)       NULL
);

CREATE INDEX IX_OrderDetails_Order ON OrderDetails(OrderId);
CREATE INDEX IX_OrderDetails_Product ON OrderDetails(ProductId);
```

### 3.3 Inventory & Finance

#### Warehouses

```sql
CREATE TABLE Warehouses (
    WarehouseId         UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    WarehouseCode       NVARCHAR(20)        NOT NULL,
    Name                NVARCHAR(100)       NOT NULL,
    Address             NVARCHAR(500)       NULL,
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Active',
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE TABLE ProductStock (
    StockId             UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    WarehouseId         UNIQUEIDENTIFIER    NOT NULL REFERENCES Warehouses(WarehouseId),
    ProductId           UNIQUEIDENTIFIER    NOT NULL REFERENCES Products(ProductId),
    Quantity            INT                 NOT NULL DEFAULT 0,
    ReservedQuantity    INT                 NOT NULL DEFAULT 0, -- For pending orders
    LastUpdated         DATETIME2           NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_Product_Warehouse UNIQUE (WarehouseId, ProductId)
);
```

#### Stock Movements

```sql
CREATE TABLE StockMovements (
    MovementId          UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    MovementNumber      NVARCHAR(20)        NOT NULL,
    MovementType        NVARCHAR(20)        NOT NULL, -- 'StockIn', 'StockOut', 'Transfer', 'Return', 'Adjustment'
    WarehouseId         UNIQUEIDENTIFIER    NOT NULL REFERENCES Warehouses(WarehouseId),
    ToWarehouseId       UNIQUEIDENTIFIER    NULL REFERENCES Warehouses(WarehouseId), -- For transfers
    ReferenceType       NVARCHAR(50)        NULL, -- 'SalesInvoice', 'PurchaseOrder', 'Manual'
    ReferenceId         UNIQUEIDENTIFIER    NULL,
    Notes               NVARCHAR(500)       NULL,
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Draft',
    CreatedBy           UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),
    ApprovedBy          UNIQUEIDENTIFIER    NULL REFERENCES Users(UserId),
    ApprovedAt          DATETIME2           NULL
);

CREATE TABLE StockMovementDetails (
    DetailId            UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    MovementId          UNIQUEIDENTIFIER    NOT NULL REFERENCES StockMovements(MovementId) ON DELETE CASCADE,
    ProductId           UNIQUEIDENTIFIER    NOT NULL REFERENCES Products(ProductId),
    Quantity            INT                 NOT NULL,
    UnitType            NVARCHAR(10)        NOT NULL,
    Notes               NVARCHAR(200)       NULL
);
```

#### Receivables

```sql
CREATE TABLE CustomerTransactions (
    TransactionId       UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    CustomerId          UNIQUEIDENTIFIER    NOT NULL REFERENCES Customers(CustomerId),
    TransactionType     NVARCHAR(20)        NOT NULL, -- 'Invoice', 'Payment', 'Adjustment', 'Refund'
    ReferenceType       NVARCHAR(50)        NULL,
    ReferenceId         UNIQUEIDENTIFIER    NULL,
    Amount              DECIMAL(18,2)       NOT NULL, -- Positive for debit, negative for credit
    BalanceBefore       DECIMAL(18,2)       NOT NULL,
    BalanceAfter        DECIMAL(18,2)       NOT NULL,
    Notes               NVARCHAR(500)       NULL,
    CreatedBy           UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_CustomerTransactions_Customer ON CustomerTransactions(CustomerId, CreatedAt DESC);
```

### 3.4 Promotions

```sql
CREATE TABLE Promotions (
    PromotionId         UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    DistributorId       UNIQUEIDENTIFIER    NOT NULL REFERENCES Distributors(DistributorId),
    PromotionCode       NVARCHAR(20)        NOT NULL,
    Name                NVARCHAR(200)       NOT NULL,
    Description         NVARCHAR(MAX)       NULL,
    PromotionType       NVARCHAR(50)        NOT NULL, -- 'PercentDiscount', 'FixedDiscount', 'BuyXGetY', 'GiftItem'
    StartDate           DATE                NOT NULL,
    EndDate             DATE                NOT NULL,
    MinQuantity         INT                 NULL,
    MinAmount           DECIMAL(18,2)       NULL,
    DiscountPercent     DECIMAL(5,2)        NULL,
    DiscountAmount      DECIMAL(18,2)       NULL,
    MaxDiscount         DECIMAL(18,2)       NULL,
    ApplicableProducts  NVARCHAR(MAX)       NULL, -- JSON array of ProductIds
    ApplicableCustomers NVARCHAR(MAX)       NULL, -- JSON: {"types": [], "groups": []}
    Status              NVARCHAR(20)        NOT NULL DEFAULT 'Active',
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_Promotions_Distributor_Date ON Promotions(DistributorId, StartDate, EndDate);
```

### 3.5 Monitoring & Tracking

#### Attendance

```sql
CREATE TABLE Attendance (
    AttendanceId        UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    UserId              UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    AttendanceDate      DATE                NOT NULL,
    ClockInTime         DATETIME2           NULL,
    ClockInLatitude     DECIMAL(10,7)       NULL,
    ClockInLongitude    DECIMAL(10,7)       NULL,
    ClockOutTime        DATETIME2           NULL,
    ClockOutLatitude    DECIMAL(10,7)       NULL,
    ClockOutLongitude   DECIMAL(10,7)       NULL,
    WorkingMinutes      INT                 NULL,
    Notes               NVARCHAR(500)       NULL,
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT UQ_User_Date UNIQUE (UserId, AttendanceDate)
);

CREATE INDEX IX_Attendance_User ON Attendance(UserId, AttendanceDate DESC);
```

#### Location History

```sql
CREATE TABLE LocationHistory (
    LocationId          BIGINT              PRIMARY KEY IDENTITY(1,1),
    UserId              UNIQUEIDENTIFIER    NOT NULL REFERENCES Users(UserId),
    Latitude            DECIMAL(10,7)       NOT NULL,
    Longitude           DECIMAL(10,7)       NOT NULL,
    Accuracy            FLOAT               NULL,
    BatteryLevel        INT                 NULL,
    IsMoving            BIT                 NULL,
    RecordedAt          DATETIME2           NOT NULL,
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_LocationHistory_User_Time ON LocationHistory(UserId, RecordedAt DESC);

-- Partitioning by month for large datasets (optional for free tier)
-- Consider auto-deletion of records older than 90 days
```

### 3.6 Audit & Sync

```sql
CREATE TABLE AuditLogs (
    AuditId             BIGINT              PRIMARY KEY IDENTITY(1,1),
    UserId              UNIQUEIDENTIFIER    NULL,
    Action              NVARCHAR(50)        NOT NULL, -- 'Create', 'Update', 'Delete', 'Login', etc.
    EntityType          NVARCHAR(100)       NOT NULL,
    EntityId            NVARCHAR(100)       NULL,
    OldValues           NVARCHAR(MAX)       NULL, -- JSON
    NewValues           NVARCHAR(MAX)       NULL, -- JSON
    IpAddress           NVARCHAR(50)        NULL,
    UserAgent           NVARCHAR(500)       NULL,
    CreatedAt           DATETIME2           NOT NULL DEFAULT GETUTCDATE()
);

CREATE INDEX IX_AuditLogs_Entity ON AuditLogs(EntityType, EntityId);
CREATE INDEX IX_AuditLogs_User ON AuditLogs(UserId, CreatedAt DESC);

CREATE TABLE SyncMetadata (
    SyncId              UNIQUEIDENTIFIER    PRIMARY KEY DEFAULT NEWID(),
    EntityType          NVARCHAR(100)       NOT NULL,
    EntityId            UNIQUEIDENTIFIER    NOT NULL,
    LastModified        DATETIME2           NOT NULL,
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

### 5.2 Performance Considerations

- Use covering indexes for frequently accessed columns
- Partition LocationHistory by month (if exceeding free tier limits)
- Archive data older than 1 year to separate tables
- Consider columnstore indexes for reporting tables

---

## 6. Data Retention Policy

| Data Type | Retention Period | Action |
|-----------|------------------|--------|
| **Location History** | 90 days | Auto-delete via SQL Agent job |
| **Audit Logs** | 1 year | Archive to cold storage |
| **Visit Photos** | 1 year | Move to archive tier |
| **Orders** | 5 years | Retain for compliance |
| **Master Data** | Indefinite | Soft delete only |

---

## 7. Related Documents

- [05-API-DESIGN.md](05-API-DESIGN.md) - API specifications
- [07-SECURITY-ARCHITECTURE.md](07-SECURITY-ARCHITECTURE.md) - Data security
- [adr/ADR-002-sql-server.md](adr/ADR-002-sql-server.md) - Database decision
