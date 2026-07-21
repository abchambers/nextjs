-- Workspace switcher support: a classroom member must be able to see the
-- school and class context that was explicitly assigned to them. This keeps
-- the switcher useful for students, instructors, and multi-workspace staff.

create or replace function public.can_view_organization(target_organization uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select public.is_owner() or exists (
    select 1 from public.organization_memberships
    where organization_id = target_organization and user_id = auth.uid() and status = 'active'
  ) or exists (
    select 1
    from public.classroom_memberships cm
    join public.classrooms c on c.id = cm.classroom_id
    where c.organization_id = target_organization
      and cm.user_id = auth.uid()
      and cm.status = 'active'
  );
$$;

-- Forecast-run policies remain private by default. Workspace membership only
-- establishes switcher visibility here; future publication policies will grant
-- access to expressly shared classroom/company forecasts, never every record.
