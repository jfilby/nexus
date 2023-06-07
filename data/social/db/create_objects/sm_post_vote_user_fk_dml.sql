REM Nexus generated DML file

ALTER TABLE public.sm_post_vote_user
  ADD CONSTRAINT sm_post_vote_user_fk_1
  FOREIGN KEY (sm_post_id)
  REFERENCES sm_post (id);

ALTER TABLE public.sm_post_vote_user
  ADD CONSTRAINT sm_post_vote_user_fk_2
  FOREIGN KEY (account_user_id)
  REFERENCES account_user (id);

