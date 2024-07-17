CREATE OR REPLACE PACKAGE pck_api_google AS -- Package provides implementation of Google API 

  PROCEDURE streetview_metadata( -- Procedure returns metadata from Google Streeetview API
    p_api_key VARCHAR2, -- Google API key
    p_address VARCHAR2, -- Address  
    r_metadata OUT VARCHAR2 -- Metadata
  );

  PROCEDURE streetview_image( -- Procedure returns image from Google Streeetview API
    p_api_key VARCHAR2, -- Google  API key
    p_address VARCHAR2, -- Address
    r_image OUT BLOB -- Image
  );

END;
/
