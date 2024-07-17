CREATE OR REPLACE PACKAGE BODY pck_api_i18n AS

    FUNCTION t(
        p_text app_i18n.text%TYPE,
        p_lang app_i18n.lang%TYPE DEFAULT 'en',
        p_correction app_i18n.correction%TYPE DEFAULT NULL
    ) RETURN app_i18n.translation%TYPE
    AS
        v_text app_i18n.text%TYPE;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        IF p_correction IS NOT NULL THEN
            UPDATE app_i18n SET correction = p_correction, modified = SYSTIMESTAMP WHERE text LIKE p_text AND lang = p_lang;
            IF SQL%ROWCOUNT = 0 THEN
                INSERT INTO app_i18n (lang, text, correction) VALUES (p_lang, p_text, p_correction);
            END IF;
            COMMIT;
        END IF;

        BEGIN
            SELECT COALESCE(correction, translation, text) INTO v_text FROM app_i18n WHERE text LIKE p_text AND lang = p_lang;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
            BEGIN
                INSERT INTO app_i18n (lang, text, correction) VALUES (p_lang, p_text, p_correction);
                COMMIT;
                v_text := p_text;
            END;
        END;

        RETURN v_text;

    END;

    PROCEDURE job_i18n
    AS
        v_service_provider VARCHAR2(200 CHAR);
        v_api_key VARCHAR2(200 CHAR);
        v_batch_size PLS_INTEGER;
        v_translation app_i18n.translation%TYPE;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        BEGIN
            SELECT content INTO v_service_provider FROM app_settings WHERE id = 'APP_I18N_SERVICE_PROVIDER';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;

        SELECT content INTO v_batch_size FROM app_settings WHERE id = 'APP_I18N_BATCH_SIZE';
        SELECT content INTO v_api_key FROM app_settings WHERE id = 'APP_OPENAI_API_KEY';

        FOR t IN (
            SELECT text, lang
            FROM app_i18n
            WHERE translation IS NULL
            FETCH NEXT v_batch_size ROWS ONLY
        ) LOOP

            IF v_service_provider = 'openai' THEN

                pck_api_openai.completion( 
                    v_api_key, 
                    'gpt-4-turbo',
                    'Translate provided text to ' || UPPER(t.lang) || 'language',
                    t.text, 
                    v_translation 
                );

                UPDATE app_i18n SET translation = v_translation, modified = SYSTIMESTAMP WHERE text LIKE t.text AND lang = t.lang;

                COMMIT;

            END IF;    

        END LOOP;
    END;

END;
/
