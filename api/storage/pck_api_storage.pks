CREATE OR REPLACE PACKAGE pck_api_storage -- Package for storing andprocessing large binary objects
AS

  PROCEDURE upload( -- Procedure stores binary file
    p_file app_storage.content%TYPE, -- File content
    p_file_name app_storage.file_name%TYPE, -- File name
    r_id OUT app_storage.id%TYPE -- File ID
  );

  PROCEDURE upload( -- Procedure stores binary file
    p_file app_storage.content%TYPE, -- File content
    p_file_name app_storage.file_name%TYPE -- File name
  );

  PROCEDURE download( -- Procedure retrieves binary file
    p_id app_storage.id%TYPE, -- File ID
    r_file OUT NOCOPY app_storage.content%TYPE, -- File content
    r_file_name OUT app_storage.file_name%TYPE, -- File name
    r_file_size OUT app_storage.file_size%TYPE, -- File size
    r_file_ext OUT app_storage.file_ext%TYPE, -- File ext
    r_mime_type OUT app_storage.mime_type%TYPE -- Mime type
  );

  PROCEDURE download( -- Procedure retrieves binary file
    p_id app_storage.id%TYPE, -- File ID
    r_file OUT NOCOPY app_storage.content%TYPE, -- File content
    r_file_name OUT app_storage.file_name%TYPE -- File name
  );

  PROCEDURE delete( -- Procedure deletes binary file
    p_id app_storage.id%TYPE -- File ID
  );

END;
/
