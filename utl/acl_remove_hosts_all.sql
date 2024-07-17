DECLARE
    v_schema_name VARCHAR2(30 CHAR) := UPPER(TRIM(:schema_name));
BEGIN
    FOR e IN (
        SELECT
            host,
            lower_port,
            upper_port,
            privilege
        FROM dba_host_aces
        WHERE principal = v_schema_name
    ) LOOP
        DBMS_NETWORK_ACL_ADMIN.REMOVE_HOST_ACE (
            e.host,
            e.lower_port,
            e.upper_port,
            xs$ace_type(
                privilege_list => xs$name_list(e.privilege),
                principal_name => v_schema_name,
                principal_type => xs_acl.ptype_db
            )
        );
    END LOOP;
END;
/
