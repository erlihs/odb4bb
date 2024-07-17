SET  SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT FAILURE

PROMPT Add Access Control List entry in Oracle Database for Bullshit Bingo

VARIABLE schema_name VARCHAR2(30 CHAR)
VARIABLE host VARCHAR2(200 CHAR)
VARIABLE port NUMBER
VARIABLE privilege VARCHAR2(200 CHAR)
VARIABLE ace CLOB

ARGUMENT 1 PROMPT 'Enter schema name: '
ARGUMENT 2 PROMPT 'Enter host name: '
ARGUMENT 3 PROMPT 'Enter port number: '
ARGUMENT 4 PROMPT 'Enter privilege: '

EXEC :schema_name:= UPPER('&1');
EXEC :host:= '&2';
EXEC :port:= '&3';
EXEC :privilege := '&4';

EXEC :ace:= '[{"host": "' || :host || '", "port": ' || :port || ', "privilege": "' || :privilege || '"}]';

UNDEFINE 1
UNDEFINE 2
UNDEFINE 3
UNDEFINE 4

PROMPT Starting..

PROMPT Creating ACE
@./utl/set_schema.sql
@./utl/acl_append_hosts.sql

PROMPT ..done
@./utl/reset_schema.sql
