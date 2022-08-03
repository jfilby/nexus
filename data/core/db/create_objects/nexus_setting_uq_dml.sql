REM Nexus generated DML file

ALTER TABLE nexus_setting
  ADD CONSTRAINT nexus_setting_uq_1 UNIQUE (module, key);

