SET @previous_year = 2022;
SET @current_year = 2023;

DROP TABLE IF EXISTS `Final_Patients`;

CREATE TABLE `Final_Patients` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mrn VARCHAR(255),
    full_name VARCHAR(255),
    gender VARCHAR(255),
    DateOfBirth DATE,
    Age INT
);

INSERT INTO rafvue_v28.`Final_Patients` (mrn, full_name, gender, DateOfBirth, Age)
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
    FROM rafvue.Eligible_for_RAF 
    WHERE serviceYear > 2021
) AS subquery
GROUP BY mrn;

DROP TABLE IF EXISTS hcc_2022;

CREATE TABLE hcc_2022 AS
SELECT
    hc.transaction_id,
    hc.mrn,
    hc.DiagnosisCodeQualifier,
    hc.DiagnosisCode,
    hc.serviceYear,
    codes.`CMS-HCC Model Category V28` AS UASI_HCC,
    codes.`Acute / Chronic` as AcuteChronic,
    codes.`HCC Weight` as weight,
    codes.ITAC_category
FROM
    rafvue.hcc_codes_eligible hc
LEFT JOIN (
    SELECT 
        ccw.DiagnosisCode,
        ccw.`CMS-HCC Model Category V28`,
        ccw.`Acute / Chronic`,
        ccw.`HCC Weight`,
        ITAC_Groups.ITAC_category
    FROM 
        rafvue.`Complete HCC Codes and Weights` ccw
    LEFT JOIN (
        SELECT ITAC_category, group_priority 
        FROM rafvue_v28.ITAC_Hierarchies 
        GROUP BY ITAC_category, group_priority
    ) AS ITAC_Groups ON ITAC_Groups.group_priority = ccw.UASI_HCC
    WHERE 
        ccw.DiagnosisCode IS NOT NULL 
        AND ccw.`CMS-HCC Model Category V28` IS NOT NULL AND ccw.`CMS-HCC Model Category V28`!=''
) AS codes ON hc.DiagnosisCode = codes.DiagnosisCode
WHERE 
    hc.serviceYear = @previous_year and codes.`CMS-HCC Model Category V28` IS NOT NULL AND codes.`CMS-HCC Model Category V28`!='';

    
drop table if exists hcc_2022_min;
create table hcc_2022_min as 
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM rafvue_v28.hcc_2022 where ITAC_Category IS NOT NULL
and AcuteChronic="Chronic" group by mrn, ITAC_Category, weight;

ALTER TABLE `hcc_2022_min`
ADD INDEX `idx_mrn` (`mrn`);

ALTER TABLE `hcc_2022`
ADD INDEX `idx_hcc_2022_mrn` (`mrn`);

ALTER TABLE Final_Patients
ADD INDEX `idx_fp_mrn` (`mrn`);

ALTER TABLE Final_Patients
ADD COLUMN hierarchy_raf_2022 DOUBLE;

/* Add previous year Hierachy weight */

UPDATE Final_Patients AS up
JOIN (
    SELECT mrn, SUM(weight) AS total_weight
    FROM hcc_2022_min
    GROUP BY mrn
) AS ph
ON up.mrn = ph.mrn
SET up.hierarchy_raf_2022 = ph.total_weight;


/* Demographic weight */

ALTER TABLE Final_Patients
ADD COLUMN demographic_weight double DEFAULT NULL;

UPDATE Final_Patients AS up
JOIN demographic_weights AS dw
ON up.Gender = dw.Gender AND up.Age = dw.Age
SET up.demographic_weight = CAST(dw.Weight AS double);

/* Disease Interactions */


DROP TABLE IF EXISTS `raf_interactions1_2022`;
create table `raf_interactions1_2022`
SELECT hcc_2022.mrn, interactions.HCC, interactions.GroupInteraction
FROM hcc_2022
INNER JOIN rafvue.interactions ON hcc_2022.UASI_HCC = interactions.HCC
GROUP BY hcc_2022.mrn, interactions.HCC, interactions.GroupInteraction;

DROP TABLE IF EXISTS `raf_interactions2_2022`;
create table `raf_interactions2_2022`
SELECT raf_interactions1_2022.mrn, raf_interactions1_2022.GroupInteraction
FROM raf_interactions1_2022
GROUP BY raf_interactions1_2022.mrn,raf_interactions1_2022.GroupInteraction;

DROP TABLE IF EXISTS `raf_interactions3_2022`;
create table `raf_interactions3_2022`
SELECT raf_interactions2_2022.mrn,
 LEFT(GroupInteraction, 1) AS interaction_group, COUNT(raf_interactions2_2022.mrn) AS CountOfMrn
FROM raf_interactions2_2022
GROUP BY raf_interactions2_2022.mrn, LEFT(GroupInteraction, 1)
HAVING COUNT(raf_interactions2_2022.mrn) > 1;

Alter table `raf_interactions3_2022`
add column bonus_weight double DEFAULT NULL;

UPDATE raf_interactions3_2022 AS raf
JOIN (
    SELECT bonus_weight, interaction_category
    FROM rafvue.interactions
    group by interaction_category, bonus_weight
) AS inter ON raf.interaction_group = inter.interaction_category
SET raf.bonus_weight = inter.bonus_weight;

Alter table Final_Patients
add column disease_interaction_2022 double default null;

UPDATE Final_Patients AS fp
JOIN (
    SELECT mrn, SUM(bonus_weight) AS disease_interaction_2022
    FROM raf_interactions3_2022
    GROUP BY mrn
) AS ph
ON fp.mrn = ph.mrn
SET fp.disease_interaction_2022 = ph.disease_interaction_2022;


# Current Year RAF Calc



DROP TABLE IF EXISTS hcc_2023;

CREATE TABLE hcc_2023 AS
SELECT
    hc.transaction_id,
    hc.mrn,
    hc.DiagnosisCodeQualifier,
    hc.DiagnosisCode,
    hc.serviceYear,
    codes.`CMS-HCC Model Category V28` AS UASI_HCC,
    codes.`Acute / Chronic` as AcuteChronic,
    codes.`HCC Weight` as weight,
    codes.ITAC_category
FROM
    rafvue.hcc_codes_eligible hc
LEFT JOIN (
    SELECT 
        ccw.DiagnosisCode,
        ccw.`CMS-HCC Model Category V28`,
        ccw.`Acute / Chronic`,
        ccw.`HCC Weight`,
        ITAC_Groups.ITAC_category
    FROM 
        rafvue.`Complete HCC Codes and Weights` ccw
    LEFT JOIN (
        SELECT ITAC_category, group_priority 
        FROM rafvue.ITAC_Hierarchies 
        GROUP BY ITAC_category, group_priority
    ) AS ITAC_Groups ON ITAC_Groups.group_priority = ccw.UASI_HCC
    WHERE 
        ccw.DiagnosisCode IS NOT NULL 
        AND ccw.`CMS-HCC Model Category V28` IS NOT NULL
) AS codes ON hc.DiagnosisCode = codes.DiagnosisCode
WHERE 
    hc.serviceYear = @current_year and codes.`CMS-HCC Model Category V28` IS NOT NULL;


drop table if exists hcc_2023_min;
create table hcc_2023_min as 
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM hcc_2023 where ITAC_Category IS NOT NULL 
group by mrn, ITAC_Category, weight;

ALTER TABLE `hcc_2023_min`
ADD INDEX `idx_mrn` (`mrn`);


ALTER TABLE `hcc_2023`
ADD INDEX `idx_hcc_2023_mrn` (`mrn`);


ALTER TABLE Final_Patients
ADD COLUMN hierarchy_raf_2023 DOUBLE;

/* Add current year Hierachy weight */

UPDATE Final_Patients AS up
JOIN (
    SELECT mrn, SUM(weight) AS total_weight
    FROM hcc_2023_min
    GROUP BY mrn
) AS ph
ON up.mrn = ph.mrn
SET up.hierarchy_raf_2023 = ph.total_weight;

/* Disease Interactions */


DROP TABLE IF EXISTS `raf_interactions1_2023`;
create table `raf_interactions1_2023`
SELECT hcc_2023.mrn, interactions.HCC, interactions.GroupInteraction
FROM hcc_2023
INNER JOIN interactions ON hcc_2023.UASI_HCC = interactions.HCC
GROUP BY hcc_2023.mrn, interactions.HCC, interactions.GroupInteraction;

DROP TABLE IF EXISTS `raf_interactions2_2023`;
create table `raf_interactions2_2023`
SELECT raf_interactions1_2023.mrn, raf_interactions1_2023.GroupInteraction
FROM raf_interactions1_2023
GROUP BY raf_interactions1_2023.mrn,raf_interactions1_2023.GroupInteraction;

DROP TABLE IF EXISTS `raf_interactions3_2023`;
create table `raf_interactions3_2023`
SELECT raf_interactions2_2023.mrn,
 LEFT(GroupInteraction, 1) AS interaction_group, COUNT(raf_interactions2_2023.mrn) AS CountOfMrn
FROM raf_interactions2_2023
GROUP BY raf_interactions2_2023.mrn, LEFT(GroupInteraction, 1)
HAVING COUNT(raf_interactions2_2023.mrn) > 1;

Alter table `raf_interactions3_2023`
add column bonus_weight double DEFAULT NULL;

UPDATE raf_interactions3_2023 AS raf
JOIN (
    SELECT bonus_weight, interaction_category
    FROM rafvue.interactions
    group by interaction_category, bonus_weight
) AS inter ON raf.interaction_group = inter.interaction_category
SET raf.bonus_weight = inter.bonus_weight;
	
Alter table Final_Patients
add column disease_interaction_2023 double default null;

UPDATE Final_Patients AS fp
JOIN (
    SELECT mrn, SUM(bonus_weight) AS disease_interaction_2023
    FROM raf_interactions3_2023
    GROUP BY mrn
) AS ph
ON fp.mrn = ph.mrn
SET fp.disease_interaction_2023 = ph.disease_interaction_2023;


# calculate current year chronic raf




drop table if exists chronic_hcc_2023_min;
create table chronic_hcc_2023_min as 
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM hcc_2023 where ITAC_Category IS NOT NULL 
and AcuteChronic="Chronic" group by mrn, ITAC_Category, weight;


ALTER TABLE `chronic_hcc_2023_min`
ADD INDEX `idx_chronic_hcc_2023_min_mrn` (`mrn`);

ALTER TABLE Final_Patients
ADD COLUMN hierarchy_chronic_raf_2023 DOUBLE;

/* Add current year Hierachy weight */

UPDATE Final_Patients AS up
JOIN (
    SELECT mrn, SUM(weight) AS total_weight
    FROM chronic_hcc_2023_min
    GROUP BY mrn
) AS ph
ON up.mrn = ph.mrn
SET up.hierarchy_chronic_raf_2023 = ph.total_weight;

DROP TABLE IF EXISTS `chronic_raf_interactions1_2023`;
create table `chronic_raf_interactions1_2023`
SELECT hcc_2023.mrn, interactions.HCC, interactions.GroupInteraction
FROM hcc_2023
INNER JOIN interactions ON hcc_2023.UASI_HCC = interactions.HCC where hcc_2023.AcuteChronic="Chronic"
GROUP BY hcc_2023.mrn, interactions.HCC, interactions.GroupInteraction ;

DROP TABLE IF EXISTS `chronic_raf_interactions2_2023`;
create table `chronic_raf_interactions2_2023`
SELECT chronic_raf_interactions1_2023.mrn, chronic_raf_interactions1_2023.GroupInteraction
FROM chronic_raf_interactions1_2023
GROUP BY chronic_raf_interactions1_2023.mrn,chronic_raf_interactions1_2023.GroupInteraction;

DROP TABLE IF EXISTS `chronic_raf_interactions3_2023`;
create table `chronic_raf_interactions3_2023`
SELECT chronic_raf_interactions2_2023.mrn,
 LEFT(GroupInteraction, 1) AS interaction_group, COUNT(chronic_raf_interactions2_2023.mrn) AS CountOfMrn
FROM chronic_raf_interactions2_2023
GROUP BY chronic_raf_interactions2_2023.mrn, LEFT(GroupInteraction, 1)
HAVING COUNT(chronic_raf_interactions2_2023.mrn) > 1;

Alter table `chronic_raf_interactions3_2023`
add column bonus_weight double DEFAULT NULL;

UPDATE chronic_raf_interactions3_2023 AS raf
JOIN (
    SELECT bonus_weight, interaction_category
    FROM rafvue.interactions
    group by interaction_category, bonus_weight
) AS inter ON raf.interaction_group = inter.interaction_category
SET raf.bonus_weight = inter.bonus_weight;
	
Alter table Final_Patients
add column chronic_disease_interaction_2023 double default null;

UPDATE Final_Patients AS fp
JOIN (
    SELECT mrn, SUM(bonus_weight) AS chronic_disease_interaction_2023
    FROM chronic_raf_interactions3_2023
    GROUP BY mrn
) AS ph
ON fp.mrn = ph.mrn
SET fp.chronic_disease_interaction_2023 = ph.chronic_disease_interaction_2023;

#Round all decimals in Final Patients

UPDATE `Final_Patients`
SET 
    `hierarchy_raf_2022` = ROUND(`hierarchy_raf_2022`, 4),
    `demographic_weight` = ROUND(`demographic_weight`, 4),
    `disease_interaction_2022` = ROUND(`disease_interaction_2022`, 4),
    `hierarchy_raf_2023` = ROUND(`hierarchy_raf_2023`, 4),
    `disease_interaction_2023` = ROUND(`disease_interaction_2023`, 4),
    `hierarchy_chronic_raf_2023` = ROUND(`hierarchy_chronic_raf_2023`, 4),
    `chronic_disease_interaction_2023` = ROUND(`chronic_disease_interaction_2023`, 4);



 ALTER TABLE Final_Patients
ADD COLUMN raf_2023 double DEFAULT NULL;

UPDATE Final_Patients
SET raf_2023 = COALESCE(hierarchy_raf_2023, 0) + COALESCE(demographic_weight, 0) + COALESCE(disease_interaction_2023, 0);

ALTER TABLE Final_Patients
ADD COLUMN chronic_raf_2022 double DEFAULT NULL;

UPDATE Final_Patients
SET chronic_raf_2022 = COALESCE(hierarchy_raf_2022, 0) + COALESCE(demographic_weight, 0) + COALESCE(disease_interaction_2022, 0);

ALTER TABLE Final_Patients
ADD COLUMN chronic_raf_2023 double DEFAULT NULL;

UPDATE Final_Patients
SET chronic_raf_2023 = COALESCE(hierarchy_chronic_raf_2023, 0) + COALESCE(demographic_weight, 0) + COALESCE(chronic_disease_interaction_2023, 0);

ALTER TABLE Final_Patients
ADD COLUMN raf_variance double DEFAULT NULL;

UPDATE Final_Patients
SET raf_variance = COALESCE(chronic_raf_2023, 0) - COALESCE(chronic_raf_2022, 0);



UPDATE `Final_Patients`
SET 
    `raf_2023` = ROUND(`raf_2023`, 4),
    `chronic_raf_2022` = ROUND(`chronic_raf_2022`, 4),
    `chronic_raf_2023` = ROUND(`chronic_raf_2023`, 4),
    `raf_variance` = ROUND(`raf_variance`, 4);




#Calculate recapture 

DROP TABLE IF EXISTS recap;
CREATE TABLE recap AS
SELECT
    hc.transaction_id,
    hc.mrn,
    hc.DiagnosisCodeQualifier,
    hc.DiagnosisCode,
    hc.serviceYear,
    codes.`CMS-HCC Model Category V28` AS UASI_HCC,
    codes.`Acute / Chronic` as AcuteChronic
FROM
    rafvue.hcc_codes_eligible hc 
LEFT JOIN
    rafvue.`Complete HCC Codes and Weights` codes ON hc.DiagnosisCode = codes.DiagnosisCode
where codes.`CMS-HCC Model Category V28` is not null AND codes.DiagnosisCode IS NOT NULL AND codes.`CMS-HCC Model Category V28`!='';
    
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
    FROM rafvue.ITAC_Hierarchies
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



INSERT INTO ITAC_Analysis (HCC, HCC_Name, Weights)
SELECT HCC, HCC_Name, Weights
FROM hcc_weights;


set sql_safe_updates=0;
UPDATE rafvue_v28.ITAC_Analysis ia
JOIN rafvue_v28.`Complete HCC Codes and Weights` sla ON ia.HCC = sla.`CMS-HCC Model Category V28`
SET ia.AcuteChronic = sla.`Acute / Chronic`;


set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(*) AS HCC_Count
    FROM recap
    WHERE serviceYear = @previous_year
    GROUP BY UASI_HCC
) AS recap_counts ON ia.HCC = recap_counts.UASI_HCC
SET ia.HCC_Count_2022 = IFNULL(recap_counts.HCC_Count, 0);

set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(DISTINCT mrn) AS Distinct_Patients
    FROM recap
    WHERE serviceYear = @previous_year
    GROUP BY UASI_HCC
) AS patient_counts ON ia.HCC = patient_counts.UASI_HCC
SET ia.total_patients_2022 = IFNULL(patient_counts.Distinct_Patients, 0);


set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(*) AS HCC_Count
    FROM recap
    WHERE serviceYear = @current_year
    GROUP BY UASI_HCCv28_hccs_2023
) AS recap_counts ON ia.HCC = recap_counts.UASI_HCC
SET ia.HCC_Count_2023 = IFNULL(recap_counts.HCC_Count, 0);

set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(DISTINCT mrn) AS Distinct_Patients
    FROM recap
    WHERE serviceYear = @current_year
    GROUP BY UASI_HCC
) AS patient_counts ON ia.HCC = patient_counts.UASI_HCC
SET ia.total_patients_2023 = IFNULL(patient_counts.Distinct_Patients, 0);


set sql_safe_updates = 0;
UPDATE rafvue.ITAC_Analysis itac
LEFT JOIN (
    SELECT
        itac.HCC AS HCC,
        itac.HCC_Name AS HCC_Name,
        COUNT(CASE WHEN FIND_IN_SET(itac.HCC, fp.recaptured_hccs) > 0 THEN 1 END) AS Patient_Count
    FROM
        rafvue.ITAC_Analysis itac
    LEFT JOIN
        rafvue.Final_Patients fp ON 1=1
    GROUP BY
        itac.HCC, itac.HCC_Name
) subquery ON itac.HCC = subquery.HCC
SET itac.total_recapture = subquery.Patient_Count;


set sql_safe_updates = 0;
UPDATE rafvue.ITAC_Analysis itac
SET itac.recapture_percentage = ((itac.total_recapture / (SELECT COUNT(*) FROM Final_Patients)) * 100);


CREATE TABLE `ITAC_Analysis` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `HCC` double DEFAULT NULL,
  `HCC_Name` varchar(255) DEFAULT NULL,
  `Weights` double DEFAULT NULL,
  `AcuteChronic` varchar(255) DEFAULT NULL,
  `HCC_Count_2022` int DEFAULT '0',
  `total_patients_2022` int DEFAULT '0',
  `HCC_Count_2023` int DEFAULT '0',
  `total_patients_2023` int DEFAULT '0',
  `Non_Recaptured_Patients_Count` int DEFAULT '0',
  `total_recapture` int DEFAULT '0',
  `recapture_percentage` decimal(10,2) DEFAULT '0.00',
  `hcc_recapture_deficit` int DEFAULT '0',
  `hcc_recapture_deficit_percentage` int DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `idx_id` (`ID`),
  KEY `idx_hcc` (`HCC`)
) ENGINE=InnoDB AUTO_INCREMENT=255 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO ITAC_Analysis (HCC, HCC_Name, Weights)
SELECT HCC, HCC_Name, Weights
FROM hcc_weights;


set sql_safe_updates=0;
UPDATE ITAC_Analysis ia
JOIN rafvue.`St Lukes Analysis` sla ON ia.HCC = sla.HCC
SET ia.AcuteChronic = sla.`Acute / Chronic`;


set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(*) AS HCC_Count
    FROM recap
    WHERE serviceYear = @previous_year
    GROUP BY UASI_HCC
) AS recap_counts ON ia.HCC = recap_counts.UASI_HCC
SET ia.HCC_Count_2022 = IFNULL(recap_counts.HCC_Count, 0);

set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(DISTINCT mrn) AS Distinct_Patients
    FROM recap
    WHERE serviceYear = @previous_year
    GROUP BY UASI_HCC
) AS patient_counts ON ia.HCC = patient_counts.UASI_HCC
SET ia.total_patients_2022 = IFNULL(patient_counts.Distinct_Patients, 0);


set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(*) AS HCC_Count
    FROM recap
    WHERE serviceYear = @current_year
    GROUP BY UASI_HCC
) AS recap_counts ON ia.HCC = recap_counts.UASI_HCC
SET ia.HCC_Count_2023 = IFNULL(recap_counts.HCC_Count, 0);

set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(DISTINCT mrn) AS Distinct_Patients
    FROM recap
    WHERE serviceYear = @current_year
    GROUP BY UASI_HCC
) AS patient_counts ON ia.HCC = patient_counts.UASI_HCC
SET ia.total_patients_2023 = IFNULL(patient_counts.Distinct_Patients, 0);


set sql_safe_updates = 0;
UPDATE ITAC_Analysis itac
LEFT JOIN (
    SELECT
        itac.HCC AS HCC,
        itac.HCC_Name AS HCC_Name,
        COUNT(CASE WHEN FIND_IN_SET(itac.HCC, fp.recaptured_hccs) > 0 THEN 1 END) AS Patient_Count
    FROM
        ITAC_Analysis itac
    LEFT JOIN
        Final_Patients fp ON 1=1
    GROUP BY
        itac.HCC, itac.HCC_Name
) subquery ON itac.HCC = subquery.HCC
SET itac.total_recapture = subquery.Patient_Count;


set sql_safe_updates = 0;
UPDATE ITAC_Analysis itac
SET itac.recapture_percentage = ((itac.total_recapture / (SELECT COUNT(*) FROM Final_Patients)) * 100);

