BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_app_users START WITH 1';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF; 
END;
/

BEGIN
    EXECUTE IMMEDIATE '
CREATE TABLE app_users (
   id NUMBER(19) NOT NULL,
   uuid CHAR(32 CHAR) DEFAULT LOWER(SYS_GUID()) NOT NULL,
   status CHAR(1 CHAR) DEFAULT ''N'' NOT NULL,
   username VARCHAR2(240 CHAR) NOT NULL,
   password VARCHAR2(240 CHAR) NOT NULL,
   fullname VARCHAR2(240 CHAR) NOT NULL,
   created TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
   attempts NUMBER(10) DEFAULT 0 NOT NULL,
   accessed TIMESTAMP(6)
)
    ';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_users IS 'Table for storing and processing user data';
COMMENT ON COLUMN app_users.id IS 'Primary key';
COMMENT ON COLUMN app_users.uuid IS 'Unique user identifier';
COMMENT ON COLUMN app_users.status IS 'Status (A - active; D - disabled; N - uNverified)';
COMMENT ON COLUMN app_users.username IS 'Username';
COMMENT ON COLUMN app_users.password IS 'Password';
COMMENT ON COLUMN app_users.fullname IS 'Full name';
COMMENT ON COLUMN app_users.created IS 'Date and time when user was created';
COMMENT ON COLUMN app_users.attempts IS 'Number of authentication attempts';
COMMENT ON COLUMN app_users.accessed IS 'Date and time when user performed last successful login';

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE app_users ADD CONSTRAINT cpk_app_users PRIMARY KEY (id)';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE app_users ADD CONSTRAINT csc_app_users_status CHECK (status IN (''A'', ''D'', ''N''))';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-2264) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX idx_app_users_uuid ON app_users(uuid)';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX idx_app_users_username ON app_users(username)';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

DECLARE
    c_salt VARCHAR2(32 CHAR) := DBMS_RANDOM.STRING('X', 32);
    v_password app_users.password%TYPE := c_salt || DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(TRIM(:app_pass) || c_salt),4);
BEGIN
    UPDATE app_users SET
        username = UPPER(TRIM(:app_user)),
        password = v_password,
        fullname = 'Admin Admin' 
    WHERE id = 1;
    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO app_users(id, username, password, fullname) VALUES (
            seq_app_users.NEXTVAL,
            UPPER(TRIM(:app_user)), 
            v_password, 
            'Admin Admin'
        );
    END IF;
    COMMIT;
END;
/
