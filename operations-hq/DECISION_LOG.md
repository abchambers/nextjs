# Decision Log

| Date | Decision | Status | Consequence |
| --- | --- | --- | --- |
| 2026-07-23 | Keep public weather, professional forecasting, and education products under one brand with modular product boundaries | Adopted | Shared identity/data contracts; distinct scopes and navigation |
| 2026-07-23 | Classroom forecasts remain private to the classroom and never alter public Frontline Forecast output | Adopted | Education can be a safe practice space without compromising public trust |
| 2026-07-23 | Adopt Frontline Forecast as the proposed visible product and company brand | Adopted pending clearance | Existing technical identifiers and deployment URLs remain stable until a deliberate migration |
| 2026-07-23 | School codes are invitation/redemption mechanisms, not proof of a paid license | Adopted | Billing entitlement remains server-controlled and auditable |
| 2026-07-23 | Provider-neutral data layer precedes owned models/sensor network | Adopted | Current APIs remain replaceable as first-party data matures |
| 2026-07-23 | Concept Lab is isolated from production UI, styles, APIs, and deployment | Adopted | Design exploration cannot accidentally regress the live product |

## How to use this log

Add a row only for decisions that change scope, security, privacy, commercial direction, or architecture. Do not use it for small visual adjustments.
