REM Nexus generated DML file

CREATE TABLE public.menu_item (
  menu_item_id BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
  parent_menu_item_id BIGINT,
  name CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  url CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  screen CHARACTER VARYING COLLATE pg_catalog."default" NOT NULL,
  level INT NOT NULL,
  position INT NOT NULL,
  role_ids BIGINT[],
  created TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT menu_item_pkey PRIMARY KEY (menu_item_id)
)
TABLESPACE pg_default;

