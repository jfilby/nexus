REM Nexus generated DML file

ALTER TABLE public.menu_item
  ADD CONSTRAINT menu_item_fk_1
  FOREIGN KEY (parent_id)
  REFERENCES menu_item (id);

