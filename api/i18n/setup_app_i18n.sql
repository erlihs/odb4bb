BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE app_i18n';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-942) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE '
CREATE TABLE app_i18n (
    module VARCHAR2(200 CHAR),
    locale VARCHAR2(2 CHAR) NOT NULL,
    key VARCHAR2(200 CHAR),
    value CLOB,
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
COMMENT ON COLUMN app_i18n.module IS 'Module name';
COMMENT ON COLUMN app_i18n.locale IS 'Locale code';
COMMENT ON COLUMN app_i18n.key IS 'Key for the text';
COMMENT ON COLUMN app_i18n.value IS 'Original text (en)';
COMMENT ON COLUMN app_i18n.translation IS 'Translated text';
COMMENT ON COLUMN app_i18n.correction IS 'Correction text';
COMMENT ON COLUMN app_i18n.created IS 'Date and time when created';
COMMENT ON COLUMN app_i18n.modified IS 'Date and time when modified';
 

BEGIN
    EXECUTE IMMEDIATE '
CREATE UNIQUE INDEX idx_app_i18n_module_locale_key ON app_i18n (module, locale, key)
    ';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/


BEGIN
    EXECUTE IMMEDIATE '
CREATE INDEX idx_app_i18n_module_locale ON app_i18n (module, locale)
    ';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

BEGIN

    MERGE INTO app_settings USING DUAL ON (id = 'APP_I18N_SERVICE_PROVIDER')
    WHEN MATCHED THEN UPDATE SET content = 'openai'
    WHEN NOT MATCHED THEN INSERT (id, content, description) VALUES ('APP_I18N_SERVICE_PROVIDER', 'openai', 'Translation service provider');

    MERGE INTO app_settings USING DUAL ON (id = 'APP_I18N_MODEL')
    WHEN MATCHED THEN UPDATE SET content = 'gpt-4o-mini-2024-07-18'
    WHEN NOT MATCHED THEN INSERT (id, content, description) VALUES ('APP_I18N_MODEL', 'gpt-4o-mini-2024-07-18', 'Translation service model');

    MERGE INTO app_settings USING DUAL ON (id = 'APP_I18N_BATCH_SIZE')
    WHEN MATCHED THEN UPDATE SET content = '1000'
    WHEN NOT MATCHED THEN INSERT (id, content, description) VALUES ('APP_I18N_BATCH_SIZE', '1000', 'Batch size for processing translations');

    MERGE INTO app_settings USING DUAL ON (id = 'APP_I18N_API_KEY')
    WHEN MATCHED THEN UPDATE SET content = ''
    WHEN NOT MATCHED THEN INSERT (id, content, description) VALUES ('APP_I18N_API_KEY', '', 'Api key for processing translations.');

    COMMIT;
    
END;
/

BEGIN
    pck_api_jobs.add('i18n','pck_api_i18n.job_i18n', '', '', 'Job does AI translation.');
END;
/
