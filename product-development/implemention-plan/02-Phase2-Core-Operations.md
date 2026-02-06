# Phase 2: Core Operations - Implementation Plan

**Project:** DMS VIPPro (Distribution Management System)
**Phase:** 2 - Core Operations
**PRD Version:** v2.3
**Architecture Version:** v2.0
**Status:** Planning
**Target Completion:** TBD

---

## 1. Phase Overview

Phase 2 implements the core business operations of DMS VIPPro - order management (Pre-sales and Van-sales), inventory management, customer visits with photo capture, attendance tracking, and basic reporting. This phase enables end-to-end business workflows from customer visits to order fulfillment.

### 1.1 Objectives

- Implement complete order management workflow
- Build inventory management system (stock in/out/transfers)
- Develop customer visit functionality with GPS tracking
- Implement attendance (chấm công) with GPS validation
- Create basic reporting and KPI tracking
- Enable Van-sales mode (immediate fulfillment)

### 1.2 Success Criteria

- [ ] NVBH can check-in/check-out at customers with GPS
- [ ] Orders can be created (Pre-sales and Van-sales)
- [ ] GSBH can approve/reject orders
- [ ] Stock movements tracked accurately
- [ ] Attendance recorded with GPS and photos
- [ ] Visit photos uploaded and displayed
- [ ] Basic operational reports available

---

## 2. Technical Architecture Reference

### 2.1 Database Groups Involved

- **Group G (Sales O2C)**: Orders, Sales Order Lines, Delivery, Invoice, Payment
- **Group H (Inventory)**: Warehouses, Inventory Transactions, Inventory Balance
- **Group I (Field Force)**: Visits, Visit Actions, Attachments, Attendance
- **Group F (Pricing)**: Price Lists, Price List Items, Promotions

### 2.2 Key Business Flows

#### Order Flow (Pre-sales)
```
NVBH Create Order → Pending → GSBH Approve → Approved → Stock Out → Delivery → Invoice → Payment
```

#### Order Flow (Van-sales) [v2.0]
```
NVBH Create Van-sale Order → Immediate Stock Deduction → On-site Delivery → Payment Collection
```

#### Visit Flow
```
NVBH Check-in (GPS) → Capture Photos → Create Order (optional) → Check-out (GPS)
```

---

## 3. Detailed Implementation Tasks

### 3.1 Order Management (Week 1-3)

#### Task 2.1: Order Model & Database
**Description:** Implement order-related database entities

**Subtasks:**
- [ ] Create EF Core migration for Group G (Sales O2C):
  - `sales_order` table with status tracking
  - `sales_order_line` table with pricing snapshots
  - `sales_order_status_history` table for audit trail
- [ ] Add Pre-sales vs Van-sales support
  - `order_type` enum: 'PRESALES', 'VANSALES'
  - `van_sale_warehouse_id` for Van-sales orders
  - `payment_method` and `amount_paid` for Van-sales
- [ ] Implement order status workflow:
  - 'DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'COMPLETED', 'CANCELLED'
  - Add status transition validation

**Deliverables:**
- EF Core migration for orders
- Order entities with relationships
- Status workflow documentation

**Dependencies:** Phase 1 complete (master data APIs)
**Estimated Time:** 3 days

---

#### Task 2.2: Order Service (Business Logic)
**Description:** Implement order business logic

**Subtasks:**
- [ ] Create `OrderService`:
  - `createOrder()` - validate customer, products, pricing
  - `calculatePricing()` - apply discounts, promotions
  - `approveOrder()` - change status to APPROVED, create delivery
  - `rejectOrder()` - change status to REJECTED with reason
  - `completeOrder()` - final delivery confirmation
- [ ] Implement Van-sales immediate fulfillment:
  - `createVanSaleOrder()` - deduct stock immediately
  - `processVanSalePayment()` - record payment, update receivables
- [ ] Add order validation rules:
  - Credit limit check for customer
  - Stock availability check
  - Minimum order value check
  - Business hours validation (optional)
- [ ] Implement order status history tracking
- [ ] Add promotion engine:
  - Load active promotions for customer
  - Calculate line-level and order-level discounts

**Deliverables:**
- `OrderService` with all business logic
- Unit tests for order calculations
- Promotion calculation logic

**Dependencies:** Task 2.1
**Estimated Time:** 6 days

---

#### Task 2.3: Order Management API
**Description:** REST API endpoints for order management

**Subtasks:**
- [ ] Implement `OrdersController`:
  - `GET /api/orders` (list with filters)
    - Query params: status, fromDate, toDate, customerId, orderType
  - `GET /api/orders/{id}` (order detail with lines)
  - `POST /api/orders` (create order)
    - Body: customer, orderType, vanSaleWarehouseId, items, notes
  - `POST /api/orders/{id}/approve` (GSBH approval)
  - `POST /api/orders/{id}/reject` (GSBH rejection)
    - Body: reason
  - `PUT /api/orders/{id}` (edit - only DRAFT status)
  - `DELETE /api/orders/{id}` (cancel - DRAFT only)
- [ ] Add order number generation (DH-YYYYMMDD-NNN, VS-YYYYMMDD-NNN)
- [ ] Implement pagination for large order lists
- [ ] Add order search by customer name, order number
- [ ] Add API documentation (Swagger)

**Deliverables:**
- Order API endpoints (6+)
- Swagger documentation
- Integration tests

**Dependencies:** Task 2.2
**Estimated Time:** 4 days

---

### 3.2 Pricing & Promotions (Week 3-4)

#### Task 2.4: Price List Management
**Description:** Implement pricing system

**Subtasks:**
- [ ] Create `PriceListService`:
  - `getProductPrice()` - get price by customer type
  - `getPriceList()` - load active price list
- [ ] Implement `PriceListsController`:
  - `GET /api/price-lists` (list active price lists)
  - `GET /api/price-lists/{id}/items` (price list items)
  - `POST /api/price-lists` (create price list)
  - `POST /api/price-lists/{id}/items` (add price items)
- [ ] Add price history support (effective date ranges)
- [ ] Implement customer-specific pricing

**Deliverables:**
- Price list management API
- Pricing logic integrated with order creation

**Dependencies:** Task 2.3
**Estimated Time:** 3 days

---

#### Task 2.5: Promotion Engine
**Description:** Implement discount/promotion system

**Subtasks:**
- [ ] Create `PromotionService`:
  - `getActivePromotions()` - by customer, date
  - `calculateDiscount()` - apply promotion to order
  - Promotion types: quantity-based, value-based, mix-match
- [ ] Implement `PromotionsController`:
  - `GET /api/promotions` (list active)
  - `GET /api/promotions/{id}` (promotion details)
  - `POST /api/promotions` (create promotion)
  - `PUT /api/promotions/{id}` (update)
- [ ] Add promotion validation:
  - Date range validation
  - Customer type applicability
  - Product applicability
- [ ] Test promotion calculation scenarios

**Deliverables:**
- Promotion management API
- Promotion engine with unit tests
- Documentation on promotion types

**Dependencies:** Task 2.4
**Estimated Time:** 4 days

---

### 3.3 Inventory Management (Week 4-5)

#### Task 2.6: Inventory Model & Database
**Description:** Implement inventory database structure

**Subtasks:**
- [ ] Create EF Core migration for Group H (Inventory):
  - `warehouse` table (Main, VanSale types)
  - `inventory_balance` table (snapshot table for fast queries)
  - `inventory_txn` table (transaction log)
  - `inventory_txn_line` table (transaction items)
- [ ] Implement inventory transaction types:
  - 'IMPORT' - stock in
  - 'EXPORT_SALES' - order fulfillment
  - 'TRANSFER_OUT' - warehouse transfer
  - 'TRANSFER_IN' - warehouse transfer
  - 'ADJUSTMENT' - manual adjustment
- [ ] Add batch/lot support (date tracking)
- [ ] Set up inventory balance triggers
  - On transaction insert → update `inventory_balance`

**Deliverables:**
- EF Core migration for inventory
- Trigger scripts for balance updates
- Inventory data model

**Dependencies:** Task 2.1
**Estimated Time:** 3 days

---

#### Task 2.7: Inventory Service
**Description:** Implement inventory business logic

**Subtasks:**
- [ ] Create `InventoryService`:
  - `stockIn()` - increase stock
  - `stockOut()` - decrease stock (with availability check)
  - `transferStock()` - move stock between warehouses
  - `adjustStock()` - manual correction
  - `getAvailableStock()` - query `inventory_balance`
  - `getLowStockItems()` - alert threshold
- [ ] Implement FIFO logic for stock allocation
- [ ] Add stock reservation for Van-sales orders
- [ ] Implement transaction logging with audit trail
- [ ] Add stock movement notifications

**Deliverables:**
- `InventoryService` with all operations
- Unit tests for inventory calculations
- Stock movement notifications

**Dependencies:** Task 2.6
**Estimated Time:** 5 days

---

#### Task 2.8: Inventory Management API
**Description:** REST API for inventory operations

**Subtasks:**
- [ ] Implement `InventoryController`:
  - `GET /api/inventory/warehouses` (list warehouses)
  - `GET /api/inventory/warehouses/{id}/stock` (stock levels)
  - `POST /api/inventory/stock-in` (import stock)
    - Body: warehouseId, items, notes
  - `POST /api/inventory/transfers` (stock transfer)
    - Body: sourceWarehouseId, destinationWarehouseId, items
  - `GET /api/inventory/transfers` (transfer history)
  - `POST /api/inventory/adjustments` (manual adjustment)
- [ ] Add stock availability checks in order creation
- [ ] Implement low stock alerts
- [ ] Add API documentation

**Deliverables:**
- Inventory API endpoints (7+)
- Swagger documentation
- Integration tests

**Dependencies:** Task 2.7
**Estimated Time:** 4 days

---

### 3.4 Customer Visits (Week 5-6)

#### Task 2.9: Visit Model & Database
**Description:** Implement visit tracking database

**Subtasks:**
- [ ] Create EF Core migration for Group I (Field Force):
  - `visit` table (check-in/out, GPS, status)
  - `visit_action` table (order, photo, survey actions)
  - `attachment` table (photos, documents)
- [ ] Add GPS coordinates fields:
  - `checkin_lat`, `checkin_long`
  - `checkout_lat`, `checkout_long`
- [ ] Implement visit status:
  - 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
- [ ] Add visit validation rules:
  - Maximum visit duration
  - GPS accuracy threshold

**Deliverables:**
- EF Core migration for visits
- Visit entities with GPS support

**Dependencies:** Task 2.3
**Estimated Time:** 2 days

---

#### Task 2.10: Visit Service
**Description:** Implement visit business logic

**Subtasks:**
- [ ] Create `VisitService`:
  - `checkIn()` - validate GPS proximity to customer (within 100m)
  - `checkOut()` - record visit completion
  - `uploadPhoto()` - compress and store photo
  - `getVisitHistory()` - customer visit timeline
- [ ] Implement GPS distance calculation (Haversine formula)
- [ ] Add visit duration tracking
- [ ] Implement photo compression
- [ ] Add visit summary calculation (total visits, visits with order, etc.)

**Deliverables:**
- `VisitService` with GPS validation
- Unit tests for distance calculation
- Photo compression logic

**Dependencies:** Task 2.9
**Estimated Time:** 4 days

---

#### Task 2.11: Visit Management API
**Description:** REST API for visit operations

**Subtasks:**
- [ ] Implement `VisitsController`:
  - `GET /api/visits` (list with filters)
    - Query params: customerId, salesmanId, fromDate, toDate, status
  - `GET /api/visits/{id}` (visit detail)
  - `POST /api/visits/check-in` (check-in)
    - Body: customerId, latitude, longitude, visitType
  - `POST /api/visits/{id}/check-out` (check-out)
    - Body: latitude, longitude, visitResult, notes
  - `POST /api/visits/{id}/photos` (upload photo)
    - Body: photo (multipart), albumType, latitude, longitude
  - `GET /api/visits/{id}/photos` (visit photos)
- [ ] Add GPS validation on check-in
  - Calculate distance to customer registered location
  - Return warning if > 100m
- [ ] Implement photo storage (Azure Blob)
  - Upload to organized path: `visits/YYYY/MM/{visitId}/{photoId}.jpg`
  - Generate thumbnails
  - Return CDN URLs
- [ ] Add visit statistics endpoint

**Deliverables:**
- Visit API endpoints (6+)
- Azure Blob integration
- Swagger documentation

**Dependencies:** Task 2.10
**Estimated Time:** 4 days

---

### 3.5 Attendance (Chấm công) (Week 6-7)

#### Task 2.12: Attendance Model & Database
**Description:** Implement attendance tracking

**Subtasks:**
- [ ] Create EF Core migration for `attendance` table:
  - Fields: employee_id, date, checkin_time, checkout_time, status
  - GPS fields: checkin_lat/long, checkout_lat/long
  - Photo fields: checkin_photo_url, checkout_photo_url
- [ ] Add attendance status:
  - 'PRESENT', 'ABSENT', 'LATE', 'EARLY_DEPARTURE'
- [ ] Add attendance summary fields:
  - `total_hours`, `working_hours`, `late_minutes`, `early_minutes`

**Deliverables:**
- EF Core migration for attendance
- Attendance entity

**Dependencies:** Task 2.11
**Estimated Time:** 2 days

---

#### Task 2.13: Attendance Service
**Description:** Implement attendance business logic

**Subtasks:**
- [ ] Create `AttendanceService`:
  - `clockIn()` - record check-in with GPS and photo
  - `clockOut()` - record check-out
  - `getMonthlyAttendance()` - generate timesheet (days 1-31)
  - `calculateWorkHours()` - compute daily/weekly hours
- [ ] Implement late/early departure logic:
  - Define working hours (e.g., 8:00-17:00)
  - Calculate tardiness/early minutes
- [ ] Add multiple check-in support (take first/last)
- [ ] Generate timesheet format for export

**Deliverables:**
- `AttendanceService` with all logic
- Timesheet generation logic
- Unit tests for hour calculations

**Dependencies:** Task 2.12
**Estimated Time:** 3 days

---

#### Task 2.14: Attendance API
**Description:** REST API for attendance

**Subtasks:**
- [ ] Implement `AttendanceController`:
  - `GET /api/attendance` (list with filters)
    - Query params: employeeId, month (YYYY-MM)
  - `GET /api/attendance/timesheet/{employeeId}/{month}` (timesheet)
  - `POST /api/attendance/clock-in` (check-in)
    - Body: latitude, longitude, photo
  - `POST /api/attendance/clock-out` (check-out)
    - Body: latitude, longitude, photo
  - `GET /api/attendance/summary` (attendance summary)
- [ ] Add attendance photo upload (Azure Blob)
- [ ] Implement timesheet export (Excel)

**Deliverables:**
- Attendance API endpoints (5+)
- Excel export for timesheet
- Swagger documentation

**Dependencies:** Task 2.13
**Estimated Time:** 3 days

---

### 3.6 Mobile App - Visit & Order Features (Week 7-9)

#### Task 2.15: Visit Screens
**Description:** Implement visit flow in mobile app

**Subtasks:**
- [ ] Create `VisitDetailScreen`:
  - Show customer info (name, address, phone)
  - Display GPS coordinates
  - Show distance from current location
  - Check-in button (enabled when < 100m)
  - Photo upload buttons (album type selection)
  - Check-out button
- [ ] Create `VisitViewModel`:
  - `checkIn()` - call visit API
  - `checkOut()` - call visit API
  - `uploadPhoto()` - compress and upload
  - `getVisitHistory()` - load customer visits
- [ ] Create `CameraScreen`:
  - CameraX integration
  - Photo capture
  - Preview and retake
  - Album type selection (TrungBay, MatTien, POSM)
- [ ] Add GPS permission handling
- [ ] Implement GPS distance calculation in UI

**Deliverables:**
- Visit detail screen
- Camera screen with album selection
- GPS validation in UI

**Dependencies:** Phase 1 mobile app
**Estimated Time:** 5 days

---

#### Task 2.16: Order Creation Screens
**Description:** Implement order creation in mobile app

**Subtasks:**
- [ ] Create `OrderCreationScreen`:
  - Product selection (searchable)
  - Quantity input with UOM conversion
  - Line totals calculation
  - Discount display
  - Order summary (subtotal, tax, total)
  - Order mode selection (Pre-sales / Van-sales)
  - Van-sale: payment method, amount collected
- [ ] Create `OrderViewModel`:
  - `loadProducts()` - from local DB
  - `addToOrder()` - add product line
  - `removeFromOrder()` - remove line
  - `calculateTotals()` - apply discounts
  - `submitOrder()` - create order API call
- [ ] Create `OrderHistoryScreen`:
  - List of orders (today, week, month)
  - Order detail view
  - Order status tracking
- [ ] Implement offline order queue
  - Store orders locally when offline
  - Auto-sync when connected
- [ ] Add promotion display (active promotions for customer)

**Deliverables:**
- Order creation screen
- Order history screen
- Offline order queue

**Dependencies:** Task 2.15
**Estimated Time:** 5 days

---

#### Task 2.17: Attendance Screens
**Description:** Implement chấm công in mobile app

**Subtasks:**
- [ ] Create `AttendanceScreen`:
  - Clock-in button (photo + GPS)
  - Clock-out button (photo + GPS)
  - Show today's status (clocked in/out time)
  - Show work hours
- [ ] Create `AttendanceViewModel`:
  - `clockIn()` - call attendance API
  - `clockOut()` - call attendance API
  - `loadTodayStatus()` - check today's attendance
- [ ] Integrate with camera (photo capture on clock-in/out)
- [ ] Display GPS location on check-in/out
- [ ] Show monthly timesheet (read-only)

**Deliverables:**
- Attendance screen
- Timesheet view
- Photo capture on clock-in/out

**Dependencies:** Task 2.16
**Estimated Time:** 3 days

---

### 3.7 Web Dashboard - Order & Inventory (Week 9-11)

#### Task 2.18: Order Management Pages
**Description:** Implement order management in web app

**Subtasks:**
- [ ] Create `OrdersPage`:
  - Order list with filters (status, date, customer)
  - Search by order number, customer name
  - Pagination
- [ ] Create `OrderDetailPage`:
  - Order header info (customer, date, status)
  - Order lines (product, qty, price, discount)
  - Status history timeline
  - Approve/Reject buttons (for GSBH)
  - View delivery info
- [ ] Create `ApprovalQueuePage`:
  - List of pending orders (for GSBH quick access)
  - Quick approve/reject actions
  - Filter by employee, route
- [ ] Implement order PDF export

**Deliverables:**
- Order management pages
- Approval queue
- PDF export

**Dependencies:** Phase 1 web dashboard
**Estimated Time:** 4 days

---

#### Task 2.19: Inventory Management Pages
**Description:** Implement inventory management in web app

**Subtasks:**
- [ ] Create `WarehousesPage`:
  - List of warehouses
  - Warehouse stock levels
  - Low stock alerts
- [ ] Create `StockInPage`:
  - Stock in form
  - Product selection
  - Quantity input
  - Confirm stock in
- [ ] Create `StockTransferPage`:
  - Source/destination warehouse selection
  - Product selection
  - Quantity input
  - Transfer history list
- [ ] Create `InventoryReportPage`:
  - Stock levels by warehouse
  - Stock movements (import/export/transfer)
  - Export to Excel

**Deliverables:**
- Inventory management pages
- Stock reports
- Excel export

**Dependencies:** Task 2.18
**Estimated Time:** 4 days

---

#### Task 2.20: Visit Monitoring Pages
**Description:** Implement visit monitoring in web app

**Subtasks:**
- [ ] Create `VisitMonitoringPage`:
  - Today's visits list (by employee)
  - Visit status (completed, in-progress)
  - Visit with/without order
  - Visit with/without photo
  - Map view with current employee locations
- [ ] Create `PhotoGalleryPage`:
  - Filter by employee, customer, date, album type
  - Thumbnail gallery
  - Photo detail view (full size)
  - Download option
- [ ] Create `VisitDetailPage`:
  - Visit timeline
  - Check-in/out GPS locations
  - Photos captured
  - Orders created during visit
  - Notes

**Deliverables:**
- Visit monitoring page
- Photo gallery
- Visit detail view

**Dependencies:** Task 2.19
**Estimated Time:** 4 days

---

#### Task 2.21: Attendance Management Pages
**Description:** Implement attendance management in web app

**Subtasks:**
- [ ] Create `AttendancePage`:
  - Employee list for selected month
  - Timesheet table (days 1-31)
  - For each day: Check-in, Check-out, Late, Early, Hours, Work status
  - Summary: Days worked, Late count, Early count, Total hours
  - Filter by month, department, employee
- [ ] Create `AttendanceDetailPage`:
  - Employee info
  - Monthly timesheet
  - GPS map for check-in/out locations
  - Attendance photos
- [ ] Implement attendance export (Excel)

**Deliverables:**
- Attendance management page
- Timesheet display
- Excel export

**Dependencies:** Task 2.20
**Estimated Time:** 3 days

---

### 3.8 Basic Reporting (Week 11-12)

#### Task 2.22: Operational Reports
**Description:** Implement basic operational reports

**Subtasks:**
- [ ] Create `ReportService`:
  - `getVisitReport()` - visits by employee, customer, date
  - `getOrderReport()` - orders by status, date, customer
  - `getSalesReport()` - sales by product, customer, period
  - `getInventoryReport()` - stock levels, movements
  - `getAttendanceReport()` - attendance summary
- [ ] Implement `ReportsController`:
  - `GET /api/reports/visits` (visit report)
  - `GET /api/reports/orders` (order report)
  - `GET /api/reports/sales` (sales report)
  - `GET /api/reports/inventory` (inventory report)
  - `GET /api/reports/attendance` (attendance report)
  - `GET /api/reports/{type}/export` (Excel export)
- [ ] Add date range filters
- [ ] Implement grouping (by employee, by route, by customer)

**Deliverables:**
- Report API endpoints
- Report generation logic
- Excel export

**Dependencies:** Task 2.21
**Estimated Time:** 4 days

---

#### Task 2.23: Web Report Pages
**Description:** Implement report UI in web app

**Subtasks:**
- [ ] Create `ReportsPage`:
  - Report type selector (Visit, Order, Sales, Inventory, Attendance)
  - Date range filter
  - Additional filters (employee, customer, route, etc.)
  - Generate report button
  - Export to Excel button
- [ ] Create `VisitReportView`:
  - Table with visit details
  - Summary metrics (total visits, with order, with photo)
  - Charts (visit by day, by employee)
- [ ] Create `SalesReportView`:
  - Table with sales details
  - Summary metrics (total revenue, orders, avg order value)
  - Charts (sales trend, top products, top customers)
- [ ] Create `AttendanceReportView`:
  - Timesheet view
  - Summary metrics (days worked, late count, total hours)
- [ ] Add Recharts for visualizations

**Deliverables:**
- Reports page with multiple report types
- Charts and visualizations
- Excel export

**Dependencies:** Task 2.22
**Estimated Time:** 4 days

---

### 3.9 Testing & QA (Week 12-13)

#### Task 2.24: End-to-End Testing
**Description:** Test complete business flows

**Subtasks:**
- [ ] Test Pre-sales order flow:
  - NVBH check-in → create order → check-out
  - GSBH approve order
  - Stock out → delivery
  - Verify inventory updated
- [ ] Test Van-sales order flow:
  - NVBH check-in → create Van-sale order → immediate stock deduction
  - Payment collection
  - Verify inventory and receivables
- [ ] Test visit flow with GPS:
  - Check-in within 100m (should succeed)
  - Check-in > 100m (should warn)
  - Photo upload
  - Check-out
- [ ] Test attendance flow:
  - Clock-in with GPS + photo
  - Clock-out with GPS + photo
  - Verify timesheet generated
- [ ] Test offline scenarios:
  - Create order offline
  - Sync when online
  - Verify no conflicts

**Deliverables:**
- E2E test scenarios documented
- Test results report
- Bug fixes for issues found

**Dependencies:** Task 2.23
**Estimated Time:** 3 days

---

#### Task 2.25: Performance Testing
**Description:** Load and stress testing

**Subtasks:**
- [ ] Load test order creation (100 concurrent users)
- [ ] Load test visit check-in (200 concurrent users)
- [ ] Load test sync API (500 concurrent users)
- [ ] Test database performance with large datasets
  - 10,000 customers
  - 5,000 products
  - 50,000 orders
  - 100,000 visits
- [ ] Test mobile app performance
  - App startup time
  - List scrolling performance
  - GPS accuracy
- [ ] Optimize slow queries based on results

**Deliverables:**
- Performance test report
- Database optimization recommendations
- Implemented optimizations

**Dependencies:** Task 2.24
**Estimated Time:** 3 days

---

#### Task 2.26: User Acceptance Testing (UAT)
**Description:** Testing with real users

**Subtasks:**
- [ ] Deploy to staging environment
- [ ] Onboard pilot users:
  - 5 NVBH users
  - 3 GSBH users
  - 2 Admin NPP users
- [ ] Conduct user training sessions
- [ ] Collect user feedback:
  - Usability issues
  - Feature requests
  - Bugs found
- [ ] Prioritize and fix critical issues
- [ ] Update documentation based on feedback

**Deliverables:**
- UAT test plan
- User feedback report
- Bug fixes implemented
- Updated documentation

**Dependencies:** Task 2.25
**Estimated Time:** 5 days

---

### 3.10 Documentation & Deployment (Week 13-14)

#### Task 2.27: Technical Documentation
**Description:** Update technical docs

**Subtasks:**
- [ ] Update API documentation (Swagger)
- [ ] Document order workflow (Pre-sales vs Van-sales)
- [ ] Document inventory transaction rules
- [ ] Document visit GPS validation rules
- [ ] Create troubleshooting guide
- [ ] Update architecture diagrams with new features

**Deliverables:**
- Updated API docs
- Workflow documentation
- Troubleshooting guide

**Dependencies:** Task 2.26
**Estimated Time:** 2 days

---

#### Task 2.28: User Documentation
**Description:** Create user guides

**Subtasks:**
- [ ] Create Order Management guide:
  - Creating orders (Pre-sales)
  - Creating orders (Van-sales)
  - Approving/rejecting orders
- [ ] Create Inventory Management guide:
  - Stock in
  - Stock transfer
  - Viewing stock levels
- [ ] Create Visit Management guide:
  - Check-in/check-out
  - GPS requirements
  - Photo upload
- [ ] Create Attendance guide:
  - Clock-in/clock-out
  - Viewing timesheet
- [ ] Create video tutorials

**Deliverables:**
- 4 user guides
- Video tutorials (optional)

**Dependencies:** Task 2.27
**Estimated Time:** 3 days

---

#### Task 2.29: Production Deployment
**Description:** Deploy Phase 2 to production

**Subtasks:**
- [ ] Run database migrations on production
- [ ] Deploy backend API (zero-downtime)
- [ ] Deploy updated mobile app (internal beta testing)
- [ ] Deploy updated web app
- [ ] Configure monitoring for new features
- [ ] Verify all endpoints working
- [ ] Smoke test all critical flows

**Deliverables:**
- Phase 2 deployed to production
- Monitoring configured
- Smoke test results

**Dependencies:** Task 2.28
**Estimated Time:** 2 days

---

## 4. Dependencies & Risks

### 4.1 Technical Dependencies
- GPS accuracy on Android devices
- Azure Blob storage for photo uploads
- Performance of inventory queries with large datasets
- Sync conflict resolution complexity

### 4.2 External Dependencies
- Google Maps API for distance calculation
- Azure Blob storage reliability
- Mobile device GPS hardware quality

### 4.3 Known Risks

| Risk | Impact | Probability | Mitigation |
|-------|---------|--------------|------------|
| GPS inaccuracy in urban areas | High | High | Allow manual override, use multiple GPS sources |
| Photo upload failures | Medium | Medium | Implement retry logic, offline queue |
| Order conflicts in sync | Medium | Medium | ServerWins strategy, conflict UI |
| Performance issues with large inventory | High | Medium | Proper indexing, caching, pagination |
| Van-sales stock availability issues | High | Low | Real-time stock validation, reservation system |

---

## 5. Milestones & Timeline

### Week 1-3: Order Management
- ✅ Order database schema
- ✅ Order service with pricing
- ✅ Order API endpoints
- ✅ Price list management
- ✅ Promotion engine

### Week 4-5: Inventory Management
- ✅ Inventory database schema
- ✅ Inventory service
- ✅ Inventory API endpoints
- ✅ Stock transaction logging

### Week 6-7: Visits & Attendance
- ✅ Visit database schema
- ✅ Visit service with GPS validation
- ✅ Visit API endpoints
- ✅ Attendance database schema
- ✅ Attendance service
- ✅ Attendance API endpoints

### Week 7-9: Mobile Features
- ✅ Visit screens
- ✅ Order creation screens
- ✅ Attendance screens
- ✅ Photo upload functionality

### Week 9-11: Web Dashboard
- ✅ Order management pages
- ✅ Inventory management pages
- ✅ Visit monitoring pages
- ✅ Attendance management pages

### Week 11-12: Reporting
- ✅ Operational reports API
- ✅ Web report pages
- ✅ Excel export functionality

### Week 12-13: Testing
- ✅ E2E testing
- ✅ Performance testing
- ✅ User acceptance testing

### Week 13-14: Documentation & Deployment
- ✅ Technical documentation
- ✅ User documentation
- ✅ Production deployment

**Total Estimated Duration:** 14 weeks

---

## 6. Success Metrics

### Operational Metrics
- Orders processed per day: > 500
- Average order approval time: < 2 hours
- Visit check-in success rate: > 95%
- Photo upload success rate: > 99%
- Inventory sync accuracy: 100%

### Performance Metrics
- Order creation response time: < 1 second
- Visit check-in response time: < 500ms
- Inventory query response time: < 2 seconds
- Photo upload time (5MB photo): < 10 seconds

### User Experience Metrics
- NVBH can complete visit flow in < 5 minutes
- GSBH can approve order in < 1 minute
- Offline order sync completes in < 30 seconds
- Mobile app crash rate: < 1%

---

## 7. Handoff to Phase 3

### Deliverables
1. Working order management system (Pre-sales + Van-sales)
2. Inventory management with stock tracking
3. Visit tracking with GPS and photos
4. Attendance system with timesheets
5. Basic operational reports
6. Updated mobile and web apps
7. Complete documentation

### Prerequisites for Phase 3
- All Phase 2 tasks completed
- Production stable for 2 weeks
- User feedback collected and prioritized
- Performance baselines established
- Known limitations documented

---

**Document Version:** 1.0
**Created Date:** 2026-02-06
**Author:** Implementation Team
**Related Documents:**
- [PRD-v2.md](../current-feature/PRD-v2.md)
- [00-ARCHITECTURE-OVERVIEW.md](../architecture/00-ARCHITECTURE-OVERVIEW.md)
- [04-DATA-ARCHITECTURE.md](../architecture/04-DATA-ARCHITECTURE.md)
- [05-API-DESIGN.md](../architecture/05-API-DESIGN.md)
- [Phase 1: Foundation](01-Phase1-Foundation.md)
- [Phase 3: Advanced Features](03-Phase3-Advanced-Features.md)
