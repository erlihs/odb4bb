CREATE OR REPLACE PACKAGE pck_api_http AS -- Package for HTTP call processing

  FUNCTION mime_type( -- Function returns mime type from file extention, e.g. mp3->audio/mpeg
    p_ext VARCHAR2 --  File extention
  ) RETURN VARCHAR2; -- Mime type

  PROCEDURE request( -- Function initiates HTTP request
    p_req IN OUT utl_http.req, -- HTTP request
    p_method VARCHAR2, -- Method (GET, POST, PUT, DELETE, ..)
    p_url VARCHAR2, -- Url
    p_version VARCHAR2 DEFAULT 'HTTP/1.1' --  Version
  ); 

  PROCEDURE request_auth_basic( -- Procedure authenticates user with username and password
    p_req IN OUT utl_http.req, -- HTTP request
    p_username VARCHAR2, -- User name
    p_password VARCHAR2 -- Password
  );

  PROCEDURE request_auth_token( -- Procedure adds Bearer token to the request
    p_req IN OUT utl_http.req, -- HTTP request
    p_token VARCHAR2 -- Token
  );

  PROCEDURE request_auth_wallet( -- Procedure adds Oracle Wallet to HTTP connection (must be called before starting request)
    p_wallet_path VARCHAR2, -- Path to Oracle Wallet (without "file" prefix)
    p_wallet_password VARCHAR2 -- Wallet password
  );

  PROCEDURE request_content_type( -- Procedure adds content type header to the HTTP request
    p_req IN OUT utl_http.req, -- HTTP request
    p_content_type VARCHAR2 -- Content type
  );

  PROCEDURE request_charset( -- Procedure adds charset header to the HTTP request
    p_req IN OUT utl_http.req, -- HTTP request
    p_body_charset VARCHAR2 -- Charset
  );

  PROCEDURE request_json( -- Procedure adds JSON payload to the HTTP request
    p_req IN OUT utl_http.req, -- HTTP request
    p_json CLOB -- JSON data
  );

  PROCEDURE request_multipart_start( -- Procedure starts multipart form data request
    p_req IN OUT utl_http.req, -- HTTP request
    p_charset VARCHAR2 DEFAULT 'UTF-8' -- Charset
  );

  PROCEDURE request_multipart_varchar2( -- Procedure adds Varchar2 data to multipart form data 
    p_req IN OUT utl_http.req, -- HTTP request
    p_name VARCHAR2, -- Name
    p_value VARCHAR2, -- Value
    p_charset VARCHAR2 DEFAULT 'UTF-8' -- Charset
  );

  PROCEDURE request_multipart_blob( -- Procedure add file to multipart form data
    p_req IN OUT utl_http.req, -- HTTP request
    p_name VARCHAR2, -- Name
    P_filename VARCHAR2, -- File name  
    p_blob BLOB -- File content
  );

  PROCEDURE request_multipart_end( -- Procedure closes multipart data
    p_req IN OUT utl_http.req -- HTTP request
  );

  PROCEDURE response_text( -- Function returns text data from HTTP request
    p_req IN OUT utl_http.req, -- HTTP request
    r_clob OUT CLOB -- Response data
  );

  PROCEDURE response_binary( -- Function returns binary data from HTTP request
    p_req IN OUT utl_http.req, -- HTTP request
    r_blob OUT BLOB -- Response data
  );

END;
/
