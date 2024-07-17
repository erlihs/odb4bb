# Database

*This is automatically generated content*

## Summary

- Database version: **Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - Production**
- Generated: **2024-07-16 17:23**
- Schema: **BSB_TST**

## NLS settings

| Parameter | Value |
| --------- | ----- |
|NLS_LANGUAGE|AMERICAN|
|NLS_TERRITORY|AMERICA|
|NLS_CURRENCY|USD|
|NLS_ISO_CURRENCY|AMERICA|
|NLS_NUMERIC_CHARACTERS|.,|
|NLS_CALENDAR|GREGORIAN|
|NLS_DATE_FORMAT|RRRR.MM.DD|
|NLS_DATE_LANGUAGE|AMERICAN|
|NLS_CHARACTERSET|AL32UTF8|
|NLS_SORT|BINARY|
|NLS_TIME_FORMAT|HH24:MI:SSXFF|
|NLS_TIMESTAMP_FORMAT|RRRR.MM.DD HH24:MI:SSXFF|
|NLS_TIME_TZ_FORMAT|HH24:MI:SSXFF TZM|
|NLS_TIMESTAMP_TZ_FORMAT|RRRR.MM.DD HH24:MI:SSXFF TZM|
|NLS_DUAL_CURRENCY|$|
|NLS_NCHAR_CHARACTERSET|AL16UTF16|
|NLS_COMP|BINARY|
|NLS_LENGTH_SEMANTICS|BYTE|
|NLS_NCHAR_CONV_EXCP|FALSE|

## Triggers

| Trigger name | Description |
| ------------ | ----------- |
|TRG_AFTER_LOGON|Trigger sets NLS for all connections|

## Sequences

| Sequence name | Cache size | Last number |
| ------------- | ----------:| -----------:|
|SEQ_APP_EMAILS|20|1|
|SEQ_APP_ROLES|0|3|
|SEQ_APP_USERS|20|21|

## Tables

### Summary

| Table name | Description |
| ---------- | ----------- |
|APP_AUDIT|Table for storing and processing audit data|
|APP_EMAILS|Table for storing and processing email data|
|APP_EMAILS_ADDR|Table for storing and processing email addressess|
|APP_EMAILS_ATTC|Table for storing and processing email attachments|
|APP_EMAILS_SETTINGS|Table for storing and processing email settings|
|APP_I18N|Table for storing and processing internationalization data|
|APP_PERMISSIONS|Table for storing user permissions|
|APP_ROLES|Table for storing user roles|
|APP_SETTINGS|Table for storing system parameters|
|APP_STORAGE|Table for  storing and processing documents, images, etc.|
|APP_TOKENS|Table for storing and processing user tokens|
|APP_TOKEN_SETTINGS|Table for storing and processing token settings|
|APP_TOKEN_TYPES|Table for storing and processing token types|
|APP_USERS|Table for storing and processing user data|
|DR$SDX_APP_I18N$B||
|DR$SDX_APP_I18N$C||
|DR$SDX_APP_I18N$G||
|DR$SDX_APP_I18N$I||
|DR$SDX_APP_I18N$K||
|DR$SDX_APP_I18N$N||
|DR$SDX_APP_I18N$Q||
|DR$SDX_APP_I18N$U||

### APP_AUDIT

Table for storing and processing audit data

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID|CHAR (32 CHAR)|LOWER(SYS_GUID()) |Y|Y|Primary key|
|UUID|CHAR (32 CHAR)||||Unique user identifier|
|SEVERITY|CHAR (1 CHAR)|'I' |Y||Severity level (D - debug, I - info, W - warning, E - error)|
|ACTION|VARCHAR2 (2000 CHAR)||Y||Activity that caused audit record|
|DETAILS|VARCHAR2 (2000 CHAR)||||Detailed information|
|STACK|VARCHAR2 (2000 CHAR)|||||
|CREATED|TIMESTAMP(6)|SYSTIMESTAMP |Y||Date and time when audit record was created|
|AGENT|VARCHAR2 (2000 CHAR)||||Browser agent|
|IP|VARCHAR2 (240 CHAR)||||IP address|

#### Constraints

| Constraint name | Search conditions | Description |
| --------------- | ----------------- | ----------- |
|CSC_APP_AUDIT_SEVERITY|severity IN ('D', 'I', 'W', 'E')||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|IDX_APP_AUDIT_CREATED||N|CREATED||
|IDX_APP_AUDIT_UUID||N|UUID||
|PK_APP_AUDIT|Y|N|ID||

### APP_EMAILS

Table for storing and processing email data

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID|NUMBER||Y|Y|Primary key|
|SUBJECT|VARCHAR2 (240 CHAR)||Y||Email subject|
|CONTENT|CLOB||||Email content (HTML)|
|PRIORITY|NUMBER|3 |Y||Email priority (1 - highest .. 9 - lowest)|
|STATUS|CHAR (1 CHAR)|'N' |Y||Status (N - not sent,  S - sent, E - error)|
|CREATED|TIMESTAMP(6)|SYSTIMESTAMP |Y||Date and time when created|
|DELIVERED|TIMESTAMP(6)||||Date and time when delivered|
|ATTEMPTS|NUMBER|0 |Y||Number  of senfing attempts|
|POSTPONED|TIMESTAMP(6)||||Date and time until which  not to send again|
|ERROR|VARCHAR2 (2000 CHAR)||||Error text|

#### Constraints

| Constraint name | Search conditions | Description |
| --------------- | ----------------- | ----------- |
|CSC_APP_EMAILS_STATUS|status IN ('N', 'S', 'E')||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_EMAILS|Y|N|ID||

#### Partitions

| Partition name | Tablespavce name | Description |
| -------------- | ---------------- | ----------- |
|EMAILS_ACTIVE|DATA||
|EMAILS_ARCHIVE|DATA||

### APP_EMAILS_ADDR

Table for storing and processing email addressess

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID_EMAIL|NUMBER||Y||Email ID|
|ADDR_TYPE|VARCHAR2 (7 CHAR)||Y||Address type (From, ReplyTo, To, Cc, Bcc)|
|ADDR_ADDR|VARCHAR2 (240 CHAR)||Y||Email address|
|ADDR_NAME|VARCHAR2 (240 CHAR)||||Email address name|

#### Constraints

| Constraint name | Search conditions | Description |
| --------------- | ----------------- | ----------- |
|CSC_APP_EMAILS_ADDR_ADDR_TYPE|addr_type IN ('From', 'ReplyTo', 'To', 'Cc', 'Bcc')||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|IDX_APP_EMAILS_ADDR_ID_EMAIL||N|ID_EMAIL||
|IDX_APP_EMAILS_ADDR_UNIQUE|Y|N|ID_EMAIL, ADDR_TYPE, ADDR_ADDR||

### APP_EMAILS_ATTC

Table for storing and processing email attachments

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID_EMAIL|NUMBER||Y||Email ID|
|FILE_NAME|VARCHAR2 (240 CHAR)||Y||Attachment name|
|FILE_DATA|BLOB||Y||Attachment data|

### APP_EMAILS_SETTINGS

Table for storing and processing email settings

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|SMTP_HOST|VARCHAR2 (2000 CHAR)||||SMTP server host|
|SMTP_PORT|NUMBER||||SMTP server port|
|SMTP_CRED|VARCHAR2 (2000 CHAR)||||SMTP server credentials|
|FROM_ADDR|VARCHAR2 (2000 CHAR)||||Default email address|
|FROM_NAME|VARCHAR2 (2000 CHAR)||||Default email name|
|REPLYTO_ADDR|VARCHAR2 (2000 CHAR)||||Default reply-to email address|
|REPLYTO_NAME|VARCHAR2 (2000 CHAR)||||Default reply-to email name|
|BATCH_LIMIT|NUMBER||||Maximum number of emails to send in one batch|

### APP_I18N

Table for storing and processing internationalization data

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|TEXT|CLOB||Y||Original text (en)|
|LANG|CHAR (2 CHAR)||Y||Language code|
|TRANSLATION|CLOB||||Translated text|
|CORRECTION|CLOB||||Correction text|
|CREATED|TIMESTAMP(6)|SYSTIMESTAMP |Y||Date and time when created|
|MODIFIED|TIMESTAMP(6)||||Date and time when modified|

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|IDX_APP_I18N_LANG||N|LANG||
|SDX_APP_I18N||N|TEXT||

### APP_PERMISSIONS

Table for storing user permissions

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID_USER|NUMBER||Y|Y|User id|
|ID_ROLE|NUMBER||Y|Y|Role id|
|PERMISSION|VARCHAR2 (2000 CHAR)||Y||Permission details|
|VALID_FROM|TIMESTAMP(6)|SYSTIMESTAMP |Y||Validity period from|
|VALID_TO|TIMESTAMP(6)||||Validity period to|

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_PERMISSIONS|Y|N|ID_USER, ID_ROLE||

### APP_ROLES

Table for storing user roles

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID|NUMBER||Y|Y|Role id|
|ROLE|VARCHAR2 (50 CHAR)||Y||Role name|
|DESCRIPTION|VARCHAR2 (500 CHAR)||||Role description|

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_ROLES|Y|N|ID||

### APP_SETTINGS

Table for storing system parameters

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID|VARCHAR2 (30 CHAR)||Y|Y|Primary key|
|DESCRIPTION|VARCHAR2 (2000 CHAR)||||Parameter description|
|CONTENT|VARCHAR2 (2000 CHAR)||||Variable character value up to 2000 unicode characters|
|OPTIONS|CLOB||||Setting options in JSON format|

#### Constraints

| Constraint name | Search conditions | Description |
| --------------- | ----------------- | ----------- |
|CSC_APP_SETTINGS_OPTIONS|options IS JSON||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_SETTINGS|Y|N|ID||

### APP_STORAGE

Table for  storing and processing documents, images, etc.

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID|CHAR (32 CHAR)|LOWER(SYS_GUID()) |Y|Y|Storage id|
|FILE_NAME|VARCHAR2 (2000 CHAR)||||File name|
|FILE_SIZE|NUMBER||||File size in bytes|
|FILE_EXT|VARCHAR2 (30 CHAR)||||File extention|
|MIME_TYPE|VARCHAR2 (200 CHAR)||||File mime type|
|CONTENT|BLOB||||Binary file content|
|CREATED|TIMESTAMP(6)|SYSTIMESTAMP |Y||Date and time of storing|
|MODIFIED|TIMESTAMP(6)||||Date and time of last modification|

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_STORAGE|Y|N|ID||

### APP_TOKENS

Table for storing and processing user tokens

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID_USER|NUMBER||Y||Reference to user (APP_USERS.ID)|
|ID_TOKEN_TYPE|CHAR (1 CHAR)||Y||Reference to token type (APP_TOKEN_TYPES.ID)|
|TOKEN|VARCHAR2 (2000 CHAR)||Y|Y|Token content, primary key|
|CREATED|TIMESTAMP(6)|SYSTIMESTAMP |Y||Date and time when token was created|
|EXPIRATION|TIMESTAMP(6)||Y||Date and time when token expires|

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_TOKENS|Y|N|TOKEN||
|IDQ_APP_TOKENS|Y|N|ID_USER, ID_TOKEN_TYPE||

### APP_TOKEN_SETTINGS

Table for storing and processing token settings

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ISSUER|VARCHAR2 (200 CHAR)||Y||Token issuer|
|AUDIENCE|VARCHAR2 (200 CHAR)||Y||Token audience|
|SECRET|CHAR (32 CHAR)||Y||Token secret|

### APP_TOKEN_TYPES

Table for storing and processing token types

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID|CHAR (1 CHAR)||Y|Y|Token type|
|DESCRIPTION|VARCHAR2 (200 CHAR)||Y||Token type description|
|EXPIRATION|NUMBER||Y||Token expiration time in seconds|

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_TOKEN_TYPES|Y|N|ID||

### APP_USERS

Table for storing and processing user data

#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|ID|NUMBER||Y|Y|Primary key|
|UUID|CHAR (32 CHAR)|LOWER(SYS_GUID()) |Y||Unique user identifier|
|STATUS|CHAR (1 CHAR)|'N' |Y||Status (A - active; D - disabled; N - uNverified)|
|USERNAME|VARCHAR2 (240 CHAR)||Y||Username|
|PASSWORD|VARCHAR2 (240 CHAR)||Y||Password|
|FULLNAME|VARCHAR2 (240 CHAR)||Y||Full name|
|CREATED|TIMESTAMP(6)|SYSTIMESTAMP |Y||Date and time when user was created|
|ATTEMPTS|NUMBER|0 |Y||Number of authentication attempts|
|ACCESSED|TIMESTAMP(6)||||Date and time when user performed last successful login|

#### Constraints

| Constraint name | Search conditions | Description |
| --------------- | ----------------- | ----------- |
|CSC_APP_USERS_STATUS|status IN ('A', 'D', 'N')||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|CPK_APP_USERS|Y|N|ID||
|IDX_APP_USERS_USERNAME|Y|N|USERNAME||
|IDX_APP_USERS_UUID|Y|N|UUID||

### DR$SDX_APP_I18N$B



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|MIN_DOCID|NUMBER|||||
|MAX_DOCID|NUMBER|||||
|STATUS|NUMBER|||||

### DR$SDX_APP_I18N$C



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|DML_SCN|NUMBER|||||
|DML_ID|NUMBER|||||
|DML_OP|NUMBER|||||
|DML_RID|ROWID|||||

### DR$SDX_APP_I18N$G



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|TOKEN_TEXT|VARCHAR2 (63.75 CHAR)||Y|||
|TOKEN_TYPE|NUMBER||Y|||
|TOKEN_FIRST|NUMBER||Y|||
|TOKEN_LAST|NUMBER||Y|||
|TOKEN_COUNT|NUMBER||Y|||
|TOKEN_INFO|BLOB|||||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|DR$SDX_APP_I18N$H||N|TOKEN_TEXT, TOKEN_TYPE, TOKEN_FIRST, TOKEN_LAST, TOKEN_COUNT||

### DR$SDX_APP_I18N$I



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|TOKEN_TEXT|VARCHAR2 (63.75 CHAR)||Y|||
|TOKEN_TYPE|NUMBER||Y|||
|TOKEN_FIRST|NUMBER||Y|||
|TOKEN_LAST|NUMBER||Y|||
|TOKEN_COUNT|NUMBER||Y|||
|TOKEN_INFO|BLOB|||||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|DR$SDX_APP_I18N$X||N|TOKEN_TEXT, TOKEN_TYPE, TOKEN_FIRST, TOKEN_LAST, TOKEN_COUNT||

### DR$SDX_APP_I18N$K



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|DOCID|NUMBER|||||
|TEXTKEY|ROWID|||||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|DR$SDX_APP_I18N$KD||N|DOCID, TEXTKEY||
|DR$SDX_APP_I18N$KR||N|TEXTKEY, DOCID||

### DR$SDX_APP_I18N$N



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|NLT_DOCID|NUMBER|||||
|NLT_MARK|CHAR (.25 CHAR)||Y|||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|DR$SDX_APP_I18N$NI||N|NLT_DOCID||

### DR$SDX_APP_I18N$Q



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|DML_ID|NUMBER|||||
|DML_OP|NUMBER|||||
|DML_RID|ROWID|||||

### DR$SDX_APP_I18N$U



#### Columns

| Column name | Column type | Default | Not null | Primary key | Description |
| ----------- | ----------- | ------- | -------- | ----------- | ----------- |
|RID|ROWID|||||

#### Indexes

| Index name | Unique | Generated | Columns | Description |
| ---------- | ------ | --------- | ------- | ----------- |
|DR$SDX_APP_I18N$UI||N|RID||

## Packages

### Summary

| Package name | Description |
| ------------ | ----------- |
|PCK_API_AUDIT|Package defines audit logging API|
|PCK_API_AUTH|Package provides methods for issuing and validating tokens |
|PCK_API_EMAILS|Package for sending emails|
|PCK_API_GOOGLE|Package provides implementation of Google API |
|PCK_API_HTTP|Package for HTTP call processing|
|PCK_API_I18N|Package provides translation services|
|PCK_API_JOBS|Package for managing jobs|
|PCK_API_LOB|Package for LOB processing. Credit: https://github.com/paulzip-dev/Base64|
|PCK_API_OPENAI|Package provides implementation of Open AI API |
|PCK_API_SETTINGS|Package provides methods for managing application settings |
|PCK_API_STORAGE|Package for storing andprocessing large binary objects|
|PCK_API_ZIP|Package for handling zip files, Credit: https://github.com/antonscheffer/as_zip |
|PCK_APP_DEMO|Demo package|

### PCK_API_AUDIT

Package defines audit logging API

Dependencies:

| Referenced type | Referenced name |
| --------------- | --------------- |
|TABLE|APP_AUDIT|

#### DBG

Procedure logs a debug entry

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ACTION|IN|VARCHAR2||Action performed|
|P_DETAILS|IN|VARCHAR2|NULL|Details|

#### ERR

Procedure logs an error entry

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ACTION|IN|VARCHAR2||Action performed|
|P_DETAILS|IN|VARCHAR2|NULL|Details|

#### INF

Procedure logs an info entry

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ACTION|IN|VARCHAR2||Action performed|
|P_DETAILS|IN|VARCHAR2|NULL|Details|

#### LOG

Procedure logs an audit entry

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CHAR||Concatenated key-value pairs|
|P_UUID|IN|CHAR||User unique ID |
|P_SEVERITY|IN|CHAR||Severity level (D - debug, I - info, W - warning, E - error)|
|P_ACTION|IN|VARCHAR2||Action performed|
|P_DETAILS|IN|VARCHAR2||Details|

#### MRG

Helper function to concatenate key-value pairs

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|VARCHAR2||Concatenated key-value pairs|
|P_KEY1|IN|VARCHAR2|NULL|Key 1|
|P_VAL1|IN|VARCHAR2|NULL|Value 1|
|P_KEY2|IN|VARCHAR2|NULL|Key 2|
|P_VAL2|IN|VARCHAR2|NULL|Value 2|
|P_KEY3|IN|VARCHAR2|NULL|Key 3|
|P_VAL3|IN|VARCHAR2|NULL|Value 3|
|P_KEY4|IN|VARCHAR2|NULL|Key 4|
|P_VAL4|IN|VARCHAR2|NULL|Value 4|
|P_KEY5|IN|VARCHAR2|NULL|Key 5|
|P_VAL5|IN|VARCHAR2|NULL|Value 5|
|P_KEY6|IN|VARCHAR2|NULL|Key 6|
|P_VAL6|IN|VARCHAR2|NULL|Value 6|

#### WRN

Procedure logs a warning entry

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ACTION|IN|VARCHAR2||Action performed|
|P_DETAILS|IN|VARCHAR2|NULL|Details|

### PCK_API_AUTH

Package provides methods for issuing and validating tokens 

Dependencies:

| Referenced type | Referenced name |
| --------------- | --------------- |
|TABLE|APP_USERS|
|TABLE|APP_TOKEN_TYPES|
|TABLE|APP_TOKENS|
|TABLE|APP_ROLES|
|TABLE|APP_PERMISSIONS|

#### AUTH

Function authenticates user

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CHAR||User unique ID|
|P_USERNAME|IN|VARCHAR2||Username|
|P_PASSWORD|IN|VARCHAR2||Password|

#### AUTH

Function authenticates user

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_USERNAME|IN|VARCHAR2||Username|
|P_PASSWORD|IN|VARCHAR2||Password|
|R_UUID|OUT|CHAR||User unique ID|

#### HTTP_401

Procedure sends HTTP 401 Unauthorized status

#### HTTP_403

Procedure sends HTTP 403 Forbidden status

#### PRIV

Function checks user privileges

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|VARCHAR2||Privilege (NULL - no pprivilege)|
|P_UUID|IN|CHAR|NULL|User unique ID (NULL - current user from bearer token)|
|P_ROLE|IN|VARCHAR2|NULL|Privilege|

#### RESET

Procedure revokes a JWT token

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_UUID|IN|CHAR||User unique ID|
|P_TYPE|IN|CHAR|NULL|Token type (APP_TOKEN_TYPES.ID), NULL - all tokens|

#### TOKEN

Procedure issues a JWT token

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_UUID|IN|CHAR||User unique ID|
|P_TYPE|IN|CHAR||Token type (APP_TOKEN_TYPES.ID)|
|R_TOKEN|OUT|VARCHAR2||Token|

#### TOKEN

Procedure issues a JWT token

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|VARCHAR2||Token|
|P_UUID|IN|CHAR||User unique ID|
|P_TYPE|IN|CHAR||Token type (APP_TOKEN_TYPES.ID)|

#### UUID

Function returns user unique ID from JWT token passed in the Authorization header as a Bearer token

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CHAR||Privilege (NULL - no pprivilege)|
|P_CHECK_EXPIRATION|IN|CHAR|'Y'|Check token expiration (Y/N)|

### PCK_API_EMAILS

Package for sending emails

Dependencies:

| Referenced type | Referenced name |
| --------------- | --------------- |
|TABLE|APP_EMAILS|
|TABLE|APP_EMAILS_ADDR|
|TABLE|APP_EMAILS_ATTC|

#### ADDR

Add an email address to the email

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN/OUT|NUMBER||Email ID|
|P_TYPE|IN|VARCHAR2||Email address type (From, ReplyTo, To, Cc, Bcc)|
|P_EMAIL_ADDR|IN|VARCHAR2||Email address|
|P_EMAIL_NAME|IN|VARCHAR2||Email addressee name|

#### ATTC

Add an attachment to the email

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN/OUT|NUMBER||Email ID|
|P_FILE_NAME|IN|VARCHAR2||Attachment file name|
|P_FILE_DATA|IN|BLOB||Attachment file data|

#### MAIL

Create a new email

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|R_ID|OUT|NUMBER||Email ID|
|P_EMAIL_ADDR|IN|VARCHAR2||Email address|
|P_EMAIL_NAME|IN|VARCHAR2||Email name|
|P_SUBJECT|IN|VARCHAR2||Email subject|
|P_CONTENT|IN|CLOB||Email content|
|P_PRIORITY|IN|NUMBER|3|Email priority (1..10)|

#### SEND

Send the email

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN/OUT|NUMBER||Email ID|
|P_POSTPONE|IN|BINARY_INTEGER|300|Postpone sending the email (seconds)|

### PCK_API_GOOGLE

Package provides implementation of Google API 

#### STREETVIEW_IMAGE

Procedure returns image from Google Streeetview API

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||Google  API key|
|P_ADDRESS|IN|VARCHAR2||Address|
|R_IMAGE|OUT|BLOB||Image|

#### STREETVIEW_METADATA

Procedure returns metadata from Google Streeetview API

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||Google API key|
|P_ADDRESS|IN|VARCHAR2||Address  |
|R_METADATA|OUT|VARCHAR2||Metadata|

### PCK_API_HTTP

Package for HTTP call processing

#### MIME_TYPE

Function returns mime type from file extention, e.g. mp3->audio/mpeg

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|VARCHAR2||Mime type|
|P_EXT|IN|VARCHAR2||File extention|

#### REQUEST

Function initiates HTTP request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_METHOD|IN|VARCHAR2||Method (GET, POST, PUT, DELETE, ..)|
|P_URL|IN|VARCHAR2||Url|
|P_VERSION|IN|VARCHAR2|'HTTP/1.1'|Version|

#### REQUEST_AUTH_BASIC

Procedure authenticates user with username and password

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_USERNAME|IN|VARCHAR2||User name|
|P_PASSWORD|IN|VARCHAR2||Password|

#### REQUEST_AUTH_TOKEN

Procedure adds Bearer token to the request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_TOKEN|IN|VARCHAR2||Token|

#### REQUEST_AUTH_WALLET

Procedure adds Oracle Wallet to HTTP connection (must be called before starting request)

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_WALLET_PATH|IN|VARCHAR2||Path to Oracle Wallet (without "file" prefix)|
|P_WALLET_PASSWORD|IN|VARCHAR2||Wallet password|

#### REQUEST_CHARSET

Procedure adds charset header to the HTTP request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_BODY_CHARSET|IN|VARCHAR2||Charset|

#### REQUEST_CONTENT_TYPE

Procedure adds content type header to the HTTP request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_CONTENT_TYPE|IN|VARCHAR2||Content type|

#### REQUEST_JSON

Procedure adds JSON payload to the HTTP request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_JSON|IN|CLOB||JSON data|

#### REQUEST_MULTIPART_BLOB

Procedure add file to multipart form data

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_NAME|IN|VARCHAR2||Name|
|P_FILENAME|IN|VARCHAR2||File name  |
|P_BLOB|IN|BLOB||File content|

#### REQUEST_MULTIPART_END

Procedure closes multipart data

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|

#### REQUEST_MULTIPART_START

Procedure starts multipart form data request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_CHARSET|IN|VARCHAR2|'UTF-8'|Charset|

#### REQUEST_MULTIPART_VARCHAR2

Procedure adds Varchar2 data to multipart form data 

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|P_NAME|IN|VARCHAR2||Name|
|P_VALUE|IN|VARCHAR2||Value|
|P_CHARSET|IN|VARCHAR2|'UTF-8'|Charset|

#### RESPONSE_BINARY

Function returns binary data from HTTP request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|R_BLOB|OUT|BLOB||Response data|

#### RESPONSE_TEXT

Function returns text data from HTTP request

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_REQ|IN/OUT|PL/SQL RECORD||HTTP request|
|R_CLOB|OUT|CLOB||Response data|

### PCK_API_I18N

Package provides translation services

Dependencies:

| Referenced type | Referenced name |
| --------------- | --------------- |
|TABLE|APP_I18N|

#### JOB_I18N

Job to translate all text via translation service provider

#### T

Translate text

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CLOB||Translated text|
|P_TEXT|IN|CLOB||Text to translate|
|P_LANG|IN|CHAR|'en'|Language, 2 letter code from ISO-639|
|P_CORRECTION|IN|CLOB|NULL|Correction, if translation is incorrect override and save manual correction|

### PCK_API_JOBS

Package for managing jobs

#### ADD

Add a new job

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_NAME|IN|VARCHAR2||Job name|
|P_PROGRAM|IN|VARCHAR2||Program name (PLSQL procedure)|
|P_ARGUMENTS|IN|CLOB||JSON array of arguments,  format [] of {type, name, value}|
|P_SCHEDULE|IN|VARCHAR2||Schedule interval, https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SCHEDULER.html#ARPLS-GUID-73622B78-EFF4-4D06-92F5-E358AB2D58F3|
|P_DESCRIPTION|IN|VARCHAR2||Job description|

#### DISABLE

Disable a job

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_NAME|IN|VARCHAR2||Job name|

#### ENABLE

Enable a job

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_NAME|IN|VARCHAR2||Job name|

#### REMOVE

Remove a job

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_NAME|IN|VARCHAR2||Job name|

#### RUN

Run a job

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_NAME|IN|VARCHAR2||Job name|

### PCK_API_LOB

Package for LOB processing. Credit: https://github.com/paulzip-dev/Base64

#### BASE64_TO_BLOB

Function decodes BASE64 to BLOB

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|BLOB||BLOB|
|P_BASE64|IN|CLOB||BASE64|

#### BASE64_TO_CLOB

Function decodes BASE64 to CLOB

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CLOB||CLOB|
|P_BASE64|IN|CLOB||BASE64|

#### BASE64_TO_VARCHAR2

Function decodes BASE64 to VARCHAR2

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|VARCHAR2||VARCHAR2|
|P_BASE64|IN|CLOB||BASE64|

#### BLOB_TO_BASE64

Function encodes BLOB to BASE64

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CLOB||CLOB|
|P_BLOB|IN|BLOB||BLOB|
|P_NEWLINE|IN|BINARY_INTEGER|1|Split in chunks (0 - No, 1 - Yes) |

#### BLOB_TO_CLOB

Function converts BLOB to CLOB

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CLOB||CLOB|
|P_BLOB|IN|BLOB||BLOB|
|P_CHARSET_ID|IN|NUMBER|dbms_lob.default_csid|Character set ID |
|P_ERROR_ON_WARNING|IN|BINARY_INTEGER|0|Raise exception on warning (0 - No, 1 - Yes)|

#### CLOB_TO_BASE64

Function encodes CLOB to BASE64

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CLOB||CLOB|
|P_CLOB|IN|CLOB||CLOB|
|P_NEWLINE|IN|BINARY_INTEGER|1|Split in chunks (0 - No, 1 - Yes) |

#### CLOB_TO_BLOB

Function converts CLOB to BLOB

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|BLOB||BLOB|
|P_CLOB|IN|CLOB||CLOB|
|P_CHARSET_ID|IN|NUMBER|dbms_lob.default_csid|Character set ID |
|P_ERROR_ON_WARNING|IN|BINARY_INTEGER|0|Raise exception on warning (0 - No, 1 - Yes)|

#### VARCHAR2_TO_BASE64

Function encodes VARCHAR2 to BASE64

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|CLOB||CLOB|
|P_VARCHAR2|IN|VARCHAR2||VARCHAR2|
|P_NEWLINE|IN|BINARY_INTEGER|1|Split in chunks (0 - No, 1 - Yes) |

### PCK_API_OPENAI

Package provides implementation of Open AI API 

#### COMPLETION

Procedure serves dialog with Open AI, https://platform.openai.com/docs/api-reference/chat

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||OpenAI API Key|
|P_MODEL|IN|VARCHAR2||Model (gpt-4 and dated model releases, gpt-4-1106-preview, gpt-4-vision-preview, gpt-4-32k and dated model releases, gpt-3.5-turbo and dated model releases, gpt-3.5-turbo-16k and dated model releases, fine-tuned versions of gpt-3.5-turbo)|
|P_PROMPT|IN|VARCHAR2||Prompt|
|P_MESSAGE|IN|CLOB||Message|
|R_MESSAGE|OUT|CLOB||Message|

#### MODERATIONS

Procedure  provides moderation, https://platform.openai.com/docs/api-reference/moderations

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||OpenAI API Key|
|P_MODEL|IN|VARCHAR2||Model (text-moderation-stable, text-moderation-latest)|
|P_PROMPT|IN|VARCHAR2||Prompt|
|R_MODERATIONS|OUT|CLOB||Moderation results |

#### SPEECH

Procedure generates speech from text, https://platform.openai.com/docs/api-reference/audio

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||OpenAI API Key|
|P_MODEL|IN|VARCHAR2||Model (tts-1, tts-1-hd)|
|P_INPUT|IN|VARCHAR2||Text|
|P_VOICE|IN|VARCHAR2||Voice (alloy, echo, fable, onyx, nova, shimmer)|
|P_RESPONSE_FORMAT|IN|VARCHAR2||File format (mp3, opus, aac, flac)|
|P_SPEED|IN|FLOAT||Speed (0.25..4)|
|R_SPEECH|OUT|BLOB||Audio file|

#### SPEECH

Procedure generates speech from text, https://platform.openai.com/docs/api-reference/audio

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||OpenAI API Key|
|P_INPUT|IN|VARCHAR2||Text|
|R_SPEECH|OUT|BLOB||Audio file|

#### TRANSCRIPT

Procedure transctipts audio file, https://platform.openai.com/docs/api-reference/audio/createTranscription

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||OpenAI API Key|
|P_FILE|IN|BLOB||File|
|P_FILENAME|IN|VARCHAR2||Filename|
|P_MODEL|IN|VARCHAR2||Model (whisper-1)|
|P_LANGUAGE|IN|VARCHAR2||Language (ISO-639-1)|
|P_PROMPT|IN|VARCHAR2||Prompt|
|P_RESPONSE_FORMAT|IN|VARCHAR2||Response format (json, text, srt, verbose_json, vtt)|
|P_TEMPERATURE|IN|VARCHAR2||Temperature (0..1)|
|R_TRANSCRIPT|OUT|VARCHAR2||Transcript|

#### TRANSLATIONS

Procedure translates audio file, https://platform.openai.com/docs/api-reference/audio/createTranslations

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||OpenAI API Key|
|P_FILE|IN|BLOB||File|
|P_FILENAME|IN|VARCHAR2||Filename|
|P_MODEL|IN|VARCHAR2||Model (whisper-1)|
|P_LANGUAGE|IN|VARCHAR2||Language (ISO-639-1)|
|P_PROMPT|IN|VARCHAR2||Prompt|
|P_RESPONSE_FORMAT|IN|VARCHAR2||Response format (json, text, srt, verbose_json, vtt)|
|P_TEMPERATURE|IN|VARCHAR2||Temperature (0..1)|
|R_TRANSCRIPT|OUT|VARCHAR2||Transcript|

#### VISION

Procedure provides image analysis capabilities, https://platform.openai.com/docs/guides/vision

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_API_KEY|IN|VARCHAR2||OpenAI API Key|
|P_MODEL|IN|VARCHAR2||Model (gpt-4-vision-preview)|
|P_PROMPT|IN|VARCHAR2||Prompt|
|P_IMAGE|IN|CLOB||image in base64 format|
|R_MESSAGE|OUT|CLOB||Vision response|

### PCK_API_SETTINGS

Package provides methods for managing application settings 

Dependencies:

| Referenced type | Referenced name |
| --------------- | --------------- |
|TABLE|APP_SETTINGS|

#### READ

Procedure returns value of the setting with the specified id

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN|VARCHAR2||Id of the setting|
|R_CONTENT|OUT|VARCHAR2||Value of the setting (variable character)|

#### READ

Procedure returns value of the setting with the specified id

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|VARCHAR2||Value of the setting (variable character)|
|P_ID|IN|VARCHAR2||Id of the setting|

#### REMOVE

Procedure deletes setting with the specified id

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN|VARCHAR2||Id of the setting|

#### WRITE

Procedure sets value of the setting with the specified id

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN|VARCHAR2||Id of the setting|
|P_CONTENT|IN|VARCHAR2||Value of the setting (variable character)|
|P_DESCRIPTION|IN|VARCHAR2|NULL|Description of the setting|

### PCK_API_STORAGE

Package for storing andprocessing large binary objects

Dependencies:

| Referenced type | Referenced name |
| --------------- | --------------- |
|TABLE|APP_STORAGE|

#### DELETE

Procedure deletes binary file

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN|CHAR||File ID|

#### DOWNLOAD

Procedure retrieves binary file

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN|CHAR||File ID|
|R_FILE|OUT|BLOB||File content|
|R_FILE_NAME|OUT|VARCHAR2||File name|
|R_FILE_SIZE|OUT|NUMBER||File size|
|R_FILE_EXT|OUT|VARCHAR2||File ext|
|R_MIME_TYPE|OUT|VARCHAR2||Mime type|

#### DOWNLOAD

Procedure retrieves binary file

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ID|IN|CHAR||File ID|
|R_FILE|OUT|BLOB||File content|
|R_FILE_NAME|OUT|VARCHAR2||File name|

#### UPLOAD

Procedure stores binary file

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_FILE|IN|BLOB||File content|
|P_FILE_NAME|IN|VARCHAR2||File name|
|R_ID|OUT|CHAR||File ID|

#### UPLOAD

Procedure stores binary file

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_FILE|IN|BLOB||File content|
|P_FILE_NAME|IN|VARCHAR2||File name|

### PCK_API_ZIP

Package for handling zip files, Credit: https://github.com/antonscheffer/as_zip 

#### ADD

Add a file to a zip archive

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ZIP|IN/OUT|BLOB||The zip archive|
|P_NAME|IN|VARCHAR2||The name of the file|
|P_CONTENT|IN|BLOB||The content of the file, if content will be NULL, a directory will be created|
|P_PASSWORD|IN|VARCHAR2|NULL|The password for the file|
|P_COMMENT|IN|VARCHAR2|NULL|The comment for the file|

#### DETAILS

Get the details of a file in a zip archive

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ZIP|IN|BLOB||The zip archive|
|P_NAME|IN|VARCHAR2||The name of the file|
|R_SIZE|OUT|BINARY_INTEGER||The size of the file|
|R_COMPRESSED_SIZE|OUT|BINARY_INTEGER||The compressed size of the file|
|R_IS_DIRECTORY|OUT|BOOLEAN||The file is a directory|
|R_HAS_PASSWORD|OUT|BOOLEAN||The file has a password|
|R_COMMENT|OUT|VARCHAR2||The comment of the file|

#### EXTRACT

Extract a file from a zip archive

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ZIP|IN/OUT|BLOB||The zip archive|
|P_NAME|IN|VARCHAR2||The name of the file|
|R_CONTENT|OUT|BLOB||The content of the file|
|P_PASSWORD|IN|VARCHAR2|NULL|The password for the file|

#### LIST

List the files in a zip archive

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
||OUT|TABLE||The list of files|
|P_ZIP|IN|BLOB||The zip archive|
|P_SEARCH|IN|VARCHAR2|NULL|The search string|
|P_LIMIT|IN|BINARY_INTEGER|100|The maximum number of files to return|
|P_OFFSET|IN|BINARY_INTEGER|0|The number of files to skip|

#### REMOVE

Remove a file from a zip archive

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|P_ZIP|IN/OUT|BLOB||The zip archive|
|P_NAME|IN|VARCHAR2||The name of the file|

### PCK_APP_DEMO

Demo package

#### GET_STATUS

Get status of the application

| Argument name | In Out | Data type | Default value | Description |
| ------------- | ------ | --------- | ------------- | ----------- |
|R_VERSION|OUT|VARCHAR2||Version of the application|
|R_CREATED|OUT|DATE||Date of creation|
|R_DBSIZE|OUT|REF CURSOR||Database size|
|R_ACE|OUT|REF CURSOR||Acces control list entries|


