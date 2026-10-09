-- ============================================================
-- 공유 물건(공유) 기능용 Supabase 설정 — 한 번만 실행하면 됩니다.
-- 실행 위치: Supabase 대시보드 → SQL Editor → New query → 아래 전체 붙여넣기 → Run
-- 여러 번 실행해도 안전합니다. (이미 있으면 건너뜀)
-- ============================================================

-- 1) 매물 표에 '공유 여부' 칸 추가 (기본값: 공유 안 함)
alter table public.crm_properties
  add column if not exists is_shared boolean not null default false;

-- 2) 공유 코멘트 표 (공유 물건 카드에 직원들이 남기는 코멘트)
create table if not exists public.crm_comments (
  id          text primary key,
  property_id text not null,
  user_id     text not null,
  author      text,
  content     text not null,
  date        text
);
create index if not exists crm_comments_property_idx on public.crm_comments (property_id);

-- 3) 코멘트 표 보안: 로그인한 직원만 읽고 쓸 수 있음
alter table public.crm_comments enable row level security;
drop policy if exists "crm_comments_read"   on public.crm_comments;
drop policy if exists "crm_comments_insert" on public.crm_comments;
create policy "crm_comments_read"   on public.crm_comments for select to authenticated using (true);
create policy "crm_comments_insert" on public.crm_comments for insert to authenticated with check (true);

-- 4) 변경 사항이 바로 적용되도록 알림
notify pgrst, 'reload schema';

-- ------------------------------------------------------------
-- (되돌리고 싶을 때만) 아래 두 줄의 주석을 풀어서 실행
-- drop table if exists public.crm_comments;
-- alter table public.crm_properties drop column if exists is_shared;
-- ------------------------------------------------------------
