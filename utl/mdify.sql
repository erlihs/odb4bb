CREATE OR REPLACE PROCEDURE mdify(
  p_schema_name IN VARCHAR2
) AS
  v_schema_name VARCHAR2(30) := UPPER(p_schema_name);

  lf VARCHAR2(2) := CHR(10);
  v VARCHAR2(2000 CHAR);
  n PLS_INTEGER;

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

  PROCEDURE line(p VARCHAR2 DEFAULT '') AS
  BEGIN
    r := r || p || lf;
  END;

  PROCEDURE list_item(key VARCHAR2, val VARCHAR2) AS
  BEGIN
    r := r || '- ' || key || ': **' || val || '**' || lf;
  END;

BEGIN

  EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || v_schema_name;

  line('# Database');
  line();

  line ('*This is automatically generated content*');
  line();

  --  Summary

  line('## Summary');
  line();

  SELECT BANNER INTO v FROM V$VERSION;
  list_item('Database version', v);
  list_item('Generated', TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI'));
  list_item('Schema', v_schema_name);

  line();

  -- NLS

  line('## NLS settings');
  line();

  line('| Parameter | Value |');
  line('| --------- | ----- |');
  FOR c IN (
    SELECT parameter, value FROM v$nls_parameters
  ) LOOP
    line('|' || c.parameter || '|' || c.value || '|');
  END LOOP;

  line();

  -- TYPES

  SELECT COUNT(*)
  INTO n
  FROM all_objects o
  WHERE o.object_type = 'TYPE'
  AND o.owner = v_schema_name;

  IF n > 0 THEN

    line('## Types');
    line();

    line('| Type name | Description |');
    line('| --------- | ----------- |');
    FOR c IN (
      SELECT 
        o.object_name,
        (
          SELECT 
            REPLACE(REPLACE(TRIM(REPLACE(SUBSTR(s.text,INSTR(s.text,'--',1)),'--','')),CHR(13),''),CHR(10),'') 
          FROM all_source s
          WHERE INSTR(s.text,'--',1) > 0
          AND ROWNUM = 1
          AND s.type = o.object_type 
          AND s.name = o.object_name
          AND s.owner = v_schema_name
        ) AS comments
      FROM all_objects o
      WHERE o.object_type = 'TYPE'
      AND o.owner = v_schema_name
      ORDER BY o.object_name
    ) LOOP
      line('|' || c.object_name || '|' || c.comments || '|');
    END LOOP;

    line('');

  END IF;

-- TRIGGERS

  SELECT COUNT(*)
  INTO n
  FROM all_objects o
  WHERE o.object_type = 'TRIGGER'
  AND o.owner = v_schema_name;

  IF n > 0 THEN

    line('## Triggers');
    line();

    line('| Trigger name | Description |');
    line('| ------------ | ----------- |');
    FOR c IN (
      SELECT 
        o.object_name,
        (
        SELECT 
          REPLACE(REPLACE(TRIM(REPLACE(SUBSTR(s.text,INSTR(s.text,'--',1)),'--','')),CHR(13),''),CHR(10),'') 
        FROM all_source s
        WHERE INSTR(s.text,'--',1) > 0
        AND ROWNUM = 1
        AND s.type = o.object_type 
        AND s.name = o.object_name
        AND s.owner = v_schema_name
        ) AS comments
      FROM all_objects o
      WHERE o.object_type = 'TRIGGER'
      AND o.owner = v_schema_name
      ORDER BY o.object_name
    ) LOOP
      line('|' || c.object_name || '|' || c.comments || '|');
    END LOOP;

    line('');

  END IF;
  
  -- SEQUENCES

  SELECT COUNT(*)
  INTO n
  FROM all_sequences
  WHERE sequence_owner = v_schema_name;

  IF n > 0 THEN

    line('## Sequences');
    line();

    line('| Sequence name | Cache size | Last number |');
    line('| ------------- | ----------:| -----------:|');
    FOR c IN (
      SELECT 
        sequence_name AS object_name,
        cache_size,
        last_number 
      FROM all_sequences
      WHERE sequence_owner = v_schema_name 
      ORDER BY sequence_name
    ) LOOP
      line('|' || c.object_name || '|' || c.cache_size || '|' || TO_CHAR(c.last_number) || '|');
    END LOOP;

    line('');

  END IF;
  
  -- TABLES

  SELECT COUNT(*) 
  INTO n
  FROM all_tables t
  WHERE t.owner = v_schema_name;

  IF n > 0 THEN

    line('## Tables');
    line();

    line('### Summary');
    line();

    line('| Table name | Description |');
    line('| ---------- | ----------- |');

    FOR c IN (
      SELECT t.table_name, c.comments FROM all_tables t
      JOIN all_tab_comments c ON c.table_name  = t.table_name
      WHERE t.owner = v_schema_name
      AND c.owner = v_schema_name
      ORDER BY t.table_name
    ) LOOP 
      line('|' || c.table_name || '|' || c.comments || '|');
    END LOOP;

    line('');

    -- TABLE - DETAILS

    FOR c IN (
      SELECT t.table_name, c.comments FROM all_tables t
      JOIN all_tab_comments c ON c.table_name  = t.table_name
      WHERE t.owner = v_schema_name
      AND c.owner = v_schema_name
      ORDER BY t.table_name
    ) LOOP 

      line('### ' || c.table_name);
      line();
      line(c.comments);
      line();   

      -- Table columns
      line('#### Columns');
      line();   
      line('| Column name | Column type | Default | Not null | Primary key | Description |');
      line('| ----------- | ----------- | ------- | -------- | ----------- | ----------- |');

      FOR c2 IN (
        SELECT 
          tc.column_name,
          CASE 
            WHEN tc.data_type IN ('CHAR','VARCHAR2') THEN tc.data_type || ' (' || CAST((tc.char_col_decl_length / 4) AS VARCHAR2(254)) || ' CHAR)'
            ELSE tc.data_type
            END AS column_type,
          tc.data_default AS column_default, -- (!) LONG
          CASE tc.nullable 
            WHEN 'N' THEN 'Y' 
            ELSE '' 
            END AS column_not_null,
          CASE 
            WHEN EXISTS (
              SELECT ucc.table_name, ucc.column_name
              FROM all_constraints uc, all_cons_columns ucc
              WHERE ucc.table_name = tc.table_name
              AND ucc.column_name = tc.column_name
              AND uc.constraint_type = 'P'
              AND uc.constraint_name = ucc.constraint_name
              AND uc.owner = v_schema_name
              AND ucc.owner = v_schema_name
            ) THEN 'Y' 
            ELSE ''
            END AS column_pk,
          (
            SELECT 
              ucc2.table_name || ' (' || ucc2.column_name || ')' 
            FROM all_constraints uc, all_cons_columns ucc, all_cons_columns ucc2
            WHERE uc.table_name = tc.table_name
            AND ucc.column_name = tc.column_name
            AND uc.constraint_type = 'R'
            AND ucc.constraint_name = uc.constraint_name   
            AND ucc2.constraint_name = uc.r_constraint_name
            AND uc.owner = v_schema_name
            AND ucc.owner = v_schema_name
            AND ucc2.owner = v_schema_name
          ) AS column_fk,
          (SELECT ul.tablespace_name FROM all_lobs ul WHERE ul.table_name = tc.table_name AND ul.column_name = tc.column_name AND ul.owner = v_schema_name) AS column_lob,
          tcc.comments
        FROM all_tab_columns tc
        LEFT JOIN all_col_comments tcc ON tcc.table_name = tc.table_name AND tcc.column_name = tc.column_name
        WHERE tc.table_name = c.table_name -- TABLE_NAME
        AND tc.owner = v_schema_name
        AND tcc.owner = v_schema_name			
        ORDER BY tc.table_name, tc.column_id
      ) LOOP
        line('|'|| c2.column_name ||'|'|| c2.column_type ||'|'|| c2.column_default ||'|'|| c2.column_not_null ||'|'|| c2.column_pk ||'|'|| c2.comments ||'|');
      END LOOP;

      line();   

      -- Table constraints

      SELECT COUNT(*)
      INTO n
      FROM all_constraints uc
      WHERE uc.constraint_type = 'C'
      AND uc.table_name = c.table_name -- TABLE_NAME
      AND uc.generated = 'USER NAME'
      AND uc.owner = v_schema_name;

      IF n > 0 THEN

        line('#### Constraints');
        line();   

        line('| Constraint name | Search conditions | Description |');
        line('| --------------- | ----------------- | ----------- |');
    
        FOR c3 IN (
          SELECT 
            uc.constraint_name, 
            uc.search_condition,
            '' AS comments
          FROM all_constraints uc
          WHERE uc.constraint_type = 'C'
          AND uc.table_name = c.table_name -- TABLE_NAME
          AND uc.generated = 'USER NAME'
          AND uc.owner = v_schema_name
          ORDER BY uc.constraint_name
        ) LOOP
          line('|' || c3.constraint_name || '|' || c3.search_condition || '|' || c3.comments || '|');
        END LOOP;

        line();   

      END IF;

      --  Table indexes

      SELECT COUNT(*)
      INTO n
      FROM all_indexes ui 
      WHERE ui.table_name = c.table_name -- TABLE_NAME
      AND ui.owner = v_schema_name;

      IF n > 0 THEN

        line('#### Indexes');
        line();   
        
        line('| Index name | Unique | Generated | Columns | Description |');
        line('| ---------- | ------ | --------- | ------- | ----------- |');
    
        FOR c4 IN (
          SELECT 
            ui.index_name,
            CASE WHEN ui.uniqueness = 'UNIQUE' THEN 'Y' ELSE '' END AS index_unique,
            ui.generated AS index_generated,
            (
              SELECT LISTAGG(column_name || CASE WHEN uic.descend = 'ASC' THEN '' ELSE ' ' || uic.descend END,', ') WITHIN GROUP (ORDER BY uic.column_position) AS index_columns 
              FROM all_ind_columns uic 
              WHERE uic.index_name = ui.index_name
              AND uic.index_owner = v_schema_name
            ) AS index_columns,
            '' AS comments
          FROM all_indexes ui 
          WHERE ui.table_name = c.table_name -- TABLE_NAME
          AND ui.owner = v_schema_name
          ORDER BY ui.index_name    
        ) LOOP
          line('|' || c4.index_name || '|' || c4.index_unique || '|' || c4.index_generated || '|' || c4.index_columns || '|' || c4.comments || '|');
        END LOOP;

        line();

      END IF; 

      -- Table partitions

      SELECT COUNT(*)
      INTO n
      FROM all_tab_partitions tp
      WHERE tp.table_name = c.table_name -- TABLE_NAME
      AND tp.table_owner = v_schema_name;

      IF n > 0 THEN

        line('#### Partitions');
        line();   

        line('| Partition name | Tablespavce name | Description |');
        line('| -------------- | ---------------- | ----------- |');
    
        FOR c5 IN (
          SELECT 
            tp.partition_name,
            tp.tablespace_name,
            '' AS comments
          FROM all_tab_partitions tp
          WHERE tp.table_name = c.table_name -- TABLE_NAME
          AND tp.table_owner = v_schema_name
          ORDER BY tp.partition_name
        ) LOOP
          line('|' || c5.partition_name || '|' || c5.tablespace_name || '|' || c5.comments || '|');
        END LOOP;

        line();

      END IF;    

    END LOOP;

  END IF;  

  -- PACKAGES

  SELECT COUNT(*)
  INTO n
  FROM all_procedures up
  WHERE up.procedure_name IS NULL
  AND up.object_type = 'PACKAGE'
  AND up.owner = v_schema_name;

  IF n > 0 THEN

    line('## Packages');
    line();

    line('### Summary');
    line();

    line('| Package name | Description |');
    line('| ------------ | ----------- |');

    FOR c IN (
      SELECT 
        up.object_name AS package_name,
        (
          SELECT 
            REPLACE(REPLACE(TRIM(REPLACE(SUBSTR(s.text,INSTR(s.text,'--',1)),'--','')),CHR(13),''),CHR(10),'') 
          FROM all_source s
          WHERE name = up.object_name
          AND type = 'PACKAGE'
          AND (UPPER(s.text)LIKE '%PACKAGE%')
          AND (UPPER(s.text) NOT LIKE '%BODY%')
          AND s.text LIKE '%--%'
          AND rownum = 1
          AND s.owner = v_schema_name
        ) AS comments
      FROM all_procedures up
      WHERE up.procedure_name IS NULL
      AND up.object_type = 'PACKAGE'
      AND up.owner = v_schema_name
      ORDER BY package_name
    ) LOOP 
      line('|' || c.package_name || '|' || c.comments || '|');
    END LOOP;

    line('');

    -- PACKAGE - DETAILS

    FOR c IN (
      SELECT 
        up.object_name AS package_name,
        (
          SELECT 
            REPLACE(REPLACE(TRIM(REPLACE(SUBSTR(s.text,INSTR(s.text,'--',1)),'--','')),CHR(13),''),CHR(10),'') 
          FROM all_source s
          WHERE name = up.object_name
          AND type = 'PACKAGE'
          AND (UPPER(s.text)LIKE '%PACKAGE%')
          AND (UPPER(s.text) NOT LIKE '%BODY%')
          AND s.text LIKE '%--%'
          AND rownum = 1
          AND s.owner = v_schema_name
        ) AS comments
      FROM all_procedures up
      WHERE up.procedure_name IS NULL
      AND up.object_type = 'PACKAGE'
      AND up.owner = v_schema_name
      ORDER BY package_name
    ) LOOP 
      
      line('### ' || c.package_name);
      line();

      line(c.comments);
      line();   

      -- Package dependencies

      SELECT COUNT(*)
      INTO n
      FROM all_dependencies d
      WHERE d.owner = v_schema_name
      AND d.referenced_owner = v_schema_name
      AND d.type = 'PACKAGE'
      AND d.name = c.package_name;

      IF n > 0 THEN

        line('Dependencies:');
        line();

        line('| Referenced type | Referenced name |');
        line('| --------------- | --------------- |');

        FOR c4 IN (
          SELECT 
            d.referenced_type,
            d.referenced_name
          FROM all_dependencies d
          WHERE d.owner = v_schema_name
          AND d.referenced_owner = v_schema_name
          AND d.type = 'PACKAGE'
          AND d.name = c.package_name
        ) LOOP
          line('|' || c4.referenced_type || '|' || c4.referenced_name || '|');
        END LOOP;

        line();

      END IF;

      -- Package routines

      FOR c2 IN (
        SELECT 
          o.procedure_name,
          o.overload,
          (
            SELECT 
              REPLACE(REPLACE(TRIM(REPLACE(SUBSTR(s.text,INSTR(s.text,'--',1)),'--','')),CHR(13),''),CHR(10),'')  
            FROM all_source s
            WHERE name = o.object_name
            AND type = 'PACKAGE'
            AND (
              ((UPPER(s.text) LIKE '%PROCEDURE%') OR (UPPER(s.text) LIKE '%FUNCTION%'))
              AND
              (UPPER(s.text) LIKE '% ' || UPPER(o.procedure_name) || ' %' OR UPPER(s.text) LIKE '% ' || UPPER(o.procedure_name) || '(%' OR UPPER(s.text) LIKE '% ' || UPPER(o.procedure_name) || ';%')
            )
            AND s.text LIKE '%--%'
            AND rownum = 1
            AND s.owner = v_schema_name
          ) AS comments
        FROM all_procedures o
        WHERE o.object_name = c.package_name
        AND o.object_name IS NOT NULL
        AND o.procedure_name IS NOT NULL
        AND o.owner = v_schema_name
      ) LOOP 

        line('#### ' || c2.procedure_name);
        line();   

        line(c2.comments);
        line();

        SELECT COUNT(*)
        INTO n
        FROM all_arguments a
        WHERE a.package_name = c.package_name
        AND a.object_name = c2.procedure_name
        AND (overload IS NULL OR overload = c2.overload)
        AND a.owner = v_schema_name;

        IF n > 0 THEN

          line('| Argument name | In Out | Data type | Default value | Description |');
          line('| ------------- | ------ | --------- | ------------- | ----------- |');

          FOR c3 IN (
            SELECT
              argument_name,
              data_type,
              in_out,
              (
                SELECT 
                    REGEXP_REPLACE(REGEXP_SUBSTR(s.text, 'DEFAULT\s+(\S+)', 1, 1, NULL, 1), ',$', '')
                FROM all_source s
                WHERE NAME = package_name
                AND TYPE = 'PACKAGE'
                AND s.owner = v_schema_name
                AND (
                  ((argument_name IS NOT NULL) AND (INSTR(UPPER(text),argument_name) > 0))
                  OR
                  ((argument_name IS NULL) AND (INSTR(UPPER(text),')') > 0) AND (INSTR(UPPER(text),'RETURN') > 0) AND (INSTR(UPPER(text),';') > 0)) 
                )  
                AND line > (
                  SELECT MIN(line)
                  FROM all_source
                  WHERE (((INSTR(UPPER(text),'PROCEDURE') > 0) OR (INSTR(UPPER(text),'FUNCTION') > 0)) AND (INSTR(UPPER(text),UPPER(OBJECT_NAME)) > 0))
                  AND owner = v_schema_name
                )
                AND s.TEXT LIKE '%--%'
                AND rownum = 1 
              ) AS default_value,
              (
                SELECT REPLACE(REPLACE(TRIM(REPLACE(SUBSTR(text,INSTR(text,'--',1)),'--','')),CHR(13),''),CHR(10),'')
                FROM all_source s
                WHERE NAME = package_name
                AND TYPE = 'PACKAGE'
                AND s.owner = v_schema_name
                AND (
                  ((argument_name IS NOT NULL) AND (INSTR(UPPER(text),argument_name) > 0))
                  OR
                  ((argument_name IS NULL) AND (INSTR(UPPER(text),')') > 0) AND (INSTR(UPPER(text),'RETURN') > 0) AND (INSTR(UPPER(text),';') > 0)) 
                )  
                AND line > (
                  SELECT MIN(line)
                  FROM all_source
                  WHERE (((INSTR(UPPER(text),'PROCEDURE') > 0) OR (INSTR(UPPER(text),'FUNCTION') > 0)) AND (INSTR(UPPER(text),UPPER(OBJECT_NAME)) > 0))
                  AND owner = v_schema_name
                )
                AND s.TEXT LIKE '%--%'
                AND rownum = 1 
              ) AS comments
            FROM all_arguments
            WHERE package_name = c.package_name
            AND object_name = c2.procedure_name
            AND (overload IS NULL OR overload = c2.overload)
            AND owner = v_schema_name
            ORDER BY position
          ) LOOP
            line('|' || c3.argument_name || '|' || c3.in_out || '|' || c3.data_type || '|' || c3.default_value || '|' || c3.comments || '|');
          END LOOP;

          line();

        END IF;  

      END LOOP;  

    END LOOP;

  END IF;  

  -- DONE

  print;

END;
/
