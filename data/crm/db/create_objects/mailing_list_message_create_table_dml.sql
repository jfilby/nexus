REM Nexus generated DML file

CREATE TABLE public.mailing_list_message (
  mailing_list_message_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  account_user_id BIGINT NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  subject CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  message CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  updated TIMESTAMP WITH TIME ZONE,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT mailing_list_message_pkey PRIMARY KEY (mailing_list_message_id)
)
TABLESPACE pg_default;

