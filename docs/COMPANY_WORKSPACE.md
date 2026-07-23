# Frontline Forecast — Company Workspace

This is the working plan for turning Frontline Forecast into a sustainable weather and education company. It is intentionally separate from the live product UI.

## Product principle

One company, shared identity and weather-data foundation; distinct products with clear boundaries.

```text
Frontline Forecast
├── Public weather and company site
├── Forecasting workspace (personal and professional)
├── Education Suite (schools, classes, assignments, private assessment)
├── Operations HQ (users, access, licenses, billing, support, controlled production operations)
└── Data engine (weather sources, models, sensors, archives, APIs)
```

The public product never exposes student records or classroom forecasts. A classroom may create a class outlook for its own learning community, but it is not Frontline Forecast's public forecast.

## Product guardrails

- The current application is the source of truth for the existing visual language and workflow.
- Do not redesign live screens while building infrastructure unless a specific product need requires it.
- Every visible control must answer a clear user need; do not add internal status, placeholder actions, or tutorial-like copy to the product.
- Keep roles, workspaces, billing entitlements, and publication scope separate concepts.
- Forecast evidence is immutable at submission; the forecaster's view at the time must remain reviewable.
- Build provider-neutral data contracts before making irreversible commitments to one weather API.

## Design exploration boundary

If a redesign is explored, it must live in a separate `concepts/` area or static design artifact:

- No imports from live application code.
- No shared stylesheets or components.
- No database writes, authentication, or live API keys.
- No deployment over the production application.
- A concept becomes product work only after an explicit decision to port individual ideas into the current visual system.

## Current foundation

| Area | Current state | Next hardening step |
| --- | --- | --- |
| Product UI | Weather, radar, forecasts, records, classroom, and control views exist | Continue targeted workflow and mobile acceptance testing |
| Identity | Supabase email/password accounts and profiles exist | Production confirmation return + cookie-backed server sessions |
| Workspaces | Personal, organization, and classroom scopes exist | Add organization plan/seat visibility and invitation redemption UI |
| Education | Assignments, class outlook, instructor review, and private student work exist | Pilot with a real instructor and simplify from observed behavior |
| Data | NWS/NOAA, Open-Meteo, OpenWeather, and stored snapshots feed the UI | Canonical data contracts, source provenance, usage metering, fallbacks |
| Deployment | GitHub → Vercel and Supabase production are live | Monitoring, backup checks, staging/preview policy, release checklist |

## Near-term sequence

### Phase 1 — Trustworthy beta foundation

**Goal:** Make one production path safe enough for real pilot users.

1. Fix email-confirmation and password-reset redirects to the production origin.
2. Move from browser-managed session handling to Supabase SSR/cookie sessions.
3. Validate RLS and privacy boundaries for personal, organization, and classroom records.
4. Add error monitoring, source-status monitoring, and a simple operational log.
5. Write a pilot onboarding checklist and test the complete instructor/student journey.

**Exit criteria:** a new user can register, confirm email, join the right workspace, submit a forecast, and be reviewed without manual database repair.

### Phase 2 — School licensing and administration

**Goal:** Let a school adopt the product without bespoke setup for each student.

1. Organization entitlement record: plan, status, seat limit, dates, billing-provider IDs.
2. Secure school/invitation code redemption with expiration, capacity, audit trail, and a hashed code store.
3. Organization owner tools: plan summary, available seats, instructors, active classes, and invites.
4. Create classrooms only inside an active school entitlement.
5. Connect a verified billing webhook before automatically upgrading an organization.

**Recommended commercial model:**

| Customer | Initial offer | Later offer |
| --- | --- | --- |
| Instructor pilot | Time-limited, capped classroom | Department purchase |
| Small school/program | Annual classroom or instructor-seat plan | Multi-course license |
| District/university | Contracted annual site license | SSO, roster integrations, reporting |
| Professional forecaster | Individual Pro plan | Team workspace and data/API plan |

### Phase 3 — Cost control and supportability

**Goal:** Know the cost and health of every customer workspace.

1. Meter expensive requests by organization/workspace and source.
2. Cache public data responsibly and rate-limit authenticated write operations.
3. Add provider fallback states: stale data is labeled, not silently presented as current.
4. Set usage caps and alerts before any provider bill can surprise the company.
5. Create a support inbox, incident template, customer export/delete workflow, and status page plan.

### Phase 4 — Public company site

**Goal:** Explain the product without mixing public marketing with the working desk.

- Brand story and public weather landing page.
- Education Suite overview and educator pilot request.
- Forecasting/Pro overview.
- Pricing, support, documentation, Terms, Privacy, and data-source attribution.
- Separate public-facing routes/subdomain from authenticated app routes.

### Phase 5 — Data platform evolution

**Goal:** Make outside providers replaceable and prepare for first-party observations.

```text
Provider or sensor
→ source adapter
→ canonical observation/model schema
→ validation + provenance + storage
→ forecast views, maps, Skew-T, verification, archive, API
```

Future sensor requirements: station identifier, precise coordinates/elevation, calibration history, timestamp and timezone, quality flags, device health, retention policy, and consent/privacy policy. Do not use unvalidated sensor readings as authoritative public observations.

## Operating model: where to manage what

| Need | System of record | Why |
| --- | --- | --- |
| Product source and release history | GitHub | Code review, branches, rollback history |
| Production deployments/logs/environment | Vercel | Deployments, scheduled jobs, runtime failures |
| Users, records, RLS, organizations | Supabase | Authentication and durable application data |
| Weather source credentials | Vercel/Supabase server environment only | No secrets in browser code or Git history |
| Billing and invoices | Billing provider + webhook ledger in Supabase | Payment state must be server-confirmed |
| Internal work planning | This document initially; later a dedicated project tool | Prevent product controls from becoming an internal project board |

### Operations HQ evolution

Operations HQ begins as this separate planning/runbook workspace. It should later become a protected internal application with its own owner/admin permission model and a narrow server-side control API. It may govern production organizations, licensing, source health, cache/failover actions, feature access, and release visibility; it should not share the customer product navigation or expose secrets directly.

## Revenue and pricing hypotheses to test

- Education SaaS is the most credible first recurring-revenue product because the current workflow already has differentiated classroom value.
- A professional workflow can follow, focused on archived reasoning, evidence, and data consolidation rather than competing head-on with full enterprise meteorology suites.
- API/data resale is a later business: confirm commercial-use and redistribution rights before promising it.
- Build a provider-cost model before pricing: cost per active user, active classroom, map load, model request, radar refresh, and archive saved.

## Legal, privacy, and provider diligence

Before broad school or public launch, obtain appropriate professional advice and complete:

- Terms of Service and Privacy Policy.
- Student-data/privacy review, including applicability of FERPA, COPPA, and local school procurement requirements.
- Data retention, deletion, export, and account termination policy.
- Commercial-use, attribution, caching, and redistribution review for every weather, radar, map, and model source.
- Accessibility review, beginning with keyboard flow, contrast, form labels, mobile behavior, and WCAG-informed acceptance checks.
- Domain ownership, registrar MFA/domain lock, company email, business registration, accounting, and insurance decisions.

## Security baseline

- No service-role or provider-secret value in `NEXT_PUBLIC_*` variables or client code.
- Every exposed Supabase table has RLS with a workspace ownership/membership predicate.
- Roles are not taken from user-editable profile metadata.
- Payment and license state come from a verified server-side provider webhook.
- Rate-limit sign-up, confirmation resend, code redemption, forecasting writes, and costly model/map requests.
- Enable MFA for GitHub, Vercel, Supabase, registrar, email, and billing accounts.
- Maintain tested backups and a key-rotation runbook.

## Decision log

| Decision | Status | Reason |
| --- | --- | --- |
| One brand, modular products | Adopted | Shared identity/data without a confusing monolith |
| Class forecasts are never public Frontline Forecast forecasts | Adopted | Keeps learning safe and scopes clear |
| Code-based school joining | Foundation in progress | Codes are invitations tied to an entitlement, not a license by themselves |
| External providers first; own models later | Adopted | Build a data layer before buying compute and operations burden |
| Separate redesign concepts from the live app | Adopted | Protects the current product from accidental visual/workflow regressions |

## Questions to resolve before self-serve sales

1. Which customer is first: one instructor, a department, a local media/school weather team, or independent forecasters?
2. What exact deliverable makes a school renew after one semester?
3. Do schools need SSO, roster sync, data-processing agreements, or procurement documents at launch?
4. What data/source features are essential for a paid tier versus freely available elsewhere?
5. What should happen when an entitlement expires: read-only archive, instructor-only archive, or export period?
6. Which domain will be the long-term public identity and which subdomain hosts the authenticated application?
