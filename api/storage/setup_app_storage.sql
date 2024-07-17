BEGIN
    EXECUTE IMMEDIATE '
CREATE TABLE app_storage(
    id CHAR(32 CHAR) DEFAULT LOWER(SYS_GUID()) NOT NULL,
    file_name VARCHAR2(2000 CHAR),
    file_size NUMBER(19),
    file_ext VARCHAR2(30 CHAR),
    mime_type VARCHAR2(200 CHAR),
    content BLOB,
    created TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    modified TIMESTAMP 
)
    LOB (content) STORE AS SECUREFILE (
    NOCACHE LOGGING NOCOMPRESS KEEP_DUPLICATES
)
    ';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_storage IS 'Table for  storing and processing documents, images, etc.';
COMMENT ON COLUMN app_storage.id IS 'Storage id';
COMMENT ON COLUMN app_storage.file_name IS 'File name';
COMMENT ON COLUMN app_storage.file_size IS 'File size in bytes';
COMMENT ON COLUMN app_storage.file_ext IS 'File extention';
COMMENT ON COLUMN app_storage.mime_type IS 'File mime type';
COMMENT ON COLUMN app_storage.content IS 'Binary file content';
COMMENT ON COLUMN app_storage.created IS 'Date and time of storing';
COMMENT ON COLUMN app_storage.modified IS 'Date and time of last modification';

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE app_storage ADD CONSTRAINT cpk_app_storage PRIMARY KEY (id)';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/
