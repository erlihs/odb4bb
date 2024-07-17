CREATE OR REPLACE PACKAGE BODY pck_api_google AS 

  PROCEDURE streetview_metadata(
    p_api_key VARCHAR2,
    p_address VARCHAR2,
    r_metadata OUT VARCHAR2
  ) AS
    v_req utl_http.req;
    v_uri VARCHAR2(2000 CHAR) := 'https://maps.googleapis.com/maps/api/streetview/metadata' 
      || '?key=' || p_api_key || CHR(38) 
      || 'location=' || utl_url.escape(p_address, url_charset => 'AL32UTF8');
  BEGIN
      pck_api_http.request(v_req, 'GET', v_uri);
      pck_api_http.request_content_type(v_req, 'application/json');
      pck_api_http.request_charset(v_req, 'UTF-8');
      pck_api_http.response_text(v_req, r_metadata);        
  END;

  PROCEDURE streetview_image(
    p_api_key VARCHAR2,
    p_address VARCHAR2,
    r_image OUT BLOB
  ) AS
    v_req utl_http.req;
    v_uri VARCHAR2(2000 CHAR) := 'https://maps.googleapis.com/maps/api/streetview' 
      || '?key=' || p_api_key || CHR(38) 
      || 'location=' || utl_url.escape(p_address, url_charset => 'AL32UTF8') || CHR(38) 
      || 'size=512x512';
  BEGIN
      pck_api_http.request(v_req, 'GET', v_uri);
      pck_api_http.response_binary(v_req, r_image);        
  END;
 
END;
/
