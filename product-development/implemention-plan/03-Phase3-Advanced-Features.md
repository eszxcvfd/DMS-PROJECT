# Phase 3: Advanced Features - Implementation Plan

**Project:** DMS VIPPro (Distribution Management System)
**Phase:** 3 - Advanced Features
**PRD Version:** v2.3
**Architecture Version:** v2.0
**Status:** Planning
**Target Completion:** TBD

---

## 1. Phase Overview

Phase 3 implements advanced features that enhance the system's capabilities, including full KPI management, GSBH mobile functions (NPP onboarding, route management, KPI assignment), display scoring, Van-sale stock management, and advanced reporting. This phase also prepares the system for external integrations.

### 1.1 Objectives

- Implement complete KPI management system (targets, tracking, reports)
- Build GSBH mobile functions (Mở mới NPP, Quản lý tuyến, Chia KPI)
- Develop display scoring system (chấm điểm trưng bày VIP)
- Implement Van-sale stock management
- Create advanced reporting and analytics dashboards
- Prepare for external system integrations

### 1.2 Success Criteria

- [ ] KPI targets can be assigned and tracked
- [ ] GSBH can create NPP profiles on mobile
- [ ] GSBH can manage routes on mobile
- [ ] Display photos can be scored (Đạt/Không đạt)
- [ ] Van-sale stock tracked accurately
- [ ] Advanced reports available (multi-dimensional analysis)

---

## 2. Technical Architecture Reference

### 2.1 Database Groups Involved

- **Group J (KPI)**: KPI Metrics, KPI Targets, Product KPIs
- **Group I (Field Force)**: Display Scores (extended)
- **Group H (Inventory)**: Van-sale warehouse management
- **Group A (Organization)**: Extended org hierarchy support

### 2.2 New Business Flows

#### GSBH Mobile Flow
```
GSBH creates NPP profile → Upload photos → Submit → Admin approves → NPP active
GSBH creates route → Assign customers → Import from Excel
GSBH assigns KPI → Set targets → Employees view on mobile
```

#### Display Scoring Flow
```
NVBH uploads display photos → Pending queue → GSBH scores (Đạt/Không đạt) → Report generated
```

---

## 3. Detailed Implementation Tasks

### 3.1 KPI Management System (Week 1-3)

#### Task 3.1: KPI Model & Database
**Description:** Implement KPI tracking database structure

**Subtasks:**
- [ ] Create EF Core migration for Group J (KPI):
  - `kpi_metric` table (metric definitions: visits, orders, revenue, etc.)
  - `kpi_target` table (targets per employee/month)
  - `kpi_product_target` table (focus product targets)
- [ ] Add KPI calculation logic:
  - `actual_value` - calculated from transactions
  - `achievement_percent` - (actual / target) * 100
  - `trend` - ahead/on_track/behind based on pace
- [ ] Implement KPI types:
  - General KPIs: visits, orders, revenue, new customers, SKU count, working hours
  - Product KPIs: quantity and revenue for focus products

**Deliverables:**
- EF Core migration for KPI
- KPI entities with calculation logic

**Dependencies:** Phase 2 complete (orders, visits, attendance working)
**Estimated Time:** 3 days

---

#### Task 3.2: KPI Service (Calculation Engine)
**Description:** Implement KPI calculation and tracking

**Subtasks:**
- [ ] Create `KPIService`:
  - `assignTargets()` - set KPI targets for employee/month
  - `assignProductTargets()` - set focus product targets
  - `calculateKPIs()` - compute actual values from transactions
  - `calculateTrend()` - determine ahead/on_track/behind
  - `getKPIPerformance()` - get KPI results for employee
  - `getTeamKPI()` - aggregate KPIs for team/branch
- [ ] Implement KPI calculation formulas:
  - Visit Count: COUNT(visits WHERE visitDate IN period)
  - Order Count: COUNT(orders WHERE orderDate IN period AND status != 'Rejected')
  - Revenue: SUM(orders.totalAmount)
  - New Customers: COUNT(customers WHERE createdAt IN period)
  - SKU Count: COUNT(DISTINCT products in orders)
  - Working Hours: SUM(clockOutTime - clockInTime)
- [ ] Add KPI aggregation levels:
  - Employee level (individual performance)
  - Team level (GSBH team)
  - Branch level (ASM territory)
  - Region level (RSM area)

**Deliverables:**
- `KPIService` with all calculations
- Unit tests for KPI formulas
- KPI aggregation logic

**Dependencies:** Task 3.1
**Estimated Time:** 6 days

---

#### Task 3.3: KPI Management API
**Description:** REST API for KPI operations

**Subtasks:**
- [ ] Implement `KPIController`:
  - `GET /api/kpi/metrics` (list available KPI types)
  - `GET /api/kpi/targets` (list targets with filters)
    - Query params: distributorId, userId, month
  - `GET /api/kpi/targets/{id}` (target details)
  - `POST /api/kpi/targets` (create KPI target)
    - Body: userId, targetMonth, visitTarget, orderTarget, revenueTarget, etc.
  - `POST /api/kpi/targets/{id}/products` (add product targets)
    - Body: products array (productId, quantityTarget, revenueTarget)
  - `PUT /api/kpi/targets/{id}` (update target)
  - `GET /api/kpi/performance/{userId}` (KPI performance)
    - Query params: month
  - `GET /api/kpi/team` (team KPI summary)
    - Query params: unitId, month
  - `GET /api/kpi/ranking` (employee ranking)
    - Query params: month, metric
- [ ] Add KPI calculation endpoint (manual trigger)
- [ ] Implement KPI export (Excel)

**Deliverables:**
- KPI API endpoints (10+)
- Swagger documentation
- Integration tests

**Dependencies:** Task 3.2
**Estimated Time:** 4 days

---

### 3.2 GSBH Mobile - NPP Onboarding (Week 3-5)

#### Task 3.4: Distributor Model Extensions
**Description:** Extend distributor model for onboarding

**Subtasks:**
- [ ] Update `distributor` table with onboarding fields:
  - `owner_name`, `owner_family_info` (JSONB)
  - `infrastructure_info` (JSONB)
  - `vippro_target` (text)
  - `onboarding_status`: 'DRAFT', 'PENDING', 'APPROVED', 'REJECTED'
  - `onboarding_date`, `onboarding_by`
- [ ] Create `distributor_photo` table:
  - `photo_type`: 'StoreFront', 'OwnerPhoto', 'MeetingPhoto', 'BusinessLicense', 'TaxCertificate', 'Contract'
  - `photo_url`, `thumbnail_url`
  - `captured_at`, `captured_by`
- [ ] Add document upload support

**Deliverables:**
- EF Core migration for distributor extensions
- Photo entity for NPP documents

**Dependencies:** Task 3.3
**Estimated Time:** 2 days

---

#### Task 3.5: NPP Onboarding Service
**Description:** Implement NPP creation and approval workflow

**Subtasks:**
- [ ] Create `DistributorOnboardingService`:
  - `createDistributorProfile()` - create draft NPP
  - `uploadPhoto()` - upload NPP photos
  - `submitForApproval()` - submit to admin
  - `approve()` - admin approves NPP
  - `reject()` - admin rejects with reason
  - `getOnboardingStatus()` - check status
- [ ] Implement validation rules:
  - Required fields for NPP creation
  - Photo requirements (at least store front, owner, meeting photos)
  - Tax code validation
  - Bank account validation

**Deliverables:**
- `DistributorOnboardingService`
- Validation rules
- Unit tests

**Dependencies:** Task 3.4
**Estimated Time:** 4 days

---

#### Task 3.6: NPP Onboarding API
**Description:** API for GSBH mobile NPP onboarding

**Subtasks:**
- [ ] Extend `DistributorsController`:
  - `POST /api/distributors` (create NPP - extended)
    - Body: All NPP fields including family info, infrastructure, targets
  - `POST /api/distributors/{id}/photos` (upload NPP photo)
    - Body: photo (multipart), photoType, latitude, longitude, notes
  - `GET /api/distributors/{id}/photos` (list NPP photos)
  - `POST /api/distributors/{id}/submit` (submit for approval)
  - `POST /api/distributors/{id}/approve` (admin approve)
  - `POST /api/distributors/{id}/reject` (admin reject)
    - Body: reason
  - `GET /api/distributors/pending` (list pending approvals)
- [ ] Add photo upload to Azure Blob (organized path)
- [ ] Implement approval workflow
- [ ] Add notification on approval/rejection

**Deliverables:**
- NPP onboarding API endpoints
- Approval workflow
- Swagger documentation

**Dependencies:** Task 3.5
**Estimated Time:** 3 days

---

#### Task 3.7: Mobile - NPP Onboarding Screens
**Description:** GSBH mobile screens for creating NPP

**Subtasks:**
- [ ] Create `NPPOnboardingScreen` (multi-step form):
  - Step 1: Basic info (code, name, tax code, address, contact)
  - Step 2: Owner info (name, phone, family, 6 quả phúc)
  - Step 3: Infrastructure (warehouse, staff, vehicles)
  - Step 4: VIPPro targets (revenue, growth goals)
  - Step 5: Photo upload (store front, owner, meeting, docs)
  - Review and submit
- [ ] Create `NPPOnboardingViewModel`:
  - `saveDraft()` - save current step
  - `uploadPhoto()` - compress and upload
  - `submitForApproval()` - submit
  - `loadDraft()` - load saved draft
- [ ] Create `CameraScreen` (NPP photos):
  - Capture photos for each required type
  - Preview and retake
  - Upload with GPS and metadata
- [ ] Add NPP handbook viewer (read before creating)

**Deliverables:**
- NPP onboarding screens
- Photo upload for NPP
- Draft save functionality

**Dependencies:** Task 3.6
**Estimated Time:** 5 days

---

### 3.3 GSBH Mobile - Route Management (Week 5-7)

#### Task 3.8: Route Management Service Extensions
**Description:** Enhance route management for mobile

**Subtasks:**
- [ ] Extend `RouteService`:
  - `bulkAssignCustomers()` - assign multiple customers to route
  - `importRoutesFromExcel()` - parse Excel and create routes
  - `getRoutesByEmployee()` - list routes for employee
  - `getRouteCustomers()` - get customers in route with visit order
  - `updateCustomerVisitOrder()` - reorder customers
  - `validateRoute()` - check route constraints
- [ ] Implement Excel import logic:
  - Parse Excel format (RouteCode, RouteName, DayOfWeek, CustomerCode, VisitOrder, AssignedUsername)
  - Validate customer codes exist
  - Validate employee exists
  - Create or update routes
  - Assign customers with visit order
- [ ] Add route optimization validation (basic)

**Deliverables:**
- Extended `RouteService`
- Excel import logic
- Route validation rules

**Dependencies:** Task 3.7
**Estimated Time:** 4 days

---

#### Task 3.9: Route Management API Extensions
**Description:** API for GSBH mobile route management

**Subtasks:**
- [ ] Extend `RoutesController`:
  - `POST /api/routes` (create route - extended)
  - `PUT /api/routes/{id}` (update route)
  - `POST /api/routes/{id}/customers` (add customers - bulk)
    - Body: customers array (customerId, visitOrder)
  - `PATCH /api/routes/{id}/customers` (update visit order)
    - Body: customers array (customerId, visitOrder)
  - `DELETE /api/routes/{id}/customers/{customerId}` (remove customer)
  - `POST /api/routes/import` (import from Excel)
    - Body: file (xlsx), distributorId, overwrite
  - `GET /api/routes/by-employee/{employeeId}` (employee routes)
  - `GET /api/routes/{id}/customers` (route customers with order)
- [ ] Add Excel file upload handling
- [ ] Implement import error reporting

**Deliverables:**
- Route management API extensions
- Excel import endpoint
- Import validation

**Dependencies:** Task 3.8
**Estimated Time:** 3 days

---

#### Task 3.10: Mobile - Route Management Screens
**Description:** GSBH mobile screens for managing routes

**Subtasks:**
- [ ] Create `RouteListScreen`:
  - List of routes for distributor
  - Filter by day of week, employee
  - Create new route button
  - Import from Excel button
- [ ] Create `RouteDetailScreen`:
  - Route info (code, name, day, assigned employee)
  - Customer list with visit order
  - Drag-and-drop reordering
  - Add customer button
  - Remove customer button
  - Save button
- [ ] Create `RouteCreateScreen`:
  - Route form (code, name, day, assigned employee)
  - Add customers (search and select)
  - Set visit order
  - Save route
- [ ] Create `ExcelImportScreen`:
  - Upload Excel file
  - Preview import data
  - Show validation errors
  - Confirm import
- [ ] Implement drag-and-drop customer reordering

**Deliverables:**
- Route management screens
- Excel import UI
- Drag-and-drop reordering

**Dependencies:** Task 3.9
**Estimated Time:** 5 days

---

### 3.4 GSBH Mobile - KPI Assignment (Week 7-9)

#### Task 3.11: KPI Assignment Service
**Description:** Service for assigning KPIs to employees

**Subtasks:**
- [ ] Create `KPIAssignmentService`:
  - `assignEmployeeKPI()` - set KPI targets for employee
  - `assignProductKPI()` - set focus product targets
  - `batchAssignKPI()` - assign KPIs to multiple employees
  - `getKPIAssignment()` - get assigned targets
  - `copyKPIFromTemplate()` - copy from template/month
- [ ] Implement KPI assignment validation:
  - Target values should be realistic
  - Date ranges should be valid
  - Product targets should reference valid products

**Deliverables:**
- `KPIAssignmentService`
- KPI assignment validation

**Dependencies:** Task 3.10
**Estimated Time:** 3 days

---

#### Task 3.12: KPI Assignment API Extensions
**Description:** API for GSBH mobile KPI assignment

**Subtasks:**
- [ ] Extend `KPIController` for mobile:
  - `GET /api/kpi/assignments` (list assignments)
    - Query params: distributorId, userId, month
  - `POST /api/kpi/assignments` (create KPI assignment)
    - Body: userId, targetMonth, visitTarget, orderTarget, revenueTarget, etc.
  - `POST /api/kpi/assignments/{id}/products` (add product targets)
    - Body: products array
  - `PUT /api/kpi/assignments/{id}` (update assignment)
  - `DELETE /api/kpi/assignments/{id}` (delete assignment)
  - `GET /api/kpi/templates` (list KPI templates)
  - `POST /api/kpi/assign-batch` (batch assign)
    - Body: employeeIds, targetMonth, targets
- [ ] Add KPI template support

**Deliverables:**
- KPI assignment API endpoints
- Batch assignment functionality

**Dependencies:** Task 3.11
**Estimated Time:** 2 days

---

#### Task 3.13: Mobile - KPI Assignment Screens
**Description:** GSBH mobile screens for assigning KPIs

**Subtasks:**
- [ ] Create `EmployeeListScreen`:
  - List employees under GSBH
  - Filter by role, status
  - Select employee to assign KPI
- [ ] Create `KPIAssignmentScreen`:
  - Employee info
  - Month selector
  - General KPI targets (visits, orders, revenue, etc.)
  - Focus product KPIs
  - Save button
- [ ] Create `ProductKPIScreen`:
  - Product list
  - Set quantity and revenue targets
  - Add/remove products
- [ ] Create `BatchKPIAssignScreen`:
  - Select multiple employees
  - Set common targets
  - Assign to all selected
- [ ] Show KPI performance preview

**Deliverables:**
- KPI assignment screens
- Product KPI screen
- Batch assignment UI

**Dependencies:** Task 3.12
**Estimated Time:** 4 days

---

### 3.5 Display Scoring System (Week 9-11)

#### Task 3.14: Display Score Model
**Description:** Implement display scoring database

**Subtasks:**
- [ ] Create `display_score` table:
  - `visit_id` (FK to visit)
  - `customer_id`, `salesman_id`
  - `photo_count` (number of photos)
  - `upload_date`
  - `scored_by_user_id`, `scored_date`
  - `is_passed` (Đạt/Không đạt)
  - `revenue` (customer revenue at scoring time)
  - `notes`
- [ ] Link display scores to visits with photos
- [ ] Add display score status: 'PENDING', 'SCORED'

**Deliverables:**
- EF Core migration for display scoring
- Display score entity

**Dependencies:** Task 3.13
**Estimated Time:** 2 days

---

#### Task 3.15: Display Scoring Service
**Description:** Implement display scoring logic

**Subtasks:**
- [ ] Create `DisplayScoringService`:
  - `getPendingScores()` - get un-scored displays
  - `scoreDisplay()` - score display (Đạt/Không đạt)
  - `bulkScoreDisplays()` - score multiple displays
  - `getDisplayScoreReport()` - generate report
  - `getDisplayScoreSummary()` - summary stats
- [ ] Implement display score calculation:
  - Check if visit has photos
  - Link to customer revenue
  - Record scoring metadata

**Deliverables:**
- `DisplayScoringService`
- Scoring logic
- Unit tests

**Dependencies:** Task 3.14
**Estimated Time:** 3 days

---

#### Task 3.16: Display Scoring API
**Description:** API for display scoring

**Subtasks:**
- [ ] Implement `DisplayScoresController`:
  - `GET /api/display-scores` (list with filters)
    - Query params: distributorId, customerId, capturedByUserId, scoredByUserId, isPending, fromDate, toDate
  - `GET /api/display-scores/{id}` (score detail)
  - `POST /api/display-scores/{id}/score` (score display)
    - Body: isPassed, revenue, notes
  - `POST /api/display-scores/bulk-score` (bulk score)
    - Body: scores array (scoreId, isPassed, revenue, notes)
  - `GET /api/display-scores/report` (display score report)
    - Query params: fromDate, toDate
  - `GET /api/display-scores/summary` (summary)
- [ ] Add display score report generation
- [ ] Implement bulk scoring

**Deliverables:**
- Display scoring API endpoints
- Report generation
- Swagger documentation

**Dependencies:** Task 3.15
**Estimated Time:** 3 days

---

#### Task 3.17: Web - Display Scoring Pages
**Description:** Web pages for display scoring

**Subtasks:**
- [ ] Create `DisplayScoringPage`:
  - List of pending displays (un-scored)
  - Filters: customer, employee, date
  - Photo gallery view
  - Score button (Đạt/Không đạt)
  - Revenue input
  - Notes input
- [ ] Create `BulkScoringPage`:
  - List of pending displays (grid view)
  - Quick score buttons (all Đạt, all Không đạt)
  - Individual override
  - Submit scores
- [ ] Create `DisplayScoreReportPage`:
  - Summary stats (total, pending, scored, passed, failed)
  - Pass rate
  - Total revenue from passed
  - Filter by date range
  - Export to Excel
- [ ] Add photo gallery with thumbnails

**Deliverables:**
- Display scoring pages
- Bulk scoring UI
- Report page with export

**Dependencies:** Task 3.16
**Estimated Time:** 4 days

---

### 3.6 Van-sale Stock Management (Week 11-12)

#### Task 3.18: Van-sale Warehouse Model
**Description:** Extend warehouse model for Van-sale

**Subtasks:**
- [ ] Update `warehouse` table:
  - Add `type` enum: 'MAIN', 'VAN_SALE'
  - Add `assigned_user_id` (for Van-sale warehouses)
  - Add `vehicle_info` (JSONB for vehicle details)
- [ ] Create Van-sale warehouse on employee assignment
- [ ] Add Van-sale stock reservation logic

**Deliverables:**
- EF Core migration for Van-sale warehouses
- Van-sale warehouse entity

**Dependencies:** Task 3.17
**Estimated Time:** 2 days

---

#### Task 3.19: Van-sale Stock Service
**Description:** Implement Van-sale stock management

**Subtasks:**
- [ ] Extend `InventoryService`:
  - `createVanSaleWarehouse()` - create warehouse for employee
  - `transferToVan()` - transfer stock from main to van
  - `getVanStock()` - get van stock levels
  - `reserveVanStock()` - reserve stock for Van-sale order
  - `deductVanStock()` - actual deduction on order
  - `returnVanStock()` - return unsold stock
- [ ] Implement Van-sale stock validation:
  - Check van stock availability
  - Prevent over-allocation
  - Track reserved vs available stock

**Deliverables:**
- Extended `InventoryService`
- Van-sale stock logic
- Unit tests

**Dependencies:** Task 3.18
**Estimated Time:** 4 days

---

#### Task 3.20: Van-sale Stock API
**Description:** API for Van-sale stock management

**Subtasks:**
- [ ] Extend `InventoryController`:
  - `GET /api/warehouses` (list with van-sale filter)
    - Query params: distributorId, warehouseType, assignedUserId
  - `GET /api/warehouses/{id}/stock` (van stock levels)
    - Query params: search, lowStock
  - `POST /api/inventory/transfers` (transfer to van)
    - Body: sourceWarehouseId, destinationWarehouseId, items
    - transferType: 'MainToVan'
  - `GET /api/inventory/van-stock/{userId}` (employee van stock)
- [ ] Add Van-sale stock reporting

**Deliverables:**
- Van-sale stock API endpoints
- Stock transfer logic
- Stock reports

**Dependencies:** Task 3.19
**Estimated Time:** 2 days

---

#### Task 3.21: Mobile - Van-sale Stock Screens
**Description:** Mobile screens for Van-sale stock

**Subtasks:**
- [ ] Create `VanStockScreen`:
  - List of products in van stock
  - Quantity and value
  - Low stock alerts
  - Refresh button
- [ ] Create `StockTransferScreen`:
  - Request stock transfer from main warehouse
  - Select products and quantities
  - Submit request
  - View transfer history
- [ ] Update `OrderCreationScreen`:
  - Show Van-sale stock availability
  - Prevent ordering beyond available stock
  - Real-time stock updates

**Deliverables:**
- Van-stock screen
- Stock transfer screen
- Order creation with stock validation

**Dependencies:** Task 3.20
**Estimated Time:** 3 days

---

### 3.7 Advanced Reporting (Week 12-14)

#### Task 3.22: Advanced Report Service
**Description:** Implement multi-dimensional reporting

**Subtasks:**
- [ ] Extend `ReportService`:
  - `getMultiDimensionalSalesReport()` - sales by multiple dimensions
  - `getCustomerAnalysisReport()` - customer behavior analysis
  - `getProductAnalysisReport()` - product performance
  - `getEmployeePerformanceReport()` - detailed employee metrics
  - `getGeographicReport()` - sales by region/area
  - `getTimeSeriesReport()` - trend analysis
- [ ] Implement report aggregation:
  - By customer group (A/B/C/D/E)
  - By customer type (Tạp Hóa, Hiệu Thuốc, etc.)
  - By channel (GT/MT)
  - By region/area
  - By product category/brand
  - By employee/team

**Deliverables:**
- Extended `ReportService`
- Multi-dimensional report logic
- Advanced aggregations

**Dependencies:** Task 3.21
**Estimated Time:** 5 days

---

#### Task 3.23: Advanced Report API
**Description:** API for advanced reporting

**Subtasks:**
- [ ] Extend `ReportsController`:
  - `GET /api/reports/advanced/sales` (multi-dimensional sales)
    - Query params: dimensions (customer, product, employee, region), metrics, groupBy
  - `GET /api/reports/advanced/customer-analysis` (customer analysis)
  - `GET /api/reports/advanced/product-analysis` (product analysis)
  - `GET /api/reports/advanced/employee-performance` (employee metrics)
  - `GET /api/reports/advanced/geographic` (geographic report)
  - `GET /api/reports/advanced/trend` (time series)
  - `GET /api/reports/advanced/{type}/export` (Excel export)
- [ ] Add flexible query parameters for dimensions
- [ ] Implement caching for expensive reports

**Deliverables:**
- Advanced report API endpoints
- Flexible query parameters
- Report caching

**Dependencies:** Task 3.22
**Estimated Time:** 3 days

---

#### Task 3.24: Web - Advanced Report Pages
**Description:** Web pages for advanced reporting

**Subtasks:**
- [ ] Create `AdvancedReportsPage`:
  - Report type selector
  - Dimension selector (multi-select)
  - Metric selector
  - Date range filter
  - Additional filters
  - Generate report button
- [ ] Create `MultiDimensionalReportView`:
  - Pivot table display
  - Drill-down capability
  - Charts (bar, line, pie, heatmap)
  - Export options
- [ ] Create `CustomerAnalysisView`:
  - Customer segmentation
  - RFM analysis (Recency, Frequency, Monetary)
  - Customer lifetime value
  - Churn prediction (basic)
- [ ] Create `TrendAnalysisView`:
  - Time series charts
  - Trend lines
  - Period comparison (MoM, YoY)
  - Forecasting (simple moving average)

**Deliverables:**
- Advanced reports page
- Multi-dimensional report view
- Customer analysis view
- Trend analysis view

**Dependencies:** Task 3.23
**Estimated Time:** 5 days

---

### 3.8 Testing & QA (Week 14-15)

#### Task 3.25: Integration Testing
**Description:** Test advanced features end-to-end

**Subtasks:**
- [ ] Test KPI assignment and tracking:
  - Assign KPIs to employee
  - Verify calculations
  - Check trend calculation
- [ ] Test NPP onboarding flow:
  - GSBH creates NPP
  - Upload photos
  - Submit for approval
  - Admin approves
  - Verify NPP active
- [ ] Test display scoring:
  - NVBH uploads photos
  - GSBH scores displays
  - Generate report
- [ ] Test Van-sale stock:
  - Transfer stock to van
  - Create Van-sale order
  - Verify stock deduction
- [ ] Test advanced reports:
  - Generate multi-dimensional reports
  - Verify aggregations
  - Test export functionality

**Deliverables:**
- E2E test scenarios
- Test results
- Bug fixes

**Dependencies:** Task 3.24
**Estimated Time:** 3 days

---

#### Task 3.26: Performance Testing
**Description:** Test performance of advanced features

**Subtasks:**
- [ ] Load test KPI calculations (1000 employees)
- [ ] Load test advanced reports (complex queries)
- [ ] Test display scoring with large photo sets
- [ ] Test Van-sale stock queries
- [ ] Optimize slow queries
- [ ] Add caching where appropriate

**Deliverables:**
- Performance test report
- Optimizations implemented
- Caching strategy

**Dependencies:** Task 3.25
**Estimated Time:** 3 days

---

### 3.9 Documentation & Deployment (Week 15-16)

#### Task 3.27: Technical Documentation
**Description:** Update technical docs

**Subtasks:**
- [ ] Update API documentation (Swagger)
- [ ] Document KPI calculation formulas
- [ ] Document NPP onboarding workflow
- [ ] Document display scoring process
- [ ] Document Van-sale stock management
- [ ] Create troubleshooting guide for advanced features

**Deliverables:**
- Updated API docs
- Feature documentation
- Troubleshooting guide

**Dependencies:** Task 3.26
**Estimated Time:** 2 days

---

#### Task 3.28: User Documentation
**Description:** Create user guides for advanced features

**Subtasks:**
- [ ] Create KPI Management guide:
  - Assigning KPIs
  - Viewing KPI performance
  - Understanding KPI trends
- [ ] Create GSBH Mobile guide:
  - Mở mới NPP
  - Quản lý tuyến
  - Chia KPI
- [ ] Create Display Scoring guide:
  - Scoring displays
  - Viewing reports
- [ ] Create Advanced Reports guide:
  - Multi-dimensional analysis
  - Customer analysis
  - Trend analysis
- [ ] Create video tutorials

**Deliverables:**
- 4 user guides
- Video tutorials (optional)

**Dependencies:** Task 3.27
**Estimated Time:** 3 days

---

#### Task 3.29: Production Deployment
**Description:** Deploy Phase 3 to production

**Subtasks:**
- [ ] Run database migrations on production
- [ ] Deploy backend API (zero-downtime)
- [ ] Deploy updated mobile app (beta testing)
- [ ] Deploy updated web app
- [ ] Configure monitoring for new features
- [ ] Verify all endpoints working
- [ ] Smoke test all critical flows

**Deliverables:**
- Phase 3 deployed to production
- Monitoring configured
- Smoke test results

**Dependencies:** Task 3.28
**Estimated Time:** 2 days

---

## 4. Dependencies & Risks

### 4.1 Technical Dependencies
- KPI calculation accuracy with large datasets
- Excel import parsing reliability
- Display scoring workflow complexity
- Van-sale stock synchronization

### 4.2 External Dependencies
- Azure Blob storage for NPP photos
- Excel file format consistency
- GPS accuracy for NPP onboarding

### 4.3 Known Risks

| Risk | Impact | Probability | Mitigation |
|-------|---------|--------------|------------|
| KPI calculation performance | Medium | Medium | Implement caching, optimize queries |
| Excel import errors | Medium | High | Strict validation, error reporting |
| Display scoring backlog | High | Medium | Bulk scoring, reminders |
| Van-sale stock conflicts | High | Low | Real-time validation, reservation system |

---

## 5. Milestones & Timeline

### Week 1-3: KPI Management
- ✅ KPI database schema
- ✅ KPI calculation service
- ✅ KPI management API

### Week 3-5: GSBH Mobile - NPP Onboarding
- ✅ Distributor model extensions
- ✅ NPP onboarding service
- ✅ NPP onboarding API
- ✅ Mobile NPP onboarding screens

### Week 5-7: GSBH Mobile - Route Management
- ✅ Route service extensions
- ✅ Route API extensions
- ✅ Mobile route management screens

### Week 7-9: GSBH Mobile - KPI Assignment
- ✅ KPI assignment service
- ✅ KPI assignment API extensions
- ✅ Mobile KPI assignment screens

### Week 9-11: Display Scoring
- ✅ Display score model
- ✅ Display scoring service
- ✅ Display scoring API
- ✅ Web display scoring pages

### Week 11-12: Van-sale Stock
- ✅ Van-sale warehouse model
- ✅ Van-sale stock service
- ✅ Van-sale stock API
- ✅ Mobile Van-sale stock screens

### Week 12-14: Advanced Reporting
- ✅ Advanced report service
- ✅ Advanced report API
- ✅ Web advanced report pages

### Week 14-15: Testing
- ✅ Integration testing
- ✅ Performance testing

### Week 15-16: Documentation & Deployment
- ✅ Technical documentation
- ✅ User documentation
- ✅ Production deployment

**Total Estimated Duration:** 16 weeks

---

## 6. Success Metrics

### Functional Metrics
- KPI targets assigned: 100% of employees
- NPP onboarding success rate: > 90%
- Display scoring completion rate: > 95%
- Van-sale stock accuracy: 100%
- Advanced report generation time: < 10 seconds

### Performance Metrics
- KPI calculation time (100 employees): < 5 seconds
- Excel import (500 rows): < 10 seconds
- Display score report generation: < 5 seconds
- Advanced multi-dimensional report: < 15 seconds

### User Experience Metrics
- GSBH can create NPP in < 15 minutes
- GSBH can assign KPIs in < 5 minutes per employee
- GSBH can score 10 displays in < 5 minutes
- Mobile app remains responsive with large datasets

---

## 7. Handoff to Phase 4

### Deliverables
1. Complete KPI management system
2. GSBH mobile functions (NPP, Routes, KPI)
3. Display scoring system
4. Van-sale stock management
5. Advanced reporting capabilities
6. Updated mobile and web apps
7. Complete documentation

### Prerequisites for Phase 4
- All Phase 3 tasks completed
- Production stable for 2 weeks
- User feedback collected
- Performance baselines established
- System ready for optimization

---

**Document Version:** 1.0
**Created Date:** 2026-02-06
**Author:** Implementation Team
**Related Documents:**
- [PRD-v2.md](../current-feature/PRD-v2.md)
- [00-ARCHITECTURE-OVERVIEW.md](../architecture/00-ARCHITECTURE-OVERVIEW.md)
- [04-DATA-ARCHITECTURE.md](../architecture/04-DATA-ARCHITECTURE.md)
- [09-REPORTING-ARCHITECTURE.md](../architecture/09-REPORTING-ARCHITECTURE.md)
- [Phase 1: Foundation](01-Phase1-Foundation.md)
- [Phase 2: Core Operations](02-Phase2-Core-Operations.md)
- [Phase 4: Optimization](04-Phase4-Optimization.md)