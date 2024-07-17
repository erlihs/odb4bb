DECLARE
    id app_storage.id%TYPE;
    b app_storage.content%TYPE;
    n app_storage.file_name%TYPE;
BEGIN
    b := utl_raw.cast_to_raw('Hello World!');
    n := 'hello.txt';
    pck_api_storage.upload(b, n, id);
    b := EMPTY_BLOB();
    pck_api_storage.download(id, b, n);
    pck_api_storage.delete(id);
    COMMIT;
    IF dbms_lob.compare(utl_raw.cast_to_raw('Hello World!'), b) <> 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Storage test failed!');
    END IF;
END;
/