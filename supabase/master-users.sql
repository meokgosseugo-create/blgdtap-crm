-- 사원 정보 표(crm_users)를 만들고, 이미 가입한 사람들을 채워 넣고,
-- '본인'과 '마스터(wony0205)'만 볼 수 있게 합니다.
-- Supabase > SQL Editor 에 통째로 붙여넣고 Run 하세요. 여러 번 실행해도 안전합니다.

-- 1) 표 만들기 (이미 있으면 그대로 둡니다)
create table if not exists public.crm_users (
  id uuid primary key,
  "loginId" text,
  name text,
  department text,
  phone text,
  "date" text
);

-- 2) 지금까지 가입한 사람들을 채워 넣기 (이미 있는 사람은 건너뜁니다)
insert into public.crm_users (id, "loginId", name, department, phone, "date")
select u.id,
       lower(replace(u.email, '@crm.local', '')),
       coalesce(u.raw_user_meta_data->>'name', '사용자'),
       coalesce(u.raw_user_meta_data->>'department', '사원'),
       coalesce(u.raw_user_meta_data->>'phone', ''),
       to_char(u.created_at, 'YYYY-MM-DD')
from auth.users u
on conflict (id) do nothing;

-- 3) 보안 규칙: 본인과 마스터만
alter table public.crm_users enable row level security;

do $$
declare r record;
begin
  for r in select policyname from pg_policies where schemaname = 'public' and tablename = 'crm_users' loop
    execute format('drop policy %I on public.crm_users', r.policyname);
  end loop;
end $$;

create policy "users_select_self_or_master" on public.crm_users for select to authenticated
  using (id::text = auth.uid()::text or lower(auth.jwt()->>'email') = 'wony0205@crm.local');

create policy "users_insert_self_or_master" on public.crm_users for insert to authenticated
  with check (id::text = auth.uid()::text or lower(auth.jwt()->>'email') = 'wony0205@crm.local');

create policy "users_update_self_or_master" on public.crm_users for update to authenticated
  using (id::text = auth.uid()::text or lower(auth.jwt()->>'email') = 'wony0205@crm.local')
  with check (id::text = auth.uid()::text or lower(auth.jwt()->>'email') = 'wony0205@crm.local');

create policy "users_delete_master" on public.crm_users for delete to authenticated
  using (lower(auth.jwt()->>'email') = 'wony0205@crm.local');

notify pgrst, 'reload schema';

-- 확인용: 가입자 수 / 사원정보 수 (두 숫자가 같아야 합니다)
select (select count(*) from auth.users) as 가입자_전체,
       (select count(*) from public.crm_users) as 사원정보_수;
