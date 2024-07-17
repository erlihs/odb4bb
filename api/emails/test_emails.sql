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
