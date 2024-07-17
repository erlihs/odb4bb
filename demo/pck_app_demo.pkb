CREATE OR REPLACE PACKAGE BODY pck_app_demo AS -- Demo package
  
    PROCEDURE get_status( 
        r_version OUT VARCHAR2, 
        r_created OUT DATE, 
        r_dbsize OUT SYS_REFCURSOR, 
        r_ace OUT SYS_REFCURSOR 
    ) AS
    BEGIN

        SELECT banner INTO r_version FROM v$version;

        SELECT MIN(created) INTO r_created FROM user_users;

        OPEN r_dbsize FOR
        SELECT 
            tablespace_name AS "tablespace_name", 
            segment_name AS "segment_name", 
            bytes AS "bytes" 
        FROM user_segments
        ORDER BY bytes DESC;

        OPEN r_ace FOR
        SELECT 
            host AS "host",
            lower_port AS "lower_port",
            upper_port AS "upper_port",
            privilege AS "privilege",
            status AS "status"
        FROM  user_host_aces
        ORDER BY host;

    END;

END;
/
