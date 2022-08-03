REM Nexus generated DML file

ALTER TABLE account_user
  ADD CONSTRAINT account_user_uq_1 UNIQUE (email);

ALTER TABLE account_user
  ADD CONSTRAINT account_user_uq_2 UNIQUE (api_key);

ALTER TABLE account_user
  ADD CONSTRAINT account_user_uq_3 UNIQUE (last_token);

