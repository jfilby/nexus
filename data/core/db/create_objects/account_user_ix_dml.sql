REM Nexus generated DML file

CREATE UNIQUE INDEX account_user_ix_1
    ON account_user (email);

CREATE UNIQUE INDEX account_user_ix_2
    ON account_user (api_key);

CREATE UNIQUE INDEX account_user_ix_3
    ON account_user (last_token);

