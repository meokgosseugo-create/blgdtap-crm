-- 사원 정보(crm_users)는 '본인'과 '마스터(wony0205)'만 볼 수 있게 합니다.
-- Supabase > SQL Editor 에 통째로 붙여넣고 Run 하세요. 여러 번 실행해도 안전합니다.

alter table public.crm_users enable row level security;

-- 예전에 만들어 둔 규칙이 있으면 모두 지우고 아래 규칙으로 새로 만듭니다.
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
