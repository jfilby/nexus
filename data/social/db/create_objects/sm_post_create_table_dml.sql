REM Nexus generated DML file

CREATE TABLE public.sm_post (
  sm_post_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  sm_post_parent_id BIGINT,
  account_user_id BIGINT NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  post_type CHAR NOT NULL,
  status CHAR NOT NULL,
  title CHARACTER VARYING COLLATE pg_catalog."default",
  body CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  tag_ids BIGINT,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  published TIMESTAMP WITH TIME ZONE,
  update_count INT NOT NULL,
  updated TIMESTAMP WITH TIME ZONE,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT sm_post_pkey PRIMARY KEY (sm_post_id)
)
TABLESPACE pg_default;

