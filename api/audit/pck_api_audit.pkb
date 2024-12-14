CREATE OR REPLACE PACKAGE BODY pck_api_audit AS

    FUNCTION log ( 
        p_uuid app_audit.uuid%TYPE,
        p_severity app_audit.severity%TYPE,
        p_action app_audit.action%TYPE,
        p_details app_audit.details%TYPE,
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP
    ) RETURN app_audit.id%TYPE
    AS
        v_stack VARCHAR2(2000) := SUBSTR(SQLERRM || CHR(10) || '-- ' || CHR(10) || dbms_utility.format_error_backtrace, 1, 2000);
        v_request VARCHAR2(2000);
        v_agent VARCHAR2(2000);
        v_ip VARCHAR2(2000);
        v_id app_audit.id%TYPE;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        BEGIN
            v_request := TRIM(owa_util.get_cgi_env('REQUEST_METHOD') || ' ' || owa_util.get_cgi_env('SCRIPT_NAME'));
            v_agent := TRIM(owa_util.get_cgi_env('HTTP_USER_AGENT'));
            v_ip := TRIM(owa_util.get_cgi_env('REMOTE_ADDR'));
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        INSERT INTO app_audit (uuid, severity, action, details, stack, agent, ip, created)
        VALUES (
            p_uuid, 
            p_severity, 
            p_action, 
            SUBSTR(CASE WHEN v_request IS NULL THEN NULL ELSE v_request || '?' END || p_details, 1,  2000),
            CASE WHEN p_severity = 'E' THEN v_stack ELSE NULL END,
            v_agent, 
            v_ip,
            p_created
        ) RETURNING id INTO v_id;

        COMMIT;

        RETURN v_id;

    END;

    FUNCTION mrg(
        p_key1 VARCHAR2 DEFAULT NULL,
        p_val1 VARCHAR2 DEFAULT NULL,
        p_key2 VARCHAR2 DEFAULT NULL,
        p_val2 VARCHAR2 DEFAULT NULL,
        p_key3 VARCHAR2 DEFAULT NULL,
        p_val3 VARCHAR2 DEFAULT NULL,
        p_key4 VARCHAR2 DEFAULT NULL,
        p_val4 VARCHAR2 DEFAULT NULL,
        p_key5 VARCHAR2 DEFAULT NULL,
        p_val5 VARCHAR2 DEFAULT NULL,
        p_key6 VARCHAR2 DEFAULT NULL,
        p_val6 VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2
    AS
        v PLS_INTEGER := 160;
    BEGIN
    
        RETURN
            CASE WHEN p_key1 IS NOT NULL THEN CHR(38) || SUBSTR(p_key1,1,v) || '=' || SUBSTR(p_val1,1,v) ELSE NULL END ||
            CASE WHEN p_key2 IS NOT NULL THEN CHR(38) || SUBSTR(p_key2,1,v) || '=' || SUBSTR(p_val2,1,v) ELSE NULL END ||
            CASE WHEN p_key3 IS NOT NULL THEN CHR(38) || SUBSTR(p_key3,1,v) || '=' || SUBSTR(p_val3,1,v) ELSE NULL END ||
            CASE WHEN p_key4 IS NOT NULL THEN CHR(38) || SUBSTR(p_key4,1,v) || '=' || SUBSTR(p_val4,1,v) ELSE NULL END ||
            CASE WHEN p_key5 IS NOT NULL THEN CHR(38) || SUBSTR(p_key5,1,v) || '=' || SUBSTR(p_val5,1,v) ELSE NULL END ||
            CASE WHEN p_key6 IS NOT NULL THEN CHR(38) || SUBSTR(p_key6,1,v) || '=' || SUBSTR(p_val6,1,v) ELSE NULL END ||
            ''
        ;
        
    END;

    PROCEDURE dbg(
        p_action app_audit.action%TYPE,
        p_details app_audit.details%TYPE DEFAULT NULL,
        p_uuid app_audit.uuid%TYPE DEFAULT NULL,
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP
    )
    AS
        v_id app_audit.id%TYPE;
    BEGIN
        v_id := log(p_uuid, 'D', p_action, p_details, p_created);
    END;

    PROCEDURE inf(
        p_action app_audit.action%TYPE,
        p_details app_audit.details%TYPE DEFAULT NULL,
        p_uuid app_audit.uuid%TYPE DEFAULT NULL,
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP
    )
    AS
        v_id app_audit.id%TYPE;
    BEGIN
        v_id := log(p_uuid, 'I', p_action, p_details, p_created);
    END;

    PROCEDURE wrn(
        p_action app_audit.action%TYPE,
        p_details app_audit.details%TYPE DEFAULT NULL,
        p_uuid app_audit.uuid%TYPE DEFAULT NULL,
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP
    )
    AS
        v_id app_audit.id%TYPE;
    BEGIN
        v_id := log(p_uuid, 'W', p_action, p_details, p_created);
    END;

    PROCEDURE err(
        p_action app_audit.action%TYPE,
        p_details app_audit.details%TYPE DEFAULT NULL,
        p_uuid app_audit.uuid%TYPE DEFAULT NULL,
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP
    )
    AS
        v_id app_audit.id%TYPE;
    BEGIN
        v_id := log(p_uuid, 'E', p_action, p_details, p_created);
    END;

    PROCEDURE audit(
        p_data CLOB, 
        p_uuid app_audit.uuid%TYPE DEFAULT NULL
    ) AS
        v_agent VARCHAR2(2000);
        v_ip VARCHAR2(2000);
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        BEGIN
            v_agent := TRIM(owa_util.get_cgi_env('HTTP_USER_AGENT'));
            v_ip := TRIM(owa_util.get_cgi_env('REMOTE_ADDR'));
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        INSERT INTO app_audit (uuid, severity, action, details, created, agent, ip)
        SELECT p_uuid, severity, action, details, created, v_agent, v_ip
        FROM JSON_TABLE(p_data, '$[*]'
            COLUMNS (
                severity VARCHAR2(3) PATH '$.severity',
                action VARCHAR2(4000) PATH '$.action',
                details VARCHAR2(4000) PATH '$.details',
                created TIMESTAMP PATH '$.created'
            )
        );

        COMMIT;            

    EXCEPTION
        WHEN OTHERS THEN
            err('Audit error', mrg('data', p_data), p_uuid);
    END;    

END;
/
