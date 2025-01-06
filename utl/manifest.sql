create or replace PROCEDURE manifest
AS

    v_schema_name VARCHAR2(30 CHAR) := sys_context( 'userenv', 'current_schema' );

    v_cnt PLS_INTEGER;
    v_str VARCHAR2(2000 CHAR);

    PROCEDURE append(
        p_line VARCHAR2,
        p_indent NUMBER DEFAULT 0
    ) AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(RPAD(' ', p_indent * 2, ' ') || p_line);
        -- r_manifest := r_manifest || RPAD(' ', p_indent * 2, ' ') || p_line || CHR(10);
    END;

    PROCEDURE json_to_openapi3_schema(
        p_json CLOB,
        p_indent PLS_INTEGER DEFAULT 0
    ) AS

        JSON_PARSE_ERROR EXCEPTION;
        PRAGMA EXCEPTION_INIT(JSON_PARSE_ERROR, -40587);

        jt JSON_ELEMENT_T;
        ja JSON_ARRAY_T;
        jo JSON_OBJECT_T;
        jk JSON_KEY_LIST;

        PROCEDURE echo(
            p_line VARCHAR2, 
            p_indent PLS_INTEGER
        ) AS
        BEGIN
            DBMS_OUTPUT.PUT_LINE(RPAD(' ', p_indent * 2) || p_line);
            -- r_manifest := r_manifest || RPAD(' ', p_indent * 2, ' ') || p_line || CHR(10);
        END;

    BEGIN

        BEGIN
            jt := JSON_ELEMENT_T.parse(p_json);
        EXCEPTION
            WHEN JSON_PARSE_ERROR THEN
                echo('type: ' ||
                    CASE 
                    WHEN p_json IN ('true', 'false') THEN 'boolean'
                    WHEN REGEXP_LIKE(p_json, '^\d+(\.\d+)?$') THEN 'number'
                    ELSE 'string'
                    END
                , p_indent);
                RETURN;
        END;

        IF jt.is_array THEN
            echo('type: array', p_indent);
            echo('items:', p_indent);
            ja := TREAT(jt AS JSON_ARRAY_T);
            json_to_openapi3_schema(ja.get(0).to_string, p_indent + 1);
        END IF;

        IF jt.is_object THEN
            echo('type: object', p_indent);
            echo('properties:', p_indent);
            jo := TREAT(jt AS JSON_OBJECT_T);
            jk := jo.get_keys;
            FOR i IN 1..jk.COUNT LOOP
                echo(jk(i) || ':', p_indent + 1);
                json_to_openapi3_schema(jo.get(jk(i)).to_string, p_indent + 2);
            END LOOP;
        END IF;

    END;

BEGIN

    SELECT COUNT(pattern) 
    INTO v_cnt
    FROM user_ords_schemas
    WHERE parsing_schema = UPPER(v_schema_name)
    AND status = 'ENABLED';

    IF (v_cnt = 0) THEN
        raise_application_error(-20001, 'Oracle REST Data Services is not enabled');
        RETURN;
    END IF;

    append('openapi: 3.0.3');

    append('info:');
    append('title: ' || UPPER(v_schema_name) || ' API', 1);
    append('version: ''0.3''', 1);

    append('description: This is automatically generated Open API Manifest for Oracle Rest Data Services by [odb4bb](https://github.com/erlihs/odb4bb)', 1);

    append('security:');
    append('- BearerAuth: []', 1);

    append('servers:');
    append('- url: https://localhost:8443/ords/' || LOWER(v_schema_name) || '/', 1);

    append('tags:');
    FOR m IN (
        SELECT name, comments
        FROM user_ords_modules
        ORDER BY name
    ) LOOP
        append('- name: ' || m.name, 1);
        append('description: ' || m.comments, 2);
    END LOOP;

    append('paths:');
    FOR p IN (
        SELECT m.id, m.name, t.comments, m.uri_prefix, t.uri_template, s.method
        FROM user_ords_modules m
        JOIN user_ords_templates t ON t.module_id = m.id
        JOIN user_ords_services s ON s.module_id = m.id AND s.template_id = t.id
        ORDER BY m.name
    ) LOOP
        append(p.uri_prefix ||  REGEXP_REPLACE(p.uri_template, ':(\w+)', '{\1}') || ':', 1);
        append(LOWER(p.method) || ':', 2);
        append('tags:',3);
        append('- ' || p.name, 4);
        append('description: ' || p.comments,3);

        IF (p.comments LIKE '%(PUBLIC)%') THEN append('security: []', 3); END IF;

        append('responses:', 3);
        append('200:', 4);

        v_cnt := 0;
        FOR a IN (
            SELECT a.name, a.access_method, a.source_type, a.param_type, a.comments
            FROM user_ords_parameters a
            JOIN user_ords_handlers h ON h.id = a.handler_id
            JOIN user_ords_templates t ON t.id = h.template_id AND t.uri_template = p.URI_TEMPLATE
            JOIN user_ords_services s ON s.template_id = t.id AND s.handler_id = h.id AND s.module_id = p.ID
            WHERE a.access_method = 'OUT'
        ) LOOP
            v_cnt := v_cnt + 1;

            IF (v_cnt = 1) THEN
                append('description: queried record', 5);
                append('content:', 5);
                append('application/json:', 6);
                append('schema:', 7);
                append('type: object', 8);
                append('properties:', 8);
            END IF;

            append(a.name || ':', 9);

            v_str := 
                CASE 
                    WHEN REGEXP_LIKE(a.comments, '\[.*\]|\{.*\}') THEN TRIM(SUBSTR(a.comments, 1, LEAST(INSTR(a.comments, '['),INSTR(a.comments, '{')) - 1))
                    ELSE TRIM(a.comments)
                    END;
            IF (v_str IS NOT NULL) THEN
                append('description: ' || v_str, 10);
            END IF;                 

            IF (a.param_type = 'INT') THEN
                append('type: integer', 10);
            ELSIF (a.param_type = 'BOOLEAN') THEN
                append('type: boolean', 10);
            ELSIF (a.param_type = 'RESULTSET') THEN
                IF (INSTR(a.comments,'[') > 0) OR (INSTR(a.comments,'{') > 0) THEN 
                    v_str := TRIM(SUBSTR(a.comments,INSTR(a.comments,'[')-1, 4000));
                    json_to_openapi3_schema(v_str, 10);
                ELSE
                    append('type: array', 10);
                    append('items:', 10);
                    append('type: object', 11);
                    append('additionalProperties: true', 11);
                    append('description: An unknown JSON object', 11);
                END IF;    
            ELSE
                append('type: string', 10);
            END IF;

        END LOOP;

        IF (v_cnt = 0) THEN 
            append('description: No content returned', 5);
        END IF; 

        v_cnt := 0;
        FOR a IN (
            SELECT a.name, a.access_method, a.source_type, a.param_type, a.comments
            FROM user_ords_parameters a
            JOIN user_ords_handlers h ON h.id = a.handler_id
            JOIN user_ords_templates t ON t.id = h.template_id AND t.uri_template = p.URI_TEMPLATE
            JOIN user_ords_services s ON s.template_id = t.id AND s.handler_id = h.id AND s.module_id = p.ID AND s.method NOT IN ('GET')
            WHERE a.access_method = 'IN'
        ) LOOP
            v_cnt := v_cnt + 1;

            IF (v_cnt = 1) THEN
                append('requestBody:', 3);
                append('description: JSON object', 4); --todo: list params
                append('content:', 4);
                append('application/json:',5);
                append('schema:', 6);
                append('type: object', 7);
                append('properties:', 7);
            END IF;

            append(a.name || ':', 8);
            append('type: ' || CASE a.param_type 
                WHEN 'RESULTSET' THEN 'array'
                WHEN 'INT' THEN 'integer'
                WHEN 'BOOLEAN' THEN 'boolean'
                ELSE 'string'
                END
                , 9);
            IF (a.comments IS NOT NULL) THEN
                append('description: ' || a.comments, 9);
            END IF;

        END LOOP;

        v_cnt := 0;
        FOR a IN (
            SELECT a.name, a.access_method, a.source_type, a.param_type, a.comments
            FROM user_ords_parameters a
            JOIN user_ords_handlers h ON h.id = a.handler_id
            JOIN user_ords_templates t ON t.id = h.template_id AND t.uri_template = p.URI_TEMPLATE
            JOIN user_ords_services s ON s.template_id = t.id AND s.handler_id = h.id AND s.method IN ('GET')
            WHERE a.access_method = 'IN'
        ) LOOP
            v_cnt := v_cnt + 1;

            IF (v_cnt = 1) THEN
                append('parameters:', 3);
            END IF;

            append('- name: ' || a.name, 4);
            IF (INSTR(p.uri_template, a.name) > 0) THEN
                append('in: path', 5);
                append('required: true', 5);
            ELSE 
                append('in: query', 5);
                append('required: false', 5);
            END IF;
            IF (a.comments IS NOT NULL) THEN
                append('description: ' || a.comments, 5);
            END IF;
            append('schema:', 5);
            append('type: ' || CASE a.param_type 
                WHEN 'RESULTSET' THEN 'array'
                WHEN 'INT' THEN 'integer'
                WHEN 'BOOLEAN' THEN 'boolean'
                ELSE 'string'
                END
                , 6);

        END LOOP;

    END LOOP;

    append('components:', 0);
    append('securitySchemes:', 1);
    append('BearerAuth:', 2);
    append('type: http', 3);
    append('scheme: bearer', 3);
    append('bearerFormat: JWT', 3);

END;
/
