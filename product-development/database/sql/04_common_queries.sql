-- ============================================================
-- DMS VIPPro - Common Queries by Module
-- Distribution Management System
-- Version: 3.1 | PostgreSQL 16+
-- ============================================================

-- ============================================================
-- A. ORGANIZATION QUERIES
-- ============================================================

-- A1. Get organization tree (recursive)
WITH RECURSIVE org_tree AS (
    SELECT id, code, name, parent_id, type, 1 AS level,
           name::TEXT AS path
    FROM org_unit
    WHERE parent_id IS NULL AND deleted_at IS NULL

    UNION ALL

    SELECT o.id, o.code, o.name, o.parent_id, o.type, ot.level + 1,
           ot.path || ' > ' || o.name
    FROM org_unit o
    JOIN org_tree ot ON o.parent_id = ot.id
    WHERE o.deleted_at IS NULL
)
SELECT * FROM org_tree ORDER BY path;

-- A2. Get all employees under an org unit (including sub-units)
WITH RECURSIVE org_tree AS (
    SELECT id FROM org_unit WHERE id = :org_unit_id
    UNION ALL
    SELECT o.id FROM org_unit o
    JOIN org_tree ot ON o.parent_id = ot.id
    WHERE o.deleted_at IS NULL
)
SELECT e.*
FROM employee e
WHERE e.org_unit_id IN (SELECT id FROM org_tree)
    AND e.deleted_at IS NULL;

-- A3. Check user permission
SELECT EXISTS (
    SELECT 1
    FROM user_role ur
    JOIN role_permission rp ON ur.role_id = rp.role_id
    JOIN permission p ON rp.permission_id = p.id
    WHERE ur.user_id = :user_id
        AND p.code = :permission_code
) AS has_permission;

-- A4. Get user's all permissions
SELECT DISTINCT p.code, p.description, p.module
FROM user_role ur
JOIN role_permission rp ON ur.role_id = rp.role_id
JOIN permission p ON rp.permission_id = p.id
WHERE ur.user_id = :user_id
ORDER BY p.module, p.code;

-- ============================================================
-- B. TERRITORY & ROUTE QUERIES
-- ============================================================

-- B1. Get current route assignment for employee
SELECT r.id, r.code, r.name, d.name AS distributor_name,
       ra.start_date, ra.is_primary
FROM route_assignment ra
JOIN route r ON ra.route_id = r.id
JOIN distributor d ON r.distributor_id = d.id
WHERE ra.employee_id = :employee_id
    AND (ra.end_date IS NULL OR ra.end_date >= CURRENT_DATE)
ORDER BY ra.is_primary DESC;

-- B2. Get customers for a route with visit schedule for today
SELECT c.id, c.code, c.name, c.phone,
       ca.address_line, ca.latitude, ca.longitude,
       cr.visit_frequency, cr.visit_days, cr.sequence_number
FROM customer_route cr
JOIN customer c ON cr.customer_id = c.id
LEFT JOIN customer_address ca ON c.id = ca.customer_id AND ca.is_default = TRUE
WHERE cr.route_id = :route_id
    AND (cr.end_date IS NULL OR cr.end_date >= CURRENT_DATE)
    AND EXTRACT(DOW FROM CURRENT_DATE)::INT = ANY(cr.visit_days)
    AND c.deleted_at IS NULL
    AND c.status = 'ACTIVE'
ORDER BY cr.sequence_number;

-- B3. Route assignment history for a route (SCD Type 2)
SELECT e.code, e.full_name, ra.start_date, ra.end_date,
       ra.is_primary,
       CASE WHEN ra.end_date IS NULL THEN 'CURRENT' ELSE 'HISTORICAL' END AS status
FROM route_assignment ra
JOIN employee e ON ra.employee_id = e.id
WHERE ra.route_id = :route_id
ORDER BY ra.start_date DESC;

-- ============================================================
-- C. CUSTOMER QUERIES
-- ============================================================

-- C1. Search customers (fuzzy match)
SELECT c.id, c.code, c.name, c.channel, c.status,
       d.name AS distributor_name,
       similarity(c.name, :search_term) AS score
FROM customer c
JOIN distributor d ON c.distributor_id = d.id
WHERE c.deleted_at IS NULL
    AND (c.name ILIKE '%' || :search_term || '%'
         OR c.code ILIKE '%' || :search_term || '%')
ORDER BY similarity(c.name, :search_term) DESC
LIMIT 20;

-- C2. Get customers near a location (radius search)
SELECT c.id, c.code, c.name,
       ca.address_line, ca.latitude, ca.longitude,
       -- Haversine distance in meters
       (6371000 * acos(
           cos(radians(:lat)) * cos(radians(ca.latitude)) *
           cos(radians(ca.longitude) - radians(:long)) +
           sin(radians(:lat)) * sin(radians(ca.latitude))
       )) AS distance_meters
FROM customer c
JOIN customer_address ca ON c.id = ca.customer_id AND ca.is_default = TRUE
WHERE c.deleted_at IS NULL
    AND c.status = 'ACTIVE'
    AND ca.latitude IS NOT NULL
    AND ca.longitude IS NOT NULL
HAVING distance_meters <= :radius_meters
ORDER BY distance_meters;

-- C3. Customer credit check before order
SELECT
    c.id,
    c.code,
    c.name,
    c.credit_limit,
    c.outstanding_balance,
    c.credit_limit - c.outstanding_balance AS available_credit,
    CASE
        WHEN c.credit_limit = 0 THEN 'NO_CREDIT'
        WHEN :order_amount > (c.credit_limit - c.outstanding_balance) THEN 'EXCEEDED'
        ELSE 'OK'
    END AS credit_check_result
FROM customer c
WHERE c.id = :customer_id;

-- C4. Customer order history
SELECT so.order_number, so.order_date, so.total_amount, so.status,
       e.full_name AS salesman_name
FROM sales_order so
LEFT JOIN employee e ON so.salesman_id = e.id
WHERE so.customer_id = :customer_id
    AND so.deleted_at IS NULL
ORDER BY so.order_date DESC
LIMIT 20;

-- ============================================================
-- D. PRODUCT QUERIES
-- ============================================================

-- D1. Search products
SELECT p.id, p.code AS sku, p.name, p.short_name,
       b.name AS brand, u.code AS uom,
       similarity(p.name, :search_term) AS score
FROM product p
LEFT JOIN brand b ON p.brand_id = b.id
LEFT JOIN uom u ON p.primary_uom_id = u.id
WHERE p.deleted_at IS NULL
    AND p.status = 'ACTIVE'
    AND (p.name ILIKE '%' || :search_term || '%'
         OR p.code ILIKE '%' || :search_term || '%'
         OR p.barcode = :search_term)
ORDER BY similarity(p.name, :search_term) DESC
LIMIT 20;

-- D2. Get product with current price
SELECT p.id, p.code AS sku, p.name,
       u.code AS uom_code,
       pli.price,
       pl.name AS price_list_name
FROM product p
JOIN uom u ON p.primary_uom_id = u.id
LEFT JOIN price_list_item pli ON p.id = pli.product_id AND pli.uom_id = u.id
LEFT JOIN price_list pl ON pli.price_list_id = pl.id
    AND pl.status = 'ACTIVE'
    AND (pl.valid_from IS NULL OR pl.valid_from <= CURRENT_DATE)
    AND (pl.valid_to IS NULL OR pl.valid_to >= CURRENT_DATE)
WHERE p.id = :product_id
    AND p.deleted_at IS NULL;

-- D3. Get UOM conversions for a product
SELECT
    from_u.code AS from_uom,
    to_u.code AS to_uom,
    puc.factor,
    puc.is_base
FROM product_uom_conversion puc
JOIN uom from_u ON puc.from_uom_id = from_u.id
JOIN uom to_u ON puc.to_uom_id = to_u.id
WHERE puc.product_id = :product_id;

-- ============================================================
-- E. SALES ORDER QUERIES
-- ============================================================

-- E1. Create sales order with lines (transaction)
-- BEGIN;
INSERT INTO sales_order (
    order_number, distributor_id, customer_id, salesman_id,
    route_id, visit_id, order_date, total_amount, status, created_by
)
VALUES (
    :order_number, :distributor_id, :customer_id, :salesman_id,
    :route_id, :visit_id, NOW(), 0, 'DRAFT', :user_id
)
RETURNING id;

-- E2. Add order line
INSERT INTO sales_order_line (
    sales_order_id, line_number, product_id, uom_id,
    quantity, unit_price, total_price
)
VALUES (
    :order_id, :line_number, :product_id, :uom_id,
    :quantity, :unit_price, :quantity * :unit_price
);

-- E3. Update order totals
UPDATE sales_order
SET
    subtotal_amount = (
        SELECT COALESCE(SUM(total_price), 0)
        FROM sales_order_line WHERE sales_order_id = :order_id
    ),
    total_amount = (
        SELECT COALESCE(SUM(total_price - discount_amount + tax_amount), 0)
        FROM sales_order_line WHERE sales_order_id = :order_id
    )
WHERE id = :order_id;
-- COMMIT;

-- E4. Get order with lines
SELECT
    so.*,
    c.name AS customer_name,
    e.full_name AS salesman_name,
    json_agg(json_build_object(
        'line_number', sol.line_number,
        'product_code', p.code,
        'product_name', p.name,
        'uom', u.code,
        'quantity', sol.quantity,
        'unit_price', sol.unit_price,
        'total_price', sol.total_price
    ) ORDER BY sol.line_number) AS lines
FROM sales_order so
JOIN customer c ON so.customer_id = c.id
LEFT JOIN employee e ON so.salesman_id = e.id
LEFT JOIN sales_order_line sol ON so.id = sol.sales_order_id
LEFT JOIN product p ON sol.product_id = p.id
LEFT JOIN uom u ON sol.uom_id = u.id
WHERE so.id = :order_id
GROUP BY so.id, c.name, e.full_name;

-- E5. Change order status with history
INSERT INTO sales_order_status_history (
    sales_order_id, from_status, to_status, changed_by
)
SELECT id, status, :new_status, :user_id
FROM sales_order WHERE id = :order_id;

UPDATE sales_order
SET status = :new_status,
    approved_by = CASE WHEN :new_status = 'APPROVED' THEN :user_id ELSE approved_by END,
    approved_at = CASE WHEN :new_status = 'APPROVED' THEN NOW() ELSE approved_at END
WHERE id = :order_id;

-- E6. Orders pending approval
SELECT so.*, c.name AS customer_name, e.full_name AS salesman_name
FROM sales_order so
JOIN customer c ON so.customer_id = c.id
LEFT JOIN employee e ON so.salesman_id = e.id
WHERE so.status = 'SUBMITTED'
    AND so.distributor_id = :distributor_id
    AND so.deleted_at IS NULL
ORDER BY so.created_at;

-- ============================================================
-- F. INVENTORY QUERIES
-- ============================================================

-- F1. Check stock availability
SELECT
    ib.quantity,
    ib.reserved_quantity,
    ib.available_quantity,
    CASE
        WHEN ib.available_quantity >= :required_qty THEN 'AVAILABLE'
        WHEN ib.available_quantity > 0 THEN 'PARTIAL'
        ELSE 'OUT_OF_STOCK'
    END AS availability
FROM inventory_balance ib
WHERE ib.warehouse_id = :warehouse_id
    AND ib.product_id = :product_id;

-- F2. Reserve stock for order
UPDATE inventory_balance
SET reserved_quantity = reserved_quantity + :qty
WHERE warehouse_id = :warehouse_id
    AND product_id = :product_id
    AND available_quantity >= :qty
RETURNING *;

-- F3. Create inventory transaction (export for sales)
INSERT INTO inventory_txn (
    txn_number, warehouse_id, txn_type, reference_id, reference_type, status, created_by
)
VALUES (
    :txn_number, :warehouse_id, 'EXPORT_SALES', :sales_order_id, 'SALES_ORDER', 'DRAFT', :user_id
)
RETURNING id;

-- F4. Add transaction line and update balance
-- Add line
INSERT INTO inventory_txn_line (
    inventory_txn_id, product_id, uom_id, quantity, direction
)
VALUES (:txn_id, :product_id, :uom_id, :quantity, -1);

-- Update balance (on confirm)
UPDATE inventory_balance
SET
    quantity = quantity - :quantity,
    reserved_quantity = reserved_quantity - :quantity,
    last_updated_at = NOW()
WHERE warehouse_id = :warehouse_id AND product_id = :product_id;

-- F5. Stock movement report for a product
SELECT
    it.txn_date,
    it.txn_number,
    it.txn_type,
    itl.quantity * itl.direction AS movement,
    SUM(itl.quantity * itl.direction) OVER (ORDER BY it.txn_date) AS running_balance
FROM inventory_txn it
JOIN inventory_txn_line itl ON it.id = itl.inventory_txn_id
WHERE it.warehouse_id = :warehouse_id
    AND itl.product_id = :product_id
    AND it.status = 'CONFIRMED'
    AND it.txn_date BETWEEN :start_date AND :end_date
ORDER BY it.txn_date;

-- ============================================================
-- G. VISIT QUERIES
-- ============================================================

-- G1. Start visit (check-in)
INSERT INTO visit (
    visit_code, salesman_id, customer_id, route_id,
    planned_date, checkin_time, checkin_lat, checkin_long, status
)
VALUES (
    :visit_code, :salesman_id, :customer_id, :route_id,
    CURRENT_DATE, NOW(), :lat, :long, 'IN_PROGRESS'
)
RETURNING id;

-- G2. Complete visit (check-out)
UPDATE visit
SET
    checkout_time = NOW(),
    checkout_lat = :lat,
    checkout_long = :long,
    status = 'COMPLETED'
WHERE id = :visit_id;

-- G3. Log visit action
INSERT INTO visit_action (visit_id, action_type, reference_id, reference_type, data)
VALUES (:visit_id, :action_type, :reference_id, :reference_type, :data_json);

-- G4. Today's visit summary for salesman
SELECT
    COUNT(*) AS total_visits,
    COUNT(*) FILTER (WHERE status = 'COMPLETED') AS completed_visits,
    SUM(duration_minutes) FILTER (WHERE status = 'COMPLETED') AS total_duration_minutes,
    COUNT(*) FILTER (WHERE is_in_range = FALSE) AS out_of_range_count
FROM visit
WHERE salesman_id = :salesman_id
    AND DATE(checkin_time) = CURRENT_DATE;

-- G5. Visit plan for today
SELECT
    c.id AS customer_id,
    c.code AS customer_code,
    c.name AS customer_name,
    ca.address_line,
    ca.latitude,
    ca.longitude,
    cr.sequence_number,
    CASE WHEN v.id IS NOT NULL THEN 'VISITED' ELSE 'PENDING' END AS visit_status,
    v.checkin_time
FROM customer_route cr
JOIN customer c ON cr.customer_id = c.id
LEFT JOIN customer_address ca ON c.id = ca.customer_id AND ca.is_default = TRUE
LEFT JOIN visit v ON c.id = v.customer_id
    AND v.salesman_id = :salesman_id
    AND DATE(v.checkin_time) = CURRENT_DATE
WHERE cr.route_id = :route_id
    AND (cr.end_date IS NULL OR cr.end_date >= CURRENT_DATE)
    AND EXTRACT(DOW FROM CURRENT_DATE)::INT = ANY(cr.visit_days)
    AND c.deleted_at IS NULL
ORDER BY cr.sequence_number;

-- ============================================================
-- H. INVOICE & PAYMENT QUERIES
-- ============================================================

-- H1. Create invoice from delivery
INSERT INTO invoice (
    invoice_number, sales_order_id, delivery_id, customer_id, distributor_id,
    invoice_date, due_date, subtotal_amount, tax_amount, total_amount, status
)
SELECT
    :invoice_number,
    so.id,
    d.id,
    so.customer_id,
    so.distributor_id,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '30 days',
    so.subtotal_amount,
    so.tax_amount,
    so.total_amount,
    'ISSUED'
FROM sales_order so
JOIN delivery d ON so.id = d.sales_order_id
WHERE d.id = :delivery_id
RETURNING id;

-- H2. Record payment
INSERT INTO payment (
    payment_number, invoice_id, customer_id, collector_id,
    payment_date, amount, payment_method, reference_number, status
)
VALUES (
    :payment_number, :invoice_id, :customer_id, :collector_id,
    NOW(), :amount, :payment_method, :reference_number, 'PENDING'
)
RETURNING id;

-- H3. Confirm payment and update invoice
UPDATE payment SET status = 'CONFIRMED', confirmed_by = :user_id, confirmed_at = NOW()
WHERE id = :payment_id;

UPDATE invoice
SET
    paid_amount = paid_amount + (SELECT amount FROM payment WHERE id = :payment_id),
    status = CASE
        WHEN paid_amount + (SELECT amount FROM payment WHERE id = :payment_id) >= total_amount THEN 'PAID'
        ELSE 'PARTIAL'
    END
WHERE id = (SELECT invoice_id FROM payment WHERE id = :payment_id);

-- H4. Get overdue invoices for a customer
SELECT inv.*, c.name AS customer_name,
       CURRENT_DATE - inv.due_date AS days_overdue
FROM invoice inv
JOIN customer c ON inv.customer_id = c.id
WHERE inv.customer_id = :customer_id
    AND inv.status IN ('ISSUED', 'PARTIAL')
    AND inv.due_date < CURRENT_DATE
ORDER BY inv.due_date;

-- ============================================================
-- I. KPI QUERIES
-- ============================================================

-- I1. Update KPI actual value (revenue)
UPDATE kpi_target
SET actual_value = (
    SELECT COALESCE(SUM(so.total_amount), 0)
    FROM sales_order so
    WHERE so.salesman_id = kpi_target.target_entity_id
        AND so.order_date BETWEEN kpi_target.period_start AND kpi_target.period_end
        AND so.status NOT IN ('CANCELLED', 'REJECTED', 'DRAFT')
        AND so.deleted_at IS NULL
)
WHERE target_type = 'EMPLOYEE'
    AND metric_id = (SELECT id FROM kpi_metric WHERE code = 'REVENUE')
    AND CURRENT_DATE BETWEEN period_start AND period_end;

-- I2. Update KPI actual value (visits)
UPDATE kpi_target
SET actual_value = (
    SELECT COUNT(*)
    FROM visit v
    WHERE v.salesman_id = kpi_target.target_entity_id
        AND DATE(v.checkin_time) BETWEEN kpi_target.period_start AND kpi_target.period_end
        AND v.status = 'COMPLETED'
)
WHERE target_type = 'EMPLOYEE'
    AND metric_id = (SELECT id FROM kpi_metric WHERE code = 'VISITS')
    AND CURRENT_DATE BETWEEN period_start AND period_end;

-- I3. Get employee KPI dashboard
SELECT
    km.code AS metric_code,
    km.name AS metric_name,
    kt.target_value,
    kt.actual_value,
    kt.achievement_percent,
    kt.period_start,
    kt.period_end
FROM kpi_target kt
JOIN kpi_metric km ON kt.metric_id = km.id
WHERE kt.target_type = 'EMPLOYEE'
    AND kt.target_entity_id = :employee_id
    AND CURRENT_DATE BETWEEN kt.period_start AND kt.period_end
ORDER BY km.code;

-- ============================================================
-- J. REPORTING QUERIES
-- ============================================================

-- J1. Daily sales report by distributor
SELECT
    d.code AS distributor_code,
    d.name AS distributor_name,
    COUNT(DISTINCT so.id) AS order_count,
    COUNT(DISTINCT so.customer_id) AS customer_count,
    SUM(so.total_amount) AS total_sales,
    AVG(so.total_amount) AS avg_order_value
FROM sales_order so
JOIN distributor d ON so.distributor_id = d.id
WHERE DATE(so.order_date) = :report_date
    AND so.status NOT IN ('DRAFT', 'CANCELLED', 'REJECTED')
    AND so.deleted_at IS NULL
GROUP BY d.code, d.name
ORDER BY total_sales DESC;

-- J2. Product sales ranking (monthly)
SELECT
    p.code AS sku,
    p.name AS product_name,
    b.name AS brand,
    SUM(sol.quantity) AS total_quantity,
    SUM(sol.total_price) AS total_revenue,
    COUNT(DISTINCT so.id) AS order_count
FROM sales_order_line sol
JOIN sales_order so ON sol.sales_order_id = so.id
JOIN product p ON sol.product_id = p.id
LEFT JOIN brand b ON p.brand_id = b.id
WHERE DATE_TRUNC('month', so.order_date) = DATE_TRUNC('month', :report_month::DATE)
    AND so.status NOT IN ('DRAFT', 'CANCELLED', 'REJECTED')
    AND so.deleted_at IS NULL
GROUP BY p.code, p.name, b.name
ORDER BY total_revenue DESC
LIMIT 50;

-- J3. Salesman performance report
SELECT
    e.code AS employee_code,
    e.full_name AS employee_name,
    ou.name AS org_unit,
    COUNT(DISTINCT v.id) AS visit_count,
    COUNT(DISTINCT so.id) AS order_count,
    COUNT(DISTINCT so.customer_id) AS customer_count,
    COALESCE(SUM(so.total_amount), 0) AS total_sales,
    ROUND(
        CASE WHEN COUNT(DISTINCT v.id) > 0
        THEN COUNT(DISTINCT so.id)::DECIMAL / COUNT(DISTINCT v.id) * 100
        ELSE 0 END, 1
    ) AS conversion_rate
FROM employee e
JOIN org_unit ou ON e.org_unit_id = ou.id
LEFT JOIN visit v ON e.id = v.salesman_id
    AND DATE(v.checkin_time) BETWEEN :start_date AND :end_date
LEFT JOIN sales_order so ON e.id = so.salesman_id
    AND DATE(so.order_date) BETWEEN :start_date AND :end_date
    AND so.status NOT IN ('DRAFT', 'CANCELLED', 'REJECTED')
    AND so.deleted_at IS NULL
WHERE e.deleted_at IS NULL
    AND e.status = 'ACTIVE'
GROUP BY e.code, e.full_name, ou.name
ORDER BY total_sales DESC;

-- J4. Customer purchase analysis
SELECT
    c.code AS customer_code,
    c.name AS customer_name,
    c.channel,
    d.name AS distributor_name,
    COUNT(DISTINCT so.id) AS order_count,
    SUM(so.total_amount) AS total_purchase,
    AVG(so.total_amount) AS avg_order_value,
    MAX(so.order_date) AS last_order_date,
    CURRENT_DATE - MAX(so.order_date)::DATE AS days_since_last_order
FROM customer c
JOIN distributor d ON c.distributor_id = d.id
LEFT JOIN sales_order so ON c.id = so.customer_id
    AND so.status NOT IN ('DRAFT', 'CANCELLED', 'REJECTED')
    AND so.deleted_at IS NULL
WHERE c.deleted_at IS NULL
    AND c.distributor_id = :distributor_id
GROUP BY c.code, c.name, c.channel, d.name
ORDER BY total_purchase DESC;
