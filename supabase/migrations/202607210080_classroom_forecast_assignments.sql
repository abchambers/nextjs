-- Classroom forecast assignments are private workflow records. They provide
-- a target date and due window, then link a submitted forecast run back to the
-- assignment without publishing the forecast outside the classroom.

create table public.classroom_assignments (
  id uuid primary key default gen_random_uuid(),
  classroom_id uuid not null references public.classrooms(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 140),
  instructions text,
  target_date date not null,
  due_at timestamptz,
  status text not null default 'draft' check (status in ('draft', 'open', 'closed')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.forecast_runs
  add column if not exists assignment_id uuid references public.classroom_assignments(id) on delete set null;

create index classroom_assignments_classroom_date_idx
  on public.classroom_assignments (classroom_id, target_date, status);
create index forecast_runs_assignment_idx on public.forecast_runs (assignment_id, created_at desc);

create or replace function public.can_manage_classroom_assignment(target_classroom uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_admin() or exists (
    select 1 from public.classroom_memberships membership
    where membership.classroom_id = target_classroom
      and membership.user_id = auth.uid()
      and membership.status = 'active'
      and membership.role in ('instructor', 'assistant')
  );
$$;

create or replace function public.validate_forecast_assignment()
returns trigger language plpgsql security definer set search_path = public as $$
declare assignment_classroom uuid;
begin
  if new.assignment_id is null then
    return new;
  end if;

  select classroom_id into assignment_classroom
  from public.classroom_assignments
  where id = new.assignment_id;

  if assignment_classroom is null or new.classroom_id is distinct from assignment_classroom then
    raise exception 'A forecast assignment must belong to the same classroom as its forecast run.';
  end if;

  return new;
end;
$$;

drop trigger if exists forecast_runs_validate_assignment on public.forecast_runs;
create trigger forecast_runs_validate_assignment
  before insert or update of assignment_id, classroom_id on public.forecast_runs
  for each row execute procedure public.validate_forecast_assignment();

alter table public.classroom_assignments enable row level security;
grant select, insert, update, delete on public.classroom_assignments to authenticated;

create policy "Classroom members read visible assignments" on public.classroom_assignments
  for select using (
    public.can_manage_classroom_assignment(classroom_id)
    or (status in ('open', 'closed') and public.can_view_classroom(classroom_id))
  );

create policy "Instructors manage classroom assignments" on public.classroom_assignments
  for all using (public.can_manage_classroom_assignment(classroom_id))
  with check (public.can_manage_classroom_assignment(classroom_id));
