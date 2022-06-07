REM Nexus generated DML file

CREATE TABLE public.invite (
  invite_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  from_account_user_id BIGINT NOT NULL,
  from_email CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  from_name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  to_email CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  to_name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  sent TIMESTAMP WITH TIME ZONE,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT invite_pkey PRIMARY KEY (invite_id)
)
TABLESPACE pg_default;

