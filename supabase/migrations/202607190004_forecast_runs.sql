create table public.forecast_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  location_name text not null default 'Athens, GA',
  latitude numeric(8, 5),
  longitude numeric(8, 5),
  initial_horizon_days integer check (initial_horizon_days >= 1),
  status text not null default 'draft' check (status in ('draft', 'submitted', 'revised', 'verified', 'published')),
  parent_run_id uuid references public.forecast_runs(id) on delete set null,
  submitted_at timestamptz,
  published_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.forecast_periods (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.forecast_runs(id) on delete cascade,
  valid_date date not null,
  period text not null check (period in ('day', 'night')),
  forecast_data jsonb not null,
  evidence_snapshot jsonb not null,
  created_at timestamptz not null default now(),
  unique (run_id, valid_date, period)
);

create table public.forecast_verifications (
  id uuid primary key default gen_random_uuid(),
  forecast_period_id uuid not null unique references public.forecast_periods(id) on delete cascade,
  observed_data jsonb not null,
  score_data jsonb,
  verified_at timestamptz not null default now()
);

create index forecast_runs_user_created_idx on public.forecast_runs (user_id, created_at desc);
create index forecast_periods_valid_date_idx on public.forecast_periods (valid_date, period);

alter table public.forecast_runs enable row level security;
alter table public.forecast_periods enable row level security;
alter table public.forecast_verifications enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.forecast_runs, public.forecast_periods, public.forecast_verifications to authenticated;

create policy "Users manage their own forecast runs" on public.forecast_runs
  for all using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "Users manage periods for their own runs" on public.forecast_periods
  for all using (exists (select 1 from public.forecast_runs r where r.id = run_id and r.user_id = (select auth.uid())))
  with check (exists (select 1 from public.forecast_runs r where r.id = run_id and r.user_id = (select auth.uid())));

create policy "Users manage verification for their own periods" on public.forecast_verifications
  for all using (exists (select 1 from public.forecast_periods p join public.forecast_runs r on r.id = p.run_id where p.id = forecast_period_id and r.user_id = (select auth.uid())))
  with check (exists (select 1 from public.forecast_periods p join public.forecast_runs r on r.id = p.run_id where p.id = forecast_period_id and r.user_id = (select auth.uid())));
