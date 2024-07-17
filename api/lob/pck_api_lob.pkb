CREATE OR REPLACE PACKAGE BODY pck_api_lob AS

  -- PRIVATE

  c_crlf CONSTANT VARCHAR2(2) := chr(13) || chr(10);
  c_whitespace CONSTANT VARCHAR2(6) := ' ' || chr(13) || chr(10) || chr(9) || chr(11) || chr(12);
  c_max_enc_chunk_len CONSTANT PLS_INTEGER := 23760; 
  c_max_dec_chunk_len CONSTANT PLS_INTEGER := 31680; 

  FUNCTION remove_whitespace(p_varchar2 VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN translate(p_varchar2, 'a' || c_whitespace, 'a');
  END;

  FUNCTION decode_raw(
    p_varchar2 VARCHAR2,
    p_remove_whitespace BOOLEAN DEFAULT 1
  ) RETURN RAW 
  AS
  BEGIN
    RETURN 
      CASE
        WHEN p_varchar2 IS NOT NULL 
          THEN utl_encode.base64_decode(utl_raw.cast_to_raw(
            CASE 
              WHEN p_remove_whitespace = 0 THEN p_varchar2 
              ELSE remove_whitespace(p_varchar2) 
              END
          ))  
        END;
  END;

  -- PUBLIC

  FUNCTION clob_to_blob(
    p_clob CLOB,
    p_charset_id INTEGER DEFAULT dbms_lob.default_csid,
    p_error_on_warning BOOLEAN DEFAULT 0
  ) RETURN BLOB 
  AS
    v_result BLOB;
    v_dest_offset INTEGER := 1;
    v_src_offset INTEGER := 1;
    v_lang_context INTEGER := dbms_lob.default_lang_ctx;
    v_warning INTEGER;
  BEGIN
    dbms_lob.createtemporary(v_result, true, dbms_lob.call);
    dbms_lob.converttoblob(
      dest_lob     => v_result,
      src_clob     => p_clob,
      amount       => dbms_lob.lobmaxsize,
      dest_offset  => v_dest_offset,
      src_offset   => v_src_offset,
      blob_csid    => p_charset_id,
      lang_context => v_lang_context,
      warning      => v_warning
    );
    IF v_warning <> dbms_lob.no_warning AND p_error_on_warning = 1 THEN
      raise_application_error(-20001, 'Error during lob conversion : '
        || CASE
          WHEN v_warning = dbms_lob.warn_inconvertible_char THEN 'Inconvertible character'
          ELSE 'Warning code '|| v_warning
          END
      );
    END IF;
    RETURN v_result;
  END;

  FUNCTION blob_to_clob(
    p_blob BLOB,
    p_charset_id INTEGER DEFAULT dbms_lob.default_csid,
    p_error_on_warning BOOLEAN DEFAULT 0
  ) RETURN CLOB 
  AS
    v_result CLOB;
    v_dest_offset INTEGER := 1;
    v_src_offset INTEGER := 1;
    v_lang_context INTEGER := dbms_lob.default_lang_ctx;
    v_warning INTEGER;
  BEGIN
    dbms_lob.createtemporary(v_result, true, dbms_lob.call);
    dbms_lob.converttoclob(
      dest_lob     => v_result,
      src_blob     => p_blob,
      amount       => dbms_lob.lobmaxsize,
      dest_offset  => v_dest_offset,
      src_offset   => v_src_offset,
      blob_csid    => p_charset_id,
      lang_context => v_lang_context,
      warning      => v_warning
    );
    IF v_warning <> dbms_lob.no_warning AND p_error_on_warning = 1 THEN
      raise_application_error(-20001, 'Error during lob conversion : '
        || CASE
          WHEN v_warning = dbms_lob.warn_inconvertible_char THEN 'Inconvertible character'
          ELSE 'Warning code '|| v_warning
          END
      );
    END IF;
    RETURN v_result;
  END;

  FUNCTION encode_raw(
    p_raw RAW, 
    p_newline BOOLEAN DEFAULT 1
  ) RETURN VARCHAR2 
  AS
  BEGIN
    RETURN 
      CASE
        WHEN p_raw IS NULL THEN NULL
        WHEN p_newline = 0 THEN REPLACE(utl_raw.cast_to_varchar2(utl_encode.base64_encode(p_raw)), c_crlf, '')
        ELSE RTRIM(utl_raw.cast_to_varchar2(utl_encode.base64_encode(p_raw)), c_crlf)
        END;
  END;

  FUNCTION blob_to_base64(
    p_blob BLOB,
    p_newline BOOLEAN DEFAULT 1
  ) RETURN CLOB
  AS
    v_length PLS_INTEGER := COALESCE(dbms_lob.getlength(p_blob), 0);
    v_offset PLS_INTEGER := 1;
    v_chunk VARCHAR2(32767);
    v_crlf VARCHAR2(2) := CASE WHEN p_newline = 0 THEN NULL ELSE c_crlf END;
    v_result CLOB;
  BEGIN

    CASE
      WHEN v_length = 0 THEN
        v_result := CASE WHEN p_blob IS NULL THEN NULL ELSE empty_clob() END;
      WHEN v_length <= c_max_enc_chunk_len THEN
        v_result := encode_raw(p_blob, p_newline);
      ELSE
        dbms_lob.createtemporary(v_result, true, dbms_lob.call);
        FOR i in 1..CEIL(v_length / c_max_enc_chunk_len)
        LOOP
          v_chunk := CASE WHEN i > 1 THEN v_crlf END || encode_raw(dbms_lob.substr(p_blob, c_max_enc_chunk_len, v_offset), p_newline);
          dbms_lob.writeappend(v_result, length(v_chunk), v_chunk);
          v_offset := v_offset + c_max_enc_chunk_len;
        END LOOP;
      END CASE;

    RETURN v_result;

  END;  

  FUNCTION clob_to_base64(
    p_clob CLOB,
    p_newline BOOLEAN DEFAULT 1
  ) RETURN CLOB
  AS
  BEGIN
    RETURN 
      CASE
        WHEN p_clob IS NULL OR p_clob = empty_clob() THEN p_clob
        ELSE blob_to_base64(clob_to_blob(p_clob), p_newline)
        END;
  END;  

  FUNCTION varchar2_to_base64(
    p_varchar2 VARCHAR2,
    p_newline BOOLEAN DEFAULT 1
  ) RETURN CLOB
  AS
  BEGIN
    RETURN encode_raw(utl_raw.cast_to_raw(p_varchar2), p_newline);
  END;  

  FUNCTION base64_to_blob(
    p_base64 CLOB
  ) RETURN BLOB
  AS
    v_offset INTEGER := 1;
    v_length PLS_INTEGER := COALESCE(dbms_lob.getlength(p_base64), 0);
    v_buffer VARCHAR2(32767);
    v_modulo PLS_INTEGER;
    v_overflow VARCHAR2(4);
    v_buffer_length PLS_INTEGER;
    v_amount INTEGER := c_max_dec_chunk_len;
    v_result BLOB;

    PROCEDURE append_chunk(p_chunk VARCHAR2) AS
      v_buffer_raw RAW(32767);
    BEGIN
      v_buffer_raw := decode_raw(p_chunk, p_remove_whitespace => 0);
      dbms_lob.writeappend(v_result, utl_raw.length(v_buffer_raw), v_buffer_raw);
    END;

  BEGIN

    CASE
      WHEN v_length = 0 THEN
        v_result := CASE WHEN p_base64 IS NULL THEN NULL ELSE empty_blob() END;
      WHEN v_length <= c_max_dec_chunk_len THEN
        v_result := decode_raw(p_base64);  
      WHEN v_length > c_max_dec_chunk_len THEN
        dbms_lob.createtemporary(v_result, false, dbms_lob.call);
        WHILE v_offset <= v_length
        LOOP
          dbms_lob.read(p_base64, v_amount, v_offset, v_buffer);
          v_buffer := remove_whitespace(v_buffer);
          v_buffer_length := length(v_buffer);
          v_modulo  := mod(v_buffer_length, 4);
          IF v_modulo > 0 THEN
            append_chunk(v_overflow || substr(v_buffer, 1, v_buffer_length - v_modulo));
            v_overflow := substr(v_buffer, -v_modulo);
          ELSE
            append_chunk(v_buffer);
            v_overflow := NULL;
          END IF;
          v_offset := v_offset + v_amount;
        END LOOP;
        IF v_overflow IS NOT NULL THEN
          append_chunk(v_overflow);
        END IF;
    END CASE;

    RETURN v_result;

  END;  

  FUNCTION base64_to_clob(
    p_base64 CLOB
  ) RETURN CLOB
  AS
    v_length PLS_INTEGER := COALESCE(dbms_lob.getlength(p_base64), 0);
  BEGIN
    RETURN CASE
      WHEN v_length = 0 THEN p_base64
      WHEN v_length <= c_max_dec_chunk_len THEN base64_to_varchar2(p_base64)
      WHEN v_length > c_max_dec_chunk_len THEN blob_to_clob(base64_to_blob(p_base64))
      END;
  END;  

  FUNCTION base64_to_varchar2(
    p_base64 CLOB
  ) RETURN VARCHAR2
  AS
  BEGIN
    RETURN utl_raw.cast_to_varchar2(decode_raw(p_base64));
  END;  

END;
/
