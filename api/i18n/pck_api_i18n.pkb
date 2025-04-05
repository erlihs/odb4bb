CREATE OR REPLACE PACKAGE BODY pck_api_i18n AS

    PROCEDURE write(
        p_i18n CLOB
    ) AS 
    BEGIN

        FOR j IN (
            SELECT * FROM JSON_TABLE(p_i18n, '$[*]' COLUMNS (
                module VARCHAR2(4000) PATH '$.module',
                locale VARCHAR2(4000) PATH '$.locale',
                key VARCHAR2(4000) PATH '$.key',
                value CLOB PATH '$.value'
            ))
        ) LOOP

            UPDATE app_i18n
            SET value = j.value, modified = SYSTIMESTAMP, translation = NULL, correction = NULL
            WHERE module = j.module AND locale = j.locale AND key = j.key AND DBMS_LOB.COMPARE(value, j.value) <> 0;

            IF SQL%ROWCOUNT = 0 THEN
                BEGIN
                    INSERT INTO app_i18n (module, locale, key, value)
                    VALUES (j.module, j.locale, j.key, j.value);
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;
            END IF;

            COMMIT;

        END LOOP;

    END;

    PROCEDURE read(
        p_module VARCHAR2 DEFAULT NULL,
        p_locale VARCHAR2 DEFAULT NULL,
        r_i18n OUT CLOB
    ) AS
    BEGIN
        
        SELECT JSON_OBJECTAGG(locale, JSON_OBJECTAGG(key, COALESCE(correction, translation, value) RETURNING CLOB) RETURNING CLOB)
        INTO r_i18n
        FROM app_i18n
        WHERE (p_module IS NULL OR module = p_module)
        AND (p_locale IS NULL OR locale = p_locale)
        AND key IS NOT NULL
        GROUP BY locale;

    END;

    PROCEDURE job_i18n AS
        v_service_provider VARCHAR2(200 CHAR);
        v_model VARCHAR2(200 CHAR);
        v_api_key VARCHAR2(200 CHAR);
        v_batch_size PLS_INTEGER;
        v_cnt PLS_INTEGER := 0;
        v_translation app_i18n.translation%TYPE;
    BEGIN

        FOR l IN (
            SELECT DISTINCT locale
            FROM app_i18n
        ) LOOP

            FOR k IN (
                SELECT module, key, value
                FROM app_i18n
                WHERE locale <> l.locale
            ) LOOP

                BEGIN
                    INSERT INTO app_i18n (module, locale, key, value)
                    VALUES (k.module, l.locale, k.key, k.value);
                    COMMIT;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL;
                END;

            END LOOP;

        END LOOP;

        BEGIN
            SELECT content INTO v_service_provider FROM app_settings WHERE id = 'APP_I18N_SERVICE_PROVIDER';
            SELECT content INTO v_model FROM app_settings WHERE id = 'APP_I18N_MODEL';
            SELECT content INTO v_batch_size FROM app_settings WHERE id = 'APP_I18N_BATCH_SIZE';
            SELECT content INTO v_api_key FROM app_settings WHERE id = 'APP_I18N_API_KEY';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                DBMS_OUTPUT.PUT_LINE('Parameters not found for i18n: APP_I18N_SERVICE_PROVIDER, APP_I18N_MODEL, APP_I18N_BATCH_SIZE, APP_I18N_API_KEY');
                RETURN;
        END;

        FOR t IN (
            SELECT module, locale, value
            FROM app_i18n
            WHERE translation IS NULL
            FETCH NEXT v_batch_size ROWS ONLY
        ) LOOP

            IF v_service_provider = 'openai' THEN

                pck_api_openai.completion( 
                    v_api_key, 
                    v_model,
                    'Translate provided text to ' || UPPER(t.locale) || 'language. Output just translation, nothing else. Avoid any didactic or explanatory text.',
                    t.value, 
                    v_translation 
                );

                UPDATE app_i18n 
                SET translation = v_translation, modified = SYSTIMESTAMP 
                WHERE module = t.module AND locale = t.locale AND DBMS_LOB.COMPARE(value, t.value) = 0;

                COMMIT;

                v_cnt := v_cnt + 1;

            END IF;    

        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Translated ' || v_cnt || ' texts via ' || v_service_provider || ' - ' || v_model);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in job_i18n: ' || SQLERRM);    
    END;

END;
/
