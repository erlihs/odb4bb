DECLARE
  z blob;
  t0 clob;
  t1 clob;
  b blob;
  v_s0 PLS_INTEGER;
  v_s1 PLS_INTEGER;
BEGIN

    FOR i IN 1 .. 100 
    LOOP
      t0 := t0 || 'This is a test of the emergency broadcast system.  This is only a test. ';
    END LOOP;
    v_s0 := dbms_lob.getlength(t0);
    b := pck_api_lob.clob_to_blob(t0);

    pck_api_zip.add(z, 'file0.txt', b);

    pck_api_zip.extract(z, 'file0.txt', b);
    t1 := pck_api_lob.blob_to_clob(b);
    v_s1 := dbms_lob.getlength(t1);

    dbms_lob.freetemporary(z);

    IF v_s0 <> v_s1 THEN
      RAISE_APPLICATION_ERROR(-20000, 'Zip test failed');
    END IF;
END;
/