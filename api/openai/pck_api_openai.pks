CREATE OR REPLACE PACKAGE pck_api_openai AS -- Package provides implementation of Open AI API 

  PROCEDURE speech( -- Procedure generates speech from text, https://platform.openai.com/docs/api-reference/audio
    p_api_key VARCHAR2, -- OpenAI API Key
    p_model VARCHAR2, -- Model (tts-1, tts-1-hd)
    p_input VARCHAR2, -- Text
    p_voice VARCHAR2, -- Voice (alloy, echo, fable, onyx, nova, shimmer)
    p_response_format VARCHAR2, -- File format (mp3, opus, aac, flac)
    p_speed FLOAT, -- Speed (0.25..4)
    r_speech OUT BLOB -- Audio file
  );

  PROCEDURE speech( -- Procedure generates speech from text, https://platform.openai.com/docs/api-reference/audio/createSpeech
    p_api_key VARCHAR2, -- OpenAI API Key
    p_input VARCHAR2, -- Text
    r_speech OUT BLOB -- Audio file
  );
  
  PROCEDURE transcript( -- Procedure transctipts audio file, https://platform.openai.com/docs/api-reference/audio/createTranscription
    p_api_key VARCHAR2, -- OpenAI API Key
    p_file BLOB, -- File
    p_filename VARCHAR2, --  Filename
    p_model VARCHAR2, -- Model (whisper-1)
    p_language VARCHAR2, -- Language (ISO-639-1)
    p_prompt VARCHAR2, -- Prompt
    p_response_format VARCHAR2, -- Response format (json, text, srt, verbose_json, vtt)
    p_temperature VARCHAR2, -- Temperature (0..1)
    r_transcript OUT VARCHAR2 -- Transcript
  );
  
  PROCEDURE translations( -- Procedure translates audio file, https://platform.openai.com/docs/api-reference/audio/createTranslations
    p_api_key VARCHAR2, -- OpenAI API Key
    p_file BLOB, -- File
    p_filename VARCHAR2, --  Filename
    p_model VARCHAR2, -- Model (whisper-1)
    p_language VARCHAR2, -- Language (ISO-639-1)
    p_prompt VARCHAR2, -- Prompt
    p_response_format VARCHAR2, -- Response format (json, text, srt, verbose_json, vtt)
    p_temperature VARCHAR2, -- Temperature (0..1)
    r_transcript OUT VARCHAR2 -- Transcript
  );
  
  PROCEDURE completion( -- Procedure serves dialog with Open AI, https://platform.openai.com/docs/api-reference/chat
    p_api_key VARCHAR2, -- OpenAI API Key
    p_model VARCHAR2, -- Model (gpt-4 and dated model releases, gpt-4-1106-preview, gpt-4-vision-preview, gpt-4-32k and dated model releases, gpt-3.5-turbo and dated model releases, gpt-3.5-turbo-16k and dated model releases, fine-tuned versions of gpt-3.5-turbo)
    p_prompt VARCHAR2, -- Prompt
    p_message CLOB, -- Message
    r_message OUT CLOB -- Message
  );

  PROCEDURE moderations( -- Procedure  provides moderation, https://platform.openai.com/docs/api-reference/moderations
    p_api_key VARCHAR2, -- OpenAI API Key
    p_model VARCHAR2, -- Model (text-moderation-stable, text-moderation-latest)
    p_prompt VARCHAR2, -- Prompt
    r_moderations OUT CLOB -- Moderation results 
  );

  PROCEDURE vision( -- Procedure provides image analysis capabilities, https://platform.openai.com/docs/guides/vision
    p_api_key VARCHAR2, -- OpenAI API Key
    p_model VARCHAR2, -- Model (gpt-4-vision-preview)
    p_prompt VARCHAR2, -- Prompt
    p_image CLOB, -- image in base64 format
    r_message OUT CLOB -- Vision response
  );

  PROCEDURE image( -- Procedure generates images, https://platform.openai.com/docs/api-reference/images
    p_api_key VARCHAR2, -- OpenAI API Key
    p_model VARCHAR2, -- Model (dall-e-2, dall-e-3, or gpt-image-1)
    p_prompt VARCHAR2, -- Prompt
    p_n NUMBER, -- Number of images (1..10)
    p_size VARCHAR2, -- Image size ('1024x1024', '1024x1792', or '1792x1024')
    r_error OUT VARCHAR2, -- Error message
    r_image OUT CLOB -- Image in base64 format
  );
  
END;
/
