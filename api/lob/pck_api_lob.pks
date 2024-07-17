CREATE OR REPLACE PACKAGE pck_api_lob AS -- Package for LOB processing. Credit: https://github.com/paulzip-dev/Base64

  SUBTYPE BOOLEAN IS PLS_INTEGER RANGE 0..1;

  FUNCTION clob_to_blob( -- Function converts CLOB to BLOB
    p_clob CLOB, -- CLOB
    p_charset_id INTEGER DEFAULT dbms_lob.default_csid, -- Character set ID 
    p_error_on_warning BOOLEAN DEFAULT 0 -- Raise exception on warning (0 - No, 1 - Yes)
  ) RETURN BLOB; -- BLOB

  FUNCTION blob_to_clob( --  Function converts BLOB to CLOB
    p_blob BLOB, -- BLOB
    p_charset_id INTEGER DEFAULT dbms_lob.default_csid, -- Character set ID 
    p_error_on_warning BOOLEAN DEFAULT 0 -- Raise exception on warning (0 - No, 1 - Yes)
  ) RETURN CLOB; -- CLOB

  FUNCTION blob_to_base64( -- Function encodes BLOB to BASE64
    p_blob BLOB, -- BLOB
    p_newline BOOLEAN DEFAULT 1 -- Split in chunks (0 - No, 1 - Yes) 
  ) RETURN CLOB; -- CLOB

  FUNCTION clob_to_base64( -- Function encodes CLOB to BASE64
    p_clob CLOB, -- CLOB
    p_newline BOOLEAN DEFAULT 1 -- Split in chunks (0 - No, 1 - Yes) 
  ) RETURN CLOB; -- CLOB

  FUNCTION varchar2_to_base64( -- Function encodes VARCHAR2 to BASE64
    p_varchar2 VARCHAR2, -- VARCHAR2
    p_newline BOOLEAN DEFAULT 1 -- Split in chunks (0 - No, 1 - Yes) 
  ) RETURN CLOB; -- CLOB

  FUNCTION base64_to_blob( -- Function decodes BASE64 to BLOB
    p_base64 CLOB -- BASE64
  ) RETURN BLOB; -- BLOB

  FUNCTION base64_to_clob( -- Function decodes BASE64 to CLOB
    p_base64 CLOB -- BASE64
  ) RETURN CLOB; -- CLOB

  FUNCTION base64_to_varchar2( -- Function decodes BASE64 to VARCHAR2
    p_base64 CLOB -- BASE64
  ) RETURN VARCHAR2; -- VARCHAR2

END;
/
