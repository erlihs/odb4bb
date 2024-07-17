CREATE OR REPLACE PACKAGE BODY pck_api_storage
AS

  PROCEDURE upload(
    p_file app_storage.content%TYPE,
    p_file_name app_storage.file_name%TYPE,
    r_id OUT app_storage.id%TYPE
  ) AS
    v_file_ext app_storage.file_ext%TYPE := SUBSTR(p_file_name, NULLIF(INSTR(p_file_name, '.', -1) +1, 1));
    v_mime_type app_storage.mime_type%TYPE := pck_api_http.mime_type(v_file_ext); 
  BEGIN

    INSERT INTO app_storage (
      file_name,
      file_size,
      file_ext,
      mime_type,
      content
    ) VALUES (
      p_file_name,
      dbms_lob.getlength(p_file),
      v_file_ext,
      v_mime_type,
      p_file
    ) RETURNING id INTO r_id;

  END;

  PROCEDURE upload( 
    p_file app_storage.content%TYPE, 
    p_file_name app_storage.file_name%TYPE 
  ) AS
    v_id app_storage.id%TYPE;
  BEGIN
    upload(p_file, p_file_name, v_id);  
  END;

  PROCEDURE download( 
    p_id app_storage.id%TYPE, 
    r_file OUT NOCOPY app_storage.content%TYPE, 
    r_file_name OUT app_storage.file_name%TYPE, 
    r_file_size OUT app_storage.file_size%TYPE, 
    r_file_ext OUT app_storage.file_ext%TYPE, 
    r_mime_type OUT app_storage.mime_type%TYPE 
  ) AS
  BEGIN

    SELECT content, file_name, file_size, file_ext, mime_type
    INTO r_file, r_file_name, r_file_size, r_file_ext, r_mime_type
    FROM app_storage
    WHERE id = p_id;

  END;

  PROCEDURE download( 
    p_id app_storage.id%TYPE, 
    r_file OUT NOCOPY app_storage.content%TYPE, 
    r_file_name OUT app_storage.file_name%TYPE 
  ) AS
  BEGIN

    SELECT content, file_name
    INTO r_file, r_file_name
    FROM app_storage
    WHERE id = p_id;

  END; 

  PROCEDURE delete( 
    p_id app_storage.id%TYPE 
  ) AS
  BEGIN
    DELETE FROM app_storage
    WHERE id = p_id;
  END;
  
END;
/
