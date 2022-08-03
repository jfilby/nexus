REM Nexus generated DML file

ALTER TABLE mailing_list_message
  ADD CONSTRAINT mailing_list_message_uq_1 UNIQUE (unique_hash);

