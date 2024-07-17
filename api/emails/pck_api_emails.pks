CREATE OR REPLACE PACKAGE pck_api_emails -- Package for sending emails
AS

    PROCEDURE mail( -- Create a new email
        r_id OUT APP_EMAILS.ID%TYPE, -- Email ID
        p_email_addr APP_EMAILS_ADDR.ADDR_ADDR%TYPE, -- Email address
        p_email_name APP_EMAILS_ADDR.ADDR_NAME%TYPE, -- Email name
        p_subject APP_EMAILS.SUBJECT%TYPE, -- Email subject
        p_content APP_EMAILS.CONTENT%TYPE, -- Email content
        p_priority APP_EMAILS.PRIORITY%TYPE DEFAULT 3 -- Email priority (1..10)
    );

    PROCEDURE addr( -- Add an email address to the email
        p_id IN OUT APP_EMAILS.ID%TYPE, -- Email ID
        p_type APP_EMAILS_ADDR.ADDR_TYPE%TYPE, -- Email address type (From, ReplyTo, To, Cc, Bcc)
        p_email_addr APP_EMAILS_ADDR.ADDR_ADDR%TYPE, -- Email address
        p_email_name APP_EMAILS_ADDR.ADDR_NAME%TYPE -- Email addressee name
    );

    PROCEDURE attc( -- Add an attachment to the email
        p_id IN OUT APP_EMAILS.ID%TYPE, -- Email ID
        p_file_name APP_EMAILS_ATTC.FILE_NAME%TYPE, -- Attachment file name
        p_file_data APP_EMAILS_ATTC.FILE_DATA%TYPE -- Attachment file data
    );
    
    PROCEDURE send( -- Send the email
        p_id IN OUT APP_EMAILS.ID%TYPE, -- Email ID
        p_postpone PLS_INTEGER DEFAULT 300 -- Postpone sending the email (seconds)
    );

END;
/