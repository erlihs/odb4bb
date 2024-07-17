CREATE OR REPLACE PACKAGE BODY pck_api_settings AS -- Package provides methods for managing application settings 

    PROCEDURE write( 
        p_id app_settings.id%TYPE, 
        p_content app_settings.content%TYPE, 
        p_description app_settings.description%TYPE DEFAULT NULL 
    ) AS 
    BEGIN
        UPDATE app_settings SET content = p_content, description = NVL(p_description, description) WHERE id = p_id;
        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO app_settings (id, content, description) VALUES (p_id, p_content, p_description);
        END IF;
    END;

    PROCEDURE read( 
        p_id app_settings.id%TYPE, 
        r_content OUT app_settings.content%TYPE 
    ) AS
    BEGIN
        SELECT content INTO r_content FROM app_settings WHERE id = p_id;
    END;

    FUNCTION read(
        p_id app_settings.id%TYPE 
    ) RETURN app_settings.content%TYPE
    AS
        r_content app_settings.content%TYPE;
    BEGIN
        read(p_id, r_content);
        RETURN r_content;
    END; 

    PROCEDURE remove( 
        p_id app_settings.id%TYPE 
    ) AS
    BEGIN
        DELETE FROM app_settings WHERE id = p_id;
    END;

END;
/
