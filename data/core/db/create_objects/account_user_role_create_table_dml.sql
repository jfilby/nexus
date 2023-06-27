REM Nexus generated DML file

CREATE TABLE public.account_user_role (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  account_user_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  role_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT account_user_role_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

