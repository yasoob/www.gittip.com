BEGIN;
    CREATE TYPE usage_type AS ENUM ('notifications', 'gravatar', 'paypal');
    CREATE TYPE email_address_with_confirmation AS 
    (
        address text,
        confirmed boolean
    );

    ALTER TABLE participants ADD email_notifications email_address_with_confirmation DEFAULT NULL;
    ALTER TABLE participants ADD email_gravatar email_address_with_confirmation DEFAULT NULL;
    ALTER TABLE participants ADD email_paypal email_address_with_confirmation DEFAULT NULL;

    CREATE TABLE emails
    (
        id serial PRIMARY KEY,
        email email_address_with_confirmation NOT NULL,
        ctime timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
        usage usage_type NOT NULL,
        participant text NOT NULL REFERENCES participants ON UPDATE CASCADE ON DELETE RESTRICT
    );


    CREATE RULE log_notification_email_changes AS ON UPDATE
        TO participants WHERE (OLD.email_notifications IS NULL AND NOT NEW.email_notifications IS NULL)
                        OR (NEW.email_notifications IS NULL AND NOT OLD.email_notifications IS NULL)
                        OR NEW.email_notifications <> OLD.email_notifications
        DO INSERT INTO emails (email, usage, participant)
            VALUES (NEW.email_notifications, 'notifications', OLD.username);

    CREATE RULE log_gravatar_email_changes AS ON UPDATE
        TO participants WHERE (OLD.email_gravatar IS NULL AND NOT NEW.email_gravatar IS NULL)
                        OR (NEW.email_gravatar IS NULL AND NOT OLD.email_gravatar IS NULL)
                        OR NEW.email_gravatar <> OLD.email_gravatar
        DO INSERT INTO emails (email, usage, participant)
            VALUES (NEW.email_gravatar, 'gravatar', OLD.username);

    CREATE RULE log_paypal_email_changes AS ON UPDATE
        TO participants WHERE (OLD.email_paypal IS NULL AND NOT NEW.email_paypal IS NULL)
                        OR (NEW.email_paypal IS NULL AND NOT OLD.email_paypal IS NULL)
                        OR NEW.email_paypal <> OLD.email_paypal
        DO INSERT INTO emails (email, usage, participant)
            VALUES (NEW.email_paypal, 'paypal', OLD.username);

END;
