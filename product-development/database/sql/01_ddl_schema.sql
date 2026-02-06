-- ============================================================
-- DMS VIPPro - Data Definition Language (DDL)
-- Distribution Management System - Database Schema
-- Version: 3.1 | PostgreSQL 16+
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";      -- For gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "btree_gist";    -- For temporal indexing
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- For fuzzy text search

-- ============================================================
-- GROUP A: ORGANIZATION - User & RBAC
-- ============================================================

-- Org Unit (Department/Sales Team Hierarchy)
CREATE TABLE org_unit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    parent_id UUID REFERENCES org_unit(id),
    type VARCHAR(50) NOT NULL CHECK (type IN ('BRANCH', 'UNIT', 'TEAM')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE org_unit IS 'Organizational hierarchy (departments, teams)';
COMMENT ON COLUMN org_unit.type IS 'BRANCH=Chi nhánh, UNIT=Phòng ban, TEAM=Nhóm';

-- Employee (Sales Rep, Supervisor...)
CREATE TABLE employee (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    org_unit_id UUID NOT NULL REFERENCES org_unit(id),
    email VARCHAR(100),
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE employee IS 'Employee master data (NVBH, GSBH)';

-- User Account (Login credentials)
CREATE TABLE user_account (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    employee_id UUID REFERENCES employee(id),
    last_login_at TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'LOCKED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE user_account IS 'User login accounts for App/Web';

-- Role Definition
CREATE TABLE role (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE role IS 'Role definitions (SALES_REP, MANAGER, ADMIN)';

-- Permission Definition (Atomic)
CREATE TABLE permission (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    module VARCHAR(50)
);

COMMENT ON TABLE permission IS 'Atomic permissions (order.create, order.view)';

-- Role-Permission Mapping
CREATE TABLE role_permission (
    role_id UUID REFERENCES role(id) ON DELETE CASCADE,
    permission_id UUID REFERENCES permission(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- User-Role Mapping
CREATE TABLE user_role (
    user_id UUID REFERENCES user_account(id) ON DELETE CASCADE,
    role_id UUID REFERENCES role(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

-- ============================================================
-- GROUP B: TERRITORY - Route & Assignment
-- ============================================================

-- Region (Administrative Unit)
CREATE TABLE region (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE,
    name VARCHAR(100),
    parent_id UUID REFERENCES region(id),
    level INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE region IS 'Administrative regions (Province, District, Ward)';

-- Route (Sales Route)
CREATE TABLE route (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    distributor_id UUID NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE route IS 'Sales routes managed by distributors';

-- Route Assignment (SCD Type 2 - History tracking)
CREATE TABLE route_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID REFERENCES route(id),
    employee_id UUID REFERENCES employee(id),
    start_date DATE NOT NULL,
    end_date DATE,
    is_primary BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE route_assignment IS 'Employee-Route assignment history (SCD Type 2)';

-- ============================================================
-- GROUP C: DISTRIBUTOR - Partner Management
-- ============================================================

-- Distributor (Sales Partner)
CREATE TABLE distributor (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    tax_code VARCHAR(50),
    region_id UUID REFERENCES region(id),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE distributor IS 'Distributors/Dealers (NPP)';

-- Add FK constraint after distributor is created
ALTER TABLE route ADD CONSTRAINT fk_route_distributor
    FOREIGN KEY (distributor_id) REFERENCES distributor(id);

-- Distributor Bank Account
CREATE TABLE distributor_bank_account (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    distributor_id UUID REFERENCES distributor(id) ON DELETE CASCADE,
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    account_name VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Warehouse (Distributor's warehouse)
CREATE TABLE warehouse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100),
    distributor_id UUID REFERENCES distributor(id),
    type VARCHAR(20) CHECK (type IN ('MAIN', 'VAN_SALES', 'RETURN')),
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    UNIQUE(distributor_id, code)
);

COMMENT ON TABLE warehouse IS 'Warehouses (Main warehouse, Van sales)';

-- ============================================================
-- GROUP D: CUSTOMER - Outlet Management
-- ============================================================

-- Customer Group (Segment)
CREATE TABLE customer_group (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE,
    name VARCHAR(100),
    description TEXT
);

COMMENT ON TABLE customer_group IS 'Customer segments/groups';

-- Customer (Retail Outlet)
CREATE TABLE customer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    distributor_id UUID REFERENCES distributor(id),
    customer_group_id UUID REFERENCES customer_group(id),
    channel VARCHAR(50) CHECK (channel IN ('GT', 'MT', 'HORECA', 'ONLINE')),
    type VARCHAR(50),
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    credit_limit DECIMAL(18,2) DEFAULT 0,
    outstanding_balance DECIMAL(18,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_dist_cust_code UNIQUE (distributor_id, code)
);

COMMENT ON TABLE customer IS 'Retail outlets/Points of Sale';
COMMENT ON COLUMN customer.channel IS 'GT=General Trade, MT=Modern Trade, HORECA=Hotel/Restaurant/Cafe';

-- Customer Address (Multiple addresses)
CREATE TABLE customer_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customer(id) ON DELETE CASCADE,
    address_type VARCHAR(20) DEFAULT 'SHIPPING' CHECK (address_type IN ('SHIPPING', 'BILLING', 'BOTH')),
    address_line TEXT NOT NULL,
    ward_id VARCHAR(20),
    district_id VARCHAR(20),
    province_id VARCHAR(20),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE customer_address IS 'Customer addresses (shipping, billing)';

-- Customer Route Assignment (Visit frequency)
CREATE TABLE customer_route (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customer(id) ON DELETE CASCADE,
    route_id UUID REFERENCES route(id),
    visit_frequency VARCHAR(20) CHECK (visit_frequency IN ('F2', 'F4', 'F8', 'F12')),
    visit_days INT[],
    sequence_number INT,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE customer_route IS 'Customer-Route assignment with visit frequency';
COMMENT ON COLUMN customer_route.visit_frequency IS 'F2=2x/month, F4=weekly, F8=2x/week';
COMMENT ON COLUMN customer_route.visit_days IS 'Array of weekdays [1-7], e.g., [2,4,6] for Mon,Wed,Fri';

-- ============================================================
-- GROUP E: PRODUCT - SKU Management
-- ============================================================

-- Brand
CREATE TABLE brand (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE,
    name VARCHAR(100) NOT NULL,
    logo_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE'
);

-- Product Category
CREATE TABLE product_category (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE,
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES product_category(id),
    level INT DEFAULT 1
);

-- Unit of Measure
CREATE TABLE uom (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50)
);

COMMENT ON TABLE uom IS 'Units of Measure (Box, Piece, Case)';

-- Product (SKU)
CREATE TABLE product (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),
    brand_id UUID REFERENCES brand(id),
    category_id UUID REFERENCES product_category(id),
    primary_uom_id UUID REFERENCES uom(id),
    barcode VARCHAR(50),
    weight DECIMAL(10,4),
    volume DECIMAL(10,4),
    attributes JSONB DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'DISCONTINUED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE product IS 'Product master (SKU)';

-- Product UOM Conversion
CREATE TABLE product_uom_conversion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES product(id) ON DELETE CASCADE,
    from_uom_id UUID REFERENCES uom(id),
    to_uom_id UUID REFERENCES uom(id),
    factor DECIMAL(10,4) NOT NULL,
    is_base BOOLEAN DEFAULT FALSE,
    UNIQUE(product_id, from_uom_id, to_uom_id)
);

COMMENT ON TABLE product_uom_conversion IS 'UOM conversion (1 Case = 24 Pieces)';

-- ============================================================
-- GROUP F: PRICING - Price List & Promotion
-- ============================================================

-- Price List (Header)
CREATE TABLE price_list (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100),
    description TEXT,
    valid_from DATE,
    valid_to DATE,
    priority INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'ACTIVE', 'EXPIRED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Price List Item
CREATE TABLE price_list_item (
    price_list_id UUID REFERENCES price_list(id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(id),
    uom_id UUID REFERENCES uom(id),
    price DECIMAL(18,2) NOT NULL,
    min_quantity DECIMAL(12,4) DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (price_list_id, product_id, uom_id)
);

-- Promotion (Header)
CREATE TABLE promotion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255),
    description TEXT,
    type VARCHAR(50) CHECK (type IN ('DISCOUNT', 'GIFT', 'BUNDLE', 'REBATE')),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    budget DECIMAL(18,2),
    spent_amount DECIMAL(18,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'ACTIVE', 'PAUSED', 'EXPIRED')),
    rules JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE promotion IS 'Promotion programs';

-- ============================================================
-- GROUP G: SALES - Order to Cash (O2C)
-- ============================================================

-- Sales Order (Header)
CREATE TABLE sales_order (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    distributor_id UUID REFERENCES distributor(id),
    customer_id UUID REFERENCES customer(id),
    salesman_id UUID REFERENCES employee(id),
    route_id UUID REFERENCES route(id),
    visit_id UUID,
    order_date TIMESTAMPTZ NOT NULL,
    expected_delivery_date DATE,
    shipping_address_id UUID REFERENCES customer_address(id),
    subtotal_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    tax_amount DECIMAL(18,2) DEFAULT 0,
    total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    notes TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT'
        CHECK (status IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'PROCESSING', 'COMPLETED', 'CANCELLED')),
    created_by UUID REFERENCES user_account(id),
    approved_by UUID REFERENCES user_account(id),
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE sales_order IS 'Sales orders';

-- Sales Order Line
CREATE TABLE sales_order_line (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sales_order_id UUID REFERENCES sales_order(id) ON DELETE CASCADE,
    line_number INT NOT NULL,
    product_id UUID REFERENCES product(id),
    uom_id UUID REFERENCES uom(id),
    quantity DECIMAL(12,4) NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    tax_percent DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(18,2) DEFAULT 0,
    total_price DECIMAL(18,2) NOT NULL,
    promotion_id UUID REFERENCES promotion(id),
    is_free_goods BOOLEAN DEFAULT FALSE,
    notes TEXT,
    UNIQUE(sales_order_id, line_number)
);

COMMENT ON TABLE sales_order_line IS 'Sales order line items';

-- Sales Order Status History
CREATE TABLE sales_order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sales_order_id UUID REFERENCES sales_order(id) ON DELETE CASCADE,
    from_status VARCHAR(20),
    to_status VARCHAR(20) NOT NULL,
    reason TEXT,
    changed_by UUID REFERENCES user_account(id),
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Delivery (Delivery Note)
CREATE TABLE delivery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_number VARCHAR(50) NOT NULL UNIQUE,
    sales_order_id UUID REFERENCES sales_order(id),
    warehouse_id UUID REFERENCES warehouse(id),
    driver_id UUID REFERENCES employee(id),
    vehicle_number VARCHAR(20),
    delivery_date TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    receiver_name VARCHAR(100),
    receiver_phone VARCHAR(20),
    delivery_address TEXT,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'PICKING', 'SHIPPED', 'DELIVERED', 'PARTIAL', 'FAILED', 'RETURNED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Delivery Line
CREATE TABLE delivery_line (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id UUID REFERENCES delivery(id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(id),
    uom_id UUID REFERENCES uom(id),
    quantity_ordered DECIMAL(12,4) NOT NULL,
    quantity_delivered DECIMAL(12,4) NOT NULL DEFAULT 0,
    quantity_returned DECIMAL(12,4) DEFAULT 0,
    batch_number VARCHAR(50),
    expiry_date DATE
);

-- Invoice
CREATE TABLE invoice (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    sales_order_id UUID REFERENCES sales_order(id),
    delivery_id UUID REFERENCES delivery(id),
    customer_id UUID REFERENCES customer(id),
    distributor_id UUID REFERENCES distributor(id),
    invoice_date DATE NOT NULL,
    due_date DATE,
    subtotal_amount DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    tax_amount DECIMAL(18,2) DEFAULT 0,
    total_amount DECIMAL(18,2) NOT NULL,
    paid_amount DECIMAL(18,2) DEFAULT 0,
    balance DECIMAL(18,2) GENERATED ALWAYS AS (total_amount - paid_amount) STORED,
    status VARCHAR(20) DEFAULT 'DRAFT'
        CHECK (status IN ('DRAFT', 'ISSUED', 'PARTIAL', 'PAID', 'OVERDUE', 'CANCELLED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payment
CREATE TABLE payment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_number VARCHAR(50) NOT NULL UNIQUE,
    invoice_id UUID REFERENCES invoice(id),
    customer_id UUID REFERENCES customer(id),
    collector_id UUID REFERENCES employee(id),
    payment_date TIMESTAMPTZ NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    payment_method VARCHAR(50) CHECK (payment_method IN ('CASH', 'TRANSFER', 'CHECK', 'CREDIT')),
    reference_number VARCHAR(100),
    bank_name VARCHAR(100),
    notes TEXT,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED')),
    confirmed_by UUID REFERENCES user_account(id),
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- GROUP H: INVENTORY - Stock Management
-- ============================================================

-- Inventory Balance (Snapshot - High Performance)
CREATE TABLE inventory_balance (
    warehouse_id UUID REFERENCES warehouse(id),
    product_id UUID REFERENCES product(id),
    quantity DECIMAL(12,4) NOT NULL DEFAULT 0,
    reserved_quantity DECIMAL(12,4) DEFAULT 0,
    available_quantity DECIMAL(12,4) GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (warehouse_id, product_id)
);

COMMENT ON TABLE inventory_balance IS 'Current stock levels (snapshot for fast queries)';

-- Inventory Transaction (Header)
CREATE TABLE inventory_txn (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    txn_number VARCHAR(50) NOT NULL UNIQUE,
    warehouse_id UUID REFERENCES warehouse(id),
    txn_type VARCHAR(50) NOT NULL
        CHECK (txn_type IN ('IMPORT', 'EXPORT_SALES', 'EXPORT_TRANSFER', 'ADJUSTMENT', 'RETURN', 'DAMAGE')),
    txn_date TIMESTAMPTZ DEFAULT NOW(),
    reference_id UUID,
    reference_type VARCHAR(50),
    notes TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'CONFIRMED', 'CANCELLED')),
    created_by UUID REFERENCES user_account(id),
    confirmed_by UUID REFERENCES user_account(id),
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE inventory_txn IS 'Inventory transactions (source of truth)';

-- Inventory Transaction Line
CREATE TABLE inventory_txn_line (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_txn_id UUID REFERENCES inventory_txn(id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(id),
    uom_id UUID REFERENCES uom(id),
    quantity DECIMAL(12,4) NOT NULL,
    direction INT NOT NULL CHECK (direction IN (1, -1)),
    batch_number VARCHAR(50),
    expiry_date DATE,
    unit_cost DECIMAL(18,2)
);

COMMENT ON COLUMN inventory_txn_line.direction IS '1=IN (Import), -1=OUT (Export)';

-- ============================================================
-- GROUP I: FIELD FORCE - Visit & Attendance
-- ============================================================

-- Visit
CREATE TABLE visit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_code VARCHAR(50) UNIQUE,
    salesman_id UUID REFERENCES employee(id),
    customer_id UUID REFERENCES customer(id),
    route_id UUID REFERENCES route(id),
    planned_date DATE,
    checkin_time TIMESTAMPTZ NOT NULL,
    checkout_time TIMESTAMPTZ,
    duration_minutes INT GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (checkout_time - checkin_time)) / 60
    ) STORED,
    checkin_lat DECIMAL(10,8),
    checkin_long DECIMAL(11,8),
    checkout_lat DECIMAL(10,8),
    checkout_long DECIMAL(11,8),
    distance_from_customer INT,
    is_in_range BOOLEAN DEFAULT TRUE,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE visit IS 'Field visit records';

-- Add FK from sales_order to visit
ALTER TABLE sales_order ADD CONSTRAINT fk_sales_order_visit
    FOREIGN KEY (visit_id) REFERENCES visit(id);

-- Visit Action
CREATE TABLE visit_action (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_id UUID REFERENCES visit(id) ON DELETE CASCADE,
    action_type VARCHAR(50) CHECK (action_type IN ('ORDER', 'SURVEY', 'PHOTO', 'COLLECTION', 'DISPLAY_CHECK', 'COMPETITOR_CHECK')),
    reference_id UUID,
    reference_type VARCHAR(50),
    data JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Attachment (Photos/Files)
CREATE TABLE attachment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_name VARCHAR(255),
    file_size INT,
    file_type VARCHAR(50) CHECK (file_type IN ('IMAGE', 'VIDEO', 'DOC', 'PDF')),
    tag VARCHAR(50),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE attachment IS 'File attachments (photos, documents)';
COMMENT ON COLUMN attachment.tag IS 'SHELF=Display, PROMO=Promotion, COMPETITOR=Competitor';

-- Attendance
CREATE TABLE attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID REFERENCES employee(id),
    date DATE NOT NULL,
    checkin_time TIMESTAMPTZ,
    checkin_lat DECIMAL(10,8),
    checkin_long DECIMAL(11,8),
    checkout_time TIMESTAMPTZ,
    checkout_lat DECIMAL(10,8),
    checkout_long DECIMAL(11,8),
    work_hours DECIMAL(4,2) GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (checkout_time - checkin_time)) / 3600
    ) STORED,
    status VARCHAR(20) CHECK (status IN ('PRESENT', 'ABSENT', 'LEAVE', 'HALF_DAY')),
    notes TEXT,
    UNIQUE(employee_id, date)
);

-- ============================================================
-- GROUP J: KPI - Performance Metrics
-- ============================================================

-- KPI Metric Definition
CREATE TABLE kpi_metric (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    unit VARCHAR(20),
    calculation_method TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE kpi_metric IS 'KPI metric definitions (Revenue, Visits, etc.)';

-- KPI Target
CREATE TABLE kpi_target (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_id UUID REFERENCES kpi_metric(id),
    target_type VARCHAR(20) CHECK (target_type IN ('EMPLOYEE', 'ORG_UNIT', 'DISTRIBUTOR', 'ROUTE')),
    target_entity_id UUID NOT NULL,
    period_type VARCHAR(20) CHECK (period_type IN ('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    target_value DECIMAL(18,2) NOT NULL,
    actual_value DECIMAL(18,2) DEFAULT 0,
    achievement_percent DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN target_value > 0 THEN (actual_value / target_value) * 100 ELSE 0 END
    ) STORED,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE kpi_target IS 'KPI targets assigned to entities';

-- ============================================================
-- GROUP K: SYSTEM - Audit & Logging
-- ============================================================

-- System Audit Log
CREATE TABLE system_audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_value JSONB,
    new_value JSONB,
    changed_fields TEXT[],
    changed_by UUID REFERENCES user_account(id),
    ip_address INET,
    user_agent TEXT,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE system_audit_log IS 'Audit trail for all data changes';

-- System Configuration
CREATE TABLE system_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(100) NOT NULL UNIQUE,
    value TEXT,
    value_type VARCHAR(20) DEFAULT 'STRING',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TRIGGER: Auto-update updated_at
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN
        SELECT table_name
        FROM information_schema.columns
        WHERE column_name = 'updated_at'
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS trigger_update_%I ON %I;
            CREATE TRIGGER trigger_update_%I
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        ', t, t, t, t);
    END LOOP;
END $$;
