REM Nexus generated DML file

ALTER TABLE account_user_role
  ADD CONSTRAINT account_user_role_uq_1 UNIQUE (account_user_id, role_id);

