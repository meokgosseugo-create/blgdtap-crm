-- ============================================================
-- 빌딩탭 CRM — Supabase 설정 (한 번만 실행하면 됩니다. 여러 번 실행해도 안전)
-- 실행 위치: Supabase 대시보드 → SQL Editor → New query → 전체 붙여넣기 → Run
--
-- 1) 매물 저장 오류 해결: 앱이 저장하는 항목 중 표에 없는 칸을 추가합니다.
--    (예: "Could not find the 'groundfloorarea' column ...")
--    이미 있는 칸은 건드리지 않습니다.
-- 2) 공동 물건(공유) 기능에 필요한 칸과 코멘트 표를 만듭니다.
-- ============================================================

-- 1) 매물 표(crm_properties)에 없는 칸 추가
alter table public.crm_properties
  add column if not exists name              text,
  add column if not exists type              text,
  add column if not exists transactiontype   text,
  add column if not exists address           text,
  add column if not exists zoning            text,
  add column if not exists ownername         text,
  add column if not exists ownerphone        text,
  add column if not exists status            text,
  add column if not exists user_id           text,
  add column if not exists registrant        text,
  add column if not exists registrantphone   text,
  add column if not exists date              text,
  add column if not exists completionyear    text,
  add column if not exists landarea          numeric,
  add column if not exists totalfloorarea    numeric,
  add column if not exists groundfloorarea   numeric,
  add column if not exists buildingarea      numeric,
  add column if not exists buildingcoverage  numeric,
  add column if not exists floorarearatio    numeric,
  add column if not exists floorunderground  numeric,
  add column if not exists floorground       numeric,
  add column if not exists elevators         numeric,
  add column if not exists parking           numeric,
  add column if not exists price             jsonb,
  add column if not exists floordetails      jsonb,
  add column if not exists worklogs          jsonb,
  add column if not exists images            jsonb,
  add column if not exists is_shared         boolean not null default false;

-- 2) 공유 코멘트 표 (공동 물건 카드에 직원들이 남기는 코멘트)
create table if not exists public.crm_comments (
  id          text primary key,
  property_id text not null,
  user_id     text not null,
  author      text,
  content     text not null,
  date        text
);
create index if not exists crm_comments_property_idx on public.crm_comments (property_id);

-- 코멘트 표 보안: 로그인한 직원만 읽고 쓸 수 있음
alter table public.crm_comments enable row level security;
drop policy if exists "crm_comments_read"   on public.crm_comments;
drop policy if exists "crm_comments_insert" on public.crm_comments;
create policy "crm_comments_read"   on public.crm_comments for select to authenticated using (true);
create policy "crm_comments_insert" on public.crm_comments for insert to authenticated with check (true);

-- 변경 사항이 바로 적용되도록 알림
notify pgrst, 'reload schema';
