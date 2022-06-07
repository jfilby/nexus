REM Nexus generated DML file

ALTER TABLE public.sm_post
  ADD CONSTRAINT sm_post_fk_1
  FOREIGN KEY (sm_post_id)
  REFERENCES sm_post (sm_post_parent_id);

