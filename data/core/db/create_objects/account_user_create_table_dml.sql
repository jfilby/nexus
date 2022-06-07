REM Nexus generated DML file

CREATE TABLE public.account_user (
  account_user_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  account_id BIGINT,
  name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  email CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  password_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  password_salt CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  api_key CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  last_token CHARACTER VARYING COLLATE pg_catalog."default",
  sign_up_code CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  sign_up_date TIMESTAMP WITH TIME ZONE NOT NULL,
  password_reset_code CHARACTER VARYING COLLATE pg_catalog."default",
  password_reset_date TIMESTAMP WITH TIME ZONE,
  is_active BOOL NOT NULL,
  is_admin BOOL NOT NULL,
  is_verified BOOL NOT NULL,
  subscription_status CHAR,
  last_login TIMESTAMP WITH TIME ZONE,
  last_update TIMESTAMP WITH TIME ZONE,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT account_user_pkey PRIMARY KEY (account_user_id)
)
TABLESPACE pg_default;

