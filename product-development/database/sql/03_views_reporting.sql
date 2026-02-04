-- ============================================================
-- DILIGO DMS - Reporting Views
-- Distribution Management System
-- Version: 3.1 | PostgreSQL 16+
-- ============================================================

-- ============================================================
-- A. ORGANIZATION VIEWS
-- ============================================================

-- Employee with organization hierarchy
CREATE OR REPLACE VIEW v_employee_org AS
SELECT
    e.id,
    e.code AS employee_code,
    e.full_name,
    e.email,
    e.phone,
    e.status,
    ou.id AS org_unit_id,
    ou.code AS org_unit_code,
    ou.name AS org_unit_name,
    ou.type AS org_unit_type,
    parent_ou.name AS parent_org_unit_name
FROM employee e
JOIN org_unit ou ON e.org_unit_id = ou.id
LEFT JOIN org_unit parent_ou ON ou.parent_id = parent_ou.id
WHERE e.deleted_at IS NULL;

-- User with roles and permissions
CREATE OR REPLACE VIEW v_user_permissions AS
SELECT
    ua.id AS user_id,
    ua.username,
    e.full_name,
    e.code AS employee_code,
    r.code AS role_code,
    r.name AS role_name,
    ARRAY_AGG(DISTINCT p.code) AS permissions
FROM user_account ua
LEFT JOIN employee e ON ua.employee_id = e.id
JOIN user_role ur ON ua.id = ur.user_id
JOIN role r ON ur.role_id = r.id
JOIN role_permission rp ON r.id = rp.role_id
JOIN permission p ON rp.permission_id = p.id
WHERE ua.deleted_at IS NULL
GROUP BY ua.id, ua.username, e.full_name, e.code, r.code, r.name;

-- ============================================================
-- B. TERRITORY & ROUTE VIEWS
-- ============================================================

-- Current route assignments (active only)
CREATE OR REPLACE VIEW v_route_assignment_current AS
SELECT
    ra.id,
    r.id AS route_id,
    r.code AS route_code,
    r.name AS route_name,
    e.id AS employee_id,
    e.code AS employee_code,
    e.full_name AS employee_name,
    d.id AS distributor_id,
    d.code AS distributor_code,
    d.name AS distributor_name,
    ra.start_date,
    ra.is_primary
FROM route_assignment ra
JOIN route r ON ra.route_id = r.id
JOIN employee e ON ra.employee_id = e.id
JOIN distributor d ON r.distributor_id = d.id
WHERE ra.end_date IS NULL OR ra.end_date >= CURRENT_DATE;

-- Route coverage summary
CREATE OR REPLACE VIEW v_route_coverage AS
SELECT
    r.id AS route_id,
    r.code AS route_code,
    r.name AS route_name,
    d.name AS distributor_name,
    COUNT(DISTINCT cr.customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN c.status = 'ACTIVE' THEN cr.customer_id END) AS active_customers,
    e.full_name AS current_salesman
FROM route r
JOIN distributor d ON r.distributor_id = d.id
LEFT JOIN customer_route cr ON r.id = cr.route_id
    AND (cr.end_date IS NULL OR cr.end_date >= CURRENT_DATE)
LEFT JOIN customer c ON cr.customer_id = c.id AND c.deleted_at IS NULL
LEFT JOIN route_assignment ra ON r.id = ra.route_id
    AND ra.is_primary = TRUE
    AND (ra.end_date IS NULL OR ra.end_date >= CURRENT_DATE)
LEFT JOIN employee e ON ra.employee_id = e.id
WHERE r.status = 'ACTIVE'
GROUP BY r.id, r.code, r.name, d.name, e.full_name;

-- ============================================================
-- C. CUSTOMER VIEWS
-- ============================================================

-- Customer master with full details
CREATE OR REPLACE VIEW v_customer_master AS
SELECT
    c.id,
    c.code AS customer_code,
    c.name AS customer_name,
    c.channel,
    c.type,
    c.status,
    c.credit_limit,
    c.outstanding_balance,
    cg.name AS customer_group,
    d.code AS distributor_code,
    d.name AS distributor_name,
    ca.address_line AS default_address,
    ca.latitude,
    ca.longitude,
    r.code AS route_code,
    r.name AS route_name,
    cr.visit_frequency,
    cr.visit_days
FROM customer c
LEFT JOIN customer_group cg ON c.customer_group_id = cg.id
LEFT JOIN distributor d ON c.distributor_id = d.id
LEFT JOIN customer_address ca ON c.id = ca.customer_id AND ca.is_default = TRUE
LEFT JOIN customer_route cr ON c.id = cr.customer_id
    AND (cr.end_date IS NULL OR cr.end_date >= CURRENT_DATE)
LEFT JOIN route r ON cr.route_id = r.id
WHERE c.deleted_at IS NULL;

-- Customer credit status
CREATE OR REPLACE VIEW v_customer_credit AS
SELECT
    c.id,
    c.code,
    c.name,
    c.credit_limit,
    c.outstanding_balance,
    c.credit_limit - c.outstanding_balance AS available_credit,
    CASE
        WHEN c.credit_limit = 0 THEN 'NO_CREDIT'
        WHEN c.outstanding_balance >= c.credit_limit THEN 'BLOCKED'
        WHEN c.outstanding_balance >= c.credit_limit * 0.8 THEN 'WARNING'
        ELSE 'OK'
    END AS credit_status,
    d.name AS distributor_name
FROM customer c
JOIN distributor d ON c.distributor_id = d.id
WHERE c.deleted_at IS NULL AND c.status = 'ACTIVE';

-- ============================================================
-- D. PRODUCT VIEWS
-- ============================================================

-- Product catalog with brand and UOM
CREATE OR REPLACE VIEW v_product_catalog AS
SELECT
    p.id,
    p.code AS sku,
    p.name AS product_name,
    p.short_name,
    b.name AS brand_name,
    pc.name AS category_name,
    u.code AS primary_uom,
    u.name AS uom_name,
    p.barcode,
    p.status,
    p.attributes
FROM product p
LEFT JOIN brand b ON p.brand_id = b.id
LEFT JOIN product_category pc ON p.category_id = pc.id
LEFT JOIN uom u ON p.primary_uom_id = u.id
WHERE p.deleted_at IS NULL;

-- Active price list
CREATE OR REPLACE VIEW v_active_prices AS
SELECT
    p.id AS product_id,
    p.code AS sku,
    p.name AS product_name,
    u.code AS uom_code,
    pl.code AS price_list_code,
    pl.name AS price_list_name,
    pli.price,
    pli.min_quantity,
    pl.valid_from,
    pl.valid_to
FROM price_list pl
JOIN price_list_item pli ON pl.id = pli.price_list_id
JOIN product p ON pli.product_id = p.id
JOIN uom u ON pli.uom_id = u.id
WHERE pl.status = 'ACTIVE'
    AND pl.deleted_at IS NULL
    AND (pl.valid_from IS NULL OR pl.valid_from <= CURRENT_DATE)
    AND (pl.valid_to IS NULL OR pl.valid_to >= CURRENT_DATE);

-- ============================================================
-- E. SALES ORDER VIEWS
-- ============================================================

-- Sales order summary
CREATE OR REPLACE VIEW v_sales_order_summary AS
SELECT
    so.id,
    so.order_number,
    so.order_date,
    so.status,
    c.code AS customer_code,
    c.name AS customer_name,
    d.code AS distributor_code,
    d.name AS distributor_name,
    e.full_name AS salesman_name,
    r.name AS route_name,
    so.subtotal_amount,
    so.discount_amount,
    so.tax_amount,
    so.total_amount,
    COUNT(sol.id) AS line_count,
    SUM(sol.quantity) AS total_quantity
FROM sales_order so
JOIN customer c ON so.customer_id = c.id
JOIN distributor d ON so.distributor_id = d.id
LEFT JOIN employee e ON so.salesman_id = e.id
LEFT JOIN route r ON so.route_id = r.id
LEFT JOIN sales_order_line sol ON so.id = sol.sales_order_id
WHERE so.deleted_at IS NULL
GROUP BY so.id, so.order_number, so.order_date, so.status,
    c.code, c.name, d.code, d.name, e.full_name, r.name,
    so.subtotal_amount, so.discount_amount, so.tax_amount, so.total_amount;

-- Order to Cash pipeline
CREATE OR REPLACE VIEW v_order_to_cash AS
SELECT
    so.id AS order_id,
    so.order_number,
    so.order_date,
    so.status AS order_status,
    so.total_amount AS order_amount,
    c.name AS customer_name,
    d.name AS distributor_name,
    del.delivery_number,
    del.status AS delivery_status,
    del.delivered_at,
    inv.invoice_number,
    inv.invoice_date,
    inv.total_amount AS invoice_amount,
    inv.paid_amount,
    inv.balance AS invoice_balance,
    inv.status AS invoice_status,
    inv.due_date
FROM sales_order so
JOIN customer c ON so.customer_id = c.id
JOIN distributor d ON so.distributor_id = d.id
LEFT JOIN delivery del ON so.id = del.sales_order_id
LEFT JOIN invoice inv ON so.id = inv.sales_order_id
WHERE so.deleted_at IS NULL;

-- ============================================================
-- F. INVENTORY VIEWS
-- ============================================================

-- Current stock levels
CREATE OR REPLACE VIEW v_inventory_stock AS
SELECT
    ib.warehouse_id,
    w.code AS warehouse_code,
    w.name AS warehouse_name,
    w.type AS warehouse_type,
    d.name AS distributor_name,
    ib.product_id,
    p.code AS sku,
    p.name AS product_name,
    ib.quantity,
    ib.reserved_quantity,
    ib.available_quantity,
    ib.last_updated_at
FROM inventory_balance ib
JOIN warehouse w ON ib.warehouse_id = w.id
JOIN distributor d ON w.distributor_id = d.id
JOIN product p ON ib.product_id = p.id
WHERE w.deleted_at IS NULL AND p.deleted_at IS NULL;

-- Low stock alerts
CREATE OR REPLACE VIEW v_low_stock_alert AS
SELECT
    w.id AS warehouse_id,
    w.code AS warehouse_code,
    w.name AS warehouse_name,
    d.name AS distributor_name,
    p.code AS sku,
    p.name AS product_name,
    ib.quantity AS current_stock,
    ib.available_quantity,
    'LOW_STOCK' AS alert_type
FROM inventory_balance ib
JOIN warehouse w ON ib.warehouse_id = w.id
JOIN distributor d ON w.distributor_id = d.id
JOIN product p ON ib.product_id = p.id
WHERE ib.available_quantity <= 10  -- Threshold configurable
    AND w.deleted_at IS NULL
    AND p.deleted_at IS NULL
    AND p.status = 'ACTIVE';

-- Inventory movement summary
CREATE OR REPLACE VIEW v_inventory_movement AS
SELECT
    it.id,
    it.txn_number,
    it.txn_type,
    it.txn_date,
    w.name AS warehouse_name,
    it.status,
    it.reference_type,
    COUNT(itl.id) AS line_count,
    SUM(CASE WHEN itl.direction = 1 THEN itl.quantity ELSE 0 END) AS total_in,
    SUM(CASE WHEN itl.direction = -1 THEN itl.quantity ELSE 0 END) AS total_out
FROM inventory_txn it
JOIN warehouse w ON it.warehouse_id = w.id
LEFT JOIN inventory_txn_line itl ON it.id = itl.inventory_txn_id
GROUP BY it.id, it.txn_number, it.txn_type, it.txn_date,
    w.name, it.status, it.reference_type;

-- ============================================================
-- G. FIELD FORCE VIEWS
-- ============================================================

-- Visit summary
CREATE OR REPLACE VIEW v_visit_summary AS
SELECT
    v.id,
    v.visit_code,
    v.checkin_time,
    v.checkout_time,
    v.duration_minutes,
    v.status,
    e.code AS salesman_code,
    e.full_name AS salesman_name,
    c.code AS customer_code,
    c.name AS customer_name,
    r.name AS route_name,
    v.is_in_range,
    (SELECT COUNT(*) FROM visit_action va WHERE va.visit_id = v.id AND va.action_type = 'ORDER') AS order_count,
    (SELECT COUNT(*) FROM visit_action va WHERE va.visit_id = v.id AND va.action_type = 'PHOTO') AS photo_count,
    (SELECT COUNT(*) FROM visit_action va WHERE va.visit_id = v.id AND va.action_type = 'COLLECTION') AS collection_count
FROM visit v
JOIN employee e ON v.salesman_id = e.id
JOIN customer c ON v.customer_id = c.id
LEFT JOIN route r ON v.route_id = r.id;

-- Daily visit plan vs actual
CREATE OR REPLACE VIEW v_visit_plan_actual AS
SELECT
    e.id AS employee_id,
    e.code AS employee_code,
    e.full_name AS employee_name,
    r.id AS route_id,
    r.name AS route_name,
    planned.plan_date,
    planned.planned_customers,
    COALESCE(actual.visited_customers, 0) AS visited_customers,
    COALESCE(actual.visit_count, 0) AS total_visits,
    CASE
        WHEN planned.planned_customers > 0
        THEN ROUND((COALESCE(actual.visited_customers, 0)::DECIMAL / planned.planned_customers) * 100, 1)
        ELSE 0
    END AS strike_rate
FROM employee e
JOIN route_assignment ra ON e.id = ra.employee_id
    AND ra.is_primary = TRUE
    AND (ra.end_date IS NULL OR ra.end_date >= CURRENT_DATE)
JOIN route r ON ra.route_id = r.id
CROSS JOIN LATERAL (
    SELECT
        CURRENT_DATE AS plan_date,
        COUNT(DISTINCT cr.customer_id) AS planned_customers
    FROM customer_route cr
    WHERE cr.route_id = r.id
        AND (cr.end_date IS NULL OR cr.end_date >= CURRENT_DATE)
        AND EXTRACT(DOW FROM CURRENT_DATE) = ANY(cr.visit_days)
) planned
LEFT JOIN LATERAL (
    SELECT
        COUNT(DISTINCT v.customer_id) AS visited_customers,
        COUNT(v.id) AS visit_count
    FROM visit v
    WHERE v.salesman_id = e.id
        AND v.route_id = r.id
        AND DATE(v.checkin_time) = CURRENT_DATE
        AND v.status = 'COMPLETED'
) actual ON TRUE;

-- Attendance summary
CREATE OR REPLACE VIEW v_attendance_summary AS
SELECT
    a.employee_id,
    e.code AS employee_code,
    e.full_name AS employee_name,
    ou.name AS org_unit_name,
    a.date,
    a.checkin_time,
    a.checkout_time,
    a.work_hours,
    a.status,
    (SELECT COUNT(*) FROM visit v
     WHERE v.salesman_id = a.employee_id
     AND DATE(v.checkin_time) = a.date) AS visits_count
FROM attendance a
JOIN employee e ON a.employee_id = e.id
JOIN org_unit ou ON e.org_unit_id = ou.id;

-- ============================================================
-- H. KPI VIEWS
-- ============================================================

-- KPI achievement dashboard
CREATE OR REPLACE VIEW v_kpi_achievement AS
SELECT
    kt.id,
    km.code AS metric_code,
    km.name AS metric_name,
    kt.target_type,
    CASE kt.target_type
        WHEN 'EMPLOYEE' THEN e.full_name
        WHEN 'ORG_UNIT' THEN ou.name
        WHEN 'DISTRIBUTOR' THEN d.name
        WHEN 'ROUTE' THEN r.name
    END AS target_name,
    kt.period_type,
    kt.period_start,
    kt.period_end,
    kt.target_value,
    kt.actual_value,
    kt.achievement_percent,
    CASE
        WHEN kt.achievement_percent >= 100 THEN 'ACHIEVED'
        WHEN kt.achievement_percent >= 80 THEN 'ON_TRACK'
        WHEN kt.achievement_percent >= 50 THEN 'BEHIND'
        ELSE 'AT_RISK'
    END AS status
FROM kpi_target kt
JOIN kpi_metric km ON kt.metric_id = km.id
LEFT JOIN employee e ON kt.target_type = 'EMPLOYEE' AND kt.target_entity_id = e.id
LEFT JOIN org_unit ou ON kt.target_type = 'ORG_UNIT' AND kt.target_entity_id = ou.id
LEFT JOIN distributor d ON kt.target_type = 'DISTRIBUTOR' AND kt.target_entity_id = d.id
LEFT JOIN route r ON kt.target_type = 'ROUTE' AND kt.target_entity_id = r.id;

-- ============================================================
-- I. FINANCIAL VIEWS
-- ============================================================

-- Accounts receivable aging
CREATE OR REPLACE VIEW v_ar_aging AS
SELECT
    c.id AS customer_id,
    c.code AS customer_code,
    c.name AS customer_name,
    d.name AS distributor_name,
    inv.invoice_number,
    inv.invoice_date,
    inv.due_date,
    inv.total_amount,
    inv.paid_amount,
    inv.balance,
    CURRENT_DATE - inv.due_date AS days_overdue,
    CASE
        WHEN inv.due_date >= CURRENT_DATE THEN 'CURRENT'
        WHEN CURRENT_DATE - inv.due_date <= 30 THEN '1-30 DAYS'
        WHEN CURRENT_DATE - inv.due_date <= 60 THEN '31-60 DAYS'
        WHEN CURRENT_DATE - inv.due_date <= 90 THEN '61-90 DAYS'
        ELSE 'OVER 90 DAYS'
    END AS aging_bucket
FROM invoice inv
JOIN customer c ON inv.customer_id = c.id
JOIN distributor d ON inv.distributor_id = d.id
WHERE inv.status IN ('ISSUED', 'PARTIAL', 'OVERDUE')
    AND inv.balance > 0;

-- AR aging summary by bucket
CREATE OR REPLACE VIEW v_ar_aging_summary AS
SELECT
    d.id AS distributor_id,
    d.name AS distributor_name,
    SUM(CASE WHEN inv.due_date >= CURRENT_DATE THEN inv.balance ELSE 0 END) AS current_amount,
    SUM(CASE WHEN CURRENT_DATE - inv.due_date BETWEEN 1 AND 30 THEN inv.balance ELSE 0 END) AS days_1_30,
    SUM(CASE WHEN CURRENT_DATE - inv.due_date BETWEEN 31 AND 60 THEN inv.balance ELSE 0 END) AS days_31_60,
    SUM(CASE WHEN CURRENT_DATE - inv.due_date BETWEEN 61 AND 90 THEN inv.balance ELSE 0 END) AS days_61_90,
    SUM(CASE WHEN CURRENT_DATE - inv.due_date > 90 THEN inv.balance ELSE 0 END) AS over_90_days,
    SUM(inv.balance) AS total_outstanding
FROM invoice inv
JOIN distributor d ON inv.distributor_id = d.id
WHERE inv.status IN ('ISSUED', 'PARTIAL', 'OVERDUE')
    AND inv.balance > 0
GROUP BY d.id, d.name;

-- ============================================================
-- J. DAILY SUMMARY VIEWS
-- ============================================================

-- Daily sales summary by distributor
CREATE OR REPLACE VIEW v_daily_sales_summary AS
SELECT
    DATE(so.order_date) AS order_date,
    d.id AS distributor_id,
    d.code AS distributor_code,
    d.name AS distributor_name,
    COUNT(DISTINCT so.id) AS order_count,
    COUNT(DISTINCT so.customer_id) AS customer_count,
    COUNT(DISTINCT so.salesman_id) AS salesman_count,
    SUM(so.total_amount) AS total_sales,
    SUM(so.discount_amount) AS total_discount,
    AVG(so.total_amount) AS avg_order_value
FROM sales_order so
JOIN distributor d ON so.distributor_id = d.id
WHERE so.deleted_at IS NULL
    AND so.status NOT IN ('DRAFT', 'CANCELLED', 'REJECTED')
GROUP BY DATE(so.order_date), d.id, d.code, d.name;

-- Daily collection summary
CREATE OR REPLACE VIEW v_daily_collection_summary AS
SELECT
    DATE(p.payment_date) AS payment_date,
    d.id AS distributor_id,
    d.name AS distributor_name,
    COUNT(p.id) AS payment_count,
    SUM(CASE WHEN p.payment_method = 'CASH' THEN p.amount ELSE 0 END) AS cash_amount,
    SUM(CASE WHEN p.payment_method = 'TRANSFER' THEN p.amount ELSE 0 END) AS transfer_amount,
    SUM(p.amount) AS total_collected
FROM payment p
JOIN invoice inv ON p.invoice_id = inv.id
JOIN distributor d ON inv.distributor_id = d.id
WHERE p.status = 'CONFIRMED'
GROUP BY DATE(p.payment_date), d.id, d.name;
