CREATE OR REPLACE PACKAGE pck_api_auth AS -- Package provides methods for issuing and validating tokens 

    FUNCTION pwd( -- Function returns hashed password
        p_password VARCHAR2 -- Password
    ) RETURN VARCHAR2; -- Hashed password
    
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

    PROCEDURE cleanup; -- Procedure revokes expired tokens

    FUNCTION uuid(-- Function returns user unique ID from JWT token passed in the Authorization header as a Bearer token
        p_check_expiration CHAR DEFAULT 'Y' -- Check token expiration (Y/N)
    ) 
    RETURN app_users.uuid%TYPE; -- User unique ID

    FUNCTION refresh(-- Function returns user unique ID from cookie passed in the request
        p_cookie_name VARCHAR2 DEFAULT 'refresh_token', -- Cookie name
        p_check_expiration CHAR DEFAULT 'Y' -- Check token expiration (Y/N)
    ) 
    RETURN app_users.uuid%TYPE; -- User unique ID

    FUNCTION priv( -- Function checks user privileges (Deprecated)
        p_uuid app_users.uuid%TYPE DEFAULT NULL, -- User unique ID (NULL - current user from bearer token)
        p_role app_roles.role%TYPE DEFAULT NULL -- Privilege
    ) RETURN app_permissions.permission%TYPE; -- Privilege (NULL - no pprivilege)

    FUNCTION role( -- Function checks if user has role
        p_uuid app_users.uuid%TYPE DEFAULT NULL, -- User unique ID (NULL - current user from bearer token)
        p_role app_roles.role%TYPE -- Role
    ) RETURN PLS_INTEGER; -- Permission count for the role (0 - no role)

    FUNCTION perm( -- Function checks user permission
        p_uuid app_users.uuid%TYPE DEFAULT NULL, -- User unique ID (NULL - current user from bearer token)
        p_role app_roles.role%TYPE, -- Role
        p_permission app_permissions.permission%TYPE -- Permission
    ) RETURN PLS_INTEGER; -- Permission (0 - no permission, 1 - has permission)

    PROCEDURE http_401( -- Procedure sends HTTP 401 Unauthorized status
        p_error VARCHAR2 DEFAULT NULL -- Error message
    );

    PROCEDURE http_403( -- Procedure sends HTTP 403 Forbidden status
        p_error VARCHAR2 DEFAULT NULL -- Error message
    );

END;
/
