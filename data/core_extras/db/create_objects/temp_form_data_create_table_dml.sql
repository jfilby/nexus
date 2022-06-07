REM Nexus generated DML file

CREATE TEMPORARY TABLE temp_form_data (
  token CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  format CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  data CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT temp_form_data_pkey PRIMARY KEY (token)
)
TABLESPACE pg_default;

