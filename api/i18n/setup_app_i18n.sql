BEGIN
    EXECUTE IMMEDIATE '
CREATE TABLE app_i18n (
    text CLOB NOT NULL,
    lang CHAR(2 CHAR) NOT NULL,
    translation CLOB,
    correction CLOB,
    created TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified TIMESTAMP
)
    ';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_i18n IS 'Table for storing and processing internationalization data';
COMMENT ON COLUMN app_i18n.text IS 'Original text (en)';
COMMENT ON COLUMN app_i18n.lang IS 'Language code';
COMMENT ON COLUMN app_i18n.translation IS 'Translated text';
COMMENT ON COLUMN app_i18n.correction IS 'Correction text';
COMMENT ON COLUMN app_i18n.created IS 'Date and time when created';
COMMENT ON COLUMN app_i18n.modified IS 'Date and time when modified';

BEGIN
    EXECUTE IMMEDIATE 'GRANT CREATE ANY INDEX TO  ' || :schema_name;
    EXECUTE IMMEDIATE 'GRANT CREATE ANY TABLE TO  ' || :schema_name;
    BEGIN
        EXECUTE IMMEDIATE '
CREATE SEARCH INDEX sdx_app_i18n ON app_i18n (text)
        '; -- this works only starting from 23ai
    EXCEPTION
        WHEN OTHERS THEN IF SQLCODE NOT IN (-955, -922) THEN RAISE; END IF;
    END;
    EXECUTE IMMEDIATE 'REVOKE CREATE ANY INDEX FROM ' || :schema_name;
    EXECUTE IMMEDIATE 'REVOKE CREATE ANY TABLE FROM ' || :schema_name;
END;
/

BEGIN
    EXECUTE IMMEDIATE '
CREATE BITMAP INDEX idx_app_i18n_lang ON app_i18n (lang)
    ';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

MERGE INTO app_settings USING DUAL ON (id = 'APP_I18N_SERVICE_PROVIDER')
WHEN MATCHED THEN UPDATE SET content = 'openai'
WHEN NOT MATCHED THEN INSERT (id, content, description) VALUES ('APP_I18N_SERVICE_PROVIDER', 'openai', 'Translation service provider');

MERGE INTO app_settings USING DUAL ON (id = 'APP_I18N_BATCH_SIZE')
WHEN MATCHED THEN UPDATE SET content = '1000'
WHEN NOT MATCHED THEN INSERT (id, content, description) VALUES ('APP_I18N_BATCH_SIZE', '1000', 'Batch size for processing translations');

COMMIT;
/
