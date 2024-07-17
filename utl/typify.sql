CREATE OR REPLACE PROCEDURE typify
AS
    pp CLOB;

    PROCEDURE get_types(
        p CLOB
    ) AS
        m CLOB := 'Generate Typescript types from the Oracle PLSQL package body for all SYS_REFCURSOR output attributes. Do not generate type for the package itself. Output just the types, no additional text. Use Camel Case prefixed wiht T. Here is the code: ' || p;
        k VARCHAR2(2000);
        r CLOB;

        FUNCTION get_nth_word(p_string IN VARCHAR2, p_n IN NUMBER)
        RETURN VARCHAR2
        IS
            v_start NUMBER;
            v_end NUMBER;
            BEGIN
            v_start := INSTR(p_string, ' ', 1, p_n - 1) + 1;
            v_end := INSTR(p_string, ' ', 1, p_n);
            
            IF v_end = 0 THEN
                v_end := LENGTH(p_string) + 1;
            END IF;
            
            RETURN SUBSTR(p_string, v_start, v_end - v_start);
        END;

        PROCEDURE print 
        AS 
            v_offset PLS_INTEGER:=1;
            v_line VARCHAR2(32767);
            v_total_length PLS_INTEGER:=LENGTH(r);
            v_line_length PLS_INTEGER;
        BEGIN
            WHILE v_offset <= v_total_length LOOP
            v_line_length:=instr(r,chr(10),v_offset)-v_offset;
            IF v_line_length<0 THEN
                v_line_length:=v_total_length+1-v_offset;
            END IF;
            v_line:=substr(r,v_offset,v_line_length);
            dbms_output.put_line(v_line); 
            v_offset:=v_offset+v_line_length+1;
            END LOOP;
        END;

    BEGIN

        IF UPPER(p) NOT LIKE '%SYS_REFCURSOR%' THEN
            RETURN;
        END IF;

        m:=replace(m,'"','\"');
        
        SELECT content INTO k FROM app_settings WHERE id = 'APP_OPENAI_API_KEY';
        pck_api_openai.completion(
            k,
            'gpt-4-turbo',
            '',
            m,
            r
        );

        r := REPLACE(r, '```typescript', '');
        r := REPLACE(r, '```', '');
        IF r LIKE '%type%' THEN
            DBMS_OUTPUT.PUT_LINE(CHR(10));
            DBMS_OUTPUT.PUT_LINE('// Types for package ' || get_nth_word(SUBSTR(p,1,2000), 3));
            print;
        END IF;    

    END;

BEGIN

    FOR r IN (
        SELECT * 
        FROM user_source 
        WHERE type = 'PACKAGE BODY'

        ORDER BY type, name, line
    ) LOOP
        IF REPLACE(TRIM(UPPER(r.text)), ' ','') LIKE 'PACKAGEBODY%' THEN
              IF DBMS_lob.getlength(pp) > 0 THEN  get_types(pp); END IF;
              pp := NULL;  
        END IF;    
        pp := pp || r.text;
    END LOOP;    
    IF DBMS_lob.getlength(pp) > 0 THEN  get_types(pp); END IF;
END;
/
