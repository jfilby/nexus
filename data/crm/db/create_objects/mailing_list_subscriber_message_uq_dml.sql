REM Nexus generated DML file

ALTER TABLE mailing_list_subscriber_message
  ADD CONSTRAINT mailing_list_subscriber_message_uq_1 UNIQUE (mailing_list_subscriber_id, mailing_list_message_id);

