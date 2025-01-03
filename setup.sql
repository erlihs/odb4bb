SET  SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
WHENEVER OSERROR EXIT FAILURE

PROMPT Setup Oracle Database for Bullshit Bingo

VARIABLE schema_name VARCHAR2(30 CHAR)
VARIABLE schema_pass VARCHAR2(200 CHAR)
VARIABLE app_name VARCHAR2(200 CHAR)
VARIABLE app_host VARCHAR2(200 CHAR)
VARIABLE app_user VARCHAR2(200 CHAR)
VARIABLE app_pass VARCHAR2(200 CHAR)
VARIABLE version NUMBER
VARIABLE ace CLOB

ARGUMENT 1 PROMPT 'Enter schema name: '
ARGUMENT 2 PROMPT 'Enter schema password: '
ARGUMENT 3 PROMPT 'Enter application name: '
ARGUMENT 4 PROMPT 'Enter application host name: '
ARGUMENT 5 PROMPT 'Enter application username (email): '
ARGUMENT 6 PROMPT 'Enter application password: '

EXEC :schema_name:= UPPER('&1');
EXEC :schema_pass:= '&2';
EXEC :app_name := '&3';
EXEC :app_host := '&4';
EXEC :app_user := '&5';
EXEC :app_pass := '&6';
EXEC :version:= 19;
EXEC :ace:= '[{"host": "api.chucknorris.io", "port": 80, "privilege": "connect"},{"host": "api.chucknorris.io", "port": 443, "privilege": "connect"}]';

UNDEFINE 1
UNDEFINE 2
UNDEFINE 3
UNDEFINE 4
UNDEFINE 5
UNDEFINE 6

PROMPT Starting..

@./utl/reset_schema.sql
@./utl/check_version.sql

PROMPT Creating schema
@./utl/create_schema.sql
@./utl/set_schema.sql

PROMPT Creating after logon NLS trigger
@./utl/trg_after_logon.sql

PROMPT Creating API for Large Objects
@./api/lob/pck_api_lob.pks
@./api/lob/pck_api_lob.pkb

PROMPT Creating API for HTTP requests
@./utl/acl_append_hosts.sql
@./api/http/pck_api_http.pks
@./api/http/pck_api_http.pkb
@./api/http/test_http.sql
@./utl/acl_remove_hosts.sql

PROMPT Creating API for Settings
@./api/settings/setup_app_settings.sql
@./api/settings/pck_api_settings.pks
@./api/settings/pck_api_settings.pkb
@./api/settings/test_settings.sql

PROMPT Creating API for Storage
@./api/storage/setup_app_storage.sql
@./api/storage/pck_api_storage.pks
@./api/storage/pck_api_storage.pkb
@./api/storage/test_storage.sql

PROMPT Creating API for Authentication and Authorization
@./api/auth/setup_app_users.sql
@./api/auth/setup_app_tokens.sql
@./api/auth/setup_app_permissions.sql
@./api/auth/pck_api_auth.pks
@./api/auth/pck_api_auth.pkb
@./api/auth/test_auth.sql

PROMPT Creating API for Audit
@./api/audit/setup_app_audit.sql
@./api/audit/setup_app_audit_archive.sql
@./api/audit/pck_api_audit.pks
@./api/audit/pck_api_audit.pkb
@./api/audit/test_audit.sql

PROMPT Creating API for Email sending
@./api/emails/setup_app_emails.sql
@./api/emails/pck_api_emails.pks
@./api/emails/pck_api_emails.pkb

PROMPT Creating API for Job scheduling
@./api/jobs/pck_api_jobs.pks
@./api/jobs/pck_api_jobs.pkb
@./api/jobs/setup_jobs.sql
@./api/jobs/test_jobs.sql

PROMPT Creating API for Validations
@./api/validate/pck_api_validate.pks
@./api/validate/pck_api_validate.pkb

PROMPT Creating API for Zip file handling
@./api/zip/pck_api_zip.pks
@./api/zip/pck_api_zip.pkb

PROMPT Creating API for OpenAI API
@./api/openai/pck_api_openai.pks
@./api/openai/pck_api_openai.pkb

PROMPT Creating API for Google Streeetview API
@./api/google/pck_api_google.pks
@./api/google/pck_api_google.pkb

PROMPT Creating API for i18n
@./api/i18n/setup_app_i18n.sql
@./api/i18n/pck_api_i18n.pks
@./api/i18n/pck_api_i18n.pkb
--@./api/i18n/test_i18n.sql

PROMPT Creating Demo package
@./demo/pck_app_demo.pks
@./demo/pck_app_demo.pkb

PROMPT Enabling ORDS
@./utl/ordsify.sql
EXEC ordsify;
@./utl/trg_ordsify.sql

PROMPT ..done
