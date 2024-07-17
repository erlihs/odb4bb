CREATE OR REPLACE PACKAGE BODY pck_api_openai AS  

  -- PRIVATE
  
  FUNCTION j(p_string CLOB) RETURN CLOB AS
    l_clob CLOB;
  BEGIN
    l_clob := REPLACE(REPLACE(REPLACE(p_string, CHR(10), ' '), CHR(13), ' '), '  ', ' ');
    RETURN l_clob;
  END;


  -- PUBLIC
  
  PROCEDURE speech(
    p_api_key VARCHAR2,
    p_model VARCHAR2,
    p_input VARCHAR2,
    p_voice VARCHAR2,
    p_response_format VARCHAR2,
    p_speed FLOAT, 
    r_speech OUT BLOB 
  ) AS
    v_payload CLOB;
    v_req utl_http.req;
  BEGIN

    v_payload := '{' 
      || '"model": "' || p_model || '"' 
      || ', "input": "' || j(p_input) || '"' 
      || ', "voice": "' || p_voice || '"'
      || ', "response_format": "' || p_response_format || '"'
      || ', "speed": "' || p_speed || '"'
      || '}';

    pck_api_http.request(v_req, 'POST', 'https://api.openai.com/v1/audio/speech');
    pck_api_http.request_auth_token(v_req, p_api_key);
    pck_api_http.request_content_type(v_req, 'application/json');
    pck_api_http.request_charset(v_req, 'UTF-8');
    pck_api_http.request_json(v_req, v_payload);
    pck_api_http.response_binary(v_req, r_speech);
    
  END;

  PROCEDURE speech(
    p_api_key VARCHAR2,
    p_input VARCHAR2,
    r_speech OUT BLOB 
  ) AS
  BEGIN
    speech(
      p_api_key,
      'tts-1', -- model
      p_input,
      'alloy', -- voice
      'mp3', --format
      1, -- speed 
      r_speech 
    );
  END;

  PROCEDURE transcript(
    p_api_key VARCHAR2,
    p_file BLOB,
    p_filename VARCHAR2,
    p_model VARCHAR2,
    p_language VARCHAR2,
    p_prompt VARCHAR2,
    p_response_format VARCHAR2,
    p_temperature VARCHAR2,
    r_transcript OUT VARCHAR2
  ) AS
    v_req utl_http.req;
  BEGIN

    pck_api_http.request(v_req, 'POST', 'https://api.openai.com/v1/audio/transcriptions');
    pck_api_http.request_auth_token(v_req, p_api_key);

    pck_api_http.request_multipart_start(v_req);
    pck_api_http.request_multipart_varchar2(v_req, 'model', p_model);
    pck_api_http.request_multipart_varchar2(v_req, 'language', p_language);
    pck_api_http.request_multipart_varchar2(v_req, 'prompt', p_prompt);
    pck_api_http.request_multipart_varchar2(v_req, 'response_format', p_response_format);
    pck_api_http.request_multipart_varchar2(v_req, 'temperature', p_temperature);
    pck_api_http.request_multipart_blob(v_req, 'file', p_filename, p_file);
    pck_api_http.request_multipart_end(v_req);

    pck_api_http.response_text(v_req, r_transcript);

  END;

  PROCEDURE translations(
    p_api_key VARCHAR2,
    p_file BLOB,
    p_filename VARCHAR2,
    p_model VARCHAR2,
    p_language VARCHAR2,
    p_prompt VARCHAR2,
    p_response_format VARCHAR2,
    p_temperature VARCHAR2,
    r_transcript OUT VARCHAR2
  ) AS
    v_req utl_http.req;
  BEGIN

    pck_api_http.request(v_req, 'POST', 'https://api.openai.com/v1/audio/translations');
    pck_api_http.request_auth_token(v_req, p_api_key);

    pck_api_http.request_multipart_start(v_req);
    pck_api_http.request_multipart_varchar2(v_req, 'model', p_model);
    pck_api_http.request_multipart_varchar2(v_req, 'language', p_language);
    pck_api_http.request_multipart_varchar2(v_req, 'prompt', p_prompt);
    pck_api_http.request_multipart_varchar2(v_req, 'response_format', p_response_format);
    pck_api_http.request_multipart_varchar2(v_req, 'temperature', p_temperature);
    pck_api_http.request_multipart_blob(v_req, 'file', p_filename, p_file);
    pck_api_http.request_multipart_end(v_req);

    pck_api_http.response_text(v_req, r_transcript);

  END;
  
  PROCEDURE completion( 
    p_api_key VARCHAR2, 
    p_model VARCHAR2,
    p_prompt VARCHAR2,
    p_message CLOB,
    r_message OUT CLOB 
  ) AS
    v_payload CLOB;
    v_messages CLOB;
    v_req utl_http.req;
  BEGIN

    v_payload := '{
      "model": "' || p_model || '",
      "messages": [
        {"role": "system","content": "' || j(p_prompt) || '"},
        {"role": "user","content": "' || j(p_message) || '"}
      ]
    }';

    pck_api_http.request(v_req, 'POST', 'https://api.openai.com/v1/chat/completions');
    pck_api_http.request_auth_token(v_req, p_api_key);
    pck_api_http.request_content_type(v_req, 'application/json');
    pck_api_http.request_charset(v_req, 'UTF-8');
    pck_api_http.request_json(v_req, v_payload);
    pck_api_http.response_text(v_req, v_messages);

    SELECT JSON_VALUE(v_messages,'$.choices[0].message.content') INTO r_message from dual;

  END;
  
  PROCEDURE moderations( 
    p_api_key VARCHAR2, 
    p_model VARCHAR2,
    p_prompt VARCHAR2,
    r_moderations OUT CLOB 
  ) AS
    v_req utl_http.req;
    v_payload CLOB;
  BEGIN

    v_payload := '{"model": "' || p_model || '", "input": "' || j(p_prompt) || '"}';

    pck_api_http.request(v_req, 'POST', 'https://api.openai.com/v1/moderations');
    pck_api_http.request_auth_token(v_req, p_api_key);
    pck_api_http.request_content_type(v_req, 'application/json');
    pck_api_http.request_charset(v_req, 'UTF-8');
    pck_api_http.request_json(v_req, v_payload);
    pck_api_http.response_text(v_req, r_moderations);

  END;

  PROCEDURE vision( 
    p_api_key VARCHAR2, 
    p_model VARCHAR2, 
    p_prompt VARCHAR2, 
    p_image CLOB, 
    r_message OUT CLOB 
  ) AS
    v_req utl_http.req;
    v_payload CLOB;
  BEGIN

    v_payload := '{
      "model": "' || p_model || '",
      "messages": [
      {
          "role": "user",
          "content": [
          {
              "type": "text",
              "text": "' || j(p_prompt) || '"
          },
          {
              "type": "image_url",
              "image_url": {
              "url": "data:image/png;base64,'|| p_image || '"
              }
          }
          ]
      }
      ],
      "max_tokens": 600
    }';

    pck_api_http.request(v_req, 'POST', 'https://api.openai.com/v1/chat/completions');
    pck_api_http.request_auth_token(v_req, p_api_key);
    pck_api_http.request_content_type(v_req, 'application/json');
    pck_api_http.request_charset(v_req, 'UTF-8');
    pck_api_http.request_json(v_req, v_payload);
    pck_api_http.response_text(v_req, r_message);   
                
  END;

END;
/
