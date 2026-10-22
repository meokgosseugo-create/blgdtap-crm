-- 급매수 표시용 칸 추가 + 공유 매수자 통로에 포함. 한 번만 실행하면 됩니다. (여러 번 실행해도 안전)
alter table public.crm_customers
  add column if not exists is_urgent boolean not null default false;

drop view if exists public.crm_shared_customers;
create view public.crm_shared_customers as
  select id, budget, budget_max, region, buildingtype, reason, registrant, registrantphone, date, is_urgent
  from public.crm_customers
  where is_shared = true;
grant select on public.crm_shared_customers to authenticated;

notify pgrst, 'reload schema';
