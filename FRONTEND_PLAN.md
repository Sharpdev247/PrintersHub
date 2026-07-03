# PrintersHub — React Frontend Master Plan

## Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| Adapter | **Inertia.js** | Keeps Rails routing, Devise auth, sessions — no separate API or CORS |
| UI | **React 18** | Component model, hooks, Context API |
| Styling | **Tailwind CSS** | Utility-first, works with Propshaft |
| Build | **Vite + vite-rails** | Fast HMR, replaces importmap for JS |
| State | **Zustand + SWR** | Zustand for cart/UI, SWR for server-state caching |
| Forms | **React Hook Form** | Works with Inertia form helpers for CSRF + validation errors |

---

## Work Rule
- One task at a time. You submit → I build, commit, push → you verify → next task.
- Never skip ahead.

---

## Phase 0 — Foundation (shared components, build before any page)

| # | Component | Path/Scope | Key Features | Priority |
|---|---|---|---|---|
| 01 | **Navbar / Header** | All pages | Logo, search, auth state, cart badge, account switcher | Must |
| 02 | **Footer** | All public + portal | Link groups, newsletter, social, copyright | Must |
| 03 | **Portal Sidebar** | /portal/* | Role-aware nav, collapsible, active state | Must |
| 04 | **Filter Sidebar** | Listings pages | Category tree, price slider, condition, brand, clear all, URL params | Must |
| 05 | **UI Primitives** | Component library | Button, Input, Select, Modal, Drawer, Toast, Badge, Avatar, Spinner, Skeleton, Pagination, Breadcrumbs, EmptyState, ErrorBoundary | Must |

---

## Phase 1 — Public Pages

| # | Page | Path | Key Features | Priority |
|---|---|---|---|---|
| 06 | **Home / Landing** | / | Hero + search, featured categories, featured listings, how it works, seller CTA | Must |
| 07 | **Listings Index** | /listings | Grid/list toggle, filter sidebar, sort, listing cards, pagination | Must |
| 08 | **Listing Detail** | /listings/:slug | Image gallery, variants selector, make offer, add to cart, seller card, related listings | Must |
| 09 | **Category Browse** | /categories/:slug | Category header, sub-category chips, filtered listings grid | High |
| 10 | **Search Results** | /listings?q=... | Query display, listing grid, AI expand suggestion, result count | High |

---

## Phase 2 — Auth Pages

| # | Page | Path | Key Features | Priority |
|---|---|---|---|---|
| 11 | **Login** | /login | Email + password, remember me, Devise errors | Must |
| 12 | **Register** | /register | Name, email, password, account type picker, terms | Must |
| 13 | **Forgot Password** | /password/new | Email input, success state | High |
| 14 | **Reset Password** | /password/edit | New password, token from URL, redirect on success | High |

---

## Phase 3 — Portal Core

| # | Page | Path | Key Features | Priority |
|---|---|---|---|---|
| 15 | **Portal Dashboard** | /portal | Role-aware stats, activity feed, quick actions, usage bar | Must |
| 16 | **Notifications** | /portal/notifications | List by type, mark read, filter, empty state | Medium |
| 17 | **Messages / Chat** | /portal/conversations | Two-panel, real-time (Action Cable), listing context | High |

---

## Phase 4 — Seller Pages

| # | Page | Path | Key Features | Priority |
|---|---|---|---|---|
| 18 | **My Listings** | /portal/seller/listings | Status tabs, bulk actions, quick edit, AI describe button | Must |
| 19 | **Create / Edit Listing** | /portal/seller/listings/new | Multi-step: Category → Details+Variants → Pricing+AI → Photos → Publish | Must |
| 20 | **Received Orders** | /portal/seller/orders | Status filter, order table, mark shipped | Must |
| 21 | **Order Detail (Seller)** | /portal/seller/orders/:id | Summary, status timeline, shipping actions, tracking, notes | Must |
| 22 | **Offers Inbox** | /portal/seller/offers | Accept/Counter/Decline inline, offer thread, expiry countdown | High |

---

## Phase 5 — Buyer & Checkout

| # | Page | Path | Key Features | Priority |
|---|---|---|---|---|
| 23 | **Cart** | /cart | Items grouped by seller, quantity stepper, tax estimate, empty state | Must |
| 24 | **Checkout — Shipping** | /checkout/shipping | Address form, saved addresses, shipping method + rates | Must |
| 25 | **Checkout — Payment** | /checkout/payment | Payment method, coupon code, order summary sidebar | Must |
| 26 | **Order Confirmation** | /checkout/confirmation | Success state, order number, what happens next | Must |
| 27 | **My Orders (Buyer)** | /portal/buyer/orders | Order history, status badge, reorder button | Must |
| 28 | **Order Detail (Buyer)** | /portal/buyer/orders/:id | Items, status timeline, tracking, dispute action | Must |
| 29 | **Favorites / Wishlist** | /portal/buyer/favorites | Saved listings, price change indicator, add to cart | Medium |

---

## Phase 6 — Settings & CRM

| # | Page | Path | Key Features | Priority |
|---|---|---|---|---|
| 30 | **Profile Settings** | /portal/settings/profile | Avatar upload, name, bio, phone | High |
| 31 | **Account Settings** | /portal/settings/account | Account name, slug, logo, danger zone | High |
| 32 | **Team / Members** | /portal/settings/members | Members table, invite by email, change role, remove | Medium |
| 33 | **Subscription & Billing** | /portal/settings/billing | Current plan, usage meters, upgrade, invoice history | High |
| 34 | **CRM — Contacts** | /portal/crm/contacts | Contact list, search, type filter, detail drawer, add note | Medium |

---

## Phase 7 — Reports & Warehouse

| # | Page | Path | Key Features | Priority |
|---|---|---|---|---|
| 35 | **Sales Report** | /portal/reports/sales | Revenue chart, period selector, top listings, orders donut, export CSV | Medium |
| 36 | **Inventory Dashboard** | /portal/warehouse/inventory | Stock levels, low-stock alerts, inline adjust, reorder rules | Medium |
| 37 | **Purchase Orders** | /portal/warehouse/purchase-orders | PO list, create PO, receive items flow | Low |
| 38 | **Service Requests** | /portal/service | Ticket list, create request, status pipeline, assign technician | Low |

---

## Summary

| Phase | Pages | Count |
|---|---|---|
| Phase 0 — Foundation | Navbar, Footer, Portal Sidebar, Filter Panel, UI Primitives | 5 |
| Phase 1 — Public | Home, Listings, Listing Detail, Category, Search | 5 |
| Phase 2 — Auth | Login, Register, Forgot Password, Reset Password | 4 |
| Phase 3 — Portal Core | Dashboard, Notifications, Messages | 3 |
| Phase 4 — Seller | My Listings, Create/Edit, Orders, Order Detail, Offers | 5 |
| Phase 5 — Buyer | Cart, Checkout ×3, My Orders, Order Detail, Favorites | 7 |
| Phase 6 — Settings | Profile, Account, Team, Billing, CRM Contacts | 5 |
| Phase 7 — Reports | Sales Report, Inventory, Purchase Orders, Service | 4 |
| **Total** | | **38** |
