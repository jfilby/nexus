REM Nexus generated DML file

ALTER TABLE public.invite
  ADD CONSTRAINT invite_fk_1
  FOREIGN KEY (from_account_user_id)
  REFERENCES account_user (id);

