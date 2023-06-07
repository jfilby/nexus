REM Nexus generated DML file

CREATE TABLE public.list_item (
  id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  parent_id BIGINT,
  seq_no INT NOT NULL,
  name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  display_name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  description CHARACTER VARYING COLLATE pg_catalog."default",
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT list_item_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

