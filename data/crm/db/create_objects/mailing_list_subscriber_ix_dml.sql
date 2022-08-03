REM Nexus generated DML file

CREATE UNIQUE INDEX mailing_list_subscriber_ix_1
    ON mailing_list_subscriber (account_user_id);

CREATE UNIQUE INDEX mailing_list_subscriber_ix_2
    ON mailing_list_subscriber (email);

CREATE UNIQUE INDEX mailing_list_subscriber_ix_3
    ON mailing_list_subscriber (unique_hash);

