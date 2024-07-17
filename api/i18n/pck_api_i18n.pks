CREATE OR REPLACE PACKAGE pck_api_i18n AS -- Package provides translation services

    FUNCTION t( -- Translate text
        p_text app_i18n.text%TYPE, -- Text to translate
        p_lang app_i18n.lang%TYPE DEFAULT 'en',  -- Language, 2 letter code from ISO-639
        p_correction app_i18n.correction%TYPE DEFAULT NULL -- Correction, if translation is incorrect override and save manual correction
    ) RETURN app_i18n.translation%TYPE; -- Translated text

    PROCEDURE job_i18n; -- Job to translate all text via translation service provider

END;
/
