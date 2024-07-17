CREATE OR REPLACE PACKAGE BODY pck_api_emails 
AS

    PROCEDURE mail(
        r_id OUT APP_EMAILS.ID%TYPE,
        p_email_addr APP_EMAILS_ADDR.ADDR_ADDR%TYPE,
        p_email_name APP_EMAILS_ADDR.ADDR_NAME%TYPE,
        p_subject APP_EMAILS.SUBJECT%TYPE,
        p_content APP_EMAILS.CONTENT%TYPE,
        p_priority APP_EMAILS.PRIORITY%TYPE DEFAULT 3
    ) AS
    BEGIN

        INSERT INTO app_emails(
            id,
            subject,
            content,
            priority            
        ) VALUES (
            seq_app_emails.NEXTVAL,
            p_subject,
            p_content,
            p_priority
        ) RETURNING id INTO r_id;

        INSERT INTO app_emails_addr(
            id_email,
            addr_type,
            addr_addr,
            addr_name
        ) 
        SELECT
            r_id,
            'From',
            from_addr,
            from_name
        FROM app_emails_settings;

        INSERT INTO app_emails_addr(
            id_email,
            addr_type,
            addr_addr,
            addr_name
        ) 
        SELECT
            r_id,
            'ReplyTo',
            replyto_addr,
            replyto_name
        FROM app_emails_settings;

        INSERT INTO app_emails_addr(
            id_email,
            addr_type,
            addr_addr,
            addr_name
        ) VALUES (
            r_id,
            'To',
            p_email_addr,
            p_email_name
        );

        COMMIT;

    END;

    PROCEDURE addr(
        p_id IN OUT APP_EMAILS.ID%TYPE,
        p_type APP_EMAILS_ADDR.ADDR_TYPE%TYPE,
        p_email_addr APP_EMAILS_ADDR.ADDR_ADDR%TYPE,
        p_email_name APP_EMAILS_ADDR.ADDR_NAME%TYPE
    ) AS
    BEGIN

        INSERT INTO app_emails_addr(
            id_email,
            addr_type,
            addr_addr,
            addr_name
        ) VALUES (
            p_id,
            p_type,
            p_email_addr,
            p_email_name
        );

        COMMIT;

    END;

    PROCEDURE attc(
        p_id IN OUT APP_EMAILS.ID%TYPE,
        p_file_name APP_EMAILS_ATTC.FILE_NAME%TYPE,
        p_file_data APP_EMAILS_ATTC.FILE_DATA%TYPE
    ) AS
    BEGIN

        INSERT INTO app_emails_attc(
            id_email,
            file_name,
            file_data
        ) VALUES (
            p_id,
            p_file_name,
            p_file_data
        );

        COMMIT;

    END;

    PROCEDURE send(
        p_id IN OUT APP_EMAILS.ID%TYPE,
        p_postpone PLS_INTEGER DEFAULT 300
    ) AS
        c_smtp_host VARCHAR2(2000 CHAR);
        c_smtp_port PLS_INTEGER;
        c_smtp_cred VARCHAR2(2000 CHAR);
        v_conn UTL_SMTP.CONNECTION;
        c_boundary VARCHAR2(50) := '----=*#abc1234321cba#*='; 
        c_blob_mime VARCHAR2(254) := 'text/plain';
		v_chunk PLS_INTEGER  := 57;
        v_len PLS_INTEGER;
		v_blob BLOB;
        v_error VARCHAR2(2000 CHAR);

		FUNCTION email_encode_utf8 (
			p_value VARCHAR2
		) RETURN
			VARCHAR2
		AS
		BEGIN
			RETURN REPLACE('=?UTF-8?Q?' ||UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(p_value)))||'?=','=' || UTL_TCP.CRLF,'');
		END;

		FUNCTION email_format_address (
			p_addr VARCHAR2,
			p_name VARCHAR2
		) RETURN
			VARCHAR2
		AS
		BEGIN
			IF p_name IS NOT NULL THEN
				RETURN('"' || email_encode_utf8(p_name) || '"<' || p_addr || '>');
			ELSE
				RETURN ('<' || p_addr || '>');
			END IF;
		END;  

        FUNCTION clob_to_blob(
            value            IN CLOB,
            charset_id       IN INTEGER DEFAULT DBMS_LOB.DEFAULT_CSID,
            error_on_warning IN NUMBER  DEFAULT 0
        ) RETURN BLOB
        IS
            result       BLOB;
            dest_offset  INTEGER := 1;
            src_offset   INTEGER := 1;
            lang_context INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
            warning      INTEGER;
            warning_msg  VARCHAR2(50);
            BEGIN
            DBMS_LOB.CreateTemporary(
                lob_loc => result,
                cache   => TRUE
            );

            DBMS_LOB.CONVERTTOBLOB(
                dest_lob     => result,
                src_clob     => value,
                amount       => LENGTH( value ),
                dest_offset  => dest_offset,
                src_offset   => src_offset,
                blob_csid    => charset_id,
                lang_context => lang_context,
                warning      => warning
            );
            
            IF warning != DBMS_LOB.NO_WARNING THEN
                IF warning = DBMS_LOB.WARN_INCONVERTIBLE_CHAR THEN
                warning_msg := 'Warning: Inconvertible character.';
                ELSE
                warning_msg := 'Warning: (' || warning || ') during CLOB conversion.';
                END IF;
                
                IF error_on_warning = 0 THEN
                DBMS_OUTPUT.PUT_LINE( warning_msg );
                ELSE
                RAISE_APPLICATION_ERROR(
                    -20567, -- random value between -20000 and -20999
                    warning_msg
                );
                END IF;
            END IF;

            RETURN result;
        END clob_to_blob;

    BEGIN

        SELECT smtp_host, smtp_port, smtp_cred
        INTO c_smtp_host, c_smtp_port, c_smtp_cred
        FROM app_emails_settings;

        FOR e IN (
            SELECT id, subject, content
            FROM app_emails
            WHERE id = p_id
        ) LOOP

            BEGIN

                v_conn := UTL_SMTP.open_connection(c_smtp_host, c_smtp_port);
                UTL_SMTP.starttls(v_conn);
                UTL_SMTP.SET_CREDENTIAL(v_conn, c_smtp_cred, schemes => 'PLAIN');

                FOR a IN (
                    SELECT addr_addr
                    FROM app_emails_addr
                    WHERE id_email = e.id
                    AND addr_type = 'From'
                ) LOOP
                    UTL_SMTP.mail(v_conn, a.addr_addr);
                END LOOP; 

                FOR a IN (
                    SELECT addr_addr
                    FROM app_emails_addr
                    WHERE id_email = e.id
                    AND addr_type IN ('To', 'Cc', 'Bcc')
                ) LOOP
                    UTL_SMTP.rcpt(v_conn, a.addr_addr);
                END LOOP; 

                UTL_SMTP.open_data(v_conn);
        
                UTL_SMTP.write_data(v_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
        		UTL_SMTP.write_data(v_conn, 'Subject: ' || EMAIL_ENCODE_UTF8(e.subject) || UTL_TCP.CRLF);

                FOR a IN (
                    SELECT addr_type, addr_addr, addr_name
                    FROM app_emails_addr
                    WHERE id_email = e.id
                ) LOOP
                    UTL_SMTP.write_data(v_conn, a.addr_type || ': ' || EMAIL_FORMAT_ADDRESS(a.addr_addr, a.addr_name) || UTL_TCP.CRLF); 
                END LOOP; 

                UTL_SMTP.WRITE_DATA(v_conn, 'MIME-version: 1.0');
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                UTL_SMTP.write_data(v_conn, 'Content-Type: multipart/mixed; boundary="' || c_boundary || '"');	
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                UTL_SMTP.WRITE_DATA(v_conn, '--' || c_boundary);	
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                UTL_SMTP.write_data(v_conn, 'Content-Type: text/html; charset = "utf-8"');		
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                UTL_SMTP.write_data(v_conn, 'Content-Transfer-Encoding: base64');		
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                v_len := DBMS_LOB.getLength(e.content);
                IF v_len < 2000 THEN
                    UTL_SMTP.WRITE_RAW_DATA(v_conn, UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(e.content))); -- ??? CLOB
                ELSE	
                    v_blob := clob_to_blob (e.content);
                    FOR i IN 0 .. TRUNC((DBMS_LOB.GETLENGTH(v_blob) - 1 )/v_chunk) LOOP
                        UTL_SMTP.write_data(v_conn, UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.substr(v_blob, v_chunk, i * v_chunk + 1))));
                    END LOOP;
                END IF;	
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
                UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);

                FOR a IN (
                    SELECT file_data, file_name
                    FROM app_emails_attc
                    WHERE id_email = p_id
                    ORDER BY file_name
                ) LOOP
             
                    UTL_SMTP.WRITE_DATA(v_conn, '--' || c_boundary || UTL_TCP.CRLF);
                    UTL_SMTP.WRITE_DATA(v_conn, 'Content-Type: ' || c_blob_mime || '; name="' || EMAIL_ENCODE_UTF8(a.file_name) || '"' || UTL_TCP.CRLF);
                    UTL_SMTP.WRITE_DATA(v_conn, 'Content-Transfer-Encoding: base64' || UTL_TCP.CRLF);
                    UTL_SMTP.WRITE_DATA(v_conn, 'Content-Disposition: attachment; filename="' || EMAIL_ENCODE_UTF8(a.file_name) || '"' || UTL_TCP.crlf || UTL_TCP.CRLF);

                    FOR i IN 0 .. TRUNC((DBMS_LOB.GETLENGTH(a.file_data) - 1 )/v_chunk) LOOP
                        UTL_SMTP.write_data(v_conn, UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.substr(a.file_data, v_chunk, i * v_chunk + 1))));
                    END LOOP;

                    UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF || UTL_TCP.CRLF);
                            
                END LOOP;        
            
                UTL_SMTP.WRITE_DATA(v_conn, '--' || c_boundary || '--' || UTL_TCP.CRLF);

        		UTL_SMTP.close_data(v_conn);        
                UTL_SMTP.quit(v_conn);
                
                UPDATE app_emails SET
                    status = 'S',
                    delivered = SYSTIMESTAMP
                WHERE id = p_id;
                
                COMMIT;
                
            EXCEPTION
                WHEN OTHERS THEN

                    v_error := '(' || SQLCODE || ') ' || TRIM(SUBSTR(SQLERRM, 1, 254)) || ' ' || 
                        TRIM(SUBSTR(DBMS_UTILITY.FORMAT_ERROR_STACK,1,512)) || ' ' ||  TRIM(SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,512));

                    UPDATE app_emails SET
                        status = 'E',
                        attempts = attempts + 1,
                        postponed = SYSTIMESTAMP + p_postpone / 84600,
                        error = v_error
                    WHERE id = p_id;

                    COMMIT;

                    dbms_output.put_line('!!!' || v_error);

                    UTL_smtp.quit(v_conn);
                    RAISE;

            END;          
        
        END LOOP;

    END;


END;
/
