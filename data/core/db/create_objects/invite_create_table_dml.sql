REM Nexus generated DML file

CREATE TABLE public.invite (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  from_account_user_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  from_email CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  from_name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  to_email CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  to_name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  sent TIMESTAMP WITH TIME ZONE,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT invite_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

