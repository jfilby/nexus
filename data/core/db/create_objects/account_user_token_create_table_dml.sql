REM Nexus generated DML file

CREATE TABLE public.account_user_token (
  account_user_id BIGINT NOT NULL,
  unique_hash CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  token CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  deleted TIMESTAMP WITH TIME ZONE,
  CONSTRAINT account_user_token_pkey PRIMARY KEY (account_user_id)
)
TABLESPACE pg_default;

