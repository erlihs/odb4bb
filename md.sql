SET  SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT FAILURE

VARIABLE schema_name VARCHAR2(30 CHAR)
VARIABLE file_name VARCHAR2(200 CHAR)
VARIABLE version NUMBER

ARGUMENT 1 PROMPT 'Enter schema name: '
ARGUMENT 2 PROMPT 'Enter file name: '

EXEC :schema_name:= UPPER('&1');
EXEC :file_name:= '&2';
EXEC :version:= 19;

UNDEFINE 1
UNDEFINE 2

PROMPT Generating documentation for database
PROMPT Starting..
@./utl/reset_schema.sql
@./utl/check_version.sql
@./utl/mdify.sql

SET LINESIZE 2000
SET TERMOUT OFF
COL file_name NEW_VALUE file_name
SELECT :file_name AS file_name FROM dual;
SPOOL &&file_name;
EXEC mdify(:schema_name);
SPOOL OFF;
SET TERMOUT ON
/

@./utl/reset_schema.sql
PROMPT ..done