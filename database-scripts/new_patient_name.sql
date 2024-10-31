ALTER TABLE `patients_data`
DROP COLUMN new_full_name;

ALTER TABLE `patients_data`
ADD COLUMN `new_full_name` varchar(255) 
GENERATED ALWAYS AS (
    TRIM(
        CONCAT_WS(
            ' ', 
            COALESCE(CONCAT(TRIM(LastName), ', '), ''),
            TRIM(COALESCE(FirstName, '')), 
            TRIM(NULLIF(COALESCE(MiddleName, ''), ''))
        )
    )
) STORED AFTER `full_name`;


ALTER TABLE `Eligible_for_RAF`
DROP COLUMN `full_name`,
ADD COLUMN `full_name` varchar(255) 
GENERATED ALWAYS AS (
  TRIM(
    CONCAT_WS(
      ' ', 
      COALESCE(CONCAT(TRIM(`LastName`), ', '), ''),
      TRIM(COALESCE(`FirstName`, '')), 
      TRIM(NULLIF(COALESCE(`MiddleName`, ''), ''))
    )
  )
) STORED AFTER mrn;


UPDATE `Final_Patients` fp
JOIN `patients_data` pd ON fp.mrn = pd.mrn
SET fp.full_name = pd.new_full_name;

SET sql_safe_updates = 0;
UPDATE `case_review` cr
JOIN `Final_Patients` fp ON fp.mrn = cr.mrn
SET cr.patient_name = fp.full_name;

SET sql_safe_updates = 0;
UPDATE `patient_diagnosis` pd
JOIN `Final_Patients` fp ON fp.mrn = pd.mrn
SET pd.patient_name = fp.full_name;

UPDATE rafvue_v28.`Final_Patients` fp
JOIN rafvue.`patients_data` pd ON fp.mrn = pd.mrn
SET fp.full_name = pd.new_full_name;
