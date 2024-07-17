CREATE OR REPLACE PACKAGE pck_api_settings AS -- Package provides methods for managing application settings 

    PROCEDURE write( -- Procedure sets value of the setting with the specified id
        p_id app_settings.id%TYPE, -- Id of the setting
        p_content app_settings.content%TYPE, -- Value of the setting (variable character)
        p_description app_settings.description%TYPE DEFAULT NULL -- Description of the setting
    );

    PROCEDURE read( -- Procedure returns value of the setting with the specified id
        p_id app_settings.id%TYPE, -- Id of the setting
        r_content OUT app_settings.content%TYPE -- Value of the setting (variable character)
    );

    FUNCTION read(-- Function returns value of the setting with the specified id
        p_id app_settings.id%TYPE -- Id of the setting
    ) RETURN app_settings.content%TYPE; -- Value of the setting (variable character)

    PROCEDURE remove( -- Procedure deletes setting with the specified id
        p_id app_settings.id%TYPE -- Id of the setting
    );

END;
/
