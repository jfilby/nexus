REM Nexus generated DML file

CREATE TABLE public.mailing_list_message (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  account_user_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  subject CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  message CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  updated TIMESTAMP WITH TIME ZONE,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT mailing_list_message_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

