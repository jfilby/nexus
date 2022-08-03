REM Nexus generated DML file

ALTER TABLE account_user_token
  ADD CONSTRAINT account_user_token_uq_1 UNIQUE (unique_hash);

ALTER TABLE account_user_token
  ADD CONSTRAINT account_user_token_uq_2 UNIQUE (token);

