DECLARE
    v_cnt PLS_INTEGER;
BEGIN

    SELECT COUNT(username) INTO v_cnt FROM all_users WHERE username = UPPER(:schema_name);

    IF v_cnt < 1 THEN

        EXECUTE IMMEDIATE 'CREATE USER ' || UPPER(:schema_name) || ' IDENTIFIED BY ' || CHR(34) || :schema_pass || CHR(34) || ' DEFAULT TABLESPACE data TEMPORARY TABLESPACE temp PROFILE DEFAULT ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || UPPER(:schema_name) || '';
        EXECUTE IMMEDIATE 'ALTER USER ' || UPPER(:schema_name) || ' QUOTA UNLIMITED ON data';

        EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_CRYPTO TO ' || UPPER(:schema_name) || '';

        ORDS.enable_schema(
            p_enabled             => TRUE,
            p_schema              => :schema_name,
            p_url_mapping_type    => 'BASE_PATH',
            p_url_mapping_pattern => :schema_name,
            p_auto_rest_auth      => FALSE
        );

        COMMIT;

    END IF;

END;
/
