CREATE OR REPLACE PACKAGE pck_api_audit AS -- Package defines audit logging API

    FUNCTION mrg( -- Helper function to concatenate key-value pairs
        p_key1 VARCHAR2 DEFAULT NULL, -- Key 1
        p_val1 VARCHAR2 DEFAULT NULL, -- Value 1
        p_key2 VARCHAR2 DEFAULT NULL, -- Key 2
        p_val2 VARCHAR2 DEFAULT NULL, -- Value 2
        p_key3 VARCHAR2 DEFAULT NULL, -- Key 3
        p_val3 VARCHAR2 DEFAULT NULL, -- Value 3
        p_key4 VARCHAR2 DEFAULT NULL, -- Key 4
        p_val4 VARCHAR2 DEFAULT NULL, -- Value 4
        p_key5 VARCHAR2 DEFAULT NULL, -- Key 5
        p_val5 VARCHAR2 DEFAULT NULL, -- Value 5
        p_key6 VARCHAR2 DEFAULT NULL, -- Key 6
        p_val6 VARCHAR2 DEFAULT NULL -- Value 6
    ) RETURN VARCHAR2; -- Concatenated key-value pairs

    FUNCTION log( -- Procedure logs an audit entry
        p_uuid app_audit.uuid%TYPE, -- User unique ID 
        p_severity app_audit.severity%TYPE, -- Severity level (D - debug, I - info, W - warning, E - error)
        p_action app_audit.action%TYPE, -- Action performed
        p_details app_audit.details%TYPE, -- Details
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP -- Entry creation timestamp
    ) RETURN app_audit.id%TYPE; -- Log entry identifier

    PROCEDURE dbg( -- Procedure logs a debug entry
        p_action app_audit.action%TYPE, -- Action performed
        p_details app_audit.details%TYPE DEFAULT NULL, -- Details
        p_uuid app_audit.uuid%TYPE DEFAULT NULL, -- User unique ID
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP -- Entry creation timestamp
    );

    PROCEDURE inf( -- Procedure logs an info entry
        p_action app_audit.action%TYPE, -- Action performed
        p_details app_audit.details%TYPE DEFAULT NULL, -- Details
        p_uuid app_audit.uuid%TYPE DEFAULT NULL, -- User unique ID
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP -- Entry creation timestamp
    );

    PROCEDURE wrn( -- Procedure logs a warning entry
        p_action app_audit.action%TYPE, -- Action performed
        p_details app_audit.details%TYPE DEFAULT NULL, -- Details
        p_uuid app_audit.uuid%TYPE DEFAULT NULL, -- User unique ID
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP -- Entry creation timestamp
    );

    PROCEDURE err( -- Procedure logs an error entry
        p_action app_audit.action%TYPE, -- Action performed
        p_details app_audit.details%TYPE DEFAULT NULL, -- Details
        p_uuid app_audit.uuid%TYPE DEFAULT NULL, -- User unique ID
        p_created app_audit.created%TYPE DEFAULT SYSTIMESTAMP -- Entry creation timestamp
    );

    PROCEDURE audit( -- Procedure logs multiple audit entries
        p_data CLOB, -- Audit data in JSON format [{severity, action, details, created}]
        p_uuid app_audit.uuid%TYPE DEFAULT NULL -- User unique ID
    );

END;
/
