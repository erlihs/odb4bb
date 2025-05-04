# Oracle Database for Bullshit Bingo

## Overview

**Oracle Database for Bullshit Bingo** is a set of Oracle Database scripts and practices for building backend applications. It is easily deployable by running just `setup.sql` in an Autonomous Database on Oracle Cloud Infrastructure or on-premises and exposes package methods as web services via Oracle Rest Data Services. 

Modules:
- Configuration settings
- Storage
- Authentication 
- Authorization  
- Email sending
- Third-party API calls (OpenAI API, Google API)
- Job management
- Event audit
- Internationalization

## Installation

### Prerequisites

Oracle Database 19c or newer and Oracle Rest Data Services. Check out [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)!

### Setup

Run `@setup.sql schema_name schema_password application_name domain_name user_name user_password` from `admin` schema from [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/).

```ps
@setup.sql my_schema 01234567abcdeF "My Company" https://mydomain.com admin@mydomain.com abcdeF01234567
```

Alternatively, you can run just `@setup.sql` and it will prompt for required parameters.

| Parameter | Name | Description |
| --- | --- | --- |
| &1 | schema_name | Schema where all the database object will be kept |
| &2 | schema_password | Schema password |
| &3 | application_name | Application name |
| &4 | domain_name | Domain name |
| &5 | user_name | Application user |
| &6 | user_password | Application password |

The script will create a new database schema with tables and packages and will expose a demo package as a web service.  

## Usage

### Overview

The main concepts of the solution:
- structured and organized database objects
- automatic exposure of package routines as web services

#### Structure

The structure is to provide separation of core modules - building blocks and the new modules or features. The recommended structure is as follows:

| Object | Recommended naming | Notes |
| --- | --- | --- |
| Tables for core modules | app_ | |
| Packages for core modules | pck_api_ | |
| Tables for other modules | xyz_ | | 
| Packages for other modules used exclusively for the module itself | pck_xyz | |
| Packages for other modules for *public* use | pck_api_xyz | |

#### Exposing as a web services

Any package routine with name prefixes `get_`, `post_`, `put_`, and `delete_` will be automatically exposed on Oracle Rest Data Service by calling `@ords.sql` after the package is compiled. 

As an example,

```plsql
CREATE OR REPLACE PACKAGE BODY my_package AS

    PROCEDURE get_hello(
        p_name VARCHAR2,
        r_hello OUT VARCHAR2 
    ) AS
    BEGIN
        r_hello := 'Hello, ' || p_name;
    END;

END;    
/
```

will be exposed as a web service and calling `GET https://localhost:8443/ords/schema_name/my-package-v1/hello/John` will return

```json
{
    "hello" : "Hello, John"
}
```

To have optional query parameters, use `DEFAULT`. Example: 

```plsql
CREATE OR REPLACE PACKAGE BODY my_package AS

    PROCEDURE get_hello(
        p_name VARCHAR2 DEFAULT NULL,
        r_hello OUT VARCHAR2 
    ) AS
    BEGIN
        r_hello := 'Hello, ' || p_name;
    END;

END;    
/
```

will be exposed as  `GET https://localhost:8443/ords/schema_name/my-package-v1/hello/?name=John`.

For `POST`, `PUT` and `DELETE` - parameters shall be passed in `requestBody`.

### Modules

#### Configuration settings

Allows to store and retrieve value by key.

```plsql
DECLARE
    c_id app_settings.id%TYPE := 'APP_TEST';
    c_v app_settings.content%TYPE := 'Test value';
    v_v app_settings.content%TYPE;
BEGIN
    pck_api_settings.write(c_id, c_v);
    pck_api_settings.read(c_id, v_v);   
    IF v_v <> c_v THEN
        RAISE_APPLICATION_ERROR(-20000, 'Settings test failed');
    END IF;
    ROLLBACK;
END;
/
```

Settings are stored in the `app_settings` table.

The recommended approach is to use the `XYZ``_` prefix for the key, where `XYZ` represents the module. 

#### Storage

Allows to store and retrieve binary data (files).

```plsql
DECLARE
    id app_storage.id%TYPE;
    b app_storage.content%TYPE;
    n app_storage.file_name%TYPE;
BEGIN
    b := utl_raw.cast_to_raw('Hello World!');
    n := 'hello.txt';
    pck_api_storage.upload(b, n, id);
    b := EMPTY_BLOB();
    pck_api_storage.download(id, b, n);
    pck_api_storage.delete(id);
    COMMIT;
    IF dbms_lob.compare(utl_raw.cast_to_raw('Hello World!'), b) <> 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Storage test failed!');
    END IF;
END;
/
```

Files are stored in a database table `app_storage` as SECUREFILE LOBs! 

#### Event audit

Provides capability to record audit events.

```plsql
exec pck_api_audit.inf('Something just happened..');
/
```

```plsql
...
    EXCEPTION
        WHEN OTHERS THEN
            pck_api_audit.log(v_id, 'E', 'Login error', pck_api_audit.mrg('username', p_username, 'password', '********'));
    END;
...
```

Audit events are stored in the  `app_audit` table.

If an audit event is recorded in a call from a web service, it will automatically detect and record the script name, agent and IP address of that call. 

In case of an error, it will automatically detect and record the error message and backtrace.

#### Third-party API calls (OpenAI API, Google API)

Provides built-in capabilities for web service calls directly from the Oracle Database.

```plsql
DECLARE
    v_req utl_http.req;
    v_text CLOB;
BEGIN
    pck_api_http.request(v_req, 'GET', 'https://api.chucknorris.io/jokes/random');
    pck_api_http.response_text(v_req, v_text);
    DBMS_OUTPUT.PUT_LINE(JSON_VALUE(v_text, '$.value'));
END;
/
```

For calling web services directly from the Oracle Database, access must be granted by adding an entry to the Access Control List by calling `@ace.sql schema_name host port privilege`.

```ps
@ace.sql my_schema api.chucknorris.io 80 connect
@ace.sql my_schema api.chucknorris.io 443 connect
```

`pck_api_http` package provides several authentication methods:
- basic `request_auth_basic`
- bearer token `request_auth_token`
- wallet `request_auth_wallet`

Various payload options:
- Json `request_json`
- multipart `request_multipart_start` .. `request_multipart_varchar` | `request_multipart_binary` .. `request_multipart_end` 

And response can be received either as:
- text `response_text`
- binary `response_binary`

There are two sample implementations of third-party services:

Package `pck_api_openai` provides an implementation of [Open AI API](https://platform.openai.com/). 

Package `pck_api_google` provides an implementation of [Google Streetview API](https://developers.google.com/maps/). 

Both require API keys to be added in configuration settings with the utilities [OpenAi](#open-ai) and [Google](#google).

#### Email sending

Provides e-mail sending capabilities, including multiple recipients, HTML content and attachments.

For sending emails, SMTP parameters need to be added -  check the [SMTP utility](#smtp).

```plsql
DECLARE
    v_from_addr app_emails_settings.from_addr%TYPE;
    v_from_name app_emails_settings.from_name%TYPE;
    v_id app_emails.id%TYPE;
BEGIN
    SELECT from_addr, from_name INTO v_from_addr, v_from_name FROM app_emails_settings;
    pck_api_emails.mail(v_id, v_from_addr, v_from_name, 'Test email', 'This is a <b>test</b> email!');
    pck_api_emails.send(v_id);
END;
/
```

Emails are stored in tables `app_emails`, `app_emails_addr` and `app_emails_attc`. 

#### Job management

Provides simplified wrapper of `DBMS_SCHEDULER` package allowing to create jobs.

```plsql
BEGIN
    pck_api_jobs.add('test','pck_api_audit.inf', '[{"type":"VARCHAR2", "name": "p_action", "value":"Test job"}]', 'FREQ=WEEKLY; BYDAY=MON; BYHOUR=0; BYMINUTE=0; BYSECOND=0', 'Test job');
    pck_api_jobs.run('test');
END;
/
```

#### Internationalization

Provides *translation* capabilities with automated background translation via OpenAI translate API.

Run the [OpenAI](#open-ai) utility first to open the Access Control List and set the API key.

Use `pck_api_i18n.add` to batch add data to translate. Data shall be in JSON format. Run `pck_api_i18n.job_i18n` to do AI translation and `pck_api_i18n.read` to retrieve translated data.

#### Authentication & Authorization  

Provides user authentication and authorization capabilities.

User data is stored in the `app_users` table with unique user ID `uuid`, `username` and `password` fields.

Authentication method `pck_api_auth.auth` returns `uuid` if authentication is successful or NULL if not. 

Method `pck_api_auth.token` issues a JWT token. Token added as a bearer token for ORDS service calls can be verified automatically by passing NULL as UUID in `pck_ap_auth.Priv` - in such cases token is automatically obtained from incoming web service calls, decoded and validated. 

Authorization is implemented as simplified role-based authorization with data stored in `app_roles` (roles) and  `app_permissions` (roles-users) tables and can be checked with `pck_ap_auth.role` and `pck_ap_auth.perm` methods.

```plsql
DECLARE
    v_uuid app_users.uuid%TYPE;
    v_token app_tokens.token%TYPE;
BEGIN
    pck_api_auth.auth(:app_user, :app_pass, v_uuid);
    IF v_uuid IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Authentication test failed');
    END IF;
    pck_api_auth.reset(v_uuid);
    v_token := pck_api_auth.token(v_uuid, 'A');
    IF (pck_api_auth.priv(v_uuid, NULL) <> v_uuid) THEN
        RAISE_APPLICATION_ERROR(-20000, 'Authorization test failed');
    END IF;
    IF (pck_api_auth.priv(v_uuid, 'admin') <> 'Y') THEN
        RAISE_APPLICATION_ERROR(-20000, 'Authorization test failed');
    END IF;
    pck_api_auth.reset(v_uuid);
END;
/
```

In general, for each publicly exposed method, authorization guard can be applied as simple as:

```plsql
...
    PROCEDURE get_mydata(
        ...
    ) AS

    BEGIN
        IF pck_api_auth.role(NULL, 'ADMIN') IS NULL THEN pck_api_auth.http_401('You are not authorized to view this page'); RETURN; END IF;
        
        -- all good
        ...
    END;
```

#### Other

`pck_api_zip` package provides ZIP file processing capabilities.

`pck_api_lob` provides functions for large binary object conversion, like CLOB to BLOB, BASE64 encoding and decoding and others.

See full [database documentation](./db.md)

### Utilities

#### Remove

Running `@remove.sql schema_name` will destroy schema with all the objects and data. Run with extreme caution!

#### Md

Running `@md.sql schema_name file_name` will generate and write to a file database documentation in `MD` format.

#### Smtp

Running `@smtp.sql schema_name smtp_host smtp_port smtp_username smtp_password email_address_from email_name_from` will add SMTP credentials and email configuration settings, and will add entry to Access Control List allowing emails to be sent directly from Oracle Database.

#### Access Control List

Running `@ace.sql schema_name host_name port privilege` will add an entry to the Access Control List allowing outgoing calls directly from the Oracle Database. ACL need to be set from ADMIN schema.

Example:

```sql
@ace.sql BSB_PRD oaidalleapiprodscus.blob.core.windows.net 443 'connect';
```

Check ACL:

```sql
SELECT a.host, a.lower_port, a.upper_port, p.principal, p.privilege, p.is_grant
FROM dba_network_acls a
JOIN dba_network_acl_privileges p ON a.acl = p.acl;
```

#### Open AI

Running `@openai.sql schema_name openai_api_key` will add an API key to configuration settings and will add an entry to the Access Control List allowing direct calls to OpenAI API from Oracle Database.

#### Google

Running `@google.sql schema_name google_api_key` will add an API key to configuration settings and will add an entry to the Access Control List allowing direct calls to Google Streetview API from Oracle Database.

#### i18n

Running `@i18n.sql schema_name file_name` will unload translations from the `app_i18n` table to file in `JSON` format.

#### ORDS

Running `@ords.sql schema_name file_name.yaml` will automatically expose package routines with name prefixes `get_`, `post_`, `put_`, and `delete_` as web services on Oracle Rest Data Services and will generate and save to file Open API 3.0 Manifest in YAML format. 

Manifest descriptions will be generated from source comments of procedure specification, becoming descriptions for methods and parameters and responses.

```plsql
    PROCEDURE post_login( -- Procedure authenticates user and returns tokens (PUBLIC)
        p_username APP_USERS.USERNAME%TYPE, -- User name (e-mail address)
        p_password APP_USERS.PASSWORD%TYPE, -- Password
        r_access_token OUT APP_TOKENS.TOKEN%TYPE, -- Token
        r_refresh_token OUT APP_TOKENS.TOKEN%TYPE, -- Refresh token
        r_user OUT SYS_REFCURSOR -- User data [{"uuid":"abcdef","username":"admin"}]
    );
```

Sugar:

- if procedure definition line contains `(PUBLIC)` - it will unset authentication method for this procedure. Default for all procedures is `Bearer`.
- If out `SYS_REFCURSOR` parameter comment will include valid json example at the end - it will be used to generate schema for this output parameter. Otherwise it will be as `An unknown JSON object`.

## Final notes

A good overview of [developing REST applications](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/23.2/orddg/developing-REST-applications.html#GUID-A1CD111F-724B-4E91-8202-FA899EE521F1) from Oracle.

Although prerequisites require Oracle Database 19c, the solution can be easily downgraded to 12c or even lower.

Using third-party APIs (Open AI, Google) requires API keys.

Sending out e-mails requires an SMTP server. Check out [Send email with OCI email delivery](https://blogs.oracle.com/cloud-infrastructure/post/step-by-step-instructions-to-send-email-with-oci-email-delivery)

The solution uses Oracle Database enterprise-level features like partitioning. Check licensing arrangements.

Check out the [SQL Developer for VS Code](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer)!

## Credits

- [Oracle Base](https://oracle-base.com/)
- [That Jeff Smith](https://www.thatjeffsmith.com/)
- [Tanel Poder](https://tanelpoder.com/)
- Burleson Consulting

## License

[MIT](https://opensource.org/license/MIT) © 2024 Jānis Erlihs
