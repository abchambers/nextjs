-- Instructor-managed class forecast snapshots. These are intentionally scoped
-- to the classroom: they support teaching, progress review, and later public
-- publishing workflows without exposing individual student submissions.

alter table public.classroom_assignments
  add column if not exists class_forecast jsonb,
  add column if not exists class_forecast_updated_at timestamptz,
  add column if not exists class_forecast_published_at timestamptz;

alter table public.classroom_assignments
  drop constraint if exists classroom_assignments_class_forecast_object;

alter table public.classroom_assignments
  add constraint classroom_assignments_class_forecast_object
  check (class_forecast is null or jsonb_typeof(class_forecast) = 'object');
