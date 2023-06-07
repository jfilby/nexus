REM Nexus generated DML file

ALTER TABLE public.sm_post_vote
  ADD CONSTRAINT sm_post_vote_fk_1
  FOREIGN KEY (sm_post_id)
  REFERENCES sm_post (id);

