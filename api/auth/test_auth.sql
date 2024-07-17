DECLARE
    v_uuid app_users.uuid%TYPE;
    v_token app_tokens.token%TYPE;
BEGIN
    pck_api_auth.auth(:app_user, :app_pass, v_uuid);
    IF v_uuid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Authentication test failed');
    END IF;
    pck_api_auth.reset(v_uuid);
    v_token := pck_api_auth.token(v_uuid, 'A');
    IF (pck_api_auth.priv(v_uuid, NULL) <> v_uuid) THEN
        RAISE_APPLICATION_ERROR(-20000, 'Authorization test failed');
    END IF;
    IF (pck_api_auth.priv(v_uuid, 'admin') <> 'Y') THEN
        RAISE_APPLICATION_ERROR(-20000, 'Authorization test failed');
    END IF;
    pck_api_auth.reset(v_uuid);
END;
/
