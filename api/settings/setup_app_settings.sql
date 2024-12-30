BEGIN
    EXECUTE IMMEDIATE '
CREATE TABLE app_settings (
id VARCHAR2(30 CHAR) NOT NULL,
description VARCHAR2(2000 CHAR),
content VARCHAR2(2000 CHAR),
options CLOB
)
    ';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_settings IS 'Table for storing system parameters';
COMMENT ON COLUMN app_settings.id IS 'Primary key';
COMMENT ON COLUMN app_settings.description IS 'Parameter description';
COMMENT ON COLUMN app_settings.content IS 'Variable character value up to 2000 unicode characters';
COMMENT ON COLUMN app_settings.options IS 'Setting options in JSON format';

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE app_settings ADD CONSTRAINT cpk_app_settings PRIMARY KEY (id)';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE app_settings ADD CONSTRAINT csc_app_settings_options CHECK (options IS JSON)';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-2260, -40664) THEN RAISE; END IF;
END;
/

BEGIN
    UPDATE app_settings SET content = '0.3.2' WHERE id = 'APP_VERSION';
    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO app_settings (id, description, content) VALUES ('APP_VERSION', 'Oracle Database for Bullshti Bingo Releae', '0.3.2');
    END IF;
    COMMIT;
END;
/

BEGIN
    UPDATE app_settings SET content = :app_host WHERE id = 'APP_DOMAIN';
    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO app_settings (id, description, content) VALUES ('APP_DOMAIN', 'Application domain', :app_host);
    END IF;
    COMMIT;
END;
/
