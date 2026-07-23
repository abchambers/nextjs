# Organization and education access model

Frontline Forecast distinguishes platform access from membership in a company or school workspace.

## Platform roles

- **Owner**: permanent full access across every workspace and record.
- **Admin**: runs platform operations and manages ordinary platform accounts.
- **Member**: default for newly registered accounts; private access only until they join a workspace.

## Organization roles

An account may hold different roles in different organizations.

- **Admin / owner**: manages the organization and memberships.
- **Instructor**: manages school classes, student visibility, feedback, and grading workflows.
- **Reviewer**: reviews forecasts when assigned.
- **Forecaster**: creates organization forecasts; publication requires a separate scope.
- **Student**: creates private training forecasts in their enrolled classroom.

## Publication scopes

- `private`: author, permitted instructor/reviewer, and owner only.
- `class`: enrolled classroom participants.
- `school_shared`: explicitly approved school/class forecast.
- `company_review`: internal company review only.
- `company_public`: company-owned public forecast.

School and company forecasts never share a publication channel. The first implementation keeps all existing forecasts personal and private; school creation, join-code redemption, instructor review screens, and scoped publication will be built on this migration.

## Apply the foundation

Run `supabase/migrations/202607210020_organizations_and_school_workspaces.sql` in the Supabase SQL Editor before using the new owner and membership roles in production. It upgrades the designated owner account, leaves existing forecasts personal/private, and does not create a public school or company view.
