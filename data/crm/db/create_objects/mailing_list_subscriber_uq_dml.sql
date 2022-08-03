REM Nexus generated DML file

ALTER TABLE mailing_list_subscriber
  ADD CONSTRAINT mailing_list_subscriber_uq_1 UNIQUE (unique_hash);

ALTER TABLE mailing_list_subscriber
  ADD CONSTRAINT mailing_list_subscriber_uq_2 UNIQUE (mailing_list_id, account_user_id);

ALTER TABLE mailing_list_subscriber
  ADD CONSTRAINT mailing_list_subscriber_uq_3 UNIQUE (mailing_list_id, email);

