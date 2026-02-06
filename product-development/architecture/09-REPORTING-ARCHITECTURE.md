# DMS VIPPro - Reporting Architecture

## Report Specifications & KPI Calculation Logic

**Version:** 1.0
**Last Updated:** 2026-02-04
**PRD Reference:** PRD-v2.md (v2.3)

---

## 1. Overview

This document describes the reporting architecture for DMS VIPPro, including KPI calculation formulas, report specifications, and analytics design.

### Report Categories

| Category | Description | Primary Users |
| -------- | ----------- | ------------- |
| **KPI Reports** | Performance metrics and targets | ASM, RSM, GSBH |
| **Sales Reports** | Orders, revenue, products | Admin NPP, ASM |
| **Visit Reports** | Customer visits, coverage | GSBH, ASM |
| **Inventory Reports** | Stock levels, movements | Admin NPP |
| **Display Scoring** | VIP display evaluation | GSBH |

---

## 2. KPI Calculation Logic

### 2.1 Core KPI Formulas

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                          KPI CALCULATION FORMULAS                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. VISIT METRICS                                                           │
│  ───────────────                                                            │
│  Visit Count = COUNT(visits WHERE visitDate IN period)                      │
│  Visit Achievement (%) = (Actual Visits / Target Visits) × 100              │
│  Coverage Rate (%) = (Unique Customers Visited / Total Assigned) × 100      │
│  Visit Frequency = Total Visits / Unique Customers Visited                  │
│                                                                             │
│  2. ORDER METRICS                                                           │
│  ───────────────                                                            │
│  Order Count = COUNT(orders WHERE orderDate IN period AND status != Rejected)│
│  Order Achievement (%) = (Actual Orders / Target Orders) × 100              │
│  Conversion Rate (%) = (Visits with Order / Total Visits) × 100             │
│  Average Order Value (AOV) = Total Revenue / Order Count                    │
│                                                                             │
│  3. REVENUE METRICS                                                         │
│  ────────────────                                                           │
│  Gross Revenue (Doanh số) = SUM(orders.totalAmount)                         │
│  Net Revenue (Doanh thu) = Gross Revenue - Returns - Discounts              │
│  Revenue Achievement (%) = (Actual Revenue / Target Revenue) × 100          │
│  Revenue per Visit = Net Revenue / Visit Count                              │
│                                                                             │
│  4. PRODUCT METRICS                                                         │
│  ────────────────                                                           │
│  Volume = SUM(orderDetails.quantity × conversionRate)                       │
│  SKU Count = COUNT(DISTINCT products WHERE quantity > 0)                    │
│  SKU Achievement (%) = (Actual SKU / Target SKU) × 100                      │
│  Focus Product Achievement = (Actual Qty / Target Qty) × 100                │
│                                                                             │
│  5. WORKING TIME METRICS                                                    │
│  ───────────────────────                                                    │
│  Working Hours = SUM(clockOutTime - clockInTime)                            │
│  Working Days = COUNT(DISTINCT attendanceDate WHERE clockIn IS NOT NULL)    │
│  Field Time = SUM(checkOutTime - checkInTime) for all visits                │
│                                                                             │
│  6. CUSTOMER METRICS                                                        │
│  ──────────────────                                                         │
│  New Customers = COUNT(customers WHERE createdAt IN period)                 │
│  Active Customers = COUNT(customers with order IN last 30 days)             │
│  Churn Rate = (Inactive Customers / Total Customers) × 100                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 KPI Achievement Trend Calculation

```sql
-- Calculate KPI achievement trend
WITH daily_kpi AS (
    SELECT
        user_id,
        DATE(order_date) as report_date,
        COUNT(*) as daily_orders,
        SUM(total_amount) as daily_revenue
    FROM orders
    WHERE order_date >= DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY user_id, DATE(order_date)
),
running_total AS (
    SELECT
        user_id,
        report_date,
        SUM(daily_orders) OVER (PARTITION BY user_id ORDER BY report_date) as cumulative_orders,
        SUM(daily_revenue) OVER (PARTITION BY user_id ORDER BY report_date) as cumulative_revenue
    FROM daily_kpi
),
expected_pace AS (
    SELECT
        kt.user_id,
        rt.report_date,
        rt.cumulative_orders,
        rt.cumulative_revenue,
        -- Expected pace based on working days
        (kt.order_target::float / EXTRACT(DAY FROM DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day'))
            * EXTRACT(DAY FROM rt.report_date) as expected_orders,
        (kt.revenue_target::float / EXTRACT(DAY FROM DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day'))
            * EXTRACT(DAY FROM rt.report_date) as expected_revenue
    FROM running_total rt
    JOIN kpi_targets kt ON rt.user_id = kt.user_id
    WHERE kt.target_month = DATE_TRUNC('month', CURRENT_DATE)
)
SELECT
    user_id,
    report_date,
    cumulative_orders,
    cumulative_revenue,
    CASE
        WHEN cumulative_orders >= expected_orders * 1.1 THEN 'ahead'
        WHEN cumulative_orders >= expected_orders * 0.9 THEN 'on_track'
        ELSE 'behind'
    END as orders_trend,
    CASE
        WHEN cumulative_revenue >= expected_revenue * 1.1 THEN 'ahead'
        WHEN cumulative_revenue >= expected_revenue * 0.9 THEN 'on_track'
        ELSE 'behind'
    END as revenue_trend
FROM expected_pace;
```

---

## 3. Report Specifications

### 3.1 Daily Reports

#### 3.1.1 Daily Sales Summary (Báo cáo bán hàng ngày)

| Field | Description | Calculation |
| ----- | ----------- | ----------- |
| Date | Report date | Input parameter |
| Total Orders | Number of orders | COUNT(orders) |
| Total Revenue | Gross sales | SUM(totalAmount) |
| Pre-sales Orders | Orders needing approval | COUNT WHERE orderType = 'PreSales' |
| Van-sales Orders | Immediate sales | COUNT WHERE orderType = 'VanSales' |
| Pending Approval | Orders awaiting GSBH | COUNT WHERE status = 'Pending' |
| Approved | Approved orders | COUNT WHERE status = 'Approved' |
| Rejected | Rejected orders | COUNT WHERE status = 'Rejected' |

**API Endpoint:** `GET /api/reports/daily-sales?date={date}`

#### 3.1.2 Daily Visit Summary (Báo cáo viếng thăm ngày)

| Field | Description | Calculation |
| ----- | ----------- | ----------- |
| Total Visits | All visits | COUNT(visits) |
| In-Route Visits | Planned visits | COUNT WHERE visitType = 'InRoute' |
| Out-Route Visits | Unplanned visits | COUNT WHERE visitType = 'OutRoute' |
| With Order | Visits resulting in order | COUNT WHERE visitResult = 'HasOrder' |
| No Order | Visits without order | COUNT WHERE visitResult = 'NoOrder' |
| Photos Captured | Total photos | SUM(photoCount) |

**API Endpoint:** `GET /api/reports/daily-visits?date={date}`

### 3.2 Monthly Reports

#### 3.2.1 Employee KPI Report (Báo cáo KPI nhân viên)

```json
{
  "userId": "...",
  "userName": "Nguyen Van A",
  "period": "2026-02",
  "kpis": [
    {
      "metric": "visits",
      "target": 200,
      "actual": 185,
      "achievement": 92.5,
      "previousMonth": 178,
      "growth": 3.9
    },
    {
      "metric": "orders",
      "target": 150,
      "actual": 142,
      "achievement": 94.7
    },
    {
      "metric": "revenue",
      "target": 500000000,
      "actual": 485000000,
      "achievement": 97.0,
      "formattedActual": "485,000,000 đ"
    },
    {
      "metric": "newCustomers",
      "target": 10,
      "actual": 8,
      "achievement": 80.0
    }
  ],
  "productKpis": [
    {
      "productName": "Sữa tắm VIPPro 500ml",
      "quantityTarget": 100,
      "quantityActual": 95,
      "achievement": 95.0
    }
  ],
  "overallAchievement": 91.8,
  "rank": 3,
  "totalEmployees": 25
}
```

**API Endpoint:** `GET /api/reports/kpi/employee/{userId}?month={YYYY-MM}`

#### 3.2.2 Team KPI Report (Báo cáo KPI đội nhóm)

| Field | Description |
| ----- | ----------- |
| Team/Territory | Group identifier |
| Total Employees | Number of staff |
| Avg Visit Achievement | Average across team |
| Avg Order Achievement | Average across team |
| Avg Revenue Achievement | Average across team |
| Top Performer | Highest achievement |
| Bottom Performer | Lowest achievement |

**API Endpoint:** `GET /api/reports/kpi/team?month={YYYY-MM}&unitId={unitId}`

### 3.3 Customer Reports

#### 3.3.1 Customer Coverage Report (Báo cáo độ phủ khách hàng)

```sql
SELECT
    c.customer_group,
    COUNT(*) as total_customers,
    COUNT(CASE WHEN v.visit_count > 0 THEN 1 END) as visited_customers,
    ROUND(COUNT(CASE WHEN v.visit_count > 0 THEN 1 END)::numeric / COUNT(*) * 100, 1) as coverage_rate,
    COUNT(CASE WHEN o.order_count > 0 THEN 1 END) as buying_customers,
    ROUND(COUNT(CASE WHEN o.order_count > 0 THEN 1 END)::numeric / COUNT(*) * 100, 1) as buying_rate
FROM customers c
LEFT JOIN (
    SELECT customer_id, COUNT(*) as visit_count
    FROM visits
    WHERE visit_date BETWEEN :startDate AND :endDate
    GROUP BY customer_id
) v ON c.customer_id = v.customer_id
LEFT JOIN (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    WHERE order_date BETWEEN :startDate AND :endDate
      AND status != 'Rejected'
    GROUP BY customer_id
) o ON c.customer_id = o.customer_id
WHERE c.distributor_id = :distributorId
GROUP BY c.customer_group
ORDER BY c.customer_group;
```

#### 3.3.2 Customer Visit Frequency (Báo cáo tần suất viếng thăm)

| Frequency | Description | Count |
| --------- | ----------- | ----- |
| Never | 0 visits in period | X |
| Low | 1-2 visits/month | X |
| Medium | 3-4 visits/month | X |
| High | 5+ visits/month | X |

### 3.4 Product Reports

#### 3.4.1 Product Sales Report (Báo cáo bán hàng theo sản phẩm)

| Field | Description |
| ----- | ----------- |
| Product Code | SKU code |
| Product Name | Display name |
| Quantity (Main) | Units in main unit |
| Quantity (Sub) | Units in sub unit |
| Gross Revenue | Total sales |
| % of Total | Share of revenue |
| Growth vs LM | Month-over-month growth |

**API Endpoint:** `GET /api/reports/products?fromDate={date}&toDate={date}`

#### 3.4.2 Focus Product Tracking (Báo cáo sản phẩm trọng tâm)

```json
{
  "reportPeriod": "2026-02",
  "focusProducts": [
    {
      "productId": "...",
      "productName": "Sữa tắm VIPPro 500ml",
      "totalTarget": 5000,
      "totalActual": 4250,
      "achievement": 85.0,
      "byEmployee": [
        {
          "userId": "...",
          "userName": "Nguyen Van A",
          "target": 100,
          "actual": 95,
          "achievement": 95.0
        }
      ]
    }
  ]
}
```

### 3.5 Display Scoring Reports

#### 3.5.1 Display Score Summary (Báo cáo chấm điểm trưng bày)

| Field | Description | Calculation |
| ----- | ----------- | ----------- |
| Total Submissions | Photos submitted | COUNT(displayScores) |
| Pending Scoring | Not yet scored | COUNT WHERE scoredByUserId IS NULL |
| Scored | Already evaluated | COUNT WHERE scoredByUserId IS NOT NULL |
| Passed | Meeting standards | COUNT WHERE isPassed = true |
| Failed | Not meeting standards | COUNT WHERE isPassed = false |
| Pass Rate | Success percentage | Passed / Scored × 100 |
| Total Revenue | Revenue from passed | SUM(revenue WHERE isPassed = true) |

**API Endpoint:** `GET /api/reports/display-scoring?fromDate={date}&toDate={date}`

---

## 4. Dashboard Specifications

### 4.1 GSBH Dashboard

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                          GSBH DASHBOARD LAYOUT                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    TODAY'S SUMMARY ROW                               │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │
│  │  │ Active  │ │ Visits  │ │ Orders  │ │ Revenue │ │ Pending │       │   │
│  │  │ Staff   │ │ Today   │ │ Today   │ │ Today   │ │ Approval│       │   │
│  │  │   12    │ │   45    │ │   28    │ │ 85.2M   │ │   5     │       │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌───────────────────────────────┐ ┌───────────────────────────────────┐   │
│  │      LIVE MAP                 │ │     EMPLOYEE STATUS               │   │
│  │                               │ │                                   │   │
│  │  [Map with employee markers]  │ │  ┌─────────────────────────────┐ │   │
│  │  - Green: Active/Moving       │ │  │ Nguyen Van A    ● Active    │ │   │
│  │  - Yellow: At customer        │ │  │ Visit: KH001    10:30 AM    │ │   │
│  │  - Gray: Inactive             │ │  ├─────────────────────────────┤ │   │
│  │                               │ │  │ Tran Van B      ● At Store  │ │   │
│  │                               │ │  │ Check-in: KH025 10:15 AM    │ │   │
│  │                               │ │  ├─────────────────────────────┤ │   │
│  │                               │ │  │ Le Thi C        ○ Offline   │ │   │
│  │                               │ │  │ Last seen: 09:45 AM         │ │   │
│  └───────────────────────────────┘ └───────────────────────────────────┘   │
│                                                                             │
│  ┌───────────────────────────────┐ ┌───────────────────────────────────┐   │
│  │    ORDERS PENDING APPROVAL    │ │     MTD KPI PROGRESS              │   │
│  │                               │ │                                   │   │
│  │  #DH-001 | KH Minh Tam | 5.2M │ │  Visits    ████████░░  85%       │   │
│  │  #DH-002 | KH ABC      | 3.1M │ │  Orders    ███████░░░  72%       │   │
│  │  #DH-003 | KH XYZ      | 8.5M │ │  Revenue   ██████████  95%       │   │
│  │                               │ │  New Cust  █████░░░░░  45%       │   │
│  │  [View All] [Bulk Approve]    │ │                                   │   │
│  └───────────────────────────────┘ └───────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Admin NPP Dashboard

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ADMIN NPP DASHBOARD LAYOUT                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    SUMMARY CARDS                                     │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │
│  │  │ MTD     │ │ MTD     │ │ Today   │ │ Low     │ │ AR      │       │   │
│  │  │ Revenue │ │ Orders  │ │ Orders  │ │ Stock   │ │ Balance │       │   │
│  │  │ 2.5B    │ │  1,250  │ │   42    │ │   15    │ │ 850M    │       │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                    REVENUE TREND (Last 30 Days)                       │ │
│  │                                                                       │ │
│  │  100M ┤                                            ╭─╮                │ │
│  │   80M ┤                              ╭─╮    ╭─╮   │ │   ╭─╮          │ │
│  │   60M ┤         ╭─╮    ╭─╮    ╭─╮   │ │   │ │   │ │   │ │          │ │
│  │   40M ┤  ╭─╮   │ │   │ │   │ │   │ │   │ │   │ │   │ │          │ │
│  │   20M ┤ │ │   │ │   │ │   │ │   │ │   │ │   │ │   │ │          │ │
│  │    0M ┼─┴─┴───┴─┴───┴─┴───┴─┴───┴─┴───┴─┴───┴─┴───┴─┴──────────│ │
│  │       Jan 5   10     15     20     25     30    Feb 4            │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─────────────────────────────────┐ ┌─────────────────────────────────┐   │
│  │      TOP PRODUCTS              │ │      LOW STOCK ALERTS           │   │
│  │                                │ │                                 │   │
│  │  1. Sữa tắm 500ml    120M  25% │ │  ⚠ SP001 - 15 units remaining  │   │
│  │  2. Dầu gội 400ml     85M  18% │ │  ⚠ SP045 - 8 units remaining   │   │
│  │  3. Kem dưỡng 200ml   62M  13% │ │  ⚠ SP089 - 22 units remaining  │   │
│  │  4. Others           213M  44% │ │                                 │   │
│  └─────────────────────────────────┘ └─────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Excel Export Schema

### 5.1 Standard Export Format

```text
Export Filename: {ReportType}_{FromDate}_{ToDate}_{GeneratedAt}.xlsx

Sheet 1: Data
- Row 1: Report Title
- Row 2: Generated timestamp, User, Period
- Row 3: Empty
- Row 4: Column headers
- Row 5+: Data rows

Sheet 2: Summary (if applicable)
- Totals and aggregations
- Charts data
```

### 5.2 Oracle ERP Integration Export

```json
{
  "exportFormat": "Oracle_ERP_v1",
  "structure": {
    "header": {
      "sourceSystem": "VIPPro_DMS",
      "exportDate": "2026-02-04",
      "period": "2026-02",
      "distributorCode": "NPP-SGN-001"
    },
    "salesData": [
      {
        "documentType": "SALES_ORDER",
        "documentNumber": "DH-20260204-001",
        "customerCode": "KH001",
        "orderDate": "2026-02-04",
        "lines": [
          {
            "lineNumber": 1,
            "itemCode": "SP001",
            "quantity": 5,
            "unitPrice": 1200000,
            "amount": 6000000,
            "taxCode": "VAT10",
            "taxAmount": 600000
          }
        ],
        "totalAmount": 6600000
      }
    ],
    "inventoryMovements": [
      {
        "movementType": "SALES_ISSUE",
        "movementDate": "2026-02-04",
        "warehouseCode": "WH-MAIN-001",
        "itemCode": "SP001",
        "quantity": -5,
        "referenceDocument": "DH-20260204-001"
      }
    ]
  }
}
```

---

## 6. Related Documents

- [04-DATA-ARCHITECTURE.md](04-DATA-ARCHITECTURE.md) - Database schema
- [05-API-DESIGN.md](05-API-DESIGN.md) - API specifications
- [adr/ADR-008-kpi-calculation.md](adr/ADR-008-kpi-calculation.md) - KPI calculation decision
