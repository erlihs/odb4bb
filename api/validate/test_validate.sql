set SERVEROUTPUT ON
/

DECLARE 
  r SYS_REFCURSOR;
  c_required CONSTANT VARCHAR2(2000 CHAR) := '{"rules":[{"type":"required","params":null,"message":"Value is required"}]}';
  c_between_1_and_10 CONSTANT VARCHAR2(2000 CHAR) := '{"rules":[{"type":"in-range","params":{"min": 1,"max": 10},"message":"Value must be in range 1..10"}]}';
BEGIN

    IF pck_api_validate.validate('test#1','abc',c_required, r) > 0 THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #1 failed');
    END IF;
    
    IF pck_api_validate.validate('test#2','',c_required, r) = 0 THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #2 failed');
    END IF;
    
    IF pck_api_validate.validate('test#3', NULL, c_required, r) = 0 THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #3 failed');
    END IF;

    IF pck_api_validate.validate('test#4',6 , c_between_1_and_10, r) > 0 THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #4 failed');
    END IF;

    IF pck_api_validate.validate('test#5',16 , c_between_1_and_10, r) = 0 THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #5 failed');
    END IF;

END;
/
