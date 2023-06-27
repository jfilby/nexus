REM Nexus generated DML file

CREATE TABLE public.mailing_list_subscriber_message (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  account_user_id CHARACTER VARYING COLLATE pg_catalog."default",
  mailing_list_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  mailing_list_subscriber_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  mailing_list_message_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT mailing_list_subscriber_message_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

