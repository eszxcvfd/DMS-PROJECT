# ADR-004: Frontend Framework Selection

## Status
**Accepted** - 2026-02-02

## Context

We need to select a frontend framework for the web application used by:
- Supervisors (GSBH) for monitoring
- Area/Regional Managers (ASM/RSM) for dashboards
- Distributor Admins for operations management

Key requirements:
- Enterprise-grade framework with long-term support
- Strong TypeScript support
- Component-based architecture
- State management for complex data flows
- Real-time updates (SignalR integration)
- Mapping capabilities for location tracking
- Data tables and charts for reporting

## Decision

We will use **Angular 17** as our frontend framework.

### Specific Technologies:
- **Angular 17** - Core framework
- **NgRx 17** - State management
- **Angular Material 17** - UI component library
- **RxJS** - Reactive programming
- **Leaflet/OpenLayers** - Mapping
- **Chart.js / ngx-charts** - Data visualization
- **Angular CDK** - Utilities and accessibility

## Consequences

### Positive
- **Enterprise standard**: Angular is widely used in enterprise applications
- **TypeScript first**: Built with TypeScript from the ground up
- **Full framework**: Batteries included (routing, HTTP, forms, testing)
- **Consistent architecture**: Opinionated structure promotes maintainability
- **Long-term support**: Google backing with predictable release cycles
- **Strong tooling**: Angular CLI, DevTools, excellent IDE support
- **NgRx ecosystem**: Proven state management solution for complex apps
- **RxJS integration**: Native reactive programming for SignalR/real-time

### Negative
- **Learning curve**: Steeper than React/Vue for newcomers
- **Verbosity**: More boilerplate than alternatives
- **Bundle size**: Larger initial bundle (mitigated by lazy loading)
- **Change detection**: Requires understanding for optimization

### Risks
- **Developer availability**: Fewer Angular developers than React
- **Mitigation**: Provide training, well-documented codebase

## Alternatives Considered

### React
- **Pros**:
  - Largest ecosystem
  - Flexible architecture
  - More developers available
- **Cons**:
  - Not a full framework (need many decisions)
  - Less opinionated (can lead to inconsistency)
  - State management fragmented (Redux, Zustand, Jotai, etc.)
- **Decision**: Rejected due to architecture inconsistency risks

### Vue.js 3
- **Pros**:
  - Easy learning curve
  - Good TypeScript support
  - Growing enterprise adoption
- **Cons**:
  - Smaller ecosystem than React/Angular
  - Less enterprise tooling
  - Composition API still maturing
- **Decision**: Rejected for enterprise feature set

### Blazor (WebAssembly)
- **Pros**:
  - C# across full stack
  - Share code with backend
  - Strong typing
- **Cons**:
  - Large bundle size (~2-5 MB)
  - Slower initial load
  - Less mature ecosystem
  - SEO challenges (for admin app, less critical)
- **Decision**: Considered for future internal tools

### Next.js (React)
- **Pros**:
  - Full-stack capabilities
  - Excellent performance
  - SSR/SSG support
- **Cons**:
  - Overkill for admin SPA
  - SSR not needed for authenticated admin app
  - React ecosystem fragmentation
- **Decision**: Rejected as SPA sufficient for admin app

## Implementation Notes

### Project Structure
```
src/
├── app/
│   ├── core/                    # Singleton services
│   │   ├── auth/               # Authentication
│   │   ├── http/               # HTTP interceptors
│   │   └── guards/             # Route guards
│   ├── shared/                  # Shared module
│   │   ├── components/         # Reusable UI
│   │   ├── directives/         # Custom directives
│   │   ├── pipes/              # Custom pipes
│   │   └── models/             # Shared interfaces
│   ├── features/                # Feature modules
│   │   ├── dashboard/
│   │   ├── monitoring/
│   │   ├── orders/
│   │   ├── inventory/
│   │   ├── customers/
│   │   ├── products/
│   │   ├── reports/
│   │   └── admin/
│   ├── store/                   # NgRx store
│   │   ├── actions/
│   │   ├── effects/
│   │   ├── reducers/
│   │   └── selectors/
│   └── app.routes.ts
├── assets/
├── environments/
└── styles/
```

### Key Dependencies
```json
{
  "dependencies": {
    "@angular/core": "^17.0.0",
    "@angular/material": "^17.0.0",
    "@ngrx/store": "^17.0.0",
    "@ngrx/effects": "^17.0.0",
    "@microsoft/signalr": "^8.0.0",
    "leaflet": "^1.9.4",
    "chart.js": "^4.4.0",
    "ng2-charts": "^5.0.0"
  }
}
```

### State Management Pattern
```typescript
// Feature state
export interface OrdersState {
  orders: Order[];
  selectedOrder: Order | null;
  loading: boolean;
  error: string | null;
  filters: OrderFilters;
  pagination: Pagination;
}

// Actions
export const loadOrders = createAction(
  '[Orders] Load Orders',
  props<{ filters: OrderFilters }>()
);

// Reducer
export const ordersReducer = createReducer(
  initialState,
  on(loadOrders, state => ({ ...state, loading: true })),
  on(loadOrdersSuccess, (state, { orders }) => ({
    ...state,
    orders,
    loading: false
  }))
);

// Effects
loadOrders$ = createEffect(() =>
  this.actions$.pipe(
    ofType(loadOrders),
    switchMap(({ filters }) =>
      this.orderService.getOrders(filters).pipe(
        map(orders => loadOrdersSuccess({ orders })),
        catchError(error => of(loadOrdersFailure({ error })))
      )
    )
  )
);
```

### SignalR Integration
```typescript
@Injectable({ providedIn: 'root' })
export class SignalRService {
  private hubConnection: signalR.HubConnection;

  constructor(private store: Store) {
    this.hubConnection = new signalR.HubConnectionBuilder()
      .withUrl('/hubs/dms')
      .withAutomaticReconnect()
      .build();

    this.registerHandlers();
  }

  private registerHandlers(): void {
    this.hubConnection.on('LocationUpdated', (location: LocationDto) => {
      this.store.dispatch(locationUpdated({ location }));
    });

    this.hubConnection.on('OrderCreated', (order: OrderDto) => {
      this.store.dispatch(orderReceived({ order }));
    });
  }

  async start(): Promise<void> {
    await this.hubConnection.start();
  }
}
```

### Lazy Loading Configuration
```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: 'dashboard',
    loadChildren: () => import('./features/dashboard/dashboard.routes')
  },
  {
    path: 'monitoring',
    loadChildren: () => import('./features/monitoring/monitoring.routes')
  },
  {
    path: 'orders',
    loadChildren: () => import('./features/orders/orders.routes')
  },
  // ... other routes
];
```

## Performance Optimization

| Technique | Implementation |
|-----------|----------------|
| Lazy Loading | Feature modules loaded on demand |
| OnPush Change Detection | For pure components |
| TrackBy | For ngFor lists |
| Virtual Scrolling | For large data tables |
| Image Optimization | WebP with fallback |
| Bundle Analysis | Regular bundle size audits |

## References

- [Angular Documentation](https://angular.io/docs)
- [NgRx Documentation](https://ngrx.io/docs)
- [Angular Material](https://material.angular.io/)
- [Angular Style Guide](https://angular.io/guide/styleguide)
