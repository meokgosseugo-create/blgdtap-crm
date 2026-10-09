-- 고객(매수자) 저장 표를 만듭니다. (한 번만 실행하면 됩니다. 여러 번 실행해도 안전)
-- 오류: Could not find the table 'public.crm_customers' in the schema cache
create table if not exists public.crm_customers (
  id      text primary key,
  name    text,
  phone   text,
  budget  numeric,
  region  text,
  reason  text,
  date    text
);

alter table public.crm_customers enable row level security;
drop policy if exists "crm_customers_read"   on public.crm_customers;
drop policy if exists "crm_customers_insert" on public.crm_customers;
drop policy if exists "crm_customers_update" on public.crm_customers;
drop policy if exists "crm_customers_delete" on public.crm_customers;
create policy "crm_customers_read"   on public.crm_customers for select to authenticated using (true);
create policy "crm_customers_insert" on public.crm_customers for insert to authenticated with check (true);
create policy "crm_customers_update" on public.crm_customers for update to authenticated using (true) with check (true);
create policy "crm_customers_delete" on public.crm_customers for delete to authenticated using (true);

notify pgrst, 'reload schema';
