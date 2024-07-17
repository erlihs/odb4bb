SET  SERVEROUTPUT ON
SET FEEDBACK OFF
--WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
--WHENEVER OSERROR EXIT FAILURE

PROMPT Setup Oracle Database for Bullshit Bingo - SMTP

VARIABLE schema_name VARCHAR2(30 CHAR)
VARIABLE smtp_host VARCHAR2(2000 CHAR)
VARIABLE smtp_port NUMBER
VARIABLE smtp_user VARCHAR2(2000 CHAR)
VARIABLE smtp_pass VARCHAR2(2000 CHAR)
VARIABLE app_user VARCHAR2(200 CHAR)
VARIABLE app_name VARCHAR2(200 CHAR)
VARIABLE version NUMBER
VARIABLE ace CLOB
VARIABLE cred CLOB

ARGUMENT 1 PROMPT 'Enter Schema name: '
ARGUMENT 2 PROMPT 'Enter SMTP host name: '
ARGUMENT 3 PROMPT 'Enter SMTP port: '
ARGUMENT 4 PROMPT 'Enter SMTP user name: '
ARGUMENT 5 PROMPT 'Enter SMTP user password: '
ARGUMENT 6 PROMPT 'Enter email address: '
ARGUMENT 7 PROMPT 'Enter email name: '

EXEC :schema_name:= UPPER('&1');
EXEC :smtp_host:= '&2';
EXEC :smtp_port:= '&3';
EXEC :smtp_user := '&4';
EXEC :smtp_pass := '&5';
EXEC :app_user := '&6';
EXEC :app_name := '&7';
EXEC :version:= 19;
EXEC :ace:= '[{"host": "' || :smtp_host || '", "port": ' || :smtp_port || ', "privilege": "smtp"}]';
EXEC :cred:= '{ "name": "SMTP_CRED_' || :schema_name || '", "username": "' || :smtp_user || '", "password": "' || :smtp_pass || '" }';

UNDEFINE 1
UNDEFINE 2
UNDEFINE 3
UNDEFINE 4
UNDEFINE 5
UNDEFINE 6
UNDEFINE 7

PROMPT Starting..

@./utl/reset_schema.sql
@./utl/check_version.sql

PROMPT Adding ACE
@./utl/acl_append_hosts.sql

PROMPT Creating SMTP access credentials
@./utl/cloud_append_credentials.sql

PROMPT Updating Email settings
@./utl/set_schema.sql
EXEC UPDATE app_emails_settings SET smtp_host = :smtp_host, smtp_port = :smtp_port,  smtp_cred = 'SMTP_CRED_' || UPPER(:schema_name), from_addr = :app_user, from_name = :app_name, replyto_addr = :app_user, replyto_name = :app_name;
EXEC COMMIT;

PROMPT Sending test email
@./api/emails/test_emails.sql

PROMPT ..done
@./utl/reset_schema.sql
