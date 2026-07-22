-- An instructor forecast is a deliberately shared, immutable-at-submission
-- snapshot on an assignment. Student forecasts remain private to their author
-- and authorized instructors; this is the only classroom-visible forecast.

alter table public.classroom_assignments
  add column if not exists instructor_forecast jsonb,
  add column if not exists instructor_forecast_updated_at timestamptz;

alter table public.classroom_assignments
  drop constraint if exists classroom_assignments_instructor_forecast_object;

alter table public.classroom_assignments
  add constraint classroom_assignments_instructor_forecast_object
  check (instructor_forecast is null or jsonb_typeof(instructor_forecast) = 'object');
