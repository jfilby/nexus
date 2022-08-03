REM Nexus generated DML file

ALTER TABLE menu_item
  ADD CONSTRAINT menu_item_uq_1 UNIQUE (name, url, screen);

