DECLARE
    v_schema_name VARCHAR2(30 CHAR) := UPPER(TRIM(:schema_name));
    v_ace CLOB := :ace;
BEGIN

    FOR p IN (
        SELECT *
        FROM  json_table(v_ace, '$[*]' COLUMNS (
            host VARCHAR2(100) PATH '$.host',
            port NUMBER PATH '$.port',
            privilege VARCHAR2(100) PATH '$.privilege'
        ))     
    ) LOOP
        -- dbms_output.put_line(p.host || ' -> ' || p.port || ' -> ' || p.privilege);
        DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
            host => p.host,
            lower_port => p.port,
            upper_port => p.port,
            ace => xs$ace_type(
                privilege_list => xs$name_list(p.privilege),
                principal_name => v_schema_name,
                principal_type => xs_acl.ptype_db
            )
        );
    END LOOP;

END;
/

