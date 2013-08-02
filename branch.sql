BEGIN;
    CREATE TYPE email_address_with_confirmation AS
    (
        address text,
        confirmed boolean
    );

    ALTER TABLE participants ADD email email_address_with_confirmation
        DEFAULT NULL;

    CREATE TABLE emails
    ( id            serial                          PRIMARY KEY
    , email         email_address_with_confirmation NOT NULL
    , ctime         timestamp with time zone        NOT NULL
                                                     DEFAULT CURRENT_TIMESTAMP
    , participant   text                            NOT NULL
                                                     REFERENCES participants
                                                     ON UPDATE CASCADE
                                                     ON DELETE RESTRICT
    );


    CREATE RULE log_email_changes AS ON UPDATE
        TO participants WHERE (OLD.email_notifications IS NULL AND NOT NEW.email_notifications IS NULL)
                        OR (NEW.email_notifications IS NULL AND NOT OLD.email_notifications IS NULL)
                        OR NEW.email_notifications <> OLD.email_notifications
        DO INSERT INTO emails (email, usage, participant)
            VALUES (NEW.email_notifications, 'notifications', OLD.username);

END;
