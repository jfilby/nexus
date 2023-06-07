REM Nexus generated DML file

ALTER TABLE public.mailing_list_subscriber_message
  ADD CONSTRAINT mailing_list_subscriber_message_fk_1
  FOREIGN KEY (mailing_list_id)
  REFERENCES mailing_list (id);

ALTER TABLE public.mailing_list_subscriber_message
  ADD CONSTRAINT mailing_list_subscriber_message_fk_2
  FOREIGN KEY (account_user_id)
  REFERENCES account_user (id);

