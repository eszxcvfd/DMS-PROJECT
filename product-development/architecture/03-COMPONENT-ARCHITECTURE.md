# DMS VIPPro - Component Architecture (C4 Level 3)

## Distribution Management System - Component Diagrams

**Version:** 2.0
**Last Updated:** 2026-02-04
**PRD Reference:** PRD-v2.md (v2.3)

---

## 1. Overview

This document details the internal components of each container in the DMS VIPPro system, showing their responsibilities and interactions.

---

## 2. .NET API Components

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              .NET API - COMPONENT ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                              PRESENTATION LAYER                                      │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │   │
│  │   │  Auth           │ │  Customers      │ │  Orders         │ │  Visits         │  │   │
│  │   │  Controller     │ │  Controller     │ │  Controller     │ │  Controller     │  │   │
│  │   └────────┬────────┘ └────────┬────────┘ └────────┬────────┘ └────────┬────────┘  │   │
│  │            │                   │                   │                   │           │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │   │
│  │   │  Products       │ │  Inventory      │ │  Reports        │ │  Sync           │  │   │
│  │   │  Controller     │ │  Controller     │ │  Controller     │ │  Controller     │  │   │
│  │   └────────┬────────┘ └────────┬────────┘ └────────┬────────┘ └────────┬────────┘  │   │
│  │            │                   │                   │                   │           │   │
│  │   ┌─────────────────┐ ┌─────────────────┐                                          │   │
│  │   │  Monitoring     │ │  Attendance     │    ┌─────────────────────────────────┐  │   │
│  │   │  Hub (SignalR)  │ │  Controller     │    │  Common Middleware              │  │   │
│  │   └────────┬────────┘ └────────┬────────┘    │  - ExceptionHandler             │  │   │
│  │            │                   │              │  - RequestLogging               │  │   │
│  └────────────┼───────────────────┼──────────────│  - JwtAuthentication            │  │   │
│               │                   │              │  - RateLimiting                 │  │   │
│               │                   │              └─────────────────────────────────┘  │   │
│               └───────────────────┴──────────────────────────────────────────────────┘│   │
│                                           │                                            │   │
│  ┌────────────────────────────────────────┼────────────────────────────────────────┐  │   │
│  │                          APPLICATION LAYER                                       │  │   │
│  │                                        │                                         │  │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│  │   │
│  │   │  IAuthService   │ │ ICustomerService│ │  IOrderService  │ │  IVisitService  ││  │   │
│  │   │                 │ │                 │ │                 │ │                 ││  │   │
│  │   │  - Login        │ │  - GetById      │ │  - CreateOrder  │ │  - CheckIn      ││  │   │
│  │   │  - RefreshToken │ │  - GetByRoute   │ │  - ApproveOrder │ │  - CheckOut     ││  │   │
│  │   │  - ChangePass   │ │  - Create       │ │  - RejectOrder  │ │  - UploadPhoto  ││  │   │
│  │   └────────┬────────┘ └────────┬────────┘ └────────┬────────┘ └────────┬────────┘│  │   │
│  │            │                   │                   │                   │          │  │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│  │   │
│  │   │ IProductService │ │IInventoryService│ │ IReportService  │ │  ISyncService   ││  │   │
│  │   │                 │ │                 │ │                 │ │                 ││  │   │
│  │   │  - GetProducts  │ │  - StockIn      │ │  - GetKPIs      │ │  - DeltaSync    ││  │   │
│  │   │  - GetPricing   │ │  - StockOut     │ │  - GetDashboard │ │  - UploadPending││  │   │
│  │   │  - Search       │ │  - Transfer     │ │  - ExportExcel  │ │  - ResolveConf  ││  │   │
│  │   └────────┬────────┘ └────────┬────────┘ └────────┬────────┘ └────────┬────────┘│  │   │
│  │            │                   │                   │                   │          │  │   │
│  │   ┌─────────────────┐ ┌─────────────────┐                                        │  │   │
│  │   │IPromotionService│ │INotificationSvc │         ┌─────────────────────────┐    │  │   │
│  │   │                 │ │                 │         │  Validators             │    │  │   │
│  │   │  - GetActive    │ │  - SendPush     │         │  - OrderValidator       │    │  │   │
│  │   │  - Calculate    │ │  - BroadcastHub │         │  - CustomerValidator    │    │  │   │
│  │   └─────────────────┘ └─────────────────┘         │  - VisitValidator       │    │  │   │
│  └───────────────────────────────────────────────────└─────────────────────────┘────┘  │   │
│                                           │                                            │   │
│  ┌────────────────────────────────────────┼────────────────────────────────────────┐  │   │
│  │                            DOMAIN LAYER                                          │  │   │
│  │                                        │                                         │  │   │
│  │   ┌───────────────────────────────────────────────────────────────────────────┐ │  │   │
│  │   │                         ENTITIES                                          │ │  │   │
│  │   │                                                                           │ │  │   │
│  │   │  User  Customer  Product  Order  OrderDetail  Visit  VisitPhoto          │ │  │   │
│  │   │  Distributor  Route  Attendance  StockMovement  Promotion  KPI           │ │  │   │
│  │   │                                                                           │ │  │   │
│  │   └───────────────────────────────────────────────────────────────────────────┘ │  │   │
│  │                                                                                  │  │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                   │  │   │
│  │   │  Enums          │ │  Value Objects  │ │  Repository     │                   │  │   │
│  │   │                 │ │                 │ │  Interfaces     │                   │  │   │
│  │   │  - OrderStatus  │ │  - GpsCoordinate│ │                 │                   │  │   │
│  │   │  - VisitType    │ │  - Money        │ │  - IRepository  │                   │  │   │
│  │   │  - UserRole     │ │  - DateRange    │ │  - IUnitOfWork  │                   │  │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘                   │  │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘  │   │
│                                           │                                            │   │
│  ┌────────────────────────────────────────┼────────────────────────────────────────┐  │   │
│  │                       INFRASTRUCTURE LAYER                                       │  │   │
│  │                                        │                                         │  │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐│  │   │
│  │   │  AppDbContext   │ │  Repositories   │ │  BlobStorage    │ │  FirebaseService││  │   │
│  │   │  (EF Core)      │ │                 │ │  Service        │ │                 ││  │   │
│  │   │                 │ │  - CustomerRepo │ │                 │ │  - SendPush     ││  │   │
│  │   │  - DbSets       │ │  - OrderRepo    │ │  - UploadImage  │ │  - SendToTopic  ││  │   │
│  │   │  - OnModelCreat │ │  - VisitRepo    │ │  - GetSasUrl    │ │                 ││  │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘│  │   │
│  │                                                                                  │  │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                   │  │   │
│  │   │  CacheService   │ │  MapsService    │ │  BackgroundJobs │                   │  │   │
│  │   │                 │ │                 │ │                 │                   │  │   │
│  │   │  - GetOrSet     │ │  - Geocode      │ │  - SyncWorker   │                   │  │   │
│  │   │  - Invalidate   │ │  - ReverseGeo   │ │  - CleanupJob   │                   │  │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘                   │  │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘  │   │
│                                                                                        │   │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 Controllers (API Endpoints)

| Controller | Endpoints | Description |
|------------|-----------|-------------|
| **AuthController** | `/api/auth/*` | Login, logout, refresh token, password management |
| **CustomersController** | `/api/customers/*` | Customer CRUD, search, route assignment |
| **ProductsController** | `/api/products/*` | Product catalog, pricing, inventory levels |
| **OrdersController** | `/api/orders/*` | Order creation (Pre-sales/Van-sales), approval, status tracking |
| **VisitsController** | `/api/visits/*` | Check-in/out, photo upload, visit history |
| **InventoryController** | `/api/inventory/*` | Stock in/out/transfer operations, Van-sale stock |
| **ReportsController** | `/api/reports/*` | KPIs, dashboards, Excel exports, display scoring |
| **SyncController** | `/api/sync/*` | Delta sync, upload pending, conflict resolution |
| **AttendanceController** | `/api/attendance/*` | Clock in/out, timesheet |
| **MonitoringHub** | `/hubs/monitoring` | Real-time GPS, notifications (SignalR) |
| **DistributorsController** | `/api/distributors/*` | **[v2.0]** NPP CRUD, onboarding (Mở mới NPP) |
| **RoutesController** | `/api/routes/*` | **[v2.0]** Route CRUD, customer assignment, import |
| **KPIController** | `/api/kpi/*` | **[v2.0]** KPI assignment, targets, performance tracking |

### 2.2 Services (Business Logic)

| Service | Responsibility |
|---------|----------------|
| **AuthService** | JWT generation, token validation, password hashing |
| **CustomerService** | Customer CRUD, route filtering, GPS validation |
| **OrderService** | Order workflow (Pre-sales: create → approve → fulfill; Van-sales: create → immediate fulfill), pricing |
| **VisitService** | Check-in validation, GPS distance check, photo handling |
| **ProductService** | Product catalog, pricing by customer type |
| **InventoryService** | Stock movements, availability checks, Van-sale stock management |
| **PromotionService** | Active promotions, discount calculation |
| **ReportService** | KPI aggregation, dashboard data, exports, display scoring reports |
| **SyncService** | Delta sync logic, conflict resolution |
| **NotificationService** | Push notifications via FCM, SignalR broadcasts |
| **DistributorService** | **[v2.0]** NPP onboarding, profile management, document handling |
| **RouteService** | **[v2.0]** Route CRUD, customer assignment, Excel import |
| **KPIService** | **[v2.0]** KPI target assignment, performance calculation, tracking |

---

## 3. Android App Components

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                           ANDROID APP - COMPONENT ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                              PRESENTATION (UI)                                       │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │   │
│  │   │  LoginScreen    │ │  HomeScreen     │ │  RouteScreen    │ │  CustomerScreen │  │   │
│  │   │  + ViewModel    │ │  + ViewModel    │ │  + ViewModel    │ │  + ViewModel    │  │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘  │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │   │
│  │   │  VisitScreen    │ │  OrderScreen    │ │  ProductScreen  │ │  ReportScreen   │  │   │
│  │   │  + ViewModel    │ │  + ViewModel    │ │  + ViewModel    │ │  + ViewModel    │  │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘  │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐                                           │   │
│  │   │  CameraScreen   │ │  SettingsScreen │    ┌───────────────────────────────────┐ │   │
│  │   │  + ViewModel    │ │  + ViewModel    │    │  Shared UI Components             │ │   │
│  │   └─────────────────┘ └─────────────────┘    │  - TopBar, BottomNav              │ │   │
│  │                                               │  - LoadingIndicator               │ │   │
│  │                                               │  - ErrorDialog                    │ │   │
│  │                                               │  - MapView                        │ │   │
│  └───────────────────────────────────────────────└───────────────────────────────────┘─┘   │
│                                           │                                                 │
│  ┌────────────────────────────────────────┼────────────────────────────────────────────┐   │
│  │                              DOMAIN (USE CASES)                                      │   │
│  │                                        │                                             │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │   │
│  │   │  LoginUseCase   │ │ GetRouteUseCase │ │ CheckInUseCase  │ │CreateOrderUseCase│   │   │
│  │   │                 │ │                 │ │                 │ │                 │   │   │
│  │   │  - execute()    │ │  - execute()    │ │  - execute()    │ │  - execute()    │   │   │
│  │   │  - validate()   │ │  - getCached()  │ │  - validate()   │ │  - calculate()  │   │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │   │
│  │   │ SyncDataUseCase │ │UploadPhotoUCase │ │GetProductsUCase │ │ClockInOutUseCase│   │   │
│  │   │                 │ │                 │ │                 │ │                 │   │   │
│  │   │  - deltaSync()  │ │  - compress()   │ │  - search()     │ │  - validate()   │   │   │
│  │   │  - uploadPend() │ │  - upload()     │ │  - filter()     │ │  - record()     │   │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   │   │
│  │                                                                                      │   │
│  │   ┌───────────────────────────────────────────────────────────────────────────────┐ │   │
│  │   │                         DOMAIN MODELS                                         │ │   │
│  │   │                                                                               │ │   │
│  │   │  User  Customer  Product  Order  Visit  Route  Attendance  Photo             │ │   │
│  │   │                                                                               │ │   │
│  │   └───────────────────────────────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────────────────────────┘   │
│                                           │                                                 │
│  ┌────────────────────────────────────────┼────────────────────────────────────────────┐   │
│  │                              DATA (REPOSITORIES)                                     │   │
│  │                                        │                                             │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │   │
│  │   │ AuthRepository  │ │CustomerRepository│ │ OrderRepository │ │ VisitRepository │   │   │
│  │   │                 │ │                 │ │                 │ │                 │   │   │
│  │   │  - Impl with    │ │  - Local + Remote│ │  - Offline-first│ │  - GPS handling │   │   │
│  │   │    TokenManager │ │    sync logic   │ │    queue        │ │    + photos     │   │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐                                           │   │
│  │   │ProductRepository│ │ SyncRepository  │                                           │   │
│  │   │                 │ │                 │                                           │   │
│  │   │  - Cached data  │ │  - Orchestrate  │                                           │   │
│  │   │    + refresh    │ │    all syncs    │                                           │   │
│  │   └─────────────────┘ └─────────────────┘                                           │   │
│  └──────────────────────────────────────────────────────────────────────────────────────┘   │
│                                           │                                                 │
│  ┌────────────────────────────────────────┼────────────────────────────────────────────┐   │
│  │                              DATA SOURCES                                            │   │
│  │                                        │                                             │   │
│  │   ┌─────────────────────────────────────────────────────────────────────────────┐   │   │
│  │   │                         LOCAL (Room SQLite)                                  │   │   │
│  │   │                                                                              │   │   │
│  │   │   CustomerDao  ProductDao  OrderDao  VisitDao  SyncMetadataDao  UserDao     │   │   │
│  │   │                                                                              │   │   │
│  │   │   - @Insert, @Update, @Delete, @Query                                        │   │   │
│  │   │   - Flow<List<T>> for reactive updates                                       │   │   │
│  │   │                                                                              │   │   │
│  │   └─────────────────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                                      │   │
│  │   ┌─────────────────────────────────────────────────────────────────────────────┐   │   │
│  │   │                         REMOTE (Retrofit)                                    │   │   │
│  │   │                                                                              │   │   │
│  │   │   AuthApi  CustomerApi  OrderApi  VisitApi  ProductApi  SyncApi             │   │   │
│  │   │                                                                              │   │   │
│  │   │   - @GET, @POST, @PUT, @DELETE                                              │   │   │
│  │   │   - suspend functions for coroutines                                         │   │   │
│  │   │                                                                              │   │   │
│  │   └─────────────────────────────────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────────────────────────────┘   │
│                                           │                                                 │
│  ┌────────────────────────────────────────┼────────────────────────────────────────────┐   │
│  │                         CORE / FRAMEWORK                                             │   │
│  │                                        │                                             │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │   │
│  │   │ LocationManager │ │  CameraManager  │ │  SyncWorker     │ │  NetworkMonitor │   │   │
│  │   │                 │ │                 │ │  (WorkManager)  │ │                 │   │   │
│  │   │  - GPS tracking │ │  - CameraX      │ │                 │ │  - Connectivity │   │   │
│  │   │  - Background   │ │  - Compression  │ │  - Periodic     │ │    listener     │   │   │
│  │   │    location     │ │                 │ │  - Constraints  │ │                 │   │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                       │   │
│  │   │  TokenManager   │ │  FCMService     │ │   Hilt DI       │                       │   │
│  │   │                 │ │                 │ │   Modules       │                       │   │
│  │   │  - SecurePrefs  │ │  - OnMessage    │ │                 │                       │   │
│  │   │  - Refresh      │ │  - Token update │ │  - NetworkMod   │                       │   │
│  │   └─────────────────┘ └─────────────────┘ │  - DatabaseMod  │                       │   │
│  │                                           │  - RepoModule   │                       │   │
│  │                                           └─────────────────┘                       │   │
│  └──────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.1 Screens and ViewModels

| Screen | ViewModel | Key Functions |
|--------|-----------|---------------|
| **LoginScreen** | LoginViewModel | User authentication, credential storage |
| **HomeScreen** | HomeViewModel | Dashboard, today's summary, quick actions |
| **RouteScreen** | RouteViewModel | Today's route, customer list, map view |
| **CustomerScreen** | CustomerViewModel | Customer details, visit history, orders |
| **VisitScreen** | VisitViewModel | Check-in/out, GPS capture, status update |
| **OrderScreen** | OrderViewModel | Order creation (Pre-sales/Van-sales), product selection, totals |
| **ProductScreen** | ProductViewModel | Product catalog, search, inventory |
| **CameraScreen** | CameraViewModel | Photo capture, compression, tagging |
| **ReportScreen** | ReportViewModel | KPIs, performance charts |
| **SettingsScreen** | SettingsViewModel | User preferences, sync status |
| **NPPOnboardingScreen** | NPPOnboardingViewModel | **[v2.0 GSBH]** Create new NPP, capture docs/photos |
| **RouteManagementScreen** | RouteManagementViewModel | **[v2.0 GSBH]** Create/edit routes, assign customers |
| **KPIAssignmentScreen** | KPIAssignmentViewModel | **[v2.0 GSBH]** Set KPI targets for employees |
| **EmployeeMonitorScreen** | EmployeeMonitorViewModel | **[v2.0 GSBH]** View employee locations/visits/photos |

### 3.2 Key Use Cases

| Use Case | Description |
|----------|-------------|
| **LoginUseCase** | Authenticate user, store JWT, handle refresh |
| **GetRouteUseCase** | Fetch today's assigned route with customers |
| **CheckInUseCase** | Validate GPS proximity, record check-in time |
| **CreateOrderUseCase** | Build order (Pre-sales or Van-sales), apply promotions, queue for sync |
| **SyncDataUseCase** | Perform delta sync with server |
| **UploadPhotoUseCase** | Compress and upload visit photos |
| **ClockInOutUseCase** | Record daily attendance |
| **CreateNPPUseCase** | **[v2.0 GSBH]** Create new distributor with photos and documents |
| **ManageRouteUseCase** | **[v2.0 GSBH]** Create/edit routes, assign customers, import Excel |
| **AssignKPIUseCase** | **[v2.0 GSBH]** Set KPI targets for employees with date ranges |
| **VanSaleOrderUseCase** | **[v2.0]** Create Van-sale order with immediate stock deduction |

---

## 4. Web Application Components

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                           WEB APP - COMPONENT ARCHITECTURE                                  │
│                                  (React + TypeScript)                                       │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                   PAGES                                              │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │   │
│  │   │  LoginPage      │ │  DashboardPage  │ │  MonitoringPage │ │  OrdersPage     │  │   │
│  │   │                 │ │                 │ │                 │ │                 │  │   │
│  │   │  - LoginForm    │ │  - KPICards     │ │  - LiveMap      │ │  - OrderList    │  │   │
│  │   │  - AuthContext  │ │  - Charts       │ │  - EmployeeList │ │  - OrderDetail  │  │   │
│  │   │                 │ │  - Alerts       │ │  - Filters      │ │  - Approval     │  │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘  │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐  │   │
│  │   │  CustomersPage  │ │  ProductsPage   │ │  InventoryPage  │ │  ReportsPage    │  │   │
│  │   │                 │ │                 │ │                 │ │                 │  │   │
│  │   │  - CustomerTable│ │  - ProductGrid  │ │  - StockList    │ │  - ReportFilters│  │   │
│  │   │  - CustomerForm │ │  - PriceEditor  │ │  - MovementForm │ │  - DataTable    │  │   │
│  │   │  - MapView      │ │  - CategoryTree │ │  - StockCard    │ │  - ExportBtn    │  │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘  │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐                                           │   │
│  │   │  VisitsPage     │ │  SettingsPage   │                                           │   │
│  │   │                 │ │                 │                                           │   │
│  │   │  - VisitTable   │ │  - UserProfile  │                                           │   │
│  │   │  - PhotoGallery │ │  - Preferences  │                                           │   │
│  │   │  - Timeline     │ │  - UserMgmt     │                                           │   │
│  │   └─────────────────┘ └─────────────────┘                                           │   │
│  └─────────────────────────────────────────────────────────────────────────────────────┘   │
│                                           │                                                 │
│  ┌────────────────────────────────────────┼────────────────────────────────────────────┐   │
│  │                               COMPONENTS                                             │   │
│  │                                        │                                             │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │   │
│  │   │  Layout         │ │  DataTable      │ │  MapComponent   │ │  Charts         │   │   │
│  │   │  - Header       │ │  - Sortable     │ │  - Leaflet/GMaps│ │  - LineChart    │   │   │
│  │   │  - Sidebar      │ │  - Pagination   │ │  - Markers      │ │  - BarChart     │   │   │
│  │   │  - Footer       │ │  - Filters      │ │  - Polylines    │ │  - PieChart     │   │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   │   │
│  │                                                                                      │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │   │
│  │   │  Forms          │ │  Modals         │ │  Cards          │ │  Common         │   │   │
│  │   │  - Input        │ │  - Confirm      │ │  - KPICard      │ │  - Loading      │   │   │
│  │   │  - Select       │ │  - Detail       │ │  - StatCard     │ │  - ErrorBoundary│   │   │
│  │   │  - DatePicker   │ │  - Form         │ │  - CustomerCard │ │  - Toast        │   │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────────────────────────────┘   │
│                                           │                                                 │
│  ┌────────────────────────────────────────┼────────────────────────────────────────────┐   │
│  │                                 HOOKS & STATE                                        │   │
│  │                                        │                                             │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │   │
│  │   │  useAuth        │ │  useOrders      │ │  useCustomers   │ │  useRealtime    │   │   │
│  │   │                 │ │  (React Query)  │ │  (React Query)  │ │  (SignalR)      │   │   │
│  │   │  - login()      │ │                 │ │                 │ │                 │   │   │
│  │   │  - logout()     │ │  - list         │ │  - list         │ │  - locations    │   │   │
│  │   │  - user         │ │  - approve      │ │  - create       │ │  - notifications│   │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   │   │
│  │                                                                                      │   │
│  │   ┌───────────────────────────────────────────────────────────────────────────────┐ │   │
│  │   │                         Zustand Store (Global State)                          │ │   │
│  │   │                                                                               │ │   │
│  │   │  authStore  uiStore (sidebar, theme)  filterStore (date range, territory)   │ │   │
│  │   │                                                                               │ │   │
│  │   └───────────────────────────────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────────────────────────┘   │
│                                           │                                                 │
│  ┌────────────────────────────────────────┼────────────────────────────────────────────┐   │
│  │                                 API LAYER                                            │   │
│  │                                        │                                             │   │
│  │   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                       │   │
│  │   │  apiClient      │ │  signalRClient  │ │  api/*          │                       │   │
│  │   │  (Axios)        │ │                 │ │                 │                       │   │
│  │   │                 │ │  - connect()    │ │  - authApi      │                       │   │
│  │   │  - interceptors │ │  - subscribe()  │ │  - ordersApi    │                       │   │
│  │   │  - refresh      │ │  - handlers     │ │  - customersApi │                       │   │
│  │   └─────────────────┘ └─────────────────┘ └─────────────────┘                       │   │
│  └──────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.1 Pages Detail

| Page | Components | Key Features |
|------|------------|--------------|
| **LoginPage** | LoginForm, AuthContext | User authentication, SSO integration |
| **DashboardPage** | KPICards, Charts, AlertList | Real-time metrics, notifications |
| **MonitoringPage** | LiveMap, EmployeeList, FilterPanel | GPS tracking, employee status |
| **OrdersPage** | OrderTable, OrderDetailModal, ApprovalButtons | Order management, bulk actions |
| **CustomersPage** | CustomerTable, CustomerForm, MapView | Customer CRUD, route assignment |
| **ProductsPage** | ProductGrid, PriceEditor, CategoryTree | Product catalog management |
| **InventoryPage** | StockList, MovementForm, TransferModal | Stock management, Van-sale transfers |
| **ReportsPage** | ReportFilters, DataTable, ExportButton | Analytics, Excel exports |
| **VisitsPage** | VisitTable, PhotoGallery, Timeline | Visit history, photo review |
| **SettingsPage** | UserProfile, Preferences, UserManagement | System configuration |
| **NPPManagementPage** | NPPTable, NPPForm, PhotoGallery | **[v2.0]** Distributor management |
| **RouteManagementPage** | RouteTable, RouteEditor, CustomerAssignment | **[v2.0]** Route CRUD |
| **KPIDashboardPage** | KPITargetTable, PerformanceCharts, EmployeeSelector | **[v2.0]** KPI tracking |
| **DisplayScoringPage** | PendingScoreList, PhotoViewer, ScoreForm | **[v2.0]** VIP display scoring |

### 4.2 Custom Hooks

```typescript
// useAuth.ts
const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const login = async (username: string, password: string) => { ... };
  const logout = async () => { ... };
  const refreshToken = async () => { ... };

  return { user, isLoading, login, logout, refreshToken };
};

// useOrders.ts (React Query)
const useOrders = (filters: OrderFilters) => {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => ordersApi.list(filters),
  });
};

const useApproveOrder = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ordersApi.approve,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    },
  });
};

// useRealtime.ts (SignalR)
const useRealtime = (distributorId: string) => {
  const [locations, setLocations] = useState<Map<string, Location>>(new Map());
  const connectionRef = useRef<HubConnection | null>(null);

  useEffect(() => {
    const connection = new HubConnectionBuilder()
      .withUrl(`${API_URL}/hubs/monitoring`, {
        accessTokenFactory: () => getAccessToken(),
      })
      .withAutomaticReconnect()
      .build();

    connection.on('LocationUpdate', (data: LocationUpdate) => {
      setLocations(prev => new Map(prev).set(data.userId, data));
    });

    connection.start().then(() => {
      connection.invoke('JoinGroup', `Location_${distributorId}`);
    });

    connectionRef.current = connection;
    return () => { connection.stop(); };
  }, [distributorId]);

  return { locations };
};

// useKPI.ts [v2.0]
const useKPIPerformance = (userId: string, month: string) => {
  return useQuery({
    queryKey: ['kpi-performance', userId, month],
    queryFn: () => kpiApi.getPerformance(userId, month),
    refetchInterval: 5 * 60 * 1000, // Refresh every 5 minutes
  });
};

// useDisplayScoring.ts [v2.0]
const usePendingScores = (filters: ScoreFilters) => {
  return useQuery({
    queryKey: ['display-scores', 'pending', filters],
    queryFn: () => displayScoreApi.listPending(filters),
  });
};

const useScoreDisplay = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: displayScoreApi.score,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['display-scores'] });
    },
  });
};
```

### 4.3 State Management (Zustand)

```typescript
// authStore.ts
interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  setAuth: (user: User, tokens: Tokens) => void;
  clearAuth: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      setAuth: (user, tokens) => set({
        user,
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      }),
      clearAuth: () => set({
        user: null,
        accessToken: null,
        refreshToken: null,
      }),
    }),
    { name: 'auth-storage' }
  )
);

// filterStore.ts
interface FilterState {
  dateRange: DateRange;
  distributorId: string | null;
  territory: string | null;
  setDateRange: (range: DateRange) => void;
  setDistributor: (id: string) => void;
}

export const useFilterStore = create<FilterState>((set) => ({
  dateRange: { from: startOfMonth(new Date()), to: new Date() },
  distributorId: null,
  territory: null,
  setDateRange: (range) => set({ dateRange: range }),
  setDistributor: (id) => set({ distributorId: id }),
}));
```

### 4.4 API Layer

```typescript
// apiClient.ts
const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Try refresh token
      const refreshed = await refreshAccessToken();
      if (refreshed) {
        return apiClient.request(error.config);
      }
      useAuthStore.getState().clearAuth();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// ordersApi.ts
export const ordersApi = {
  list: (filters: OrderFilters) =>
    apiClient.get<PaginatedResponse<Order>>('/orders', { params: filters }),

  getById: (id: string) =>
    apiClient.get<Order>(`/orders/${id}`),

  create: (data: CreateOrderDto) =>
    apiClient.post<Order>('/orders', data),

  approve: (id: string) =>
    apiClient.post(`/orders/${id}/approve`),

  reject: (id: string, reason: string) =>
    apiClient.post(`/orders/${id}/reject`, { reason }),
};

// kpiApi.ts [v2.0]
export const kpiApi = {
  getTargets: (filters: KPIFilters) =>
    apiClient.get<PaginatedResponse<KPITarget>>('/kpi/targets', { params: filters }),

  createTarget: (data: CreateKPITargetDto) =>
    apiClient.post<KPITarget>('/kpi/targets', data),

  getPerformance: (userId: string, month: string) =>
    apiClient.get<KPIPerformance>(`/kpi/performance/${userId}`, { params: { month } }),
};

// displayScoreApi.ts [v2.0]
export const displayScoreApi = {
  listPending: (filters: ScoreFilters) =>
    apiClient.get<PaginatedResponse<DisplayScore>>('/display-scores', {
      params: { ...filters, isPending: true }
    }),

  score: (id: string, data: ScoreDto) =>
    apiClient.post(`/display-scores/${id}/score`, data),

  bulkScore: (scores: BulkScoreDto[]) =>
    apiClient.post('/display-scores/bulk-score', { scores }),
};
```

---

## 5. Component Interactions

### 5.1 Order Approval Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                           ORDER APPROVAL COMPONENT FLOW                                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  MOBILE APP                    .NET API                           WEB APP              │
│  ──────────                    ────────                           ───────              │
│                                                                                         │
│  1. OrderScreen                                                                         │
│     │                                                                                   │
│     ├── CreateOrderUseCase                                                             │
│     │   └── OrderRepository.create()                                                   │
│     │       └── OrderApi.POST /api/orders                                              │
│     │           │                                                                       │
│     │           ▼                                                                       │
│     │       2. OrdersController.Create()                                               │
│     │           └── OrderService.CreateOrder()                                         │
│     │               ├── Validate order                                                 │
│     │               ├── Apply promotions                                               │
│     │               ├── Save to database                                               │
│     │               └── NotificationService.NotifySupervisor()                         │
│     │                   │                                                               │
│     │                   ├── SignalR → MonitoringHub                                    │
│     │                   │                                                   ┌──────────┤
│     │                   │                                                   │          │
│     │                   └── FCM push notification                          3. Real-time│
│     │                                                                         update   │
│     │                                                                       │          │
│     │                                                   ┌───────────────────┘          │
│     │                                                   ▼                              │
│     │                                               OrdersPage                         │
│     │                                               │                                  │
│     │                                               ├── useOrders hook receives update│
│     │                                               │                                  │
│     │                                               ├── 4. Supervisor reviews order   │
│     │                                               │   └── OrderDetail modal         │
│     │                                               │                                  │
│     │                                               ├── 5. Clicks "Approve"           │
│     │                                               │   └── ordersApi.approve(id)     │
│     │                                               │       │                         │
│     │           ┌─────────────────────────────────────────────┘                       │
│     │           ▼                                                                      │
│     │       6. OrdersController.Approve()                                              │
│     │           └── OrderService.ApproveOrder()                                        │
│     │               ├── Update status                                                  │
│     │               ├── Create sales invoice                                           │
│     │               ├── NotificationService.NotifyNVBH()                               │
│     │               │   └── FCM push to mobile                                         │
│     │               │       │                                                          │
│     ◄───────────────────────┘                                                          │
│     │                                                                                   │
│  7. FCMService receives push                                                           │
│     └── Notification shown to NVBH                                                     │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 GPS Monitoring Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                           GPS MONITORING COMPONENT FLOW                                  │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  ANDROID APP                                                                            │
│  ──────────                                                                             │
│                                                                                         │
│  LocationManager (Background Service)                                                   │
│  │                                                                                      │
│  ├── 1. Request location updates every 5 min                                           │
│  │   └── FusedLocationProviderClient                                                   │
│  │                                                                                      │
│  ├── 2. On location update                                                              │
│  │   ├── Store locally (Room)                                                          │
│  │   └── If online, send to API                                                        │
│  │       │                                                                              │
│  │       └── POST /api/monitoring/location                                             │
│  │           │                                                                          │
│  │           ▼                                                                          │
│  │                                                                                      │
│  .NET API                                                                               │
│  ────────                                                                               │
│  │                                                                                      │
│  3. MonitoringController.UpdateLocation()                                               │
│     │                                                                                   │
│     ├── Save to LocationHistory table                                                   │
│     │                                                                                   │
│     └── MonitoringHub.BroadcastToGroup()                                               │
│         │ Group: "Location_{DistributorId}"                                            │
│         │                                                                               │
│         ▼                                                                               │
│                                                                                         │
│  WEB APP                                                                                │
│  ───────                                                                                │
│  │                                                                                      │
│  4. useRealtime hook                                                                    │
│     │                                                                                   │
│     ├── signalRClient.on("LocationUpdate", handler)                                    │
│     │                                                                                   │
│     └── Updates map markers in MonitoringPage                                          │
│         │                                                                               │
│         └── MapComponent re-renders with new position                                  │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Related Documents

- [02-CONTAINER-ARCHITECTURE.md](02-CONTAINER-ARCHITECTURE.md) - Container overview
- [04-DATA-ARCHITECTURE.md](04-DATA-ARCHITECTURE.md) - Database schema
- [05-API-DESIGN.md](05-API-DESIGN.md) - API endpoint specifications
- [08-MOBILE-ARCHITECTURE.md](08-MOBILE-ARCHITECTURE.md) - Android app details
