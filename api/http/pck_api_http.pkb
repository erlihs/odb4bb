CREATE OR REPLACE PACKAGE BODY pck_api_http AS

  SUBTYPE BOOLEAN IS PLS_INTEGER RANGE 0..1;

  c_debug CONSTANT BOOLEAN := 0;
  c_boundary CONSTANT VARCHAR2(30 CHAR) := 'gc0p4Jq0M2Yt08jU534c0p';

  FUNCTION mime_type(
    p_ext VARCHAR2
  ) RETURN VARCHAR2 
  AS
  BEGIN

    RETURN 
      CASE TRIM(LOWER(p_ext))
        WHEN 'aac' THEN 'audio/aac'
        WHEN 'abw' THEN 'application/x-abiword'
        WHEN 'apng' THEN 'image/apng'
        WHEN 'arc' THEN 'application/x-freearc'
        WHEN 'avif' THEN 'image/avif'
        WHEN 'avi' THEN 'video/x-msvideo'
        WHEN 'azw' THEN 'application/vnd.amazon.ebook'
        WHEN 'bin' THEN 'application/octet-stream'
        WHEN 'bmp' THEN 'image/bmp'
        WHEN 'bz' THEN 'application/x-bzip'
        WHEN 'bz2' THEN 'application/x-bzip2'
        WHEN 'cda' THEN 'application/x-cdf'
        WHEN 'csh' THEN 'application/x-csh'
        WHEN 'css' THEN 'text/css'
        WHEN 'csv' THEN 'text/csv'
        WHEN 'doc' THEN 'application/msword'
        WHEN 'docx' THEN 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        WHEN 'eot' THEN 'application/vnd.ms-fontobject'
        WHEN 'epub' THEN 'application/epub+zip'
        WHEN 'gz' THEN 'application/gzip'
        WHEN 'gif' THEN 'image/gif'
        WHEN 'htm' THEN 'text/html'
        WHEN 'html' THEN 'text/html'
        WHEN 'ico' THEN 'image/vnd.microsoft.icon'
        WHEN 'ics' THEN 'text/calendar'
        WHEN 'jar' THEN 'application/java-archive'
        WHEN 'jpeg' THEN 'image/jpeg'
        WHEN 'jpg' THEN 'image/jpeg'
        WHEN 'js' THEN 'text/javascript'
        WHEN 'json' THEN 'application/json'
        WHEN 'jsonld' THEN 'application/ld+json'
        WHEN 'mid' THEN 'audio/midi, audio/x-midi'
        WHEN 'midi' THEN 'audio/midi, audio/x-midi'
        WHEN 'mjs' THEN 'text/javascript'
        WHEN 'mp3' THEN 'audio/mpeg'
        WHEN 'mp4' THEN 'video/mp4'
        WHEN 'mpeg' THEN 'video/mpeg'
        WHEN 'mpkg' THEN 'application/vnd.apple.installer+xml'
        WHEN 'odp' THEN 'application/vnd.oasis.opendocument.presentation'
        WHEN 'ods' THEN 'application/vnd.oasis.opendocument.spreadsheet'
        WHEN 'odt' THEN 'application/vnd.oasis.opendocument.text'
        WHEN 'oga' THEN 'audio/ogg'
        WHEN 'ogv' THEN 'video/ogg'
        WHEN 'ogx' THEN 'application/ogg'
        WHEN 'opus' THEN 'audio/opus'
        WHEN 'otf' THEN 'font/otf'
        WHEN 'png' THEN 'image/png'
        WHEN 'pdf' THEN 'application/pdf'
        WHEN 'php' THEN 'application/x-httpd-php'
        WHEN 'ppt' THEN 'application/vnd.ms-powerpoint'
        WHEN 'pptx' THEN 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
        WHEN 'rar' THEN 'application/vnd.rar'
        WHEN 'rtf' THEN 'application/rtf'
        WHEN 'sh' THEN 'application/x-sh'
        WHEN 'svg' THEN 'image/svg+xml'
        WHEN 'tar' THEN 'application/x-tar'
        WHEN 'tif' THEN 'image/tiff'
        WHEN 'tiff' THEN 'image/tiff'
        WHEN 'ts' THEN 'video/mp2t'
        WHEN 'ttf' THEN 'font/ttf'
        WHEN 'txt' THEN 'text/plain'
        WHEN 'vsd' THEN 'application/vnd.visio'
        WHEN 'wav' THEN 'audio/wav'
        WHEN 'weba' THEN 'audio/webm'
        WHEN 'webm' THEN 'video/webm'
        WHEN 'webp' THEN 'image/webp'
        WHEN 'woff' THEN 'font/woff'
        WHEN 'woff2' THEN 'font/woff2'
        WHEN 'xhtml' THEN 'application/xhtml+xml'
        WHEN 'xls' THEN 'application/vnd.ms-excel'
        WHEN 'xlsx' THEN 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        WHEN 'xml' THEN 'application/xml'
        WHEN 'xul' THEN 'application/vnd.mozilla.xul+xml'
        WHEN 'zip' THEN 'application/zip'
        WHEN '7z' THEN 'application/x-7z-compressed'
        ELSE 'application/octet-stream'
        END;
  END;

  PROCEDURE request(
    p_req IN OUT utl_http.req,
    p_method VARCHAR2,
    p_url VARCHAR2,
    p_version VARCHAR2 DEFAULT 'HTTP/1.1'
  )
  AS
  BEGIN
    IF c_debug = 1 THEN dbms_output.put_line(p_method || ' ' || p_url); END IF;
    p_req := utl_http.begin_request(p_url, p_method, p_version);
  END;

  PROCEDURE request_auth_basic(
    p_req IN OUT utl_http.req,
    p_username VARCHAR2,
    p_password VARCHAR2
  ) AS
  BEGIN
    IF c_debug = 1 THEN dbms_output.put_line('Authorization: Basic ' || p_username || ':' || REGEXP_REPLACE(p_password, '-\w', '*')); END IF;
    utl_http.set_authentication(p_req, p_username, p_password);
  END;

  PROCEDURE request_auth_token(
    p_req IN OUT utl_http.req,
    p_token VARCHAR2
  ) AS
  BEGIN
    IF c_debug = 1 THEN dbms_output.put_line('Authorization: Bearer ' || REGEXP_REPLACE(p_token, '\w', '*')); END IF;
    utl_http.set_header(p_req, 'Authorization', 'Bearer ' || p_token);
  END;

  PROCEDURE request_auth_wallet( -- https://oracle-base.com/articles/misc/utl_http-and-ssl
    p_wallet_path VARCHAR2,
    p_wallet_password VARCHAR2
  ) AS
  BEGIN
    IF c_debug = 1 THEN dbms_output.put_line('Authorization: Wallet file:' || p_wallet_path || ' : ' || REGEXP_REPLACE(p_wallet_password, '\w', '*')); END IF;
    utl_http.set_wallet('file:' || p_wallet_path, p_wallet_password);
  END;

  PROCEDURE request_content_type(
    p_req IN OUT utl_http.req,
    p_content_type VARCHAR2
  ) AS
  BEGIN
    IF p_content_type IS NOT NULL THEN 
      IF c_debug = 1 THEN dbms_output.put_line('Header content-type: ' || p_content_type); END IF;
      utl_http.set_header(p_req, 'content-type', p_content_type);
    END IF;
  END;

  PROCEDURE request_charset(
    p_req IN OUT utl_http.req,
    p_body_charset VARCHAR2
  ) AS
  BEGIN
    IF p_body_charset IS NOT NULL THEN
      IF c_debug = 1 THEN dbms_output.put_line('Charset: ' || p_body_charset); END IF;
      utl_http.set_body_charset(p_body_charset);
    END IF;
  END;

  PROCEDURE request_json(
    p_req IN OUT utl_http.req,
    p_json CLOB
  ) AS 
    v_payload_length PLS_INTEGER := dbms_lob.getlength(p_json);
    v_amount PLS_INTEGER := 2000;
    v_offset PLS_INTEGER := 1;
    v_buffer VARCHAR2(6000);
  BEGIN
      IF c_debug = 1 THEN dbms_output.put_line('Transfer-Encoding: chunked'); END IF;
      utl_http.set_header (p_req, 'Transfer-Encoding', 'chunked');
      WHILE (v_offset < v_payload_length)
      LOOP
          dbms_lob.read (p_json, v_amount, v_offset, v_buffer);
          IF c_debug = 1 THEN dbms_output.put_line(v_buffer); END IF;
          utl_http.write_raw(p_req, utl_raw.cast_to_raw(v_buffer));            
          v_offset := v_offset + v_amount;
      END LOOP;
  END;

  PROCEDURE request_multipart_start(
    p_req IN OUT utl_http.req,
    p_charset VARCHAR2 DEFAULT 'UTF-8'
  ) AS 
  BEGIN
    IF c_debug = 1 THEN 
      dbms_output.put_line('Content-Type: multipart/form-data; boundary="' || c_boundary || '"' || CASE WHEN p_charset IS NOT NULL THEN '; charset=UTF-8' ELSE '' END); 
      dbms_output.put_line('Transfer-Encoding: chunked'); 
    END IF;
    utl_http.set_header(p_req, 'Content-Type', 'multipart/form-data; boundary="' || c_boundary || '"' || CASE WHEN p_charset IS NOT NULL THEN '; charset=UTF-8' ELSE '' END);
    utl_http.set_header (p_req, 'Transfer-Encoding', 'chunked');
  END;

  PROCEDURE request_multipart_varchar2(
    p_req IN OUT utl_http.req,
    p_name VARCHAR2,
    p_value VARCHAR2,
    p_charset VARCHAR2 DEFAULT 'UTF-8'
  ) AS 
    v_chunk CLOB := ''
        || '--' || c_boundary || utl_tcp.crlf
        || 'Content-Disposition: form-data; name="' || p_name || '"' || utl_tcp.crlf
        || 'Content-Type: "application/text' || CASE WHEN p_charset IS NOT NULL THEN '; charset=utf-8"' ELSE '"' END || utl_tcp.crlf
        || utl_tcp.crlf
        || utl_url.escape(p_value) || utl_tcp.crlf;
  BEGIN
    IF c_debug = 1 THEN dbms_output.put_line(v_chunk); END IF;
    utl_http.write_text(p_req, v_chunk);
  END;

  PROCEDURE request_multipart_blob(
    p_req IN OUT utl_http.req,
    p_name VARCHAR2,
    P_filename VARCHAR2,
    p_blob BLOB
  ) AS 
    v_chunk CLOB := ''
        || '--' || c_boundary || utl_tcp.crlf
        || 'Content-Disposition: form-data; name="' || p_name || '"; filename="' || p_filename || '"' || utl_tcp.crlf
        || 'Content-Type: ' || mime_type(SUBSTR(p_filename, NULLIF(INSTR(p_filename, '.', -1) +1, 1))) || utl_tcp.crlf
        || utl_tcp.crlf;
    v_offset number := 1;
    v_amount number := 2000;
    v_buffer raw(32767);
  BEGIN
    IF c_debug = 1 THEN dbms_output.put_line(v_chunk); END IF;
    utl_http.write_text(p_req, v_chunk);

    IF c_debug = 1 THEN dbms_output.put_line('Writing out ' || dbms_lob.getlength(p_blob) || ' bytes..'); END IF;
    WHILE (v_offset < DBMS_LOB.getlength(p_blob))
    LOOP
        DBMS_LOB.read(p_blob, v_amount, v_offset, v_buffer);
        utl_http.write_raw(p_req, v_buffer);
        v_offset := v_offset + v_amount;
    END LOOP;    
  
  END;

  PROCEDURE request_multipart_end(
    p_req IN OUT utl_http.req
  ) AS 
  BEGIN
    IF c_debug = 1 THEN dbms_output.put_line(utl_tcp.crlf || '--' || c_boundary || '--'); END IF;
    utl_http.write_text(p_req, utl_tcp.crlf || '--' || c_boundary || '--');
  END;

  PROCEDURE response_text(
    p_req IN OUT utl_http.req,
    r_clob OUT CLOB
  )
  AS
    v_res utl_http.resp;
    v_chunk VARCHAR2(4000);
    v_result CLOB;
  BEGIN
    v_res := utl_http.get_response(p_req);
    dbms_lob.createtemporary(v_result, true, dbms_lob.call);
    BEGIN
      LOOP
        utl_http.read_line(v_res, v_chunk);
        IF c_debug = 1 THEN dbms_output.put_line(length(v_chunk)  || ' bytes..'); END IF;
        dbms_lob.writeappend(v_result, length(v_chunk), v_chunk);
      END LOOP;
      utl_http.end_response(v_res);
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        utl_http.end_response(v_res);
    END;
    r_clob := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      utl_http.end_response(v_res);
      RAISE;
  END;

  PROCEDURE response_binary(
    p_req IN OUT utl_http.req,
    r_blob OUT BLOB
  )
  AS
    v_res utl_http.resp;
    v_chunk RAW(32767);
    v_result BLOB;
  BEGIN
    v_res := utl_http.get_response(p_req);
    dbms_lob.createtemporary(v_result, true, dbms_lob.call);
    BEGIN
      LOOP
        utl_http.read_raw(v_res, v_chunk);
        IF c_debug = 1 THEN dbms_output.put_line(utl_raw.length(v_chunk)  || ' bytes..'); END IF;
        dbms_lob.writeappend(v_result, utl_raw.length(v_chunk), v_chunk);
      END LOOP;
      utl_http.end_response(v_res);
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        utl_http.end_response(v_res);
    END;
    r_blob := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      utl_http.end_response(v_res);
      RAISE;
  END;

END;  
/
