REM Nexus generated DML file

CREATE TABLE public.mailing_list_subscriber (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  account_user_id CHARACTER VARYING COLLATE pg_catalog."default",
  mailing_list_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  is_active BOOL NOT NULL,
  email CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  name CHARACTER VARYING COLLATE pg_catalog."default",
  verification_code CHARACTER VARYING COLLATE pg_catalog."default",
  is_verified BOOL NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT mailing_list_subscriber_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

