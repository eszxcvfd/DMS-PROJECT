# DILIGO DMS - System Context (C4 Level 1)

## 1. System Context Diagram

```mermaid
C4Context
    title System Context Diagram - DILIGO DMS

    Person(nvbh, "Nhân viên bán hàng (NVBH)", "Field sales representative who visits customers and creates orders")
    Person(gsbh, "Giám sát bán hàng (GSBH)", "Sales supervisor who monitors NVBH activities")
    Person(asm, "Area Sales Manager (ASM)", "Manages sales in a region")
    Person(rsm, "Regional Sales Manager (RSM)", "Manages multiple areas")
    Person(admin, "Admin NPP", "Distributor administrator managing operations")

    System(dms, "DILIGO DMS", "Distribution Management System for managing sales force, orders, inventory, and customer relationships")

    System_Ext(maps, "Google Maps Platform", "Provides geocoding, directions, and map visualization")
    System_Ext(firebase, "Firebase Cloud Messaging", "Push notification delivery service")
    System_Ext(erp, "Oracle ERP", "Enterprise resource planning system for finance")
    System_Ext(sms, "SMS Gateway", "SMS delivery for OTP and notifications")

    Rel(nvbh, dms, "Uses mobile app for", "check-in, orders, photos")
    Rel(gsbh, dms, "Uses web/mobile for", "monitoring, approval")
    Rel(asm, dms, "Uses web for", "area reports, KPIs")
    Rel(rsm, dms, "Uses web for", "regional dashboards")
    Rel(admin, dms, "Uses web for", "master data, inventory")

    Rel(dms, maps, "Gets location data from", "REST API")
    Rel(dms, firebase, "Sends notifications via", "FCM")
    Rel(dms, erp, "Exports data to", "Excel files")
    Rel(dms, sms, "Sends SMS via", "REST API")
```

---

## 2. User Personas

### 2.1 Nhân viên bán hàng (NVBH) - Sales Representative

| Attribute | Description |
|-----------|-------------|
| **Role** | Field sales representative |
| **Primary Device** | Android smartphone |
| **Location** | On the field, visiting customers |
| **Key Activities** | Check-in/out, create orders, capture photos, update customer info |
| **Pain Points** | Limited connectivity, need offline mode, GPS accuracy |
| **Goals** | Complete daily route, maximize orders, accurate reporting |

**User Journey:**
```
Morning: Clock-in → Receive route → Travel to first customer
At Customer: Check-in → Take photos → Create order → Check-out
End of Day: Complete route → Clock-out → Sync pending data
```

### 2.2 Giám sát bán hàng (GSBH) - Sales Supervisor

| Attribute | Description |
|-----------|-------------|
| **Role** | Direct supervisor of NVBH team |
| **Primary Device** | Desktop/Laptop + Mobile |
| **Location** | Office and field visits |
| **Key Activities** | Monitor NVBH locations, approve orders, track KPIs |
| **Pain Points** | Real-time visibility, fraudulent check-ins |
| **Goals** | Ensure team productivity, quick order processing |

### 2.3 Area Sales Manager (ASM)

| Attribute | Description |
|-----------|-------------|
| **Role** | Manages multiple GSBH and routes |
| **Primary Device** | Desktop/Laptop |
| **Location** | Regional office |
| **Key Activities** | View area reports, manage routes, performance analysis |
| **Pain Points** | Aggregated data delays, route optimization |
| **Goals** | Meet regional targets, optimize coverage |

### 2.4 Regional Sales Manager (RSM)

| Attribute | Description |
|-----------|-------------|
| **Role** | Strategic management of large regions |
| **Primary Device** | Desktop/Laptop |
| **Location** | Head office |
| **Key Activities** | Dashboard analysis, strategic planning, trend analysis |
| **Pain Points** | Data consistency, reporting delays |
| **Goals** | Strategic growth, market share increase |

### 2.5 Admin NPP - Distributor Administrator

| Attribute | Description |
|-----------|-------------|
| **Role** | Operational manager at distributor |
| **Primary Device** | Desktop |
| **Location** | Distributor office |
| **Key Activities** | Manage master data, process orders, inventory, AR |
| **Pain Points** | Manual data entry, inventory accuracy |
| **Goals** | Efficient operations, accurate records |

---

## 3. External Systems

### 3.1 Google Maps Platform

| Aspect | Details |
|--------|---------|
| **Purpose** | Location services, geocoding, routing |
| **Integration Type** | REST API |
| **APIs Used** | Geocoding API, Directions API, Places API, Maps JavaScript API |
| **Data Flow** | DMS → Google Maps (coordinates) → DMS (addresses, routes) |
| **Frequency** | Real-time for live tracking, on-demand for routing |
| **Cost Model** | Pay-per-use |

### 3.2 Firebase Cloud Messaging (FCM)

| Aspect | Details |
|--------|---------|
| **Purpose** | Push notifications to mobile devices |
| **Integration Type** | FCM HTTP v1 API |
| **Message Types** | Order status, alerts, announcements |
| **Data Flow** | DMS Backend → FCM → Mobile App |
| **Frequency** | Event-driven |
| **Reliability** | Best-effort delivery with retry |

### 3.3 Oracle ERP

| Aspect | Details |
|--------|---------|
| **Purpose** | Financial and accounting integration |
| **Integration Type** | Excel file export |
| **Data Exported** | Sales transactions, inventory movements |
| **Data Flow** | DMS → Excel file → Manual import to Oracle |
| **Frequency** | Daily/Weekly batch |
| **Format** | XLSX with predefined template |

### 3.4 SMS Gateway

| Aspect | Details |
|--------|---------|
| **Purpose** | OTP verification, notifications |
| **Integration Type** | REST API |
| **Providers** | Twilio / Local provider (VN) |
| **Data Flow** | DMS → SMS Gateway → User's phone |
| **Frequency** | On-demand |
| **Reliability** | Retry mechanism with fallback |

---

## 4. System Interactions

### 4.1 Mobile App ↔ Backend

```mermaid
sequenceDiagram
    participant Mobile as NVBH Mobile App
    participant API as DMS Backend
    participant DB as SQL Server
    participant Cache as Redis

    Mobile->>API: Login (credentials)
    API->>DB: Validate user
    DB-->>API: User details
    API-->>Mobile: JWT Token + User info

    Mobile->>API: Sync master data
    API->>Cache: Check cache
    Cache-->>API: Cached data (if fresh)
    API-->>Mobile: Master data (customers, products)

    Mobile->>API: Submit check-in
    API->>DB: Store check-in
    API-->>Mobile: Confirmation

    Mobile->>API: Submit order
    API->>DB: Create order
    API->>API: Apply promotions
    API-->>Mobile: Order confirmation
```

### 4.2 Web App ↔ Backend

```mermaid
sequenceDiagram
    participant Web as Web Application
    participant API as DMS Backend
    participant SignalR as SignalR Hub
    participant DB as SQL Server

    Web->>API: Login
    API-->>Web: JWT Token

    Web->>SignalR: Connect (token)
    SignalR-->>Web: Connected

    Web->>API: Get NVBH locations
    API->>DB: Query locations
    API-->>Web: Location data

    Note over SignalR: Real-time updates
    SignalR->>Web: NVBH location updated
    SignalR->>Web: New order received
```

---

## 5. Data Flows

### 5.1 Order Processing Flow

```mermaid
flowchart LR
    A[NVBH Creates Order] --> B[Order Pending]
    B --> C{GSBH Review}
    C -->|Approve| D[Order Approved]
    C -->|Reject| E[Order Rejected]
    D --> F[Create Sales Invoice]
    F --> G[Create Warehouse Receipt]
    G --> H[Update Inventory]
    H --> I[Update Customer AR]
    I --> J[Export to Excel]
    J --> K[Import to Oracle ERP]
```

### 5.2 Location Tracking Flow

```mermaid
flowchart TD
    A[Mobile App] -->|Every 5 min| B[Collect GPS]
    B --> C{Network Available?}
    C -->|Yes| D[Send to Backend]
    C -->|No| E[Store Locally]
    D --> F[Backend Receives]
    F --> G[Store in DB]
    F --> H[Push via SignalR]
    H --> I[Web Dashboard Updates]
    E -->|When Online| D
```

---

## 6. Security Boundaries

```mermaid
flowchart TB
    subgraph External["External Network"]
        Mobile[Mobile App]
        Browser[Web Browser]
    end

    subgraph DMZ["DMZ"]
        WAF[Web Application Firewall]
        APIGW[API Gateway]
    end

    subgraph Internal["Internal Network"]
        API[API Services]
        SignalR[SignalR Hub]
        Worker[Background Workers]
    end

    subgraph Data["Data Tier"]
        DB[(SQL Server)]
        Cache[(Redis)]
        Blob[(Blob Storage)]
    end

    Mobile -->|HTTPS| WAF
    Browser -->|HTTPS| WAF
    WAF --> APIGW
    APIGW --> API
    APIGW --> SignalR
    API --> DB
    API --> Cache
    API --> Blob
    Worker --> DB
```

---

## 7. Constraints

### 7.1 Technical Constraints
| Constraint | Description | Impact |
|------------|-------------|--------|
| SQL Server only | Database must be SQL Server | Limits to Microsoft ecosystem tools |
| .NET Backend | API must be .NET | Requires Windows/Linux with .NET runtime |
| Android only | No iOS support initially | Limits to Android device users |
| Excel export for ERP | No direct ERP integration | Manual process for ERP sync |

### 7.2 Business Constraints
| Constraint | Description | Impact |
|------------|-------------|--------|
| Offline mode required | Must work without network | Requires robust sync mechanism |
| Multi-distributor | Each NPP operates independently | Data isolation requirements |
| Legacy data | Must import existing data | Migration effort required |
| Vietnamese language | Primary UI language | Localization requirements |

---

## 8. Assumptions

| ID | Assumption | Risk if Invalid |
|----|------------|-----------------|
| A1 | All NVBH have Android smartphones | Need to provide devices |
| A2 | Customers have GPS coordinates | Initial data collection effort |
| A3 | Network coverage in most areas | Extended offline capabilities |
| A4 | Users comfortable with mobile apps | Training requirements |
| A5 | Azure services available in Vietnam | Consider local cloud alternatives |

---

## 9. Dependencies

| Dependency | Type | Criticality | Fallback |
|------------|------|-------------|----------|
| Google Maps API | External Service | High | OpenStreetMap |
| Firebase FCM | External Service | Medium | Local push service |
| Azure Cloud | Infrastructure | Critical | AWS/GCP migration possible |
| SQL Server | Database | Critical | None (requirement) |
| Internet connectivity | Infrastructure | High | Offline mode |
