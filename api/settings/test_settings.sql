DECLARE
    c_id app_settings.id%TYPE := 'APP_TEST';
    c_v app_settings.content%TYPE := 'Test value';
    v_v app_settings.content%TYPE;
BEGIN
    pck_api_settings.write(c_id, c_v);
    pck_api_settings.read(c_id, v_v);   
    IF v_v <> c_v THEN
        RAISE_APPLICATION_ERROR(-20000, 'Settings test failed');
    END IF;
    ROLLBACK;
END;
/
