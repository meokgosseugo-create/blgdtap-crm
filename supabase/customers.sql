-- 고객(매수자) 저장 표 + 공동 매수자(이름·전화번호 숨김) 설정. 한 번만 실행하면 됩니다. (여러 번 실행해도 안전)
-- 오류: Could not find the table 'public.crm_customers' in the schema cache

-- 1) 표 만들기 (이미 있으면 건드리지 않음)
create table if not exists public.crm_customers (
  id      text primary key,
  name    text,
  phone   text,
  budget  numeric,      -- 단위: 억 (예: 12.5 = 12억 5,000만원)
  region  text,
  reason  text,
  date    text
);

-- 2) 공유 기능에 필요한 칸 추가
alter table public.crm_customers
  add column if not exists user_id    text,
  add column if not exists registrant text,
  add column if not exists is_shared  boolean not null default true;

-- 3) 원본 표는 등록한 본인만 볼 수 있게 (이름·전화번호 보호)
alter table public.crm_customers enable row level security;
drop policy if exists "crm_customers_read"   on public.crm_customers;
drop policy if exists "crm_customers_insert" on public.crm_customers;
drop policy if exists "crm_customers_update" on public.crm_customers;
drop policy if exists "crm_customers_delete" on public.crm_customers;
create policy "crm_customers_read"   on public.crm_customers for select to authenticated
  using (lower(user_id) = lower(replace(auth.jwt() ->> 'email', '@crm.local', '')));
create policy "crm_customers_insert" on public.crm_customers for insert to authenticated
  with check (lower(user_id) = lower(replace(auth.jwt() ->> 'email', '@crm.local', '')));
create policy "crm_customers_update" on public.crm_customers for update to authenticated
  using (lower(user_id) = lower(replace(auth.jwt() ->> 'email', '@crm.local', '')))
  with check (lower(user_id) = lower(replace(auth.jwt() ->> 'email', '@crm.local', '')));
create policy "crm_customers_delete" on public.crm_customers for delete to authenticated
  using (lower(user_id) = lower(replace(auth.jwt() ->> 'email', '@crm.local', '')));

-- 4) 공동 매수자: 공유를 켠 매수자의 금액·지역·구매사유만 모두에게 보여 주는 통로 (이름·전화번호 없음)
drop view if exists public.crm_shared_customers;
create view public.crm_shared_customers as
  select id, budget, region, reason, registrant, date
  from public.crm_customers
  where is_shared = true;
grant select on public.crm_shared_customers to authenticated;

notify pgrst, 'reload schema';
