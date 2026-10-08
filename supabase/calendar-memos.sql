-- ============================================================
-- 개인 캘린더 일정(메모) 표 만들기 — 한 번만 실행하면 됩니다. (이미 있으면 건너뜀)
-- 오류: "Could not find the table 'public.crm_memos' in the schema cache" 해결용
-- 실행 위치: Supabase 대시보드 → SQL Editor → New query → 붙여넣기 → Run
-- ============================================================
create table if not exists public.crm_memos (
  id        text primary key,
  user_id   text not null,
  "dateStr" text not null,   -- 앱이 'dateStr'(대소문자 구분)로 저장하므로 따옴표로 만든다
  text      text not null
);
create index if not exists crm_memos_user_idx on public.crm_memos (user_id);

alter table public.crm_memos enable row level security;
drop policy if exists "crm_memos_read"   on public.crm_memos;
drop policy if exists "crm_memos_insert" on public.crm_memos;
drop policy if exists "crm_memos_delete" on public.crm_memos;
create policy "crm_memos_read"   on public.crm_memos for select to authenticated using (true);
create policy "crm_memos_insert" on public.crm_memos for insert to authenticated with check (true);
create policy "crm_memos_delete" on public.crm_memos for delete to authenticated using (true);

notify pgrst, 'reload schema';
