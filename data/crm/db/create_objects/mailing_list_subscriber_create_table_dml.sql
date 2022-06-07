REM Nexus generated DML file

CREATE TABLE public.mailing_list_subscriber (
  mailing_list_subscriber_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  account_user_id BIGINT,
  mailing_list_id BIGINT NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  is_active BOOL NOT NULL,
  email CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  name CHARACTER VARYING COLLATE pg_catalog."default",
  verification_code CHARACTER VARYING COLLATE pg_catalog."default",
  is_verified BOOL NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT mailing_list_subscriber_pkey PRIMARY KEY (mailing_list_subscriber_id)
)
TABLESPACE pg_default;

