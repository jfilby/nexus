REM Nexus generated DML file

CREATE TABLE public.sm_post (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  parent_id CHARACTER VARYING COLLATE pg_catalog."default",
  account_user_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  post_type CHAR NOT NULL,
  status CHAR NOT NULL,
  title CHARACTER VARYING COLLATE pg_catalog."default",
  body CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  tag_ids CHARACTER VARYING COLLATE pg_catalog."default",
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  published TIMESTAMP WITH TIME ZONE,
  update_count INT NOT NULL,
  updated TIMESTAMP WITH TIME ZONE,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT sm_post_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

