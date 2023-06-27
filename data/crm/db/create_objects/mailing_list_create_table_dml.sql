REM Nexus generated DML file

CREATE TABLE public.mailing_list (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  account_user_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT mailing_list_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

