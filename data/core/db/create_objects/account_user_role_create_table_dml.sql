REM Nexus generated DML file

CREATE TABLE public.account_user_role (
  id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  account_user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT account_user_role_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

