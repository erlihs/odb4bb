CREATE OR REPLACE PACKAGE pck_api_validate AS -- Package to validate data (Experimental)

    /*
    {
        "rules":
            [
                {"type":"required","params":true,"message":"Value is required"},
                {"type":"in-range","params":{"min":1,"max":10},"message":"Value must be between 1 and 10"}
            ]
    }
    */
    TYPE t_error IS RECORD ( -- Error record type
        name VARCHAR2(200 CHAR), -- Field name
        message VARCHAR2(2000 CHAR) -- Error message
    );
    TYPE t_errors IS TABLE OF t_error; -- Error record table type

    FUNCTION validate( -- Procedure to validate multiple values
        p_name VARCHAR2, -- Name of value to validate
        p_value VARCHAR2, -- Value to validate
        p_options VARCHAR2, -- Rules for validation
        r_errors OUT SYS_REFCURSOR -- Cursor to return validation errors
    ) RETURN PLS_INTEGER; -- Returns number of validation errors

END;
/
