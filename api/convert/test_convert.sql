DECLARE
    x CLOB := '';
    j CLOB := '';

BEGIN
    
    j := '{"openapi":"3.0.3","info":{"title":"BSB_DEV API","version":"1.0.0"},"paths":{"/api/v1/convert/yaml_to_json":{"get":{"summary":"Convert YAML to JSON","operationId":"convertYamlToJson","responses":{"200":{"description":"Successful response"}}}}}}';
    
    pck_api_convert.json_to_xml(j, x);
    --DBMS_OUTPUT.PUT_LINE(x);

    x := '<map xmlns="http://www.w3.org/2005/xpath-functions">
  <string key="openapi">3.0.3</string>
  <map key="info">
    <string key="title">BSB_DEV API</string>
    <string key="version">1.0.0</string>
  </map>
  <map key="paths">
    <map key="/api/v1/convert/yaml_to_json">
      <map key="get">
        <string key="summary">Convert YAML to JSON</string>
        <string key="operationId">convertYamlToJson</string>
        <map key="responses">
          <map key="200">
            <string key="description">Successful response</string>
          </map>
        </map>
      </map>
    </map>
  </map>
</map>';

    pck_api_convert.xml_to_json(x, j);
    --DBMS_OUTPUT.PUT_LINE(j);

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Convert XML to JSON a test failed!');
END;
/