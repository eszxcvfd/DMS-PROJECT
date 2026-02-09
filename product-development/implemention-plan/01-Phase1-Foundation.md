# Phase 1: Foundation - Implementation Plan

**Project:** DMS VIPPro (Distribution Management System)
**Phase:** 1 - Foundation
**PRD Version:** v2.3
**Architecture Version:** v2.0
**Status:** Planning
**Target Completion:** TBD

---

## 1. Phase Overview

Phase 1 establishes the foundation infrastructure and core data management capabilities for DMS VIPPro. This phase focuses on setting up the technical backbone, implementing master data management, user authentication, and basic mobile functionality.

### 1.1 Objectives

- Set up development, testing, and production infrastructure
- Implement user management and authentication system
- Build master data management (Customers, Products, Distributors)
- Develop basic Android mobile app with offline support
- Establish core API endpoints

### 1.2 Success Criteria

- [ ] All CI/CD pipelines operational
- [ ] Users can authenticate via mobile and web
- [ ] Master data (Customers, Products) CRUD operations working
- [ ] Mobile app can sync data offline
- [ ] Basic reporting available for master data
- [ ] System deployed to free-tier environment

---

## 2. Technical Architecture Reference

### 2.1 Technology Stack

| Layer | Technology | Purpose |
|--------|------------|---------|
| **Backend** | .NET 8 (ASP.NET Core) | REST API, business logic |
| **Database** | PostgreSQL 16+ (Neon Free) | Data persistence |
| **Mobile** | Kotlin + Jetpack Compose | Android app |
| **Web** | React + TypeScript | Admin dashboard |
| **Authentication** | JWT + BCrypt | Secure authentication |
| **ORM** | Entity Framework Core | Database access |
| **Deployment** | Azure App Service (F1 Free) + Vercel | Hosting |

### 2.2 Database Groups Involved

- **Group A (Organization)**: Users, roles, permissions
- **B (Territory)**: Regions, routes
- **C (Distributors)**: Distributor profiles
- **D (Customers)**: Customer master data
- **E (Products)**: Product catalog

---

## 3. Detailed Implementation Tasks

### 3.1 Infrastructure Setup (Week 1)

#### Task 1.1: Development Environment
**Description:** Set up local development environment for all team members

**Subtasks:**
- ~~ Install .NET 8 SDK~~
- ~~ Install PostgreSQL 16 locally~~
- ~~ Set up Docker for containerized development~~
- ~~ Install Android Studio (API 34+)~~
- ~~ Install Node.js 18+ for React web~~
- ~~ Configure git repository with proper branching strategy~~
- ~~ Set up code quality tools (SonarQube, ESLint, ktlint)~~

**Deliverables:**
- Local dev environment guide (README-dev.md)
- Docker Compose configuration for local stack

**Dependencies:** None
**Estimated Time:** 3 days

---

#### Task 1.2: CI/CD Pipeline Setup
**Description:** Build automated deployment pipelines

**Subtasks:**
- [ ] Set up GitHub Actions for backend (Giang)
- [ ] Set up GitHub Actions for Android (Trung)
- [ ] Set up GitHub Actions for React web (Trung)
- [ ] Configure automated testing on PR (not need now)
- [ ] Set up code coverage reporting (not need now)
- [ ] Configure environment variables (dev, staging, prod) (Giang)

**Deliverables:**
- Working CI/CD pipelines
- Automated deployment to staging on merge to develop

**Dependencies:** Task 1.1
**Estimated Time:** 3 days

---

#### Task 1.3: Cloud Infrastructure
**Description:** Set up free-tier cloud services

**Subtasks:**
- [x] Create Azure App Service (F1 Free) for API (Trung)
- [x] Create Neon PostgreSQL free instance (Trung)
- [ ] Create Vercel account for web deployment (Giang)
- [ ] Configure Azure Blob Storage (5GB free) for images (Trung)
- [ ] Set up Firebase project for FCM (Giang)
- [ ] Get Google Maps API key (Trung)
- [ ] Configure DNS (if custom domain) (Giang)

**Deliverables:**
- Production infrastructure document (infrastructure.md)
- All credentials stored securely (Azure Key Vault / .env)

**Dependencies:** Task 1.2
**Estimated Time:** 2 days

---

### 3.2 Database & ORM Setup (Week 1-2)

#### Task 1.4: Database Schema Implementation
**Description:** Implement initial database schema from Data Architecture v3.1

**Subtasks:**
- [ ] Create EF Core migration for Group A (Organization)
  - `org_unit`, `employee`, `user_account`, `role`, `permission`, `user_role`
- [ ] Create EF Core migration for Group B (Territory)
  - `region`, `route`, `route_assignment`
- [ ] Create EF Core migration for Group C (Distributors)
  - `distributor`, `distributor_bank_account`
- [ ] Create EF Core migration for Group D (Customers)
  - `customer_group`, `customer`, `customer_address`, `customer_route`
- [ ] Create EF Core migration for Group E (Products)
  - `brand`, `product`, `uom`, `product_uom_conversion`
- [ ] Configure soft delete global filters
- [ ] Set up audit triggers for `system_audit_log`

**Deliverables:**
- EF Core migrations (5 migration files)
- `AppDbContext` with all DbSets
- Seed data for roles and permissions

**Dependencies:** Task 1.3
**Estimated Time:** 5 days

---

#### Task 1.5: Indexing & Performance
**Description:** Implement database indexes for performance

**Subtasks:**
- [ ] Create GIN indexes for text search (product name, customer name)
- [ ] Create GIST indexes for geospatial queries (latitude, longitude)
- [ ] Create partial indexes (`WHERE deleted_at IS NULL`)
- [ ] Create composite indexes for common query patterns
- [ ] Set up table partitioning plan (document for future)

**Deliverables:**
- SQL script with all indexes
- Performance benchmark results

**Dependencies:** Task 1.4
**Estimated Time:** 2 days

---

### 3.3 Authentication & Authorization (Week 2)

#### Task 1.6: Authentication API
**Description:** Implement JWT-based authentication

**Subtasks:**
- [ ] Create `AuthService` (login, refresh, logout)
- [ ] Implement password hashing with BCrypt
- [ ] Create JWT token generation and validation
- [ ] Implement `AuthController` with endpoints:
  - `POST /api/auth/login`
  - `POST /api/auth/refresh`
  - `POST /api/auth/logout`
- [ ] Set up JWT middleware configuration
- [ ] Add token refresh logic
- [ ] Implement role-based authorization policy

**Deliverables:**
- Working authentication API
- Swagger documentation for auth endpoints
- Unit tests for auth logic

**Dependencies:** Task 1.4
**Estimated Time:** 4 days

---

#### Task 1.7: Authorization Middleware
**Description:** Implement RBAC (Role-Based Access Control)

**Subtasks:**
- [ ] Create `Permission` enum and policy definitions
- [ ] Implement `[Authorize(Policy = "...")]` attribute extension
- [ ] Create authorization middleware for API routes
- [ ] Implement role hierarchy (RSM > ASM > GSBH > NVBH)
- [ ] Add permission checks in controllers

**Deliverables:**
- Authorization policy configuration
- Permission matrix documentation

**Dependencies:** Task 1.6
**Estimated Time:** 2 days

---

### 3.4 Master Data Management API (Week 3)

#### Task 1.8: Customer Management API
**Description:** CRUD operations for customers

**Subtasks:**
- [ ] Create `CustomerService` (CRUD, search, route filtering)
- [ ] Implement `CustomersController`:
  - `GET /api/customers` (list with pagination, filters)
  - `GET /api/customers/{id}`
  - `POST /api/customers` (create)
  - `PUT /api/customers/{id}` (update)
  - `DELETE /api/customers/{id}` (soft delete)
- [ ] Add GPS validation helpers
- [ ] Implement customer search with full-text
- [ ] Add validation for duplicate codes per distributor

**Deliverables:**
- Customer API endpoints (5)
- API documentation (Swagger)
- Integration tests

**Dependencies:** Task 1.7
**Estimated Time:** 4 days

---

#### Task 1.9: Product Management API
**Description:** CRUD operations for products

**Subtasks:**
- [ ] Create `ProductService` (CRUD, pricing, UOM conversion)
- [ ] Implement `ProductsController`:
  - `GET /api/products` (list with filters: brand, category, status)
  - `GET /api/products/{id}`
  - `POST /api/products` (create)
  - `PUT /api/products/{id}` (update)
  - `DELETE /api/products/{id}` (soft delete)
- [ ] Add UOM conversion logic
- [ ] Implement product search with full-text
- [ ] Add stock level query endpoint

**Deliverables:**
- Product API endpoints (5)
- API documentation
- Unit tests for pricing calculations

**Dependencies:** Task 1.8
**Estimated Time:** 4 days

---

#### Task 1.10: Distributor Management API
**Description:** CRUD operations for distributors

**Subtasks:**
- [ ] Create `DistributorService` (CRUD, bank accounts)
- [ ] Implement `DistributorsController`:
  - `GET /api/distributors` (list with pagination)
  - `GET /api/distributors/{id}`
  - `POST /api/distributors` (create)
  - `PUT /api/distributors/{id}` (update)
  - `DELETE /api/distributors/{id}` (soft delete)
- [ ] Add bank account management endpoints
- [ ] Implement distributor search

**Deliverables:**
- Distributor API endpoints (5+)
- API documentation
- Integration tests

**Dependencies:** Task 1.9
**Estimated Time:** 3 days

---

#### Task 1.11: Route Management API
**Description:** CRUD operations for routes

**Subtasks:**
- [ ] Create `RouteService` (CRUD, assignment, customer mapping)
- [ ] Implement `RoutesController`:
  - `GET /api/routes` (list with filters)
  - `GET /api/routes/today` (today's route for logged-in user)
  - `GET /api/routes/{id}`
  - `POST /api/routes` (create)
  - `PUT /api/routes/{id}` (update)
  - `POST /api/routes/{id}/customers` (add customers)
  - `PATCH /api/routes/{id}/customers` (reorder)
  - `DELETE /api/routes/{id}/customers/{customerId}` (remove)
- [ ] Add route assignment logic
- [ ] Implement temporal queries (current routes for date)

**Deliverables:**
- Route API endpoints (8)
- API documentation
- Unit tests for route assignment logic

**Dependencies:** Task 1.10
**Estimated Time:** 4 days

---

### 3.5 Basic Mobile App (Week 4-6)

#### Task 1.12: Android Project Setup
**Description:** Initialize Android project with architecture

**Subtasks:**
- [ ] Create Kotlin project (Jetpack Compose)
- [ ] Set up project structure (MVVM + Clean Architecture)
  - Presentation (UI, ViewModels)
  - Domain (Use cases, entities)
  - Data (Repositories, DAOs, API)
- [ ] Configure Hilt (Dependency Injection)
- [ ] Set up Room database for offline storage
- [ ] Add Retrofit for API calls
- [ ] Configure WorkManager for background sync
- [ ] Add Kotlin Coroutines and Flow

**Deliverables:**
- Android project structure
- Base classes (ViewModel, Repository)
- DI configuration

**Dependencies:** Task 1.11
**Estimated Time:** 3 days

---

#### Task 1.13: Offline Data Storage
**Description:** Implement Room database for offline data

**Subtasks:**
- [ ] Create Room entities (User, Customer, Product, Route)
- [ ] Create DAOs (Data Access Objects):
  - `@Dao CustomerDao` (CRUD queries)
  - `@Dao ProductDao` (search queries)
  - `@Dao RouteDao` (today's route)
  - `@Dao UserDao` (auth tokens)
- [ ] Create `AppDatabase` (Room database instance)
- [ ] Implement TypeConverters (Date, UUID, Enums)
- [ ] Set up database migrations

**Deliverables:**
- Room database schema
- DAO interfaces
- Migration scripts

**Dependencies:** Task 1.12
**Estimated Time:** 4 days

---

#### Task 1.14: Authentication Screens
**Description:** Implement login and authentication flow

**Subtasks:**
- [ ] Create `LoginScreen` UI (username, password fields)
- [ ] Create `LoginViewModel`:
  - `login()` - call auth API
  - Save JWT tokens to secure storage (EncryptedSharedPreferences)
  - Handle token refresh
- [ ] Create `LoginUseCase`
- [ ] Implement `AuthRepository` (local token storage + API calls)
- [ ] Add splash screen for session check
- [ ] Implement auto-login on app start

**Deliverables:**
- Login screen UI
- Authentication flow working
- Token refresh logic

**Dependencies:** Task 1.13
**Estimated Time:** 4 days

---

#### Task 1.15: Customer List & Detail Screens
**Description:** Display customers from route

**Subtasks:**
- [ ] Create `CustomerListScreen` (recycler view with search)
- [ ] Create `CustomerDetailScreen` (customer info, visit history)
- [ ] Create `CustomerViewModel`:
  - `loadCustomers()` - from local DB
  - `searchCustomers()` - filter by name/code
- [ ] Implement `CustomerRepository` (local + sync)
- [ ] Add GPS permission handling
- [ ] Show customer location on map (optional MVP)

**Deliverables:**
- Customer list screen
- Customer detail screen
- Customer data syncing

**Dependencies:** Task 1.14
**Estimated Time:** 4 days

---

#### Task 1.16: Product Catalog Screen
**Description:** Display product catalog

**Subtasks:**
- [ ] Create `ProductListScreen` (with filters: brand, category)
- [ ] Create `ProductDetailScreen` (price, stock, image)
- [ ] Create `ProductViewModel`:
  - `loadProducts()` - from local DB
  - `searchProducts()` - filter by name/code
- [ ] Implement `ProductRepository` (local + sync)
- [ ] Add image loading (Coil library)

**Deliverables:**
- Product list screen
- Product detail screen
- Product images cached locally

**Dependencies:** Task 1.15
**Estimated Time:** 3 days

---

#### Task 1.17: Data Synchronization
**Description:** Implement delta sync between mobile and server

**Subtasks:**
- [ ] Create `SyncWorker` (WorkManager job):
  - Runs every 15 minutes
  - Calls `/api/sync/delta?since={lastSync}`
  - Updates local Room database
- [ ] Implement `SyncRepository`:
  - Track `lastSyncTimestamp`
  - Handle conflict resolution (ServerWins)
  - Queue pending uploads (visits, orders)
- [ ] Add sync status indicator in UI
- [ ] Implement manual sync trigger (pull-to-refresh)
- [ ] Handle network connectivity changes

**Deliverables:**
- Background sync working
- Delta sync API endpoint implemented
- Offline data updated automatically

**Dependencies:** Task 1.16
**Estimated Time:** 5 days

---

### 3.6 Basic Web Dashboard (Week 6-7)

#### Task 1.18: React Web App Setup
**Description:** Initialize React project with architecture

**Subtasks:**
- [ ] Create React + TypeScript project (Vite)
- [ ] Set up project structure (feature-based)
- [ ] Configure Tailwind CSS for styling
- [ ] Add React Router for navigation
- [ ] Set up Axios for API calls
- [ ] Configure Zustand for state management
- [ ] Add React Query for data fetching

**Deliverables:**
- React project structure
- Base layout (Header, Sidebar)
- Authentication context

**Dependencies:** Task 1.17
**Estimated Time:** 2 days

---

#### Task 1.19: Authentication & Layout
**Description:** Implement web authentication

**Subtasks:**
- [ ] Create `LoginPage` (login form)
- [ ] Create `AuthContext` (manage JWT token)
- [ ] Implement `useAuth` hook
- [ ] Add protected route wrapper
- [ ] Create `DashboardLayout` (sidebar, header, content)
- [ ] Implement logout functionality

**Deliverables:**
- Login page
- Protected routes
- Dashboard layout

**Dependencies:** Task 1.18
**Estimated Time:** 3 days

---

#### Task 1.20: Master Data Management Pages
**Description:** CRUD pages for Customers, Products, Distributors

**Subtasks:**
- [ ] Create `CustomersPage`:
  - Data table with pagination
  - Search and filters
  - Create/Edit modal
  - Delete confirmation
- [ ] Create `ProductsPage`:
  - Data table with pagination
  - Filters (brand, category)
  - Create/Edit modal
- [ ] Create `DistributorsPage`:
  - Data table
  - Bank accounts management
- [ ] Implement `useCustomers`, `useProducts`, `useDistributors` hooks (React Query)

**Deliverables:**
- 3 CRUD pages functional
- Forms with validation
- API integration complete

**Dependencies:** Task 1.19
**Estimated Time:** 5 days

---

#### Task 1.21: Basic Reporting
**Description:** Simple reports for master data

**Subtasks:**
- [ ] Create `ReportsPage`:
  - Customer count by region
  - Product count by brand
  - Distributor count by status
- [ ] Add charts (Recharts library)
- [ ] Implement export to Excel functionality
- [ ] Add date range filters

**Deliverables:**
- Reports page with 3 basic reports
- Export functionality

**Dependencies:** Task 1.20
**Estimated Time:** 3 days

---

### 3.7 Testing & Quality Assurance (Week 8)

#### Task 1.22: Backend Testing
**Description:** Comprehensive testing of API endpoints

**Subtasks:**
- [ ] Unit tests for Services (80% coverage target)
  - `AuthService`, `CustomerService`, `ProductService`, etc.
- [ ] Integration tests for Controllers
  - Test full request/response cycle
- [ ] Load testing for critical endpoints (Auth, Sync)
- [ ] Security testing
  - SQL injection prevention
  - XSS protection
  - Authorization bypass checks

**Deliverables:**
- Unit test suite (200+ tests)
- Integration test suite (50+ tests)
- Load test results

**Dependencies:** Task 1.21
**Estimated Time:** 3 days

---

#### Task 1.23: Mobile Testing
**Description:** Test Android app on various devices

**Subtasks:**
- [ ] Unit tests for ViewModels and Use Cases
- [ ] UI tests with Espresso for critical flows
- [ ] Test on multiple Android versions (10-14)
- [ ] Test on different screen sizes (phone, tablet)
- [ ] Test offline functionality thoroughly
- [ ] Test sync scenarios (conflict resolution)
- [ ] Performance testing (app startup, list scrolling)

**Deliverables:**
- Unit tests for core logic
- Espresso tests for login, customer list, product list
- Device compatibility report

**Dependencies:** Task 1.22
**Estimated Time:** 3 days

---

#### Task 1.24: Web Testing
**Description:** Test React web application

**Subtasks:**
- [ ] Component unit tests (React Testing Library)
- [ ] E2E tests with Playwright for critical flows
  - Login
  - Customer CRUD
  - Product CRUD
- [ ] Cross-browser testing (Chrome, Firefox, Safari)
- [ ] Responsive design testing (mobile, tablet, desktop)
- [ ] Accessibility testing (WCAG 2.1 AA)

**Deliverables:**
- Component tests (50+)
- E2E tests (10 scenarios)
- Cross-browser compatibility report

**Dependencies:** Task 1.23
**Estimated Time:** 2 days

---

### 3.8 Documentation & Deployment (Week 8-9)

#### Task 1.25: API Documentation
**Description:** Complete API documentation

**Subtasks:**
- [ ] Update Swagger/OpenAPI documentation
- [ ] Add example requests/responses
- [ ] Document error responses
- [ ] Add authentication instructions
- [ ] Publish Swagger UI
- [ ] Create Postman collection

**Deliverables:**
- Complete Swagger documentation
- Postman collection for all endpoints

**Dependencies:** Task 1.24
**Estimated Time:** 2 days

---

#### Task 1.26: User Documentation
**Description:** Create user guides

**Subtasks:**
- [ ] Mobile app user guide (NVBH)
  - Installation
  - Login
  - Sync data
  - View customers
  - View products
- [ ] Web app user guide (Admin NPP)
  - Login
  - Manage customers
  - Manage products
  - View reports
- [ ] Admin guide (system administration)
  - Deployment
  - Configuration
  - Troubleshooting

**Deliverables:**
- 3 user guides (PDF format)
- Video tutorials (optional)

**Dependencies:** Task 1.25
**Estimated Time:** 3 days

---

#### Task 1.27: Production Deployment
**Description:** Deploy to production environment

**Subtasks:**
- [ ] Deploy backend API to Azure App Service (F1 Free)
- [ ] Run database migrations on production (Neon)
- [ ] Deploy React web app to Vercel
- [ ] Build Android APK and publish (internal testing)
- [ ] Configure monitoring (Application Insights)
- [ ] Set up error tracking (Sentry)
- [ ] Verify all endpoints are accessible
- [ ] Test authentication flow end-to-end

**Deliverables:**
- Production environment live
- Monitoring dashboards configured
- APK distributed to test users

**Dependencies:** Task 1.26
**Estimated Time:** 2 days

---

## 4. Dependencies & Risks

### 4.1 Technical Dependencies
- PostgreSQL 16 with JSONB support (Neon provides this)
- Android API 34+ for latest features
- .NET 8 SDK available on all developer machines

### 4.2 External Dependencies
- Neon PostgreSQL free tier (limit: 0.5GB DB, 3 Project branches)
- Azure App Service F1 Free (limit: 60 CPU minutes/day)
- Google Maps API key (quota limits apply)
- Firebase FCM (free tier: 10k messages/day)

### 4.3 Known Risks

| Risk | Impact | Probability | Mitigation |
|-------|---------|--------------|------------|
| Free tier resource limits | High | Medium | Monitor usage closely, have upgrade plan ready |
| Database performance on Neon Free | Medium | High | Optimize queries, use caching, limit concurrent users |
| Offline sync conflicts | Medium | Medium | Implement ServerWins strategy, add conflict resolution UI |
| Android device fragmentation | Low | High | Test on multiple devices, use backward-compatible APIs |

---

## 5. Milestones & Timeline

### Week 1-2: Infrastructure & Database
- ✅ Dev environment setup
- ✅ CI/CD pipelines
- ✅ Cloud infrastructure
- ✅ Database schema implementation
- ✅ Authentication API

### Week 3: Master Data APIs
- ✅ Customer Management API
- ✅ Product Management API
- ✅ Distributor Management API
- ✅ Route Management API

### Week 4-6: Mobile App
- ✅ Android project setup
- ✅ Offline data storage
- ✅ Authentication screens
- ✅ Customer & Product screens
- ✅ Data synchronization

### Week 6-7: Web Dashboard
- ✅ React web app setup
- ✅ Authentication & layout
- ✅ Master data management pages
- ✅ Basic reporting

### Week 8: Testing
- ✅ Backend testing
- ✅ Mobile testing
- ✅ Web testing

### Week 9: Documentation & Deployment
- ✅ API documentation
- ✅ User documentation
- ✅ Production deployment

**Total Estimated Duration:** 9 weeks

---

## 6. Success Metrics

### Technical Metrics
- API uptime: > 99%
- API response time (p95): < 500ms for master data endpoints
- App startup time: < 5 seconds
- Sync duration (full initial): < 2 minutes
- Sync duration (delta): < 30 seconds

### Functional Metrics
- All CRUD operations working for Customers, Products, Distributors
- Authentication flow working on mobile and web
- Offline data accessible after sync
- Data consistency between mobile and server

### Quality Metrics
- Backend code coverage: > 80%
- Mobile code coverage: > 70%
- Web code coverage: > 70%
- Critical bugs in production: 0

---

## 7. Handoff to Phase 2

### Deliverables
1. Source code repositories (backend, mobile, web)
2. Deployed production environment
3. API documentation (Swagger + Postman)
4. User guides
5. Test suites and test reports

### Prerequisites for Phase 2
- All Phase 1 tasks completed
- Production environment stable
- User feedback collected (from pilot testing)
- Performance baselines established

---

**Document Version:** 1.0
**Created Date:** 2026-02-06
**Author:** Implementation Team
**Related Documents:**
- [PRD-v2.md](../current-feature/PRD-v2.md)
- [00-ARCHITECTURE-OVERVIEW.md](../architecture/00-ARCHITECTURE-OVERVIEW.md)
- [04-DATA-ARCHITECTURE.md](../architecture/04-DATA-ARCHITECTURE.md)
- [Phase 2: Core Operations](02-Phase2-Core-Operations.md)
