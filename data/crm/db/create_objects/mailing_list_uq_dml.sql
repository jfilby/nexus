REM Nexus generated DML file

ALTER TABLE mailing_list
  ADD CONSTRAINT mailing_list_uq_1 UNIQUE (unique_hash);

ALTER TABLE mailing_list
  ADD CONSTRAINT mailing_list_uq_2 UNIQUE (account_user_id, name);

