-- Encryption and Decryption in PostgreSQL

-- Ensure pgcrypto extension is enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create Table for Encrypted Data
CREATE TABLE emp_sal_details (
    empid SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    salary TEXT NOT NULL, -- Encrypted salary
    deptid INTEGER NOT NULL
);

-- Function to Encrypt Text
CREATE OR REPLACE FUNCTION encrypt_text(p_plain_text TEXT)
RETURNS TEXT AS $$
DECLARE
    v_encrypted TEXT;
BEGIN
    v_encrypted := pgp_sym_encrypt(p_plain_text, '1234567891234567');
    RETURN v_encrypted;
END;
$$ LANGUAGE plpgsql;

-- Function to Decrypt Text
CREATE OR REPLACE FUNCTION decrypt_text(p_encrypted_text TEXT)
RETURNS TEXT AS $$
DECLARE
    v_decrypted TEXT;
BEGIN
    v_decrypted := pgp_sym_decrypt(p_encrypted_text::bytea, '1234567891234567');
    RETURN v_decrypted;
END;
$$ LANGUAGE plpgsql;

-- Insert Encrypted Data
INSERT INTO emp_sal_details (name, salary, deptid)
VALUES ('John Doe', encrypt_text('75000'), 101);

-- Retrieve and Decrypt Data
SELECT empid, name, decrypt_text(salary) AS decrypted_salary, deptid FROM emp_sal_details;

-- Security Best Practices
-- 1. Use strong encryption keys and store them securely.
-- 2. Restrict access to sensitive data using user roles and privileges.
-- 3. Rotate encryption keys periodically and update encrypted data accordingly.
-- 4. Ensure pgcrypto extension is enabled and properly configured.

-- Author: *Shubham Panchal*
