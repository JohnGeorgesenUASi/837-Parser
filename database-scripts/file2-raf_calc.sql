SET @previous_year = 2022;
SET @current_year = 2023;

# Select only those HCCs for eligible patients

drop table if exists hcc_codes_eligible;
create table hcc_codes_eligible as
select hc.* from hcc_codes hc inner join Final_Patients fp on 
hc.mrn = fp.mrn where hc.serviceYear> 2021;

# add non hccs to `Complete HCC Codes and Weights` Table

ALTER TABLE `Complete HCC Codes and Weights`
MODIFY COLUMN `ID` INT AUTO_INCREMENT PRIMARY KEY;

INSERT INTO `Complete HCC Codes and Weights` (
    `DiagnosisCode`,
    `Description`
)
SELECT 
    `CODE` AS `DiagnosisCode`,
    `short_description_2024` AS `Description`
FROM 
    `non_hcc`;


# Added non HCCs to  `Complete HCC Codes and Weights`

ALTER TABLE `Complete HCC Codes and Weights`
MODIFY COLUMN `ID` INT AUTO_INCREMENT PRIMARY KEY;


INSERT INTO `Complete HCC Codes and Weights` (
    `DiagnosisCode`,
    `Description`
)
SELECT 
    `CODE` AS `DiagnosisCode`,
    `short_description_2024` AS `Description`
FROM 
    `non_hcc` AS n
LEFT JOIN
    `Complete HCC Codes and Weights` AS c
ON
    n.`CODE` = c.`DiagnosisCode`
WHERE
    c.`DiagnosisCode` IS NULL;

set sql_safe_updates = 0;
DELETE FROM `Complete HCC Codes and Weights`
WHERE DiagnosisCode IS NULL;


# RAF Calculation

#previous_year Raf

CREATE INDEX idx_hc_DiagnosisCode_serviceYear ON hcc_codes_eligible (DiagnosisCode, serviceYear);
CREATE INDEX idx_ccw_DiagnosisCode_UASI_HCC ON `Complete HCC Codes and Weights` (DiagnosisCode, UASI_HCC);
CREATE INDEX idx_ITAC_Hierarchies_group_priority ON rafvue.ITAC_Hierarchies (group_priority);

DROP TABLE IF EXISTS hcc_2022;

CREATE TABLE hcc_2022 AS
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
        FROM rafvue.ITAC_Hierarchies 
        GROUP BY ITAC_category, group_priority
    ) AS ITAC_Groups ON ITAC_Groups.group_priority = ccw.UASI_HCC
    WHERE 
        ccw.DiagnosisCode IS NOT NULL 
        AND ccw.`CMS-HCC Model Category V24` IS NOT NULL
) AS codes ON hc.DiagnosisCode = codes.DiagnosisCode
WHERE 
    hc.serviceYear = @previous_year and codes.`CMS-HCC Model Category V24` IS NOT NULL;

    
drop table if exists hcc_2022_min;
create table hcc_2022_min as 
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM rafvue.hcc_2022 where ITAC_Category IS NOT NULL
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
INNER JOIN interactions ON hcc_2022.UASI_HCC = interactions.HCC
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
    FROM interactions
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
        FROM rafvue.ITAC_Hierarchies 
        GROUP BY ITAC_category, group_priority
    ) AS ITAC_Groups ON ITAC_Groups.group_priority = ccw.UASI_HCC
    WHERE 
        ccw.DiagnosisCode IS NOT NULL 
        AND ccw.`CMS-HCC Model Category V24` IS NOT NULL
) AS codes ON hc.DiagnosisCode = codes.DiagnosisCode
WHERE 
    hc.serviceYear = @current_year and codes.`CMS-HCC Model Category V24` IS NOT NULL;


drop table if exists hcc_2023_min;
create table hcc_2023_min as 
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM rafvue.hcc_2023 where ITAC_Category IS NOT NULL 
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
    FROM interactions
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
SELECT mrn, min(UASI_HCC) as MinOfUASI_HCC, ITAC_Category,weight FROM rafvue.hcc_2023 where ITAC_Category IS NOT NULL 
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
    FROM interactions
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
SET raf_variance = COALESCE(chronic_raf_2023, 0) - COALESCE(chronic_raf_2022, 0)



UPDATE `Final_Patients`
SET 
    `raf_2023` = ROUND(`raf_2023`, 4),
    `chronic_raf_2022` = ROUND(`chronic_raf_2022`, 4),
    `chronic_raf_2023` = ROUND(`chronic_raf_2023`, 4),
    `raf_variance` = ROUND(`raf_variance`, 4);

