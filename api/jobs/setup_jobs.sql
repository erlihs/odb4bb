BEGIN
    EXECUTE IMMEDIATE 'GRANT CREATE JOB TO ' || :schema_name;
    EXECUTE IMMEDIATE 'GRANT EXECUTE on dbms_scheduler TO ' || :schema_name;
END;    
/