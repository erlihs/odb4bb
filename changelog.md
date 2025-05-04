## Release 0.3.9 (2025-05-04)

### Feature

- OpenAI api new method `pck_api_openai.image` to generate image by prompt 

## Release 0.3.8 (2025-04-20)

### Refactoring

- Validation API `pck_api_validate` changed - param `value` to `params` 

## Release 0.3.7 (2025-04-13)

### Features

- Nev API `pck_api_convert` for converting data

    - xml_to_json
    - json_to_xml

- Release increment number moved as constant to `./setup.sql`

## Release 0.3.6 (2025-04-05)

### Bugfixes

- i18n fails if more than 4k of data

## Release 0.3.5 (2025-01-12)

### Features

- Refactored i18n

## Release 0.3.4 (2025-01-11)

### Features

- Refresh works either with Bearer token or Cookie

### Bugfixes 

- Validate package `pck_api_validate` 23ai -> 19 compatibility

## Release 0.3.3 (2025-01-08)

### Features

- Automated ORDS when recompiling package - trigger `trg_ordsify`
- Generation of Open API 3.0 Manifest in YAML format

### Bugfixes 

- Fixed flaw that prevented deletion of job in `pck_api_jobs.remove`
- Update of readme
- pck_api_auth.uuid exception handling 
- pck_api_auth.role returns NULL instead of 0 on no role

## Release 0.3.2 (2024-12-30)

### Bugfixes 

- Refactored `pck_api_validate` (Experimental)
- setup script sequence for jobs fixed

## Release 0.3.1 (2024-12-26)

### Features

- error message as optional parameter for `pck_api_auth.http_xyz`

## Release 0.3.0 (2024-12-25)

### Features

- password generation `pck_api_auth.pwd`
- new indexes `app_tokens.expiration`, `app_tokens.id_user`
- new job `cleanup` for cleaning up expired tokens
- new privilege validation routines `pck_api_auth.role` and `pck_api_auth.perm`
- new table `app_audit_archive`, procedure `pck_api_audit.archive` and job `archive` to archive historical audit records
- new api `pck_api_validate` (Experimental)

### Bugfixes

- long audit details trimmed to 2000 chars in `pck_api_auth.audit`
- allow multiple tokens for the same user and token type
- grant to manage scheduler

## Release 0.2.4 (2024-12-15)

### Bugfixes

- saving `:app_host` from `@setup.sql` in `app_settings`  

## Release 0.2.3 (2024-12-14)

### Features

- optional `created` parameter added to audit routines `pck_api_audit.dbg`, `...inf`, `...wrn`, `...err`
- new routine added to audit routuntines `pck_api_audit.audit` providing capability of bulk insert of audit data 

## Release 0.2.2 (2024-12-03)

### Features

- optional `uuid` parameter added to audit routines `pck_api_audit.dbg`, `...inf`, `...wrn`, `...err`

## Release 0.2.1 (2024-11-30)

### Features

- routine `pck_api_auth.refresh` added to get uuid from refresh token passed in cookie

## Release 0.2.0 (2024-07-17)

Initial release

