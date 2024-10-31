# Current Year RAF Calc



DROP TABLE IF EXISTS hcc_2024;

CREATE TABLE hcc_2024 AS
SELECT
    hc.transaction_id,
    hc.mrn,
    hc.DiagnosisCodeQualifier,
    hc.DiagnosisCode,
    hc.serviceYear,
    codes.`CMS-HCC Model Category V24` AS UASI_HCC,
    codes.`Acute / Chronic` as AcuteChronic,
    codes.`HCC Weight` as weight,
    codes.ITAC_category
FROM
    hcc_codes_eligible hc
LEFT JOIN (
    SELECT 
        ccw.DiagnosisCode,
        ccw.`CMS-HCC Model Category V24`,
        ccw.`Acute / Chronic`,
        ccw.`HCC Weight`,
        ITAC_Groups.ITAC_category
    FROM 
        `Complete HCC Codes and Weights` ccw
    LEFT JOIN (
        SELECT ITAC_category, group_priority 
        FROM demo_rafvue.ITAC_Hierarchies 
        GROUP BY ITAC_category, group_priority
    ) AS ITAC_Groups ON ITAC_Groups.group_priority = ccw.UASI_HCC
    WHERE 
        ccw.DiagnosisCode IS NOT NULL 
        AND ccw.`CMS-HCC Model Category V24` IS NOT NULL
) AS codes ON hc.DiagnosisCode = codes.DiagnosisCode
WHERE 
    hc.serviceYear = 2024 and codes.`CMS-HCC Model Category V24` IS NOT NULL;


drop table if exists hcc_2024_min;
create table hcc_2024_min as 
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM demo_rafvue.hcc_2024 where ITAC_Category IS NOT NULL 
group by mrn, ITAC_Category, weight;

ALTER TABLE `hcc_2024_min`
ADD INDEX `idx_mrn` (`mrn`);


ALTER TABLE `hcc_2024`
ADD INDEX `idx_hcc_2024_mrn` (`mrn`);


ALTER TABLE Final_Patients
ADD COLUMN hierarchy_raf_2024 DOUBLE AFTER raf_variance;

/* Add 2023 Hierachy weight */

UPDATE Final_Patients AS up
JOIN (
    SELECT mrn, SUM(weight) AS total_weight
    FROM hcc_2024_min
    GROUP BY mrn
) AS ph
ON up.mrn = ph.mrn
SET up.hierarchy_raf_2024 = ph.total_weight;

/* Disease Interactions */


DROP TABLE IF EXISTS `raf_interactions1_2024`;
create table `raf_interactions1_2024`
SELECT hcc_2024.mrn, interactions.HCC, interactions.GroupInteraction
FROM hcc_2024
INNER JOIN interactions ON hcc_2024.UASI_HCC = interactions.HCC
GROUP BY hcc_2024.mrn, interactions.HCC, interactions.GroupInteraction;

DROP TABLE IF EXISTS `raf_interactions2_2024`;
create table `raf_interactions2_2024`
SELECT raf_interactions1_2024.mrn, raf_interactions1_2024.GroupInteraction
FROM raf_interactions1_2024
GROUP BY raf_interactions1_2024.mrn,raf_interactions1_2024.GroupInteraction;

DROP TABLE IF EXISTS `raf_interactions3_2024`;
create table `raf_interactions3_2024`
SELECT raf_interactions2_2024.mrn,
 LEFT(GroupInteraction, 1) AS interaction_group, COUNT(raf_interactions2_2024.mrn) AS CountOfMrn
FROM raf_interactions2_2024
GROUP BY raf_interactions2_2024.mrn, LEFT(GroupInteraction, 1)
HAVING COUNT(raf_interactions2_2024.mrn) > 1;

Alter table `raf_interactions3_2024`
add column bonus_weight double DEFAULT NULL;

UPDATE raf_interactions3_2024 AS raf
JOIN (
    SELECT bonus_weight, interaction_category
    FROM interactions
    group by interaction_category, bonus_weight
) AS inter ON raf.interaction_group = inter.interaction_category
SET raf.bonus_weight = inter.bonus_weight;
	
Alter table Final_Patients
add column disease_interaction_2024 double default null AFTER hierarchy_raf_2024;

UPDATE Final_Patients AS fp
JOIN (
    SELECT mrn, SUM(bonus_weight) AS disease_interaction_2024
    FROM raf_interactions3_2024
    GROUP BY mrn
) AS ph
ON fp.mrn = ph.mrn
SET fp.disease_interaction_2024 = ph.disease_interaction_2024;


# calculate 2024 chronic raf




drop table if exists chronic_hcc_2024_min;
create table chronic_hcc_2024_min as 
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM demo_rafvue.hcc_2024 where ITAC_Category IS NOT NULL 
and AcuteChronic="Chronic" group by mrn, ITAC_Category, weight;


ALTER TABLE `chronic_hcc_2024_min`
ADD INDEX `idx_chronic_hcc_2024_min_mrn` (`mrn`);

ALTER TABLE Final_Patients
ADD COLUMN hierarchy_chronic_raf_2024 DOUBLE AFTEr disease_interaction_2024;

/* Add 2024 Hierachy weight */

UPDATE Final_Patients AS up
JOIN (
    SELECT mrn, SUM(weight) AS total_weight
    FROM chronic_hcc_2024_min
    GROUP BY mrn
) AS ph
ON up.mrn = ph.mrn
SET up.hierarchy_chronic_raf_2024 = ph.total_weight;

DROP TABLE IF EXISTS `chronic_raf_interactions1_2024`;
create table `chronic_raf_interactions1_2024`
SELECT hcc_2024.mrn, interactions.HCC, interactions.GroupInteraction
FROM hcc_2024
INNER JOIN interactions ON hcc_2024.UASI_HCC = interactions.HCC where hcc_2024.AcuteChronic="Chronic"
GROUP BY hcc_2024.mrn, interactions.HCC, interactions.GroupInteraction ;

DROP TABLE IF EXISTS `chronic_raf_interactions2_2024`;
create table `chronic_raf_interactions2_2024`
SELECT chronic_raf_interactions1_2024.mrn, chronic_raf_interactions1_2024.GroupInteraction
FROM chronic_raf_interactions1_2024
GROUP BY chronic_raf_interactions1_2024.mrn,chronic_raf_interactions1_2024.GroupInteraction;

DROP TABLE IF EXISTS `chronic_raf_interactions3_2024`;
create table `chronic_raf_interactions3_2024`
SELECT chronic_raf_interactions2_2024.mrn,
 LEFT(GroupInteraction, 1) AS interaction_group, COUNT(chronic_raf_interactions2_2024.mrn) AS CountOfMrn
FROM chronic_raf_interactions2_2024
GROUP BY chronic_raf_interactions2_2024.mrn, LEFT(GroupInteraction, 1)
HAVING COUNT(chronic_raf_interactions2_2024.mrn) > 1;

Alter table `chronic_raf_interactions3_2024`
add column bonus_weight double DEFAULT NULL;

UPDATE chronic_raf_interactions3_2024 AS raf
JOIN (
    SELECT bonus_weight, interaction_category
    FROM interactions
    group by interaction_category, bonus_weight
) AS inter ON raf.interaction_group = inter.interaction_category
SET raf.bonus_weight = inter.bonus_weight;
	
Alter table Final_Patients
add column chronic_disease_interaction_2024 double default null AFTER hierarchy_chronic_raf_2024;

UPDATE Final_Patients AS fp
JOIN (
    SELECT mrn, SUM(bonus_weight) AS chronic_disease_interaction_2024
    FROM chronic_raf_interactions3_2024
    GROUP BY mrn
) AS ph
ON fp.mrn = ph.mrn
SET fp.chronic_disease_interaction_2024 = ph.chronic_disease_interaction_2024;

#Round all decimals in Final Patients

UPDATE `Final_Patients`
SET 
    `hierarchy_raf_2024` = ROUND(`hierarchy_raf_2024`, 4),
    `disease_interaction_2024` = ROUND(`disease_interaction_2024`, 4),
    `hierarchy_chronic_raf_2024` = ROUND(`hierarchy_chronic_raf_2024`, 4),
    `chronic_disease_interaction_2024` = ROUND(`chronic_disease_interaction_2024`, 4);



 ALTER TABLE Final_Patients
ADD COLUMN raf_2024 double DEFAULT NULL AFTER chronic_disease_interaction_2024;

UPDATE Final_Patients
SET raf_2024 = COALESCE(hierarchy_raf_2024, 0) + COALESCE(demographic_weight, 0) + COALESCE(disease_interaction_2024, 0);

ALTER TABLE Final_Patients
ADD COLUMN chronic_raf_2024 double DEFAULT NULL AFTER raf_2024;

UPDATE Final_Patients
SET chronic_raf_2024 = COALESCE(hierarchy_chronic_raf_2024, 0) + COALESCE(demographic_weight, 0) + COALESCE(chronic_disease_interaction_2024, 0);

ALTER TABLE Final_Patients
ADD COLUMN raf_variance_2024 double DEFAULT NULL AFTER chronic_raf_2024;

UPDATE Final_Patients
SET raf_variance_2024 = COALESCE(chronic_raf_2024, 0) - COALESCE(chronic_raf_2023, 0);



UPDATE `Final_Patients`
SET 
    `raf_2024` = ROUND(`raf_2024`, 4),
    `chronic_raf_2024` = ROUND(`chronic_raf_2024`, 4),
    `raf_variance_2024` = ROUND(`raf_variance_2024`, 4);