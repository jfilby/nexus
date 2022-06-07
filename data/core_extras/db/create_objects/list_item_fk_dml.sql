REM Nexus generated DML file

ALTER TABLE public.list_item
  ADD CONSTRAINT list_item_fk_1
  FOREIGN KEY (parent_list_item_id)
  REFERENCES list_item (list_item_id);

