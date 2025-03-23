-- Encryption and Decryption in Oracle

-- Enable DBMS_CRYPTO Package
-- Ensure required privileges to use DBMS_CRYPTO
GRANT EXECUTE ON DBMS_CRYPTO TO <username>;


-- Create Table for Encrypted Data
CREATE TABLE emp_sal_details (
    empid NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    salary VARCHAR2(4000) NOT NULL,
    deptid NUMBER NOT NULL
);

-- Function to Encrypt Text
CREATE OR REPLACE FUNCTION encrypt_text(p_plain_text IN VARCHAR2)
RETURN VARCHAR2 IS
    v_key RAW(16) := UTL_RAW.CAST_TO_RAW('1234567891234567'); -- 16-byte key for AES-128
    v_encrypted RAW(2000);
BEGIN
    v_encrypted := DBMS_CRYPTO.ENCRYPT(
        src => UTL_RAW.CAST_TO_RAW(p_plain_text), -- Convert string to RAW
        typ => DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
        key => v_key
    );
    RETURN RAWTOHEX(v_encrypted); -- Convert RAW to Hex string for storage
END;
/

-- Function to Decrypt Text
CREATE OR REPLACE FUNCTION decrypt_text(p_encrypted_text IN VARCHAR2)
RETURN VARCHAR2 IS
    v_key RAW(16) := UTL_RAW.CAST_TO_RAW('1234567891234567'); -- 16-byte key for AES-128
    v_decrypted RAW(2000);
BEGIN
    v_decrypted := DBMS_CRYPTO.DECRYPT(
        src => HEXTORAW(p_encrypted_text), -- Convert Hex string back to RAW
        typ => DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
        key => v_key
    );
    RETURN UTL_RAW.CAST_TO_VARCHAR2(v_decrypted); -- Convert RAW back to string
END;
/

-- Insert Encrypted Data
DECLARE
    encryption_key RAW(16) := UTL_RAW.CAST_TO_RAW('1234567891234567');
BEGIN
    INSERT INTO emp_sal_details (empid, name, salary, deptid)
    VALUES (1, 'John Doe', encrypt_text('75000'), 101);
    COMMIT;
END;
/

-- Retrieve and Decrypt Data
DECLARE
    decrypted_salary VARCHAR2(4000);
BEGIN
    SELECT decrypt_text(salary) INTO decrypted_salary FROM emp_sal_details WHERE empid = 1;
    DBMS_OUTPUT.PUT_LINE('Decrypted Salary: ' || decrypted_salary);
END;
/

-- Security Best Practices
-- 1. Use strong encryption keys and store them securely.
-- 2. Restrict access to sensitive data using user roles and privileges.
-- 3. Rotate encryption keys periodically and update encrypted data accordingly.
-- 4. Ensure DBMS_CRYPTO package is granted execute privileges to authorized users only.

-- Author: *Shubham Panchal*
