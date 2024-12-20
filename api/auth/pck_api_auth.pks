CREATE OR REPLACE PACKAGE pck_api_auth AS -- Package provides methods for issuing and validating tokens 

    FUNCTION auth( -- Function authenticates user
        p_username app_users.username%TYPE, -- Username
        p_password app_users.password%TYPE -- Password
    ) RETURN app_users.uuid%TYPE; -- User unique ID

    PROCEDURE auth( -- Procedure authenticates user
        p_username app_users.username%TYPE, -- Username
        p_password app_users.password%TYPE, -- Password
        r_uuid OUT app_users.uuid%TYPE -- User unique ID
    );

    PROCEDURE token( -- Procedure issues a JWT token
        p_uuid app_users.uuid%TYPE, -- User unique ID
        p_type app_token_types.id%TYPE, -- Token type (APP_TOKEN_TYPES.ID)
        r_token OUT app_tokens.token%TYPE -- Token
    );

    FUNCTION token( -- Function issues a JWT token
        p_uuid app_users.uuid%TYPE, -- User unique ID
        p_type app_token_types.id%TYPE -- Token type (APP_TOKEN_TYPES.ID)
    ) RETURN app_tokens.token%TYPE; -- Token

    PROCEDURE reset( -- Procedure revokes a JWT token
        p_uuid app_users.uuid%TYPE, -- User unique ID
        p_type app_token_types.id%TYPE DEFAULT NULL -- Token type (APP_TOKEN_TYPES.ID), NULL - all tokens
    );

    FUNCTION uuid(-- Function returns user unique ID from JWT token passed in the Authorization header as a Bearer token
        p_check_expiration CHAR DEFAULT 'Y' -- Check token expiration (Y/N)
    ) 
    RETURN app_users.uuid%TYPE; -- User unique ID

    FUNCTION refresh(-- Function returns user unique ID from cookie passed in the request
        p_cookie_name VARCHAR2 DEFAULT 'refresh_token', -- Cookie name
        p_check_expiration CHAR DEFAULT 'Y' -- Check token expiration (Y/N)
    ) 
    RETURN app_users.uuid%TYPE; -- User unique ID

    FUNCTION priv( -- Function checks user privileges
        p_uuid app_users.uuid%TYPE DEFAULT NULL, -- User unique ID (NULL - current user from bearer token)
        p_role app_roles.role%TYPE DEFAULT NULL -- Privilege
    ) RETURN app_permissions.permission%TYPE; -- Privilege (NULL - no pprivilege)

    PROCEDURE http_401; -- Procedure sends HTTP 401 Unauthorized status

    PROCEDURE http_403; -- Procedure sends HTTP 403 Forbidden status

END;
/
