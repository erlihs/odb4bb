CREATE OR REPLACE PACKAGE pck_app_demo AS -- Demo package
  
    PROCEDURE get_status( -- Get status of the application
        r_version OUT VARCHAR2, -- Version of the application
        r_created OUT DATE, -- Date of creation
        r_dbsize OUT SYS_REFCURSOR, -- Database size
        r_ace OUT SYS_REFCURSOR -- Acces control list entries
    );

END;
/