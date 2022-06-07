REM Nexus generated DML file

CREATE TABLE public.mailing_list_subscriber_message (
  mailing_list_subscriber_message_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  account_user_id BIGINT,
  mailing_list_id BIGINT NOT NULL,
  mailing_list_subscriber_id BIGINT NOT NULL,
  mailing_list_message_id BIGINT NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT mailing_list_subscriber_message_pkey PRIMARY KEY (mailing_list_subscriber_message_id)
)
TABLESPACE pg_default;

