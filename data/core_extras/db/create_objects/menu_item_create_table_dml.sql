REM Nexus generated DML file

CREATE TABLE public.menu_item (
  id CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL UNIQUE,
  parent_id CHARACTER VARYING COLLATE pg_catalog."default",
  name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  url CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  screen CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  level INT NOT NULL,
  position INT NOT NULL,
  role_ids CHARACTER VARYING[] COLLATE pg_catalog."default",
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT menu_item_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

