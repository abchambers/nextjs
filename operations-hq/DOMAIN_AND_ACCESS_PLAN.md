# Domain and Access Plan

## Recommended domain model

Acquire one primary company domain first. It becomes the durable identity for email, public trust, and every product boundary.

```text
yourdomain.com          Canonical company domain
www.yourdomain.com      Public company and product site
app.yourdomain.com      Authenticated Frontline Forecast application
hq.yourdomain.com       Private owner/admin Operations HQ
status.yourdomain.com   Public service status, only when operations warrant it
```

Do not create all of these applications immediately. Reserve the namespace, configure the domain safely, and introduce each surface only when its purpose is ready.

## First setup checklist

- [ ] Choose and register the primary domain under a company-controlled registrar account.
- [ ] Enable registrar MFA, a recovery method held by the owner, and domain transfer lock.
- [ ] Set up a company mailbox such as `hello@`, `support@`, and `security@`.
- [ ] Enable MFA for GitHub, Vercel, Supabase, registrar, company email, and billing.
- [ ] Define an owner recovery/continuity record: who can access each account if the primary owner is unavailable.
- [ ] Add the primary app domain as the Supabase Site URL and redirect allow-list after it exists.
- [ ] Point `www` only when a public company page is ready; do not send visitors to an unfinished product surface.

## Access layers

| Layer | People | Purpose | Restriction |
| --- | --- | --- | --- |
| Company owner | Founder/authorized executives | Billing, vendors, deployments, security ownership | MFA, least privilege, emergency recovery documented |
| Operations HQ admin | Small trusted internal team | Organization, access, licensing, support, source status | Server-authorized, auditable actions only |
| School administrator/instructor | Customer organization | Their organization, classrooms, membership, assessments | Cannot access other schools or platform operations |
| Student/member | Customer account | Their personal work and permitted class activity | Cannot access peer/private records by default |
| Public visitor | Unauthenticated | Public weather/company information | No product administration or private data |

## Project boundaries

| Project | First implementation | Relationship to current app |
| --- | --- | --- |
| Current Frontline Forecast application | Existing Next.js application | Remains the live product and pilot environment |
| Operations HQ | New protected application after auth/licensing hardening | Same identity/data contracts; separate deployment and navigation |
| Public company site | New lightweight marketing/support application after pilot readiness | Links into app; never contains private desk workflows |
| Concept Lab | Local static exploration | No imports, data, auth, or deployment into production |

## Non-negotiable access rules

- Production secrets stay in Vercel/Supabase/provider environment settings, never in Operations HQ forms or browser code.
- Operations HQ invokes narrow server-side actions; it never gets unrestricted database or deployment credentials in the client.
- Owner/admin actions create audit records: actor, time, target, action, and reason.
- Vendor access is granted individually, time-limited where possible, and reviewed when roles change.
