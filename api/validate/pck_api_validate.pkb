CREATE OR REPLACE PACKAGE BODY pck_api_validate AS 

    FUNCTION validate(
        p_value VARCHAR2,
        p_type VARCHAR2,
        p_message VARCHAR2,
        p_criteria VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2
    AS
    BEGIN
        
        IF p_type = 'required' AND p_value IS NULL THEN RETURN p_message; END IF;
        IF p_type = 'required' AND LENGTH(p_value) < 1 THEN RETURN p_message; END IF;
        
        IF p_type = 'in-range' AND TO_NUMBER(p_value) < TO_NUMBER(JSON_VALUE(p_criteria,'$.min')) THEN RETURN p_message; END IF;
        IF p_type = 'in-range' AND TO_NUMBER(p_value) > TO_NUMBER(JSON_VALUE(p_criteria,'$.max')) THEN RETURN p_message; END IF;

        RETURN NULL;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'validation.error';    
    END;    

    PROCEDURE validate(
        p_name VARCHAR2,
        p_value VARCHAR2,
        p_rules VARCHAR2,
        r_errors OUT SYS_REFCURSOR
    ) 
    AS
    BEGIN

        OPEN r_errors FOR
        SELECT p_name AS "name", message AS "message" 
        FROM (
            SELECT validate(p_value, jt.type, jt.message, jt.value) AS message  
            FROM json_table(
                p_rules,
                '$[*]' 
                COLUMNS (
                    type VARCHAR2(2000) PATH '$.type',
                    value VARCHAR2(2000) PATH '$.value',
                    message VARCHAR2(2000) PATH '$.message'
                )
            ) jt       
        ) WHERE message IS NOT NULL;
 
    END;
END;
/
