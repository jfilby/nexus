REM Nexus generated DML file

CREATE TABLE public.sm_post_vote (
  sm_post_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  votes_up_count INT NOT NULL,
  votes_down_count INT NOT NULL,
  CONSTRAINT sm_post_vote_pkey PRIMARY KEY (sm_post_id)
)
TABLESPACE pg_default;

