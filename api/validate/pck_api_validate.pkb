CREATE OR REPLACE PACKAGE BODY pck_api_validate AS 

   FUNCTION VALIDATE(
        p_name VARCHAR2,
        p_value VARCHAR2,
        p_options VARCHAR2,
        r_errors OUT SYS_REFCURSOR
    ) RETURN PLS_INTEGER
    AS
        v_errors t_errors := t_errors();
        
        PROCEDURE add(p_message VARCHAR2) 
        AS 
        BEGIN
            v_errors.EXTEND();
            v_errors(v_errors.LAST).name := p_name;
            v_errors(v_errors.LAST).message := p_message;
        END; 

    BEGIN
        
        FOR r IN (
            SELECT jt.type, TO_CHAR(jt.value) AS value, jt.message
            FROM json_table(
                p_options,
                '$.rules[*]' 
                COLUMNS (
                    type VARCHAR2(200 CHAR) PATH '$.type',
                    value JSON PATH '$.value',
                    message VARCHAR2(2000 CHAR) PATH '$.message'
                )
            ) jt    
        ) LOOP

            IF r.type = 'required' THEN
                IF 
                    p_value IS NULL OR 
                    p_value = '' OR
                    LENGTH(p_value) < 1
                THEN
                    add(r.message);
                END IF;
            END IF;

            IF r.type = 'in-range' THEN
                IF  
                    p_value IS NULL OR 
                    TO_NUMBER(p_value) < TO_NUMBER(JSON_VALUE(r.value,'$.min')) OR 
                    TO_NUMBER(p_value) > TO_NUMBER(JSON_VALUE(r.value,'$.max'))
                THEN
                    add(r.message);
                END IF;
            END IF; 

        END LOOP;

        OPEN r_errors FOR
        SELECT *
        FROM TABLE(v_errors);

        RETURN v_errors.COUNT;

    END;

END;
/
