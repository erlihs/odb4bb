BEGIN
    EXECUTE IMMEDIATE 'GRANT CREATE JOB TO ' || :schema_name;
    EXECUTE IMMEDIATE 'GRANT MANAGE SCHEDULER TO ' || :schema_name;
    EXECUTE IMMEDIATE 'GRANT EXECUTE on dbms_scheduler TO ' || :schema_name;
END;    
/

BEGIN
    pck_api_jobs.add('cleanup','pck_api_auth.cleanup', '', 'FREQ=HOURLY', 'Job removes expired tokens');
    pck_api_jobs.run('cleanup');
END;
/

BEGIN
    pck_api_jobs.add('archive','pck_api_auth.cleanup', '', 'FREQ=DAILY', 'Job moves old archive records to archive table');
    pck_api_jobs.run('archive');
END;
/