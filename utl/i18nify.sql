DECLARE 

  r CLOB;

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

    SELECT JSON_SERIALIZE(
        (   
            SELECT 
                JSON_OBJECTAGG(
                    KEY l.lang VALUE 
                    (    
                        SELECT JSON_OBJECTAGG(
                            KEY t.text VALUE t.translation 
                        ) FROM (
                            SELECT
                                lang,
                                CAST (text AS VARCHAR2(4000)) AS text,
                                CAST (COALESCE(correction, translation)AS VARCHAR2(4000))  AS translation 
                            FROM app_i18n
                            WHERE lang = l.lang
                        ) t
                    )
                )
            FROM (
                SELECT
                    DISTINCT lang
                FROM app_i18n
            ) l
        )
        RETURNING CLOB PRETTY
    ) AS i18n
    INTO r
    FROM DUAL
    ;

    print;

END;
/
