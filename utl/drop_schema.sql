DECLARE 
    TYPE T_SCHEMAS IS TABLE OF VARCHAR2(2000 CHAR);
    v_kill T_SCHEMAS;
    v_cnt PLS_INTEGER;
BEGIN

    SELECT COUNT(username) INTO v_cnt FROM all_users WHERE username = UPPER(:schema_name) AND oracle_maintained = 'N';
    
    IF v_cnt < 1 THEN

        RAISE_APPLICATION_ERROR(-20000, 'Schema ' || :schema_name || ' does not exists');
        
    ELSE

        EXECUTE IMMEDIATE 'ALTER SESSION SET DDL_LOCK_TIMEOUT = 15';

        EXECUTE IMMEDIATE 'ALTER USER ' || UPPER(:schema_name) || ' ACCOUNT LOCK';

        SELECT 'ALTER SYSTEM KILL SESSION ''' ||s.sid ||','||s.serial#||''' IMMEDIATE'
        BULK COLLECT INTO v_kill
        FROM v$session s 
        WHERE s.username = UPPER(:schema_name);
        IF v_kill.COUNT > 0 THEN
            FOR k IN v_kill.FIRST..v_kill.LAST
            LOOP
                EXECUTE IMMEDIATE v_kill(k);
            END LOOP;
        END IF;

        ORDS.DROP_REST_FOR_SCHEMA(UPPER(:schema_name));

        COMMIT;

        EXECUTE IMMEDIATE 'DROP USER ' || UPPER(:schema_name) || ' CASCADE';
        
    END IF;

END;
/
