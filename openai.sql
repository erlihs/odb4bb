SET  SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT FAILURE

PROMPT Enable OpenAI API in Oracle Database for Bullshit Bingo

VARIABLE schema_name VARCHAR2(30 CHAR)
VARIABLE setting_id VARCHAR2(200 CHAR)
VARIABLE setting_value VARCHAR2(200 CHAR)
VARIABLE setting_description VARCHAR2(200 CHAR)
VARIABLE ace CLOB

ARGUMENT 1 PROMPT 'Enter schema name: '
ARGUMENT 2 PROMPT 'Enter OpenAI API key: '

EXEC :schema_name:= UPPER('&1');
EXEC :ace:= '[{"host": "api.openai.com", "port": 443, "privilege": "connect"},{"host": "api.openai.com", "port": 80, "privilege": "connect"}]';
EXEC :setting_id:= 'APP_OPENAI_API_KEY';
EXEC :setting_value:= '&2';
EXEC :setting_description:= 'OpenAI API key';

UNDEFINE 1
UNDEFINE 2

PROMPT Starting..

PROMPT Creating ACE
@./utl/acl_append_hosts.sql

PROMPT Saving API Key
@./utl/set_schema.sql
@./utl/set_setting.sql

PROMPT ..done
@./utl/reset_schema.sql
