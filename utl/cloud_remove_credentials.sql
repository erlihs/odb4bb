DECLARE
    v_cred CLOB := :cred;
    v_name VARCHAR2(200 CHAR) := JSON_VALUE(v_cred, '$.name');
BEGIN

    DBMS_CLOUD.DROP_CREDENTIAL (v_name);

END;    
/