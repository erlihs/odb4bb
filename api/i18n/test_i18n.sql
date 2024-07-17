DECLARE
    i CLOB := 'This is just a test.';
    o CLOB;
BEGIN
    o := pck_api_i18n.t(i, 'ee');
    pck_api_i18n.job_i18n;
    o := pck_api_i18n.t(i, 'ee');
    IF o = i THEN 
        RAISE_APPLICATION_ERROR(-20000, 'i18n test failed');
    END IF;
END;
/
