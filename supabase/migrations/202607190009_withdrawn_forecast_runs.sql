-- Mirror the forecast withdrawal policy for the run-based archive.
alter table public.forecast_runs
  drop constraint if exists forecast_runs_status_check;

alter table public.forecast_runs
  add constraint forecast_runs_status_check
  check (status in ('draft', 'submitted', 'revised', 'verified', 'published', 'withdrawn'));
