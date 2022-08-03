REM Nexus generated DML file

ALTER TABLE invite
  ADD CONSTRAINT invite_uq_1 UNIQUE (to_email);

