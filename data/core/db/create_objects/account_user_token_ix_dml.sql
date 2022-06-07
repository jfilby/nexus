REM Nexus generated DML file

CREATE UNIQUE INDEX account_user_token_ix_1
  ON account_user_token (unique_hash);

CREATE UNIQUE INDEX account_user_token_ix_2
  ON account_user_token (token);

