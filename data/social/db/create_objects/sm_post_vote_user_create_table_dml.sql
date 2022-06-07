REM Nexus generated DML file

CREATE TABLE public.sm_post_vote_user (
  sm_post_id BIGINT NOT NULL,
  account_user_id BIGINT NOT NULL,
  vote_up BOOL NOT NULL,
  vote_down BOOL NOT NULL,
  CONSTRAINT sm_post_vote_user_pkey PRIMARY KEY (sm_post_id, account_user_id)
)
TABLESPACE pg_default;

