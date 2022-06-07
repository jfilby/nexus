REM Nexus generated DML file

CREATE TABLE public.nexus_setting (
  nexus_setting_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  module CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  key CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  value CHARACTER VARYING COLLATE pg_catalog."default",
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT nexus_setting_pkey PRIMARY KEY (nexus_setting_id)
)
TABLESPACE pg_default;

