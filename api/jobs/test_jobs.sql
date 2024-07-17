BEGIN
    pck_api_jobs.add('test','pck_api_audit.inf', '[{"type":"VARCHAR2", "name": "p_action", "value":"Test job"}]', 'FREQ=WEEKLY; BYDAY=MON; BYHOUR=0; BYMINUTE=0; BYSECOND=0', 'Test job');
    pck_api_jobs.run('test');
END;
/
