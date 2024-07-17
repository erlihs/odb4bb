create or replace PACKAGE BODY pck_api_auth AS 

    -- PRIVATE

    FUNCTION jwt_b64 (
        p_string VARCHAR2
    ) RETURN VARCHAR2
    AS
    BEGIN
        RETURN translate((replace(utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(p_string))),'=')), unistr('+/=\000a\000d'), '-_');
    END;

    FUNCTION jwt_enc (
        p_string VARCHAR2,
        p_secret VARCHAR2
    ) RETURN VARCHAR2
    AS
    BEGIN
        RETURN jwt_b64(utl_raw.cast_to_varchar2(dbms_crypto.mac(utl_raw.cast_to_raw(p_string), dbms_crypto.HMAC_SH256, utl_raw.cast_to_raw(p_secret))));
    END;

    FUNCTION jwt_sign(
        p_iss VARCHAR2,
        p_sub VARCHAR2,
        p_aud VARCHAR2,
        p_exp TIMESTAMP,
        p_secret VARCHAR2
    ) RETURN VARCHAR2
    AS
        v_header VARCHAR2(2000 CHAR);
        v_payload VARCHAR2(2000 CHAR);
    BEGIN
        v_header := '{"alg":"HS256","type":"JWT"}';
        v_payload := json_object(
            'iss' VALUE p_iss,
            'sub' VALUE p_sub,
            'aud' VALUE p_aud,
            'exp' VALUE TO_CHAR( ROUND((CAST(p_exp AT TIME ZONE 'UTC' AS DATE) - TO_DATE('1970-01-01','YYYY-MM-DD')) *(24*60*60))),
            'iat' VALUE TO_CHAR(ROUND((CAST(SYSTIMESTAMP AT TIME ZONE 'UTC' AS DATE) - TO_DATE('1970-01-01','YYYY-MM-DD'))*(24*60*60))),
            'nbf' VALUE TO_CHAR(ROUND((CAST(SYSTIMESTAMP AT TIME ZONE 'UTC' AS DATE) - TO_DATE('1970-01-01','YYYY-MM-DD'))*(24*60*60))),
            'jti' VALUE LOWER(SYS_GUID())
            FORMAT JSON
        ); 
        RETURN jwt_b64(v_header) || '.' || jwt_b64(v_payload) || '.' || jwt_enc(jwt_b64(v_header) || '.' || jwt_b64(v_payload), p_secret);
    END;

    PROCEDURE jwt_decode(
        p_token VARCHAR2,
        p_secret VARCHAR2,
        r_iss OUT VARCHAR2,
        r_sub OUT VARCHAR2,
        r_aud OUT VARCHAR2,
        r_exp OUT PLS_INTEGER
    ) AS
        v_header VARCHAR2(2000 CHAR) := substr(p_token, 1, instr(p_token, '.') - 1);
        v_payload VARCHAR2(2000 CHAR) := substr(p_token, instr(p_token, '.') + 1, (instr(p_token, '.', 1, 2)) - (instr(p_token, '.') + 1));
        v_signature VARCHAR2(2000 CHAR) := substr(p_token, (instr(p_token, '.', 1, 2) + 1));
        v_payload_decoded VARCHAR2(2000 CHAR);
    BEGIN

        IF jwt_enc((v_header || '.' || v_payload), p_secret) = v_signature THEN
            v_payload_decoded := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(v_payload)));
            SELECT JSON_VALUE(v_payload_decoded, '$.iss') into r_iss FROM DUAL;
            SELECT JSON_VALUE(v_payload_decoded, '$.sub') into r_sub FROM DUAL;
            SELECT JSON_VALUE(v_payload_decoded, '$.aud') into r_aud FROM DUAL;
            SELECT JSON_VALUE(v_payload_decoded, '$.exp') into r_exp FROM DUAL;
        END IF;

    END;

    -- PUBLIC

    FUNCTION auth( 
        p_username app_users.username%TYPE, 
        p_password app_users.password%TYPE 
    ) RETURN app_users.uuid%TYPE
    AS
        v_uuid app_users.uuid%TYPE;
    BEGIN
        BEGIN
            SELECT uuid INTO v_uuid 
            FROM app_users 
            WHERE username = UPPER(TRIM(p_username)) 
            AND password = SUBSTR(password,1,32) || DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(TRIM(p_password) || SUBSTR(password,1, 32)),4);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;    
        END;
        RETURN v_uuid;
    END;

    PROCEDURE auth( 
        p_username app_users.username%TYPE, 
        p_password app_users.password%TYPE, 
        r_uuid OUT app_users.uuid%TYPE 
    ) AS
    BEGIN
        r_uuid := auth(p_username, p_password);    
    END;

    FUNCTION token(
        p_uuid app_users.uuid%TYPE, 
        p_type app_token_types.id%TYPE
    ) RETURN app_tokens.token%TYPE
    AS
        v_iss app_token_settings.issuer%TYPE;
        v_aud app_token_settings.audience%TYPE;
        v_secret app_token_settings.secret%TYPE;
        v_exp app_tokens.expiration%TYPE;
        v_token app_tokens.token%TYPE;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        SELECT issuer, audience, secret INTO v_iss, v_aud, v_secret FROM app_token_settings;

        SELECT SYSTIMESTAMP + expiration / 86400 INTO v_exp FROM app_token_types WHERE id = p_type;

        v_token := jwt_sign(v_iss, p_uuid, v_aud, v_exp, v_secret);

        INSERT INTO app_tokens (id_user, id_token_type, token, expiration)
        SELECT
            u.id,
            p_type,
            v_token,
            v_exp 
        FROM app_users u
        WHERE u.uuid = p_uuid;

        COMMIT;
        RETURN v_token;

    END;

    PROCEDURE token(
        p_uuid app_users.uuid%TYPE, 
        p_type app_token_types.id%TYPE, 
        r_token OUT app_tokens.token%TYPE
    ) AS
    BEGIN
        r_token := token(p_uuid, p_type);
    END;

    PROCEDURE reset( 
        p_uuid app_users.uuid%TYPE, 
        p_type app_token_types.id%TYPE DEFAULT NULL 
    ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DELETE FROM app_tokens WHERE id_user = (SELECT id FROM app_users WHERE uuid = p_uuid) AND (p_type IS NULL OR id_token_type = p_type);
        COMMIT;
    END;

    FUNCTION uuid (
        p_check_expiration CHAR DEFAULT 'Y'
    )
    RETURN app_users.uuid%TYPE 
    AS
        v_token app_tokens.token%TYPE := REPLACE(OWA_UTIL.GET_CGI_ENV('Authorization'),'Bearer ','');
        v_secret app_token_settings.secret%TYPE;
        v_iss app_token_settings.issuer%TYPE;
        v_sub app_users.uuid%TYPE;
        v_aud app_token_settings.audience%TYPE;
        v_exp app_token_types.expiration%TYPE;
        v_uuid app_users.uuid%TYPE;
    BEGIN

        IF v_token IS NULL THEN RETURN NULL; END IF;
        
        SELECT secret INTO v_secret FROM app_token_settings;

        jwt_decode(v_token, v_secret, v_iss, v_sub, v_aud, v_exp);

        BEGIN  
            SELECT u.uuid INTO v_uuid
            FROM app_users u
            WHERE u.uuid = v_sub 
            AND u.id IN (
                SELECT id_user
                FROM app_tokens
                WHERE token = v_token
                AND (p_check_expiration = 'N' OR expiration > SYSTIMESTAMP)
            )
            AND v_iss = (
                SELECT issuer 
                FROM app_token_settings
            );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;

        RETURN v_uuid;

    END;

    FUNCTION priv( 
        p_uuid app_users.uuid%TYPE DEFAULT NULL, 
        p_role app_roles.role%TYPE DEFAULT NULL 
    ) RETURN app_permissions.permission%TYPE
    AS
        v_uuid app_users.uuid%TYPE := p_uuid;
        v_priv app_permissions.permission%TYPE;
    BEGIN

        IF v_uuid IS NULL THEN v_uuid := uuid(); END IF;

        IF v_uuid IS NULL THEN RETURN NULL; END IF; 

        BEGIN
            SELECT permission INTO v_priv
            FROM app_permissions
            WHERE id_user = (SELECT id_user FROM app_users WHERE uuid = v_uuid)
            AND id_role = (SELECT id FROM app_roles WHERE role = UPPER(p_role))
            AND (valid_from IS NULL OR valid_from <= SYSTIMESTAMP)
            AND (valid_to IS NULL OR valid_to > SYSTIMESTAMP);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN v_priv := v_uuid;
        END;

        RETURN v_priv;

    END;        

    PROCEDURE http_401
    AS
    BEGIN
        owa_util.status_line(nstatus=>401, creason=>'Unauthorized', bclose_header=>true);
    END;

    PROCEDURE http_403
    AS
    BEGIN
        owa_util.status_line(nstatus=>403, creason=>'Forbidden', bclose_header=>true);
    END;

END;
/
