alter table public.forecasts
  drop constraint if exists forecasts_status_check;

update public.forecasts
set status = 'submitted'
where status = 'pending_verification';

alter table public.forecasts
  add column if not exists forecast_period text not null default 'day_night'
    check (forecast_period in ('day_night', 'day', 'night')),
  add column if not exists version_number integer not null default 1,
  add column if not exists parent_forecast_id uuid references public.forecasts(id) on delete set null,
  add column if not exists submitted_at timestamptz,
  add column if not exists grading_cutoff timestamptz;

alter table public.forecasts
  add constraint forecasts_status_check
  check (status in ('draft', 'submitted', 'revised', 'verified'));

create index if not exists forecasts_target_version_idx
  on public.forecasts (user_id, forecast_date, forecast_period, version_number desc);
