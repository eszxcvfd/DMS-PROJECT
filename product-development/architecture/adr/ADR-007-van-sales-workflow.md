# ADR-007: Van-sales vs Pre-sales Order Workflow Design

## Status

**Accepted**

## Date

2026-02-04

## Context

DILIGO DMS supports two distinct sales models:

1. **Pre-sales (Bán hàng thường)**: Traditional model where sales representatives take orders that are later approved and fulfilled by the distributor warehouse.

2. **Van-sales (Bán hàng theo xe)**: Sales representatives carry inventory in their vehicle, sell directly to customers, and deliver on the spot.

We need to decide how to handle these two fundamentally different workflows within the same system.

### Key Differences

| Aspect | Pre-sales | Van-sales |
|--------|-----------|-----------|
| **Inventory Source** | Main warehouse | Van warehouse (mobile) |
| **Order Approval** | Required (GSBH approves) | Not required (immediate) |
| **Delivery** | Separate step | Same time as order |
| **Payment** | Credit / COD at delivery | Cash on spot / Credit |
| **Stock Update** | After delivery | Immediately on order |
| **Invoice** | After approval | Immediately generated |

## Decision

We will implement a **unified order model with order type differentiation** rather than separate order systems.

### Order Model Design

```
Order
├── OrderType: enum { PreSales, VanSales }
├── VanSaleWarehouseId: UUID? (required for VanSales)
├── Status: varies by OrderType
│   ├── PreSales: Draft → Pending → Approved/Rejected → Delivered
│   └── VanSales: Created → Delivered (immediate)
├── PaymentInfo (enhanced for VanSales)
│   ├── PaymentMethod: Cash/Credit/Transfer
│   ├── AmountPaid: decimal
│   └── RemainingBalance: decimal
```

### Workflow Implementation

#### Pre-sales Flow
```
1. NVBH creates order → Status: "Pending"
2. Order syncs to server
3. GSBH receives notification
4. GSBH reviews and approves/rejects
5. If approved:
   - Sales invoice created
   - Stock reserved in main warehouse
   - Delivery scheduled
6. After delivery:
   - Stock deducted
   - Receivable updated
```

#### Van-sales Flow
```
1. NVBH creates Van-sale order with:
   - vanSaleWarehouseId (their assigned van)
   - paymentMethod
   - amountPaid
2. System validates stock availability in van warehouse
3. If stock available:
   - Order created with Status: "Delivered"
   - Stock immediately deducted from van
   - Invoice generated
   - Payment recorded
   - Receivable updated if partial payment
4. If stock insufficient:
   - Error returned, order not created
```

### Stock Management

```sql
-- Van-sale warehouses are linked to specific users
CREATE TABLE Warehouses (
    WarehouseId UUID PRIMARY KEY,
    WarehouseType VARCHAR(20), -- 'Main', 'VanSale'
    AssignedUserId UUID,       -- For VanSale type
    ...
);

-- Stock transfer from Main to Van
CREATE TABLE StockTransfers (
    TransferId UUID PRIMARY KEY,
    SourceWarehouseId UUID,
    DestinationWarehouseId UUID,
    TransferType VARCHAR(20), -- 'MainToVan', 'VanToMain'
    ...
);
```

### API Design

```http
POST /api/orders
{
    "orderType": "VanSales",
    "vanSaleWarehouseId": "...",
    "paymentMethod": "Cash",
    "amountPaid": 5000000,
    ...
}
```

Response includes stock validation:
```json
{
    "orderId": "...",
    "orderType": "VanSales",
    "status": "Delivered",
    "stockDeducted": true,
    "paymentInfo": {
        "method": "Cash",
        "totalAmount": 6000000,
        "amountPaid": 5000000,
        "remainingBalance": 1000000
    }
}
```

### Mobile App Changes

```kotlin
// OrderType enum
enum class OrderType {
    PreSales,
    VanSales
}

// CreateOrderUseCase handles both types
class CreateOrderUseCase {
    suspend fun execute(
        orderType: OrderType,
        vanWarehouseId: UUID? = null,
        paymentInfo: PaymentInfo? = null,
        ...
    ): Result<Order> {
        return when (orderType) {
            OrderType.PreSales -> createPreSalesOrder(...)
            OrderType.VanSales -> createVanSalesOrder(...)
        }
    }

    private suspend fun createVanSalesOrder(...): Result<Order> {
        // 1. Validate local stock
        val stock = stockRepository.getVanStock(vanWarehouseId)
        if (!validateStockAvailability(items, stock)) {
            return Result.failure(InsufficientStockException())
        }

        // 2. Deduct stock locally (optimistic)
        stockRepository.deductStock(vanWarehouseId, items)

        // 3. Create order with Delivered status
        val order = Order(
            orderType = OrderType.VanSales,
            status = OrderStatus.Delivered,
            vanSaleWarehouseId = vanWarehouseId,
            ...
        )

        // 4. Queue for sync
        return orderRepository.create(order)
    }
}
```

## Consequences

### Positive

1. **Unified codebase**: Single order model reduces complexity
2. **Consistent reporting**: Both order types in same tables
3. **Flexible**: Easy to add new order types in future
4. **Mobile offline support**: Van-sale can work offline with local stock validation
5. **Clear audit trail**: All transactions tracked uniformly

### Negative

1. **Validation complexity**: Order validation varies by type
2. **Stock sync risk**: Van stock may drift if offline too long
3. **Mobile storage**: Need to cache van warehouse stock locally

### Mitigations

1. **Type-specific validators**: Use strategy pattern for order validation
2. **Stock reconciliation**: Daily reconciliation process for van warehouses
3. **Background sync**: Prioritize stock sync when connectivity restored

## Related Decisions

- [ADR-006: Offline-first Mobile](ADR-006-offline-first-mobile.md) - Offline architecture affects Van-sales
- [ADR-003: PostgreSQL](ADR-003-postgresql.md) - Database design considerations

## References

- PRD-v2.md Section 4.2: Order Types
- PRD-v2.md Section 5.4: Van-sales Workflow
