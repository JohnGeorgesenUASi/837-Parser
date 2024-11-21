SET @previous_year = 2022;
SET @current_year = 2023;

#Calculate recapture 

DROP TABLE IF EXISTS recap;
CREATE TABLE recap AS
SELECT
    hc.transaction_id,
    hc.mrn,
    hc.DiagnosisCodeQualifier,
    hc.DiagnosisCode,
    hc.serviceYear,
    codes.`CMS-HCC Model Category V24` AS UASI_HCC,
    codes.`Acute / Chronic` as AcuteChronic
FROM
    hcc_codes_eligible hc
LEFT JOIN
    `Complete HCC Codes and Weights` codes ON hc.DiagnosisCode = codes.DiagnosisCode;
    
set sql_safe_updates=0;
DROP TABLE IF EXISTS recap_chronic;
CREATE TABLE recap_chronic AS
SELECT *
FROM recap
WHERE 
    UASI_HCC IS NOT NULL AND
    (
        (CAST(serviceYear AS UNSIGNED) = @previous_year AND AcuteChronic = 'Chronic') OR
        (CAST(serviceYear AS UNSIGNED) = @current_year and AcuteChronic IS NOT NULL)
    );
    

ALTER TABLE `recap_chronic`
ADD COLUMN `ITAC_category` double DEFAULT NULL,
ADD COLUMN `higher_priority` double DEFAULT NULL;

set sql_safe_updates = 0;
UPDATE recap_chronic rc
INNER JOIN (
    SELECT DISTINCT HCC_group, ITAC_category, Higher_priority
    FROM ITAC_Hierarchies
) ih ON rc.UASI_HCC = ih.HCC_group
SET rc.ITAC_category = ih.ITAC_category,
    rc.higher_priority = ih.Higher_priority;
    
    
ALTER TABLE `recap_chronic`
ADD INDEX `idx_mrn` (`mrn`),
ADD INDEX `idx_transaction_id` (`transaction_id`),
ADD INDEX `idx_UASI_HCC` (`UASI_HCC`),
ADD INDEX `idx_ITAC_category` (`ITAC_category`);
    
ALTER TABLE `Final_Patients`
ADD COLUMN `min_uasi_hcc_2022` VARCHAR(1024) DEFAULT NULL,
ADD COLUMN `min_uasi_hcc_2023` VARCHAR(1024) DEFAULT NULL,
ADD COLUMN `recapture_count` int DEFAULT NULL,
ADD COLUMN `recaptured_hccs` varchar(255) DEFAULT NULL,
ADD COLUMN `distinct_hcc_2022` varchar(255) DEFAULT NULL,
ADD COLUMN `distinct_hcc_2023` varchar(255) DEFAULT NULL;

UPDATE Final_Patients fp
SET fp.distinct_hcc_2022 = (
    SELECT GROUP_CONCAT(DISTINCT UASI_HCC ORDER BY UASI_HCC)
    FROM recap_chronic
    WHERE serviceYear = @previous_year AND mrn = fp.mrn
);

UPDATE Final_Patients fp
SET fp.distinct_hcc_2023 = (
    SELECT GROUP_CONCAT(DISTINCT UASI_HCC ORDER BY UASI_HCC)
    FROM recap_chronic
    WHERE serviceYear = @current_year AND mrn = fp.mrn
);

UPDATE Final_Patients fp
LEFT JOIN (
    SELECT 
        mrn, 
        GROUP_CONCAT(DISTINCT MIN_UASI ORDER BY MIN_UASI) AS min_hccs_2023
    FROM (
        SELECT 
            mrn, 
            ITAC_category, 
            MIN(UASI_HCC) as MIN_UASI
        FROM recap_chronic
        WHERE serviceYear = @current_year
        GROUP BY mrn, ITAC_category
    ) AS subquery_2023
    GROUP BY mrn
) cy ON fp.mrn = cy.mrn
SET
    fp.min_uasi_hcc_2023 = cy.min_hccs_2023;

UPDATE Final_Patients fp
LEFT JOIN (
    SELECT 
        mrn, 
        GROUP_CONCAT(DISTINCT MIN_UASI ORDER BY MIN_UASI) AS min_hccs_2022
    FROM (
        SELECT 
            mrn, 
            ITAC_category, 
            MIN(UASI_HCC) as MIN_UASI
        FROM recap_chronic
        WHERE serviceYear = @previous_year
        GROUP BY mrn, ITAC_category
    ) AS subquery_2022
    GROUP BY mrn
) py ON fp.mrn = py.mrn
SET
    fp.min_uasi_hcc_2022 = py.min_hccs_2022;

DROP TEMPORARY TABLE IF EXISTS previous_year_hcc;
DROP TEMPORARY TABLE IF EXISTS current_year_hcc;
DROP TEMPORARY TABLE IF EXISTS recapture_status;


CREATE TEMPORARY TABLE IF NOT EXISTS previous_year_hcc AS
SELECT mrn, ITAC_category, MIN(UASI_HCC) as min_previous_year_hcc
FROM recap_chronic
WHERE serviceYear = @previous_year
GROUP BY mrn, ITAC_category;

CREATE TEMPORARY TABLE IF NOT EXISTS current_year_hcc AS
SELECT mrn, ITAC_category, MIN(UASI_HCC) as min_current_year_hcc
FROM recap_chronic
WHERE serviceYear = @current_year
GROUP BY mrn, ITAC_category;

CREATE TEMPORARY TABLE IF NOT EXISTS recapture_status AS
SELECT 
    py.mrn,
    py.ITAC_category,
    py.min_previous_year_hcc,
    cy.min_current_year_hcc,
    (py.min_previous_year_hcc >= cy.min_current_year_hcc) AS is_recaptured
FROM previous_year_hcc py
JOIN current_year_hcc cy
ON py.mrn = cy.mrn AND py.ITAC_category = cy.ITAC_category;

UPDATE Final_Patients fp
LEFT JOIN (
    SELECT 
        mrn, 
        COUNT(CASE WHEN is_recaptured THEN 1 END) AS recapture_count
    FROM recapture_status
    GROUP BY mrn
) rc ON fp.mrn = rc.mrn
SET
    fp.recapture_count = rc.recapture_count;

UPDATE Final_Patients fp
LEFT JOIN (
    SELECT 
        mrn, 
        GROUP_CONCAT(CASE WHEN is_recaptured THEN min_current_year_hcc END ORDER BY min_current_year_hcc) AS recaptured_hccs
    FROM recapture_status
    GROUP BY mrn
) rs ON fp.mrn = rs.mrn
SET
    fp.recaptured_hccs = rs.recaptured_hccs;

ALTER TABLE Final_Patients
ADD COLUMN `recapture_percentage` FLOAT DEFAULT NULL;

UPDATE Final_Patients
SET recapture_percentage = CASE 
    WHEN recaptured_hccs IS NOT NULL AND recaptured_hccs != '' AND distinct_hcc_2022 IS NOT NULL AND distinct_hcc_2022 != '' THEN
        ((CHAR_LENGTH(recaptured_hccs) - CHAR_LENGTH(REPLACE(recaptured_hccs, ',', '')) + 1) /
        (CHAR_LENGTH(distinct_hcc_2022) - CHAR_LENGTH(REPLACE(distinct_hcc_2022, ',', '')) + 1)) * 100
    ELSE 0
END;

