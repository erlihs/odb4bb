-- roles

BEGIN
   EXECUTE IMMEDIATE '
CREATE SEQUENCE seq_app_roles START WITH 1 INCREMENT BY 1 NOCACHE
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE '
CREATE TABLE app_roles (
   id NUMBER(19,0) NOT NULL,
   role VARCHAR2(200) NOT NULL,
   description VARCHAR2(2000)
)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;     
/

COMMENT ON TABLE app_roles IS 'Table for storing user roles';
COMMENT ON COLUMN app_roles.id IS 'Role id';
COMMENT ON COLUMN app_roles.role IS 'Role name';
COMMENT ON COLUMN app_roles.description IS 'Role description';

BEGIN
   EXECUTE IMMEDIATE '
ALTER TABLE app_roles ADD CONSTRAINT cpk_app_roles PRIMARY KEY (id)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/   

MERGE INTO app_roles r
USING (
   SELECT 
      1 AS id,
      'ADMIN' AS role,
      'Administrator access' AS description
   FROM dual
) s ON (r.id = s.id)
WHEN MATCHED THEN 
   UPDATE SET r.role = s.role, r.description = s.description
WHEN NOT MATCHED THEN 
   INSERT (id, role, description) VALUES (seq_app_roles.NEXTVAL, s.role, s.description);

COMMIT;

-- permisssions

BEGIN
   EXECUTE IMMEDIATE '
CREATE TABLE app_permissions (
   id_user NUMBER(19,0) NOT NULL,
   id_role NUMBER(19,0) NOT NULL,
   permission VARCHAR2(2000 CHAR) NOT NULL,
   valid_from TIMESTAMP(6) DEFAULT SYSTIMESTAMP NOT NULL,
   valid_to TIMESTAMP(6)
)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-955) THEN RAISE; END IF;
END;
/

COMMENT ON TABLE app_permissions IS 'Table for storing user permissions';
COMMENT ON COLUMN app_permissions.id_user IS 'User id';
COMMENT ON COLUMN app_permissions.id_role IS 'Role id';
COMMENT ON COLUMN app_permissions.permission IS 'Permission details';
COMMENT ON COLUMN app_permissions.valid_from IS 'Validity period from';
COMMENT ON COLUMN app_permissions.valid_to IS 'Validity period to';

BEGIN
   EXECUTE IMMEDIATE '
ALTER TABLE app_permissions ADD CONSTRAINT cpk_app_permissions PRIMARY KEY (id_user, id_role)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2260) THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE '
ALTER TABLE app_permissions ADD CONSTRAINT cfk_app_permissions_id_user FOREIGN KEY (id_user) REFERENCES app_users(id)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2291, -2275) THEN RAISE; END IF; 
END;
/

BEGIN
   EXECUTE IMMEDIATE '
ALTER TABLE app_permissions ADD CONSTRAINT cfk_app_permissions_id_role FOREIGN KEY (id_role) REFERENCES app_roles(id)
   ';
EXCEPTION
   WHEN OTHERS THEN IF SQLCODE NOT IN (-2291, -2275) THEN RAISE; END IF;
END;
/

MERGE INTO app_permissions p
USING (
   SELECT 
      1 AS id_user,
      1 AS id_role,
      'Y' AS permission,
      SYSTIMESTAMP AS valid_from
   FROM dual
) s ON (p.id_user = s.id_user AND p.id_role = s.id_role)
WHEN MATCHED THEN 
   UPDATE SET p.permission = s.permission, p.valid_from = s.valid_from
WHEN NOT MATCHED THEN 
   INSERT (id_user, id_role, permission, valid_from) VALUES (s.id_user, s.id_role, s.permission, s.valid_from);

COMMIT;

/
