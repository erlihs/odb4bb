BEGIN

    MERGE INTO app_settings USING DUAL ON (id = :setting_id)
    WHEN MATCHED THEN UPDATE SET content = :setting_value, description = :setting_description
    WHEN NOT MATCHED THEN INSERT (id, content, description) VALUES (:setting_id, :setting_value, :setting_description);
    
    COMMIT;

END;
/
