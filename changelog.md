# Changelog

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

