-- Authorization helpers are used by RLS policies, not as public RPCs.
-- PostgreSQL otherwise grants EXECUTE to PUBLIC for new functions, which makes
-- these SECURITY DEFINER functions callable through the exposed public schema.

revoke all on function public.is_owner() from public, anon, service_role;
revoke all on function public.is_admin() from public, anon, service_role;
revoke all on function public.can_view_organization(uuid) from public, anon, service_role;
revoke all on function public.can_manage_organization(uuid) from public, anon, service_role;
revoke all on function public.can_view_classroom(uuid) from public, anon, service_role;
revoke all on function public.can_manage_classroom_assignment(uuid) from public, anon, service_role;
revoke all on function public.can_review_forecast_run(uuid) from public, anon, service_role;
revoke all on function public.can_view_workspace_profile(uuid) from public, anon, service_role;

grant execute on function public.is_owner() to authenticated;
grant execute on function public.is_admin() to authenticated;
grant execute on function public.can_view_organization(uuid) to authenticated;
grant execute on function public.can_manage_organization(uuid) to authenticated;
grant execute on function public.can_view_classroom(uuid) to authenticated;
grant execute on function public.can_manage_classroom_assignment(uuid) to authenticated;
grant execute on function public.can_review_forecast_run(uuid) to authenticated;
grant execute on function public.can_view_workspace_profile(uuid) to authenticated;

-- Trigger functions are never application RPC endpoints.
revoke all on function public.handle_new_user() from public, anon, authenticated, service_role;
revoke all on function public.protect_owner_role() from public, anon, authenticated, service_role;
revoke all on function public.protect_profile_identity() from public, anon, authenticated, service_role;
revoke all on function public.protect_workspace_owner_membership() from public, anon, authenticated, service_role;
revoke all on function public.validate_forecast_assignment() from public, anon, authenticated, service_role;
