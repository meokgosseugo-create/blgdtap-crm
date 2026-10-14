-- 물건의 '급매' / '금액조정' 표시를 저장할 칸을 만듭니다. 한 번만 실행하면 됩니다. (여러 번 실행해도 안전)
-- Supabase > SQL Editor 에 붙여넣고 Run 하세요.

alter table public.crm_properties
  add column if not exists is_urgent   boolean not null default false,
  add column if not exists is_adjusted boolean not null default false;

notify pgrst, 'reload schema';
