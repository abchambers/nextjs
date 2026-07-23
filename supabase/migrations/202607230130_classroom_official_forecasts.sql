-- A classroom-owned seven-day outlook is deliberately separate from an
-- assignment. Assignments contribute consensus values, while instructors
-- decide which values become the class's official internal forecast.

create table if not exists public.classroom_official_forecasts (
  classroom_id uuid primary key references public.classrooms(id) on delete cascade,
  forecast jsonb not null default '{"days":[]}'::jsonb
    check (jsonb_typeof(forecast) = 'object'),
  updated_by uuid not null references auth.users(id) on delete restrict,
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

alter table public.classroom_official_forecasts enable row level security;
grant select, insert, update on public.classroom_official_forecasts to authenticated;

drop policy if exists "Classroom members read official forecasts" on public.classroom_official_forecasts;
create policy "Classroom members read official forecasts"
  on public.classroom_official_forecasts for select to authenticated
  using (public.can_view_classroom(classroom_id));

drop policy if exists "Instructors create official forecasts" on public.classroom_official_forecasts;
create policy "Instructors create official forecasts"
  on public.classroom_official_forecasts for insert to authenticated
  with check (public.can_manage_classroom_assignment(classroom_id));

drop policy if exists "Instructors update official forecasts" on public.classroom_official_forecasts;
create policy "Instructors update official forecasts"
  on public.classroom_official_forecasts for update to authenticated
  using (public.can_manage_classroom_assignment(classroom_id))
  with check (public.can_manage_classroom_assignment(classroom_id));
