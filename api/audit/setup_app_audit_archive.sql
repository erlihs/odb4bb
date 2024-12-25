BEGIN
   EXECUTE IMMEDIATE '
CREATE TABLE app_audit_archive (
   id CHAR(32 CHAR) DEFAULT LOWER(SYS_GUID()) NOT NULL,
   uuid CHAR(32 CHAR),
   severity CHAR(1 CHAR) DEFAULT ''I'' NOT NULL,
   action VARCHAR2(2000 CHAR) NOT NULL,
   details VARCHAR2(2000 CHAR),
   stack VARCHAR2(2000 CHAR),
   created TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
   agent VARCHAR2(2000 CHAR),
   ip VARCHAR2(240 CHAR)
)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_audit_archive IS 'Table for storing and processing historical audit data';
COMMENT ON COLUMN app_audit_archive.id IS 'Primary key';
COMMENT ON COLUMN app_audit_archive.uuid IS 'Unique user identifier';
COMMENT ON COLUMN app_audit_archive.severity IS 'Severity level (D - debug, I - info, W - warning, E - error)';
COMMENT ON COLUMN app_audit_archive.action IS 'Activity that caused audit record';
COMMENT ON COLUMN app_audit_archive.details IS 'Detailed information';
COMMENT ON COLUMN app_audit_archive.created IS 'Date and time when audit record was created';
COMMENT ON COLUMN app_audit_archive.agent IS 'Browser agent';
COMMENT ON COLUMN app_audit_archive.ip IS 'IP address';

BEGIN
   EXECUTE IMMEDIATE '
ALTER TABLE app_audit_archive ADD CONSTRAINT pk_app_audit_archive PRIMARY KEY (id)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE ' 
ALTER TABLE app_audit_archive ADD CONSTRAINT csc_app_audit_archive_severity CHECK (severity IN (''D'', ''I'', ''W'', ''E''))
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260, -2264) THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE '
CREATE INDEX idx_app_audit_archive_created ON app_audit_archive(created)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

