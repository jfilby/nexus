REM Nexus generated DML file

CREATE TEMPORARY TABLE temp_queue_data (
  temp_queue_data_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  format CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  data_in CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  data_out CHARACTER VARYING COLLATE pg_catalog."default",
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  fulfilled TIMESTAMP WITH TIME ZONE NOT NULL)
TABLESPACE pg_default;

