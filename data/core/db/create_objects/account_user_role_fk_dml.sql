REM Nexus generated DML file

ALTER TABLE public.account_user_role
  ADD CONSTRAINT account_user_role_fk_1
  FOREIGN KEY (account_user_id)
  REFERENCES account_user (account_user_id);

