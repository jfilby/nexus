REM Nexus generated DML file

ALTER TABLE public.menu_item
  ADD CONSTRAINT menu_item_fk_1
  FOREIGN KEY (parent_menu_item_id)
  REFERENCES menu_item (menu_item_id);

