REM Nexus generated DML file

CREATE TABLE public.sm_post_vote_user (
  sm_post_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  account_user_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  vote_up BOOL NOT NULL,
  vote_down BOOL NOT NULL,
  CONSTRAINT sm_post_vote_user_pkey PRIMARY KEY (sm_post_id, account_user_id)
)
TABLESPACE pg_default;

