REM Nexus generated DML file

CREATE TABLE public.cached_key_value (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  key CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  value CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  updated TIMESTAMP WITH TIME ZONE,
  expires TIMESTAMP WITH TIME ZONE,
  CONSTRAINT cached_key_value_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

