set SERVEROUTPUT ON
/

BEGIN

    IF pck_api_validate.validate('abc','required','Value is required') IS NOT NULL THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #1 failed');
    END IF;
    
    IF pck_api_validate.validate('','required','Value is required') IS NULL THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #2 failed');
    END IF;
    
    IF pck_api_validate.validate(NULL,'required','Value is required') IS NULL THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #3 failed');
    END IF;

    IF pck_api_validate.validate('6','in-range','Must be between 1 and 10','{"min": 1,"max": 10}') IS NOT NULL THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #4 failed');
    END IF;

    IF pck_api_validate.validate('16','in-range','Must be between 1 and 10','{"min": 1,"max": 10}') IS NULL THEN 
      RAISE_APPLICATION_ERROR(-20000, 'validation test #5 failed');
    END IF;

END;
/
