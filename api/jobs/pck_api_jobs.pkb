CREATE OR REPLACE PACKAGE BODY pck_api_jobs AS

    PROCEDURE add(
        p_name VARCHAR2,
        p_program VARCHAR2,
        p_arguments CLOB,
        p_schedule VARCHAR2,
        p_description VARCHAR2
    ) AS
        v_cnt PLS_INTEGER;
    BEGIN
        
        remove(p_name);

        SELECT COUNT(*)
        INTO v_cnt
        FROM json_table(p_arguments, '$[*]' COLUMNS (
            type VARCHAR2 PATH '$.type',
            name VARCHAR2 PATH '$.name',
            value VARCHAR2 PATH '$.value'
        ));

        DBMS_SCHEDULER.create_program (
            program_name        => UPPER(p_name) || '_PROGRAM',
            program_type        => 'STORED_PROCEDURE',
            program_action      => p_program,
            number_of_arguments => v_cnt,
            enabled             => FALSE
        );

        FOR i IN 1..v_cnt LOOP
            DBMS_SCHEDULER.define_program_argument (
                program_name        => UPPER(p_name) || '_PROGRAM',
                argument_position   => i,
                argument_name       => json_value(p_arguments, '$[' || (i-1) || '].name'),
                argument_type       => json_value(p_arguments, '$[' || (i-1) || '].type'),
                default_value       => json_value(p_arguments, '$[' || (i-1) || '].value')
            );
        END LOOP;

        DBMS_SCHEDULER.enable(UPPER(p_name) || '_PROGRAM');

        DBMS_SCHEDULER.create_schedule (
            schedule_name       => UPPER(p_name) || '_SCHEDULE',
            start_date          => SYSTIMESTAMP,
            repeat_interval     => p_schedule
        );

        DBMS_SCHEDULER.create_job (
            job_name            => UPPER(p_name) || '_JOB',
            program_name        => UPPER(p_name) || '_PROGRAM',
            schedule_name       => UPPER(p_name) || '_SCHEDULE',
            enabled             => FALSE,
            auto_drop           => TRUE,
            comments            => p_description
        );

        DBMS_SCHEDULER.enable(UPPER(p_name) || '_PROGRAM');        
        DBMS_SCHEDULER.enable(UPPER(p_name) || '_JOB');        

    END;

    PROCEDURE remove(
        p_name VARCHAR2
    ) AS
    BEGIN

        BEGIN
            DBMS_SCHEDULER.drop_job(UPPER(p_name) || '_JOB', TRUE);
            DBMS_SCHEDULER.drop_schedule(UPPER(p_name) || '_SCHEDULE');
            DBMS_SCHEDULER.drop_program( UPPER(p_name) || '_PROGRAM');
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;

    END;

    PROCEDURE enable(
        p_name VARCHAR2
    ) AS
    BEGIN
        DBMS_SCHEDULER.enable(UPPER(p_name) || '_JOB');
    END;

    PROCEDURE disable(
        p_name VARCHAR2
    ) AS
    BEGIN
        DBMS_SCHEDULER.disable(UPPER(p_name) || '_JOB');
    END;

    PROCEDURE run(
        p_name VARCHAR2
    ) AS
    BEGIN
        DBMS_SCHEDULER.run_job(UPPER(p_name) || '_JOB');
    END;

END;
/
