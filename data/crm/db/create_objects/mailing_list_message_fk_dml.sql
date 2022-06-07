REM Nexus generated DML file

ALTER TABLE public.mailing_list_message
  ADD CONSTRAINT mailing_list_message_fk_1
  FOREIGN KEY (account_user_id)
  REFERENCES account_user (account_user_id);

