-- 물건의 '작업자'(담당해서 작업하는 사람 이름)를 저장할 칸을 만듭니다. 한 번만 실행하면 됩니다. (여러 번 실행해도 안전)
-- Supabase > SQL Editor 에 붙여넣고 Run 하세요.

alter table public.crm_properties
  add column if not exists worker text;

notify pgrst, 'reload schema';
