# Run it after running Base tables. Below are the base tables (Code is Found in rafvue_Data repo for base_tables) 
#(billing_provider, claim_date_time_period, claims, claims_reference, hcc_Codes, isa, patient, pay_to_address
#physician, receiver, rendering_provider, secondary_payer,
#service_facility_location, service_lines, submitter, subscriber, transaction)

# adding mrn for all the base tables

Alter table billing_provider
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE billing_provider AS bp
LEFT JOIN claims_reference AS cr ON bp.transaction_id = cr.transaction_id
SET bp.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

Alter table claims
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE claims AS cl
LEFT JOIN claims_reference AS cr ON cl.transaction_id = cr.transaction_id
SET cl.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';


Alter table claim_date_time_period
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE claim_date_time_period AS c_dtp
LEFT JOIN claims AS c ON c.id = c_dtp.claims_id
SET c_dtp.mrn = c.mrn;


Alter table hcc_codes
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE hcc_codes AS hc
LEFT JOIN claims_reference AS cr ON hc.transaction_id = cr.transaction_id
SET hc.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

Alter table pay_to_address
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE pay_to_address AS pa
LEFT JOIN claims_reference AS cr ON pa.transaction_id = cr.transaction_id
SET pa.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

Alter table physician
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE physician AS ph
LEFT JOIN claims_reference AS cr ON ph.transaction_id = cr.transaction_id
SET ph.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

Alter table receiver
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE receiver AS re
LEFT JOIN claims_reference AS cr ON re.transaction_id = cr.transaction_id
SET re.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';


Alter table rendering_provider
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE rendering_provider AS rp
LEFT JOIN claims_reference AS cr ON rp.transaction_id = cr.transaction_id
SET rp.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

Alter table secondary_payer
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE secondary_payer AS sp
LEFT JOIN claims_reference AS cr ON sp.transaction_id = cr.transaction_id
SET sp.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';


ALTER TABLE service_facility_location
DROP COLUMN mrn;

Alter table service_facility_location
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE service_facility_location AS sfl
LEFT JOIN claims_reference AS cr ON sfl.transaction_id = cr.transaction_id
SET sfl.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';


Alter table service_lines
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE service_lines AS sl
LEFT JOIN claims_reference AS cr ON sl.transaction_id = cr.transaction_id
SET sl.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

Alter table submitter
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE submitter AS su
LEFT JOIN claims_reference AS cr ON su.transaction_id = cr.transaction_id
SET su.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';


Alter table subscriber
ADD COLUMN mrn varchar(255);

set sql_safe_updates =0;
UPDATE subscriber AS su
LEFT JOIN claims_reference AS cr ON su.transaction_id = cr.transaction_id
SET su.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';
 
Alter table patient
ADD COLUMN mrn varchar(255);

set sql_safe_updates =0;
UPDATE patient AS p
LEFT JOIN claims_reference AS cr ON p.transaction_id = cr.transaction_id
SET p.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

ALTER TABLE billing_provider
DROP COLUMN subscriber_id;

ALTER TABLE claims
DROP COLUMN subscriber_id;

ALTER TABLE claim_date_time_period
DROP COLUMN subscriber_id;

ALTER TABLE hcc_codes
DROP COLUMN subscriber_id;

ALTER TABLE pay_to_address
DROP COLUMN subscriber_id;

ALTER TABLE physician
DROP COLUMN subscriber_id;

ALTER TABLE receiver
DROP COLUMN subscriber_id;

ALTER TABLE rendering_provider
DROP COLUMN subscriber_id;

ALTER TABLE secondary_payer
DROP COLUMN subscriber_id;

ALTER TABLE service_facility_location
DROP COLUMN subscriber_id;

ALTER TABLE service_lines
DROP COLUMN subscriber_id;

ALTER TABLE submitter
DROP COLUMN subscriber_id;


ALTER TABLE billing_provider
DROP COLUMN subscriber_id_old;

ALTER TABLE claims
DROP COLUMN subscriber_id_old;

ALTER TABLE hcc_codes
DROP COLUMN subscriber_id_old;

ALTER TABLE pay_to_address
DROP COLUMN subscriber_id_old;

ALTER TABLE physician
DROP COLUMN subscriber_id_old;

ALTER TABLE receiver
DROP COLUMN subscriber_id_old;

ALTER TABLE rendering_provider
DROP COLUMN subscriber_id_old;

ALTER TABLE secondary_payer
DROP COLUMN subscriber_id_old;

ALTER TABLE service_facility_location
DROP COLUMN subscriber_id_old;

ALTER TABLE service_lines
DROP COLUMN subscriber_id_old;

ALTER TABLE submitter
DROP COLUMN subscriber_id_old;

ALTER TABLE subscriber
DROP COLUMN subscriber_id_old;

ALTER TABLE patient
DROP COLUMN subscriber_id_old;

ALTER TABLE patients_data
DROP COLUMN subscriber_id_old;

Drop table  if exists rafvue.patients_data;
CREATE TABLE rafvue.patients_data (
    id INT NOT NULL AUTO_INCREMENT,
    transaction_id VARCHAR(255) DEFAULT NULL,
    subscriber_id_old VARCHAR(75) DEFAULT NULL,
    IdentificationCode VARCHAR(255) DEFAULT NULL,
    IdentificationCodeQualifier VARCHAR(255) DEFAULT NULL,
    FirstName VARCHAR(255) DEFAULT NULL,
    MiddleName VARCHAR(255) DEFAULT NULL,
    LastName VARCHAR(255) DEFAULT NULL,
    DateOfBirth date DEFAULT NULL,
    Gender VARCHAR(255) DEFAULT NULL,
    transaction_date date DEFAULT NULL,
    Address VARCHAR(255) DEFAULT NULL,
    City VARCHAR(255) DEFAULT NULL,
    State VARCHAR(255) DEFAULT NULL,
    PostalCode VARCHAR(255) DEFAULT NULL,
    PayerId VARCHAR(45) DEFAULT NULL,
    PayerName VARCHAR(75) DEFAULT NULL,
    Payer_Address VARCHAR(245) DEFAULT NULL,
    Payer_city VARCHAR(75) DEFAULT NULL,
    Payer_State VARCHAR(45) DEFAULT NULL,
    Payer_PostalCode VARCHAR(45) DEFAULT NULL,
    PRIMARY KEY (id)
);

INSERT INTO rafvue.patients_data (
    PayerName,
    PayerId,
    Payer_Address,
    Payer_city,
    Payer_State,
    Payer_PostalCode,
    transaction_id,
    subscriber_id_old,
    transaction_date,
    IdentificationCode,
    IdentificationCodeQualifier,
    FirstName,
    LastName,
    MiddleName,
    Address,
    City,
    State,
    PostalCode,
    DateOfBirth,
    Gender
)
SELECT
    s.PayerName,
    s.PayerId,
    s.Payer_Address,
    s.Payer_city,
    s.Payer_State,
    s.Payer_PostalCode,
    s.transaction_id,
    s.subscriber_id_old,
    s.transaction_date,
    s.IdentificationCode,
    s.IdentificationCodeQualifier,
    CASE
        WHEN s.isPatient = 'Y' THEN s.FirstName
        ELSE p.FirstName
    END AS FirstName,
    CASE
        WHEN s.isPatient = 'Y' THEN s.LastName
        ELSE p.LastName
    END AS LastName,
    CASE
        WHEN s.isPatient = 'Y' THEN s.MiddleName
        ELSE p.MiddleName
    END AS MiddleName,
    CASE
        WHEN s.isPatient = 'Y' THEN s.Address
        ELSE p.Address
    END AS Address,
    CASE
        WHEN s.isPatient = 'Y' THEN s.City
        ELSE p.City
    END AS City,
    CASE
        WHEN s.isPatient = 'Y' THEN s.State
        ELSE p.State
    END AS State,
    CASE
        WHEN s.isPatient = 'Y' THEN s.PostalCode
        ELSE p.PostalCode
    END AS PostalCode,
    CASE
        WHEN s.isPatient = 'Y' THEN s.DateOfBirth
        ELSE p.DateOfBirth
    END AS DateOfBirth,
    CASE
        WHEN s.isPatient = 'Y' THEN s.Gender
        ELSE p.Gender
    END AS Gender
FROM
    subscriber s 
LEFT JOIN
    patient p ON s.transaction_id=p.transaction_id;

Alter table patients_data
ADD COLUMN mrn varchar(255);


ALTER TABLE patients_data
ADD INDEX idx_patients_data_transaction_id (transaction_id);

ALTER TABLE claims_reference
ADD INDEX idx_claims_ref_ReferenceIdentificationQualifier (ReferenceIdentificationQualifier);

set sql_safe_updates =0;
UPDATE patients_data AS pd
LEFT JOIN claims_reference AS cr ON pd.transaction_id = cr.transaction_id
SET pd.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

ALTER TABLE `patients_data`
ADD COLUMN `full_name` varchar(255) GENERATED ALWAYS AS (CONCAT_WS(' ', COALESCE(FirstName, ''), COALESCE(MiddleName, ''), COALESCE(LastName, ''))) STORED AFTER `mrn`;


DROP TABLE IF EXISTS included_subscriber;
create table included_subscriber SELECT id, transaction_id, mrn,full_name, FirstName, LastName, MiddleName, Address, City, State, PostalCode, DateOfBirth, 
Gender, PayerName, PayerId, Payer_Address, Payer_city, Payer_State, Payer_PostalCode, transaction_date
FROM patients_data
WHERE (PayerName LIKE "%Medicare%" OR PayerName LIKE "%medicare advantage%" OR PayerName LIKE "%adv%" OR PayerName LIKE "%advantage%");

CREATE INDEX included_subscriber_id
ON included_subscriber(id);

DROP TABLE IF EXISTS service_lines_eligible;
CREATE TABLE service_lines_eligible AS
SELECT *
FROM service_lines
WHERE sv1_cpt_code_info LIKE '%99%' OR sv2_initial_hcpcs_code LIKE '%99%';

ALTER TABLE service_lines_eligible
ADD COLUMN service_date DATE;

UPDATE service_lines_eligible
SET service_date = 
    CASE 
        WHEN initial_date LIKE '%-%' THEN STR_TO_DATE(SUBSTRING_INDEX(initial_date, '-', 1), '%Y%m%d')
        ELSE STR_TO_DATE(initial_date, '%Y%m%d')
    END;


DROP TABLE IF EXISTS Eligible_for_RAF;
create table Eligible_for_RAF
SELECT
    included_subscriber.id, included_subscriber.transaction_id,included_subscriber.mrn, included_subscriber.full_name, 
    included_subscriber.LastName,included_subscriber.FirstName, included_subscriber.MiddleName,  included_subscriber.Address, 
    included_subscriber.City, included_subscriber.State,included_subscriber.PostalCode,included_subscriber.DateOfBirth,
    included_subscriber.Gender,included_subscriber.PayerName, included_subscriber.PayerId,included_subscriber.Payer_Address,
    included_subscriber.Payer_city,included_subscriber.Payer_State,included_subscriber.Payer_PostalCode,  
    included_subscriber.transaction_date as transaction_date,sle.sv1_cpt_code_info AS sv1_cpt_code_info,sle.sv2_initial_hcpcs_code AS sv2_initial_hcpcs_code,  
    sle.service_date AS service_date, LEFT(sle.initial_date, 4) AS serviceYear
FROM included_subscriber
INNER JOIN service_lines_eligible as sle ON included_subscriber.mrn = sle.mrn and included_subscriber.transaction_id = sle.transaction_id
GROUP BY
    included_subscriber.id,  included_subscriber.transaction_id,    included_subscriber.mrn, included_subscriber.full_name, 
    included_subscriber.LastName,    included_subscriber.FirstName,included_subscriber.MiddleName,  included_subscriber.Address,    
    included_subscriber.City,    included_subscriber.State,    included_subscriber.PostalCode,   included_subscriber.DateOfBirth,    
    included_subscriber.Gender,    included_subscriber.PayerName,    included_subscriber.PayerId,    included_subscriber.Payer_Address,  
    included_subscriber.Payer_city,    included_subscriber.Payer_State,    included_subscriber.Payer_PostalCode,  included_subscriber.transaction_date, 
    sle.sv1_cpt_code_info,    sle.sv2_initial_hcpcs_code, sle.initial_date, sle.service_date
HAVING (sv1_cpt_code_info LIKE "%99%" or sv2_initial_hcpcs_code LIKE "%99%");


DROP TABLE IF EXISTS `Final_Patients`;

CREATE TABLE `Final_Patients` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mrn VARCHAR(255),
    full_name VARCHAR(255),
    gender VARCHAR(255),
    DateOfBirth DATE,
    Age INT
);

INSERT INTO `Final_Patients` (mrn, full_name, gender, DateOfBirth, Age)
SELECT 
    mrn,
    MAX(full_name) AS full_name,
    MAX(Gender) AS gender,
    MAX(DateOfBirth) AS DateOfBirth,
    CASE 
        WHEN MAX(DateOfBirth) IS NULL THEN NULL
        ELSE TIMESTAMPDIFF(YEAR, MAX(DateOfBirth), CURDATE())
    END AS Age
FROM (
    SELECT 
        mrn,
        full_name,
        Gender,
        DateOfBirth
    FROM Eligible_for_RAF 
    WHERE serviceYear > 2021
) AS subquery
GROUP BY mrn;


