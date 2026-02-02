# DILIGO DMS - Component Architecture (C4 Level 3)

## Distribution Management System - Component Diagrams

**Version:** 1.0
**Last Updated:** 2026-02-02

---

## 1. Overview

This document details the internal components of each container in the DILIGO DMS system, showing their responsibilities and interactions.

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
| **OrdersController** | `/api/orders/*` | Order creation, approval, status tracking |
| **VisitsController** | `/api/visits/*` | Check-in/out, photo upload, visit history |
| **InventoryController** | `/api/inventory/*` | Stock in/out/transfer operations |
| **ReportsController** | `/api/reports/*` | KPIs, dashboards, Excel exports |
| **SyncController** | `/api/sync/*` | Delta sync, upload pending, conflict resolution |
| **AttendanceController** | `/api/attendance/*` | Clock in/out, timesheet |
| **MonitoringHub** | `/hubs/monitoring` | Real-time GPS, notifications (SignalR) |

### 2.2 Services (Business Logic)

| Service | Responsibility |
|---------|----------------|
| **AuthService** | JWT generation, token validation, password hashing |
| **CustomerService** | Customer CRUD, route filtering, GPS validation |
| **OrderService** | Order workflow (create → approve → fulfill), pricing |
| **VisitService** | Check-in validation, GPS distance check, photo handling |
| **ProductService** | Product catalog, pricing by customer type |
| **InventoryService** | Stock movements, availability checks |
| **PromotionService** | Active promotions, discount calculation |
| **ReportService** | KPI aggregation, dashboard data, exports |
| **SyncService** | Delta sync logic, conflict resolution |
| **NotificationService** | Push notifications via FCM, SignalR broadcasts |

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
| **OrderScreen** | OrderViewModel | Order creation, product selection, totals |
| **ProductScreen** | ProductViewModel | Product catalog, search, inventory |
| **CameraScreen** | CameraViewModel | Photo capture, compression, tagging |
| **ReportScreen** | ReportViewModel | KPIs, performance charts |
| **SettingsScreen** | SettingsViewModel | User preferences, sync status |

### 3.2 Key Use Cases

| Use Case | Description |
|----------|-------------|
| **LoginUseCase** | Authenticate user, store JWT, handle refresh |
| **GetRouteUseCase** | Fetch today's assigned route with customers |
| **CheckInUseCase** | Validate GPS proximity, record check-in time |
| **CreateOrderUseCase** | Build order, apply promotions, queue for sync |
| **SyncDataUseCase** | Perform delta sync with server |
| **UploadPhotoUseCase** | Compress and upload visit photos |
| **ClockInOutUseCase** | Record daily attendance |

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
