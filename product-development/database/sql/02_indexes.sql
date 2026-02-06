-- ============================================================
-- DMS VIPPro - Indexes & Performance Optimization
-- Distribution Management System
-- Version: 3.1 | PostgreSQL 16+
-- ============================================================

-- ============================================================
-- 1. SEARCH INDEXES (Full-Text & Fuzzy Search)
-- ============================================================

-- GIN Indexes for full-text search on names
CREATE INDEX idx_customer_name_trgm ON customer USING GIN (name gin_trgm_ops);
CREATE INDEX idx_product_name_trgm ON product USING GIN (name gin_trgm_ops);
CREATE INDEX idx_employee_name_trgm ON employee USING GIN (full_name gin_trgm_ops);
CREATE INDEX idx_distributor_name_trgm ON distributor USING GIN (name gin_trgm_ops);

-- ============================================================
-- 2. PARTIAL INDEXES (Active Records Only)
-- ============================================================

-- Only index non-deleted records (reduces index size by ~50%)
CREATE INDEX idx_customer_active ON customer(distributor_id, status)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_product_active ON product(brand_id, status)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_employee_active ON employee(org_unit_id, status)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_distributor_active ON distributor(region_id, status)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_sales_order_active ON sales_order(customer_id, status, order_date)
    WHERE deleted_at IS NULL;

-- ============================================================
-- 3. TEMPORAL INDEXES (Time-Range Queries)
-- ============================================================

-- Route assignment period (avoid overlapping assignments)
CREATE INDEX idx_route_assignment_period ON route_assignment
    USING GIST (employee_id, daterange(start_date, end_date, '[]'));

-- Customer route period (historical lookups)
CREATE INDEX idx_customer_route_period ON customer_route
    USING GIST (customer_id, daterange(start_date, end_date, '[]'));

-- Price list validity period
CREATE INDEX idx_price_list_validity ON price_list
    USING GIST (daterange(valid_from, valid_to, '[]'))
    WHERE status = 'ACTIVE';

-- Promotion validity period
CREATE INDEX idx_promotion_validity ON promotion(start_date, end_date)
    WHERE status = 'ACTIVE';

-- ============================================================
-- 4. GEOSPATIAL INDEXES
-- ============================================================

-- Customer location for proximity search
CREATE INDEX idx_customer_address_geo ON customer_address(latitude, longitude)
    WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- Visit check-in location
CREATE INDEX idx_visit_checkin_geo ON visit(checkin_lat, checkin_long)
    WHERE checkin_lat IS NOT NULL;

-- Attendance check-in location
CREATE INDEX idx_attendance_checkin_geo ON attendance(checkin_lat, checkin_long);

-- ============================================================
-- 5. FOREIGN KEY INDEXES (Join Performance)
-- ============================================================

-- Organization
CREATE INDEX idx_org_unit_parent ON org_unit(parent_id);
CREATE INDEX idx_employee_org_unit ON employee(org_unit_id);
CREATE INDEX idx_user_account_employee ON user_account(employee_id);

-- Territory
CREATE INDEX idx_route_distributor ON route(distributor_id);
CREATE INDEX idx_route_assignment_route ON route_assignment(route_id);
CREATE INDEX idx_route_assignment_employee ON route_assignment(employee_id);

-- Customer
CREATE INDEX idx_customer_distributor ON customer(distributor_id);
CREATE INDEX idx_customer_group_fk ON customer(customer_group_id);
CREATE INDEX idx_customer_address_customer ON customer_address(customer_id);
CREATE INDEX idx_customer_route_customer ON customer_route(customer_id);
CREATE INDEX idx_customer_route_route ON customer_route(route_id);

-- Product
CREATE INDEX idx_product_brand ON product(brand_id);
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_uom_conversion_product ON product_uom_conversion(product_id);

-- Pricing
CREATE INDEX idx_price_list_item_product ON price_list_item(product_id);

-- Sales Order
CREATE INDEX idx_sales_order_customer ON sales_order(customer_id);
CREATE INDEX idx_sales_order_distributor ON sales_order(distributor_id);
CREATE INDEX idx_sales_order_salesman ON sales_order(salesman_id);
CREATE INDEX idx_sales_order_route ON sales_order(route_id);
CREATE INDEX idx_sales_order_visit ON sales_order(visit_id);
CREATE INDEX idx_sales_order_line_order ON sales_order_line(sales_order_id);
CREATE INDEX idx_sales_order_line_product ON sales_order_line(product_id);
CREATE INDEX idx_sales_order_status_history_order ON sales_order_status_history(sales_order_id);

-- Delivery
CREATE INDEX idx_delivery_sales_order ON delivery(sales_order_id);
CREATE INDEX idx_delivery_warehouse ON delivery(warehouse_id);
CREATE INDEX idx_delivery_line_delivery ON delivery_line(delivery_id);
CREATE INDEX idx_delivery_line_product ON delivery_line(product_id);

-- Invoice & Payment
CREATE INDEX idx_invoice_sales_order ON invoice(sales_order_id);
CREATE INDEX idx_invoice_customer ON invoice(customer_id);
CREATE INDEX idx_payment_invoice ON payment(invoice_id);
CREATE INDEX idx_payment_customer ON payment(customer_id);

-- Inventory
CREATE INDEX idx_inventory_txn_warehouse ON inventory_txn(warehouse_id);
CREATE INDEX idx_inventory_txn_line_txn ON inventory_txn_line(inventory_txn_id);
CREATE INDEX idx_inventory_txn_line_product ON inventory_txn_line(product_id);

-- Field Force
CREATE INDEX idx_visit_salesman ON visit(salesman_id);
CREATE INDEX idx_visit_customer ON visit(customer_id);
CREATE INDEX idx_visit_route ON visit(route_id);
CREATE INDEX idx_visit_action_visit ON visit_action(visit_id);
CREATE INDEX idx_attachment_entity ON attachment(entity_type, entity_id);
CREATE INDEX idx_attendance_employee ON attendance(employee_id);

-- KPI
CREATE INDEX idx_kpi_target_metric ON kpi_target(metric_id);
CREATE INDEX idx_kpi_target_entity ON kpi_target(target_type, target_entity_id);

-- ============================================================
-- 6. COMPOSITE INDEXES (Common Query Patterns)
-- ============================================================

-- Sales orders by date range and status
CREATE INDEX idx_sales_order_date_status ON sales_order(order_date DESC, status)
    WHERE deleted_at IS NULL;

-- Sales orders by customer and date
CREATE INDEX idx_sales_order_customer_date ON sales_order(customer_id, order_date DESC)
    WHERE deleted_at IS NULL;

-- Visits by salesman and date
CREATE INDEX idx_visit_salesman_date ON visit(salesman_id, checkin_time DESC);

-- Visits by customer and date
CREATE INDEX idx_visit_customer_date ON visit(customer_id, checkin_time DESC);

-- Inventory transactions by warehouse and date
CREATE INDEX idx_inventory_txn_warehouse_date ON inventory_txn(warehouse_id, txn_date DESC);

-- Invoices by status and due date (for overdue tracking)
CREATE INDEX idx_invoice_status_due ON invoice(status, due_date)
    WHERE status IN ('ISSUED', 'PARTIAL', 'OVERDUE');

-- Payments by date
CREATE INDEX idx_payment_date ON payment(payment_date DESC);

-- Attendance by date range
CREATE INDEX idx_attendance_date ON attendance(date DESC, employee_id);

-- ============================================================
-- 7. COVERING INDEXES (Include columns to avoid table lookup)
-- ============================================================

-- Customer lookup with common fields
CREATE INDEX idx_customer_lookup ON customer(code, distributor_id)
    INCLUDE (name, status, channel)
    WHERE deleted_at IS NULL;

-- Product lookup with common fields
CREATE INDEX idx_product_lookup ON product(code)
    INCLUDE (name, status, primary_uom_id)
    WHERE deleted_at IS NULL;

-- Employee lookup
CREATE INDEX idx_employee_lookup ON employee(code)
    INCLUDE (full_name, status, org_unit_id)
    WHERE deleted_at IS NULL;

-- ============================================================
-- 8. UNIQUE CONSTRAINTS (Additional)
-- ============================================================

-- Ensure one default address per customer
CREATE UNIQUE INDEX idx_customer_address_default ON customer_address(customer_id)
    WHERE is_default = TRUE;

-- Ensure one default bank account per distributor
CREATE UNIQUE INDEX idx_distributor_bank_default ON distributor_bank_account(distributor_id)
    WHERE is_default = TRUE;

-- ============================================================
-- 9. AUDIT LOG INDEXES
-- ============================================================

CREATE INDEX idx_audit_log_table_record ON system_audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_changed_at ON system_audit_log(changed_at DESC);
CREATE INDEX idx_audit_log_changed_by ON system_audit_log(changed_by);

-- ============================================================
-- 10. EXPRESSION INDEXES
-- ============================================================

-- Case-insensitive username lookup
CREATE INDEX idx_user_account_username_lower ON user_account(LOWER(username));

-- Case-insensitive customer code lookup
CREATE INDEX idx_customer_code_lower ON customer(LOWER(code), distributor_id);

-- Year-month extraction for reporting
CREATE INDEX idx_sales_order_year_month ON sales_order(
    DATE_TRUNC('month', order_date)
) WHERE deleted_at IS NULL;

CREATE INDEX idx_visit_year_month ON visit(
    DATE_TRUNC('month', checkin_time)
);

-- ============================================================
-- 11. BRIN INDEXES (For Very Large Tables)
-- ============================================================

-- BRIN indexes for time-series data (more compact than B-tree)
-- Use for tables with millions of rows where data is naturally ordered

-- CREATE INDEX idx_sales_order_date_brin ON sales_order
--     USING BRIN (order_date) WITH (pages_per_range = 32);

-- CREATE INDEX idx_inventory_txn_date_brin ON inventory_txn
--     USING BRIN (txn_date) WITH (pages_per_range = 32);

-- CREATE INDEX idx_visit_date_brin ON visit
--     USING BRIN (checkin_time) WITH (pages_per_range = 32);

-- ============================================================
-- 12. STATISTICS UPDATE
-- ============================================================

-- Ensure statistics are up to date for query optimizer
ANALYZE org_unit;
ANALYZE employee;
ANALYZE user_account;
ANALYZE customer;
ANALYZE product;
ANALYZE sales_order;
ANALYZE sales_order_line;
ANALYZE inventory_balance;
ANALYZE visit;
