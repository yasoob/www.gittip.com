ALTER TABLE participants ADD email_address text DEFAULT NULL;
ALTER TABLE participants ADD email_confirmed boolean NOT NULL DEFAULT FALSE;
ALTER TABLE participants ADD email_collected timestamp with time zone DEFAULT NULL;
