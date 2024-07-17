BEGIN
   EXECUTE IMMEDIATE '
CREATE TABLE app_audit (
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

COMMENT ON TABLE app_audit IS 'Table for storing and processing audit data';
COMMENT ON COLUMN app_audit.id IS 'Primary key';
COMMENT ON COLUMN app_audit.uuid IS 'Unique user identifier';
COMMENT ON COLUMN app_audit.severity IS 'Severity level (D - debug, I - info, W - warning, E - error)';
COMMENT ON COLUMN app_audit.action IS 'Activity that caused audit record';
COMMENT ON COLUMN app_audit.details IS 'Detailed information';
COMMENT ON COLUMN app_audit.created IS 'Date and time when audit record was created';
COMMENT ON COLUMN app_audit.agent IS 'Browser agent';
COMMENT ON COLUMN app_audit.ip IS 'IP address';

BEGIN
   EXECUTE IMMEDIATE '
ALTER TABLE app_audit ADD CONSTRAINT pk_app_audit PRIMARY KEY (id)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE ' 
ALTER TABLE app_audit ADD CONSTRAINT csc_app_audit_severity CHECK (severity IN (''D'', ''I'', ''W'', ''E''))
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260, -2264) THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE '
CREATE INDEX idx_app_audit_uuid ON app_audit(uuid)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE '
CREATE INDEX idx_app_audit_created ON app_audit(created)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

DECLARE
   v_cnt PLS_INTEGER;
BEGIN
   SELECT COUNT(id) INTO v_cnt FROM app_audit;
   IF v_cnt = 0 THEN
      INSERT INTO app_audit (action) VALUES ('Database created');
      COMMIT;
   END IF;
END;
/
