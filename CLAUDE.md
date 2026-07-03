# PrintersHub — CLAUDE.md

## Project overview

Enterprise multi-tenant SaaS marketplace for printer parts, equipment, and services.

**Stack:** Rails 8.1.3 · Ruby 3.4.9 · PostgreSQL · Solid Queue/Cache/Cable · Kamal

## Architecture

### Multi-tenancy
- `Account` is the tenant. Users join via `Membership` (role on join).
- `Current < ActiveSupport::CurrentAttributes` — `Current.account`, `Current.user`, `Current.role`, `Current.membership` set per-request by `AccountScoped` concern.
- All portal controllers inherit `Portal::BaseController` which includes `AccountScoped`.

### Key models
| Model | Notes |
|---|---|
| `User` | Devise auth; belongs to many accounts via `Membership` |
| `Account` | Tenant; FriendlyId slug; soft-delete via `discard` |
| `Membership` | Join: user ↔ account with role (owner/admin/manager/sales/technician/warehouse_staff/accountant) |
| `Listing` | String-backed enums (status/condition/listing_type); `pg_search`; `audited` |
| `Order` | Integer-backed enum status; `transition_to!`; `for_account` scope |
| `ApiToken` | HMAC-SHA256 digest; `phb_` prefix; scope-based auth |
| `SubscriptionPlan` + `PlanFeature` | Plans with typed feature values (boolean/limit/string) |
| `AccountSubscription` | Live subscription; `SubscriptionEnforcer` gates features |

### Namespaces & routes
- `Portal::` — all authenticated portal controllers (layout: `portal`)
- `Portal::Seller::` — listing/order management for sellers
- `Portal::Buyer::` — order views for buyers
- `Portal::Warehouse::` — inventory management
- `Portal::Service::` — service requests
- `Portal::CRM::` — contacts
- `Portal::Reports::` — analytics (base controller: period presets)
- `Portal::Settings::` — profile/account/password/memberships
- `API::V1::` — token-authenticated REST (Bearer token)

### Authorization
- **Pundit** for resource policies (`authorize`, `policy_scope`)
- **`SubscriptionEnforcer`** for plan feature gates — raises `LimitError`, rescued in `Portal::BaseController`

### Soft deletes
- `discard` gem — `kept` / `discarded` / `with_discarded` scopes
- `discarded_at` column (never `deleted_at`)

### Audit trail
- `audited` gem on all write models
- `Current.user` set per-request and per-job so all writes are attributed

### AI features
- `Ai::BaseService` — shared Claude Haiku client (requires `ANTHROPIC_API_KEY`)
- `Ai::ListingDescriptionService`, `Ai::PriceSuggestionService`, `Ai::SearchExpanderService`
- All degrade silently (return `nil`) when key absent

## Commands

```bash
bin/rails server          # start dev server
bin/rails db:prepare      # create + migrate
bin/rails test            # run all tests
bin/rails test test/models test/services   # unit tests only
bin/kamal deploy          # deploy to production
```

## Environment variables

See `.env.example`. Key vars:
- `ANTHROPIC_API_KEY` — optional; AI features disabled if absent
- `DATABASE_URL` — production database connection string
- `RAILS_MASTER_KEY` — from `config/master.key`
- `SMTP_ADDRESS` / `SMTP_USERNAME` / `SMTP_PASSWORD` — mailer

## Testing conventions
- Minitest (Rails default), no RSpec
- Fixtures in `test/fixtures/`
- `with_env(vars) { }` helper available in all test classes
- Service tests stub API calls via `obj.stub(:chat, response)`

## Deployment
- Kamal 2.x — config in `config/deploy.yml`
- Docker multi-stage build — `Dockerfile`
- GitHub Actions CI — `.github/workflows/ci.yml` (scans → lint → test → system → deploy on main)
- Secrets in `.kamal/secrets` (reads from ENV)
