REM Nexus generated DML file

CREATE TABLE public.nexus_setting (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  module CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  key CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  value CHARACTER VARYING COLLATE pg_catalog."default",
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT nexus_setting_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

