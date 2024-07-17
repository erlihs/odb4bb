DECLARE
    c_version PLS_INTEGER := :version;
    v_banner VARCHAR2(2000 CHAR);
    v_version PLS_INTEGER;
BEGIN
    SELECT banner INTO v_banner FROM v$version;
    v_version := TO_NUMBER(REGEXP_SUBSTR(v_banner, '(\d+)', 1, 1));
    IF v_version < c_version THEN
        RAISE_APPLICATION_ERROR(-20000, 'Oracle Database version ' || c_version || ' or higher is required');
    END IF;
 END;
/
