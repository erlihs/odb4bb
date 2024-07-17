-- app_emails

BEGIN
	EXECUTE IMMEDIATE '
CREATE SEQUENCE seq_app_emails START WITH 1
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

BEGIN
	EXECUTE IMMEDIATE '
CREATE TABLE app_emails (
    id NUMBER(19,0) NOT NULL,
    subject VARCHAR2(240 CHAR) NOT NULL,
    content CLOB,
    priority  NUMBER(1) DEFAULT 3 NOT NULL,
    status CHAR(1 CHAR) DEFAULT ''N'' NOT NULL,
    created TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    delivered TIMESTAMP,
    attempts NUMBER(10) DEFAULT 0 NOT NULL,
    postponed TIMESTAMP,
    error VARCHAR2(2000 CHAR)
)
LOB(content) STORE AS SECUREFILE(
   CACHE
   NOLOGGING
)
PARTITION BY LIST (status) (
   PARTITION emails_active VALUES(''N''),
   PARTITION emails_archive VALUES(''S'', ''E'')
)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_emails IS 'Table for storing and processing email data';
COMMENT ON COLUMN app_emails.id IS 'Primary key';
COMMENT ON COLUMN app_emails.subject IS 'Email subject';
COMMENT ON COLUMN app_emails.content IS 'Email content (HTML)';
COMMENT ON COLUMN app_emails.priority IS 'Email priority (1 - highest .. 9 - lowest)';
COMMENT ON COLUMN app_emails.status IS 'Status (N - not sent,  S - sent, E - error)';
COMMENT ON COLUMN app_emails.created IS 'Date and time when created';
COMMENT ON COLUMN app_emails.delivered IS 'Date and time when delivered';
COMMENT ON COLUMN app_emails.attempts IS 'Number  of senfing attempts';
COMMENT ON COLUMN app_emails.postponed IS 'Date and time until which  not to send again';
COMMENT ON COLUMN app_emails.error IS 'Error text';

BEGIN
	EXECUTE IMMEDIATE '
ALTER TABLE app_emails ENABLE ROW MOVEMENT
	';
END;
/

BEGIN
	EXECUTE IMMEDIATE '
ALTER TABLE app_emails ADD CONSTRAINT cpk_app_emails PRIMARY KEY (id)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/

BEGIN
	EXECUTE IMMEDIATE '
ALTER TABLE app_emails ADD CONSTRAINT csc_app_emails_status CHECK (status IN (''N'', ''S'', ''E''))
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-2260, -2264) THEN RAISE; END IF;
END;
/

-- app_emails_addr

BEGIN
	EXECUTE IMMEDIATE '
CREATE TABLE app_emails_addr (
   id_email NUMBER(19,0) NOT NULL,
   addr_type VARCHAR2(7 CHAR) NOT NULL,
   addr_addr VARCHAR2(240 CHAR) NOT NULL,
   addr_name VARCHAR2(240 CHAR)
)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_emails_addr IS 'Table for storing and processing email addressess';
COMMENT ON COLUMN app_emails_addr.id_email IS 'Email ID';
COMMENT ON COLUMN app_emails_addr.addr_type IS 'Address type (From, ReplyTo, To, Cc, Bcc)';
COMMENT ON COLUMN app_emails_addr.addr_addr IS 'Email address';
COMMENT ON COLUMN app_emails_addr.addr_name IS 'Email address name';

BEGIN
	EXECUTE IMMEDIATE '
ALTER TABLE app_emails_addr ADD CONSTRAINT cfk_app_emails_addr_id_email FOREIGN KEY (id_email) REFERENCES app_emails(id)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-2264, -2275) THEN RAISE; END IF;
END;
/

BEGIN
	EXECUTE IMMEDIATE '
ALTER TABLE app_emails_addr ADD CONSTRAINT csc_app_emails_addr_addr_type CHECK (addr_type IN (''From'', ''ReplyTo'', ''To'', ''Cc'', ''Bcc''))
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-2260, -2264) THEN RAISE; END IF;
END;
/

BEGIN
	EXECUTE IMMEDIATE '	
CREATE INDEX idx_app_emails_addr_id_email ON app_emails_addr(id_email)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

BEGIN
	EXECUTE IMMEDIATE '
CREATE UNIQUE INDEX idx_app_emails_addr_unique ON app_emails_addr(id_email, addr_type, addr_addr)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

-- app_emails_attc

BEGIN
	EXECUTE IMMEDIATE '
CREATE TABLE app_emails_attc (
   id_email NUMBER(19,0) NOT NULL,
   file_name VARCHAR2(240 CHAR) NOT NULL,
   file_data BLOB NOT NULL
)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_emails_attc IS 'Table for storing and processing email attachments';
COMMENT ON COLUMN app_emails_attc.id_email IS 'Email ID';
COMMENT ON COLUMN app_emails_attc.file_name IS 'Attachment name';
COMMENT ON COLUMN app_emails_attc.file_data IS 'Attachment data';

BEGIN
	EXECUTE IMMEDIATE '
ALTER TABLE app_emails_attc ADD CONSTRAINT cfk_app_emails_attc_id_email FOREIGN KEY (id_email) REFERENCES app_emails(id)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-2264, -2275) THEN RAISE; END IF;
END;
/

-- app_emails_settings

BEGIN
	EXECUTE IMMEDIATE '
CREATE TABLE app_emails_settings (
    smtp_host VARCHAR2(2000 CHAR),
    smtp_port NUMBER(10),
    smtp_cred VARCHAR2(2000 CHAR),
    from_addr VARCHAR2(2000 CHAR),
    from_name VARCHAR2(2000 CHAR),
    replyto_addr VARCHAR2(2000 CHAR),
    replyto_name VARCHAR2(2000 CHAR),
    batch_limit NUMBER(10)
)	
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_emails_settings IS 'Table for storing and processing email settings';
COMMENT ON COLUMN app_emails_settings.smtp_host IS 'SMTP server host';
COMMENT ON COLUMN app_emails_settings.smtp_port IS 'SMTP server port';
COMMENT ON COLUMN app_emails_settings.smtp_cred IS 'SMTP server credentials';
COMMENT ON COLUMN app_emails_settings.from_addr IS 'Default email address';
COMMENT ON COLUMN app_emails_settings.from_name IS 'Default email name';
COMMENT ON COLUMN app_emails_settings.replyto_addr IS 'Default reply-to email address';
COMMENT ON COLUMN app_emails_settings.replyto_name IS 'Default reply-to email name';
COMMENT ON COLUMN app_emails_settings.batch_limit IS 'Maximum number of emails to send in one batch';


MERGE INTO app_emails_settings t
USING (
	SELECT
		:app_user AS from_addr,
		:app_name AS from_name,
		:app_user AS replyto_addr,
		:app_name AS replyto_name,
		100 AS batch_limit
	FROM dual
) s
ON (t.from_addr = s.from_addr)
WHEN MATCHED THEN
	UPDATE SET t.from_name = s.from_name, t.replyto_addr = s.replyto_addr, t.replyto_name = s.replyto_name, t.batch_limit = s.batch_limit
WHEN NOT MATCHED THEN
	INSERT (from_addr, from_name, replyto_addr, replyto_name, batch_limit)
	VALUES ( s.from_addr, s.from_name, s.replyto_addr, s.replyto_name, 100);
	
COMMIT;
/
