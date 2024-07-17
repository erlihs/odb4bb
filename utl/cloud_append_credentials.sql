DECLARE
    v_cred CLOB := :cred;
    v_name VARCHAR2(200 CHAR) := JSON_VALUE(v_cred, '$.name');
    v_username VARCHAR2(2000 CHAR) := JSON_VALUE(v_cred, '$.username');
    v_password VARCHAR2(2000 CHAR) := JSON_VALUE(v_cred, '$.password');
BEGIN

    BEGIN
        DBMS_CLOUD.DROP_CREDENTIAL (v_name);
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_CLOUD.CREATE_CREDENTIAL (
        credential_name => v_name,
        username        => v_username,
        password        => v_password 
    );

END;    
/