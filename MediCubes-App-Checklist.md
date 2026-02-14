# MediCubes App Checklist

## Implementation status (latest)

- **A1** Token & auth: JWT now includes **OrgId** and optional **RegLocId**; **TempUser** has OrgId/RegLocId; **ICurrentUser** + **CurrentUserService** added as single abstraction; login response includes **orgName** and **orgId**.
- **A2** API layer: All org-touching services use **ICurrentUser** (single abstraction). **GetAllUsers**, **GetRoles**, **GetUserById**, **DeleteUser**, **GetRolesList**, **GetRoleById**, **DeleteRoleById** filter by current user’s **TenantId**. No OrgId from client; **CreateRole**/**UpdateRole** use **TenantId** (bug fix: was **UserId**). **MenuAccessFilter** uses **ICurrentUser**. **OrgInfoService** RegisterTenant sets **OrgId** = new tenant’s **TenantId**; **UserService** RegisterUser sets **OrgId** from current user.
- **A3** Global query filter added for **OrgAppSetting**, **OrgLocation**, **AppMenu** (tenant-scoped) when **ICurrentUser** is injected; **AppDbContext** has optional second constructor for design-time/migrations.
- **B3** Frontend: **User** type has **orgId**, **orgName**, **tenantId**; login stores and displays org name in classy layout and user dropdown; token handling supports both `accessToken` and `AccessToken`.
- **Part C** `environment.apiUrl` is set; auth interceptor handles 401 and redirects to sign-in.

---

## Part A – Multi-tenancy (backend + DB)

### A1. Token & auth
- [x] **Token always carries tenant** (implemented)  
  JWT (or current token) includes: **UserId**, **OrgId**. Optional: RegLocId, UserName, IsSuperAdmin.
- [x] **One place to get “current user/tenant”** (implemented: **ICurrentUser** + **CurrentUserService**)
  e.g. **ICurrentUser** / **ITenantContext** (or **IJWTService.DecodeToken()**) used by all APIs. No direct **UAuth.DecodeToken()** in controllers; inject the abstraction instead.
- [x] **Login response** (implemented: returns **orgName**, **orgId**, **tenantId**)
  Login API returns token + user (and optionally org name) so the front can store and show “current org”.

### A2. API layer
- [x] **Every API that touches org data** (implemented: ICurrentUser; no OrgId from client)  
  Resolves current user/tenant from the abstraction and passes **OrgId** into the service/business layer (no OrgId from client for authorization).
- [ ] **No “sometimes filter by OrgId”**  
  Audit all controllers/APIs that query org-scoped data; ensure every path uses **currentUser.OrgId** (or equivalent).
- [ ] **Reports / export endpoints**  
  All report and export actions receive OrgId from current user only and pass it into queries/SPs.

### A3. Data layer & DB
- [ ] **All tenant-scoped tables have OrgId**  
  List all tables that are per-organization; add OrgId where missing.
- [ ] **All inserts**  
  Set OrgId from current user (never from request body for authorization).
- [ ] **All reads/updates/deletes**  
  Restrict by OrgId (and key) so one tenant cannot see or change another’s data.
- [ ] **Stored procedures**  
  All SPs that use org data take **@OrgId** (from server-side current user) and use it in WHERE / joins.
- [x] **Optional: global query filter** (implemented for OrgAppSetting, OrgLocation, AppMenu)
  (If using EF Core) Add a global filter on OrgId for tenant entities so it can’t be forgotten.

### A4. Tenant lifecycle (optional)
- [ ] **Tenant registration**  
  If you want “new org sign-up”: e.g. **RegisterTenant** API that creates org, default locations, and first admin user (and optionally DB/schema if multi-DB).
- [ ] **Tenant isolation tests**  
  Simple tests or manual checks: user A (Org 1) cannot see or change Org 2’s data.

---

## Part B – Front (Angular + Fuse)

### B1. App shell & routing
- [ ] **Single Angular app**  
  App using Angular 18+ and Fuse (or your chosen layout).
- [ ] **Client-side routing**  
  All main routes defined in Angular (e.g. **app.routes.ts**); no dependency on server-injected routes for navigation.
- [ ] **Layouts**  
  Empty for sign-in/sign-up; one main layout for the app.
- [ ] **Lazy-loaded feature modules**  
  One lazy module per area: e.g. inventory, registration, billing, diagnostics, accounts, each with its own **\*.routes.ts**.

### B2. Auth
- [ ] **AuthService**  
  Sign-in, sign-out, token in **localStorage** (or your chosen storage); expose **accessToken** and optionally current user.
- [ ] **HTTP interceptor**  
  Attach **Authorization: Bearer &lt;token&gt;** to API requests; on 401, clear auth and redirect to sign-in.
- [ ] **Guards**  
  **AuthGuard** on all app routes; **NoAuthGuard** on sign-in/sign-up so logged-in users are redirected.
- [ ] **Login flow**  
  Login calls backend; store token + user (and org name); redirect to main app (e.g. home or dashboard).

### B3. User & tenant on client
- [x] **User/org after login** (implemented: User type has orgId/orgName; stored and shown in layout and user menu)
  Store user + org (and optionally location) in **UserService** or **TenantService** (and/or **localStorage**) so the UI can show “Organization: X”.
- [ ] **Optional: tenant/org switcher**  
  If a user can belong to multiple orgs, add a switcher that gets a new token (or context) for the selected org.

### B4. Navigation & menu
- [ ] **Navigation**  
  Vertical/horizontal nav configured for your modules (Inventory, Registration, Billing, etc.).
- [ ] **Menu source**  
  Either static menu in Angular or a “menu”/“navigation” API that returns allowed items per user/tenant; map response to navigation items.

### B5. Feature structure
- [ ] **Per-module**  
  Each area has: **\*.routes.ts**, services (e.g. **product.service.ts**, **requisition.service.ts**), and components. API base URL from **environment.apiUrl**.
- [ ] **First feature**  
  One feature (e.g. Inventory → Product list) implemented end-to-end: route, guard, service, API with Bearer token, layout.

---

## Part C – Cross-cutting

- [x] **Environment**
  **environment.apiUrl** (and optional production) for API base URL.
- [ ] **Errors**
  Global handler or interceptor for non-401 errors (e.g. toasts or error page).
- [ ] **Optional: permissions**  
  If you need “canEdit”/“canDelete” per screen, either in JWT claims or from a “permissions”/“menu” API and used by guards or UI.

---

## Quick reference

| Goal           | Backend                                               | Front-end                                    |
|----------------|--------------------------------------------------------|----------------------------------------------|
| **Multi-tenant** | Token has OrgId; one abstraction; every API/query uses it. | Send token only; show org name from user/org. |
| **Front**      | JWT login API; optional menu/permissions API.          | Angular + Fuse, AuthService, interceptor, guards, lazy modules. |
