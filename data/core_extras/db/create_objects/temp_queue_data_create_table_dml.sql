REM Nexus generated DML file

CREATE TEMPORARY TABLE temp_queue_data (
  temp_queue_data_id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  format CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  data_in CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  data_out CHARACTER VARYING COLLATE pg_catalog."default",
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  fulfilled TIMESTAMP WITH TIME ZONE NOT NULL)
TABLESPACE pg_default;

