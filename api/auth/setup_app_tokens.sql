-- token settings

BEGIN
   EXECUTE IMMEDIATE '
CREATE TABLE app_token_settings(
   issuer VARCHAR2(200 CHAR) NOT NULL,
   audience VARCHAR2(200 CHAR) NOT NULL,
   secret CHAR(32 CHAR) ENCRYPT NOT NULL
)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END; 
/

COMMENT ON TABLE app_token_settings IS 'Table for storing and processing token settings';
COMMENT ON COLUMN app_token_settings.issuer IS 'Token issuer';
COMMENT ON COLUMN app_token_settings.audience IS 'Token audience';
COMMENT ON COLUMN app_token_settings.secret IS 'Token secret';

MERGE INTO app_token_settings t
USING (
   SELECT 
      :app_name AS issuer,
      :app_host AS audience,
      DBMS_RANDOM.STRING('X', 32) AS secret
   FROM dual
) s ON (1 = 1)
WHEN MATCHED THEN 
   UPDATE SET t.issuer = s.issuer, t.audience = s.audience, t.secret = s.secret
WHEN NOT MATCHED THEN 
   INSERT (issuer, audience, secret) VALUES (s.issuer, s.audience, s.secret);

-- token types

BEGIN
   EXECUTE IMMEDIATE '
CREATE TABLE app_token_types(
   id CHAR(1 CHAR) NOT NULL,
   description VARCHAR2(200 CHAR) NOT NULL,
   expiration NUMBER(10) NOT NULL
)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_token_types IS 'Table for storing and processing token types';
COMMENT ON COLUMN app_token_types.id IS 'Token type';
COMMENT ON COLUMN app_token_types.description IS 'Token type description';
COMMENT ON COLUMN app_token_types.expiration IS 'Token expiration time in seconds';

BEGIN
   EXECUTE IMMEDIATE '
ALTER TABLE app_token_types ADD CONSTRAINT cpk_app_token_types PRIMARY KEY (id)
   '; 
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END; 
/

MERGE INTO app_token_types t
USING (
   SELECT 
      'A' AS id,
      'Access token' AS description,
      900 AS expiration
   FROM dual
   UNION ALL
   SELECT 
      'R' AS id,
      'Refresh token' AS description,
      86400 AS expiration
   FROM dual
   UNION ALL
   SELECT 
      'P' AS id,
      'Password recovery token' AS description,
      3600 AS expiration
   FROM dual
   UNION ALL
   SELECT 
      'E' AS id,
      'Email confirmation token' AS description,
      86400 AS expiration
   FROM dual
) s ON (t.id = s.id)
WHEN MATCHED THEN 
   UPDATE SET t.description = s.description, t.expiration = s.expiration
WHEN NOT MATCHED THEN 
   INSERT (id, description, expiration) VALUES (s.id, s.description, s.expiration);

COMMIT;

-- tokens

BEGIN
   EXECUTE IMMEDIATE '
CREATE TABLE app_tokens(
   id_user NUMBER(19) NOT NULL,
   id_token_type CHAR(1 CHAR) NOT NULL,
   token VARCHAR2(2000 CHAR) NOT NULL,
   created TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
   expiration TIMESTAMP(6) NOT NULL
)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;      
/

COMMENT ON TABLE app_tokens IS 'Table for storing and processing user tokens';
COMMENT ON COLUMN app_tokens.id_user IS 'Reference to user (APP_USERS.ID)';
COMMENT ON COLUMN app_tokens.id_token_type IS 'Reference to token type (APP_TOKEN_TYPES.ID)';
COMMENT ON COLUMN app_tokens.token IS 'Token content, primary key';
COMMENT ON COLUMN app_tokens.created IS 'Date and time when token was created';
COMMENT ON COLUMN app_tokens.expiration IS 'Date and time when token expires';

BEGIN 
   EXECUTE IMMEDIATE 'ALTER TABLE app_tokens ADD CONSTRAINT cpk_app_tokens PRIMARY KEY (token)'; 
EXCEPTION 
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF; 
END;
/

BEGIN 
   EXECUTE IMMEDIATE 'ALTER TABLE app_tokens ADD CONSTRAINT cfk_app_tokens_id_user FOREIGN KEY (id_user) REFERENCES app_users(id)'; 
EXCEPTION 
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2264, -2275) THEN RAISE; END IF; 
END;
/

BEGIN 
   EXECUTE IMMEDIATE 'ALTER TABLE app_tokens ADD CONSTRAINT cfk_app_tokens_id_token_type FOREIGN KEY (id_token_type) REFERENCES app_token_types(id)';
EXCEPTION 
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2264, -2275) THEN RAISE; END IF;
END;
/

BEGIN
	EXECUTE IMMEDIATE '	
CREATE INDEX idx_app_tokens_expiration ON app_tokens(expiration)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

BEGIN
	EXECUTE IMMEDIATE '	
CREATE INDEX idx_app_tokens_id_user ON app_tokens(id_user)
	';
EXCEPTION
	WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/
