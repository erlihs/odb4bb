CREATE OR REPLACE PACKAGE pck_api_zip -- Package for handling zip files, Credit: https://github.com/antonscheffer/as_zip 
AS

  TYPE T_FILE_LIST IS TABLE OF CLOB;

  PROCEDURE add(  -- Add a file to a zip archive
    p_zip IN OUT NOCOPY BLOB, -- The zip archive
    p_name VARCHAR2 CHARACTER SET ANY_CS, -- The name of the file
    p_content BLOB, -- The content of the file, if content will be NULL, a directory will be created
    p_password VARCHAR2 DEFAULT NULL, -- The password for the file
    p_comment VARCHAR2 CHARACTER SET ANY_CS DEFAULT NULL -- The comment for the file
  );

  PROCEDURE extract( -- Extract a file from a zip archive
    p_zip IN OUT NOCOPY BLOB, -- The zip archive
    p_name VARCHAR2 CHARACTER SET ANY_CS, -- The name of the file
    r_content OUT BLOB, -- The content of the file
    p_password VARCHAR2 DEFAULT NULL -- The password for the file
  );

  PROCEDURE remove( -- Remove a file from a zip archive
    p_zip IN OUT NOCOPY BLOB, -- The zip archive
    p_name VARCHAR2 CHARACTER SET ANY_CS -- The name of the file
  );

  FUNCTION list( -- List the files in a zip archive
    p_zip BLOB, -- The zip archive
    p_search VARCHAR2 DEFAULT NULL, -- The search string
    p_limit PLS_INTEGER DEFAULT 100, -- The maximum number of files to return
    p_offset PLS_INTEGER DEFAULT 0 -- The number of files to skip
  ) RETURN T_FILE_LIST; -- The list of files

  PROCEDURE details( -- Get the details of a file in a zip archive
    p_zip BLOB, -- The zip archive
    p_name VARCHAR2 CHARACTER SET ANY_CS, -- The name of the file
    r_size OUT PLS_INTEGER, -- The size of the file
    r_compressed_size OUT PLS_INTEGER, -- The compressed size of the file
    r_is_directory OUT BOOLEAN, -- The file is a directory
    r_has_password OUT BOOLEAN, -- The file has a password
    r_comment OUT VARCHAR2 -- The comment of the file
  );

END;
/
