-- A submitted forecast may be withdrawn when it was sent by mistake.
-- Withdrawal is a soft removal: it remains available for protected audit
-- purposes but is excluded from normal student history and grading.

alter table public.forecasts
  drop constraint if exists forecasts_status_check;

alter table public.forecasts
  add constraint forecasts_status_check
  check (status in ('draft', 'submitted', 'revised', 'verified', 'withdrawn'));
