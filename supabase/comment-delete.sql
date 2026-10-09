-- 공유 코멘트를 쓴 사람이 자기 코멘트를 삭제할 수 있게 합니다. (한 번만 실행하면 됩니다)
drop policy if exists "crm_comments_delete" on public.crm_comments;
create policy "crm_comments_delete" on public.crm_comments for delete to authenticated
  using (lower(user_id) = lower(replace(auth.jwt() ->> 'email', '@crm.local', '')));

notify pgrst, 'reload schema';
