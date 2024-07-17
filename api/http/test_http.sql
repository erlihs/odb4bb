DECLARE
    v_req utl_http.req;
    v_text CLOB;
BEGIN
    pck_api_http.request(v_req, 'GET', 'https://api.chucknorris.io/jokes/random');
    pck_api_http.response_text(v_req, v_text);
    -- DBMS_OUTPUT.PUT_LINE(JSON_VALUE(v_text, '$.value'));
END;
/
