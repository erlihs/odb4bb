CREATE OR REPLACE PACKAGE pck_api_convert AS -- Package for converting data formats

  PROCEDURE xml_to_json ( -- Convert XML to JSON
      p_xml IN CLOB, -- Input XML data
      r_json IN OUT NOCOPY CLOB -- Output JSON data
  );

  PROCEDURE json_to_xml ( -- Convert JSON to XML
      p_json IN CLOB, -- Input JSON data
      r_xml IN OUT NOCOPY CLOB 
  );

END;
/
