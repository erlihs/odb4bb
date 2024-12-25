CREATE OR REPLACE PACKAGE pck_api_validate AS -- Package to validate data (Experimental)

    /*
    [
        {"type":"required","value":null,"message":"Value is required"},
        {"type":"in-range","value":{"min":1,"max":10},"message":"Value must be between 1 and 10"}
    ]
    */

     FUNCTION validate( -- Function to validate data
        p_value VARCHAR2, -- Value to validate
        p_type VARCHAR2, -- Type of validation
        p_message VARCHAR2, -- Message to return if validation fails
        p_criteria VARCHAR2 DEFAULT NULL -- Criteria for validation
    ) RETURN VARCHAR2; -- Return message if validation fails

    PROCEDURE validate( -- Procedure to validate multiple values
        p_name VARCHAR2, -- Name of value to validate
        p_value VARCHAR2, -- Value to validate
        p_rules VARCHAR2, -- Rules for validation
        r_errors OUT SYS_REFCURSOR -- Cursor to return validation errors
    ); -- Procedure to validate multiple values

END;
/
