REM Nexus generated DML file

ALTER TABLE public.sm_post
  ADD CONSTRAINT sm_post_fk_1
  FOREIGN KEY (id)
  REFERENCES sm_post (parent_id);

