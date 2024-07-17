SET  SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT FAILURE

PROMPT Remove Oracle Database for Bullshit Bingo

VARIABLE schema_name VARCHAR2(30 CHAR)

ARGUMENT 1 PROMPT 'Enter schema name: '

EXEC :schema_name:= UPPER('&1');

UNDEFINE 1

PROMPT Starting..

@./utl/reset_schema.sql
@./utl/drop_schema.sql

PROMPT ..done
