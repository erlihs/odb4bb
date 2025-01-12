CREATE OR REPLACE PACKAGE pck_api_i18n AS -- Package provides translation services

    PROCEDURE write( -- Add text for translation
        p_i18n CLOB -- Texts to translate [{module, locale, key, value}]
    );

    PROCEDURE read( -- Get translated text
        p_module VARCHAR2 DEFAULT NULL, -- Module name
        p_locale VARCHAR2 DEFAULT NULL, -- Locale
        r_i18n OUT CLOB -- Translated texts {"locale":{"key", "value"}}
    );

    PROCEDURE job_i18n; -- Job to translate all text via translation service provider

END;
/
