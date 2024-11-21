DROP TABLE IF EXISTS `json_bucket`;
 CREATE TABLE `json_bucket` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(45) DEFAULT NULL,
  `json` text,
  `is_object` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `category_UNIQUE` (`category`)
);
 
INSERT INTO rafvue.json_bucket (category, is_object) values ("actions", 0);
INSERT INTO rafvue.json_bucket (category, is_object) values ("reason", 0);
INSERT INTO rafvue.json_bucket (category, is_object) values ("follow_up", 0);
INSERT INTO rafvue.json_bucket (category, is_object) values ("additional_info", 0);
INSERT INTO rafvue.json_bucket (category, is_object) values ("follow_up_status", 0);
INSERT INTO rafvue.json_bucket (category, is_object) values ("queries", 0);
INSERT INTO rafvue.json_bucket (category, is_object) values ("case_selection_queries", 0);
 
DROP TABLE IF EXISTS rafvue.`patient_diagnosis`;
CREATE table rafvue.`patient_diagnosis` 
SELECT distinct
  el.transaction_id AS transaction_id,
  el.mrn AS mrn,
  el.DiagnosisCode AS diagnosis_code,
  el.serviceYear,
  com.Description AS description,
  com.`CMS-HCC Model Category V24` AS hcc_v24,
  com.`HCC Weight` AS hcc_weight_24,
  CASE
    WHEN com_v28.`CMS-HCC Model Category V28`='' THEN NULL
    ELSE com_v28.`CMS-HCC Model Category V28`
  END AS hcc_v28,
  com_v28.`HCC Weight` AS hcc_weight_28
FROM rafvue.hcc_codes_eligible AS el
LEFT JOIN rafvue.`Complete HCC Codes and Weights` AS com ON el.DiagnosisCode = com.DiagnosisCode
LEFT JOIN rafvue_v28.`Complete HCC Codes and Weights` AS com_v28 ON el.DiagnosisCode = com_v28.DiagnosisCode
where el.serviceYear>2021;

ALTER TABLE `patient_diagnosis`
ADD COLUMN `id` INT AUTO_INCREMENT PRIMARY KEY FIRST;


set sql_safe_updates= 0;
CREATE INDEX idx_rp_mrn ON rendering_provider (mrn);

set sql_safe_updates= 0;
ALTER TABLE `patient_diagnosis` ADD INDEX `idx_pd_transaction_id` (`transaction_id`);
ALTER TABLE `patient_diagnosis` ADD INDEX `idx_pd_mrn` (`mrn`);

Alter table rafvue.`patient_diagnosis` 
ADD COLUMN provider varchar(200) DEFAULT NULL;
 
Alter table rafvue.`patient_diagnosis` 
ADD COLUMN service_line_id INT DEFAULT NULL;

Alter table rafvue.`patient_diagnosis` 
ADD COLUMN provider_ref_id varchar(200) DEFAULT NULL;

 
UPDATE rafvue.patient_diagnosis pd
JOIN (
  SELECT transaction_id, mrn, full_name, service_line_id,prv_reference_identification AS provider_ref_id
  FROM rendering_provider
  WHERE entity_type_qualifier = '82' AND npi_number IS NOT NULL
  GROUP BY transaction_id, mrn, full_name, service_line_id,provider_ref_id
) AS rp
ON rp.transaction_id = pd.transaction_id AND rp.mrn = pd.mrn 
SET pd.provider = rp.full_name,
    pd.service_line_id = rp.service_line_id,
    pd.provider_ref_id= rp.provider_ref_id;
    
    
ALTER TABLE service_lines
ADD COLUMN service_date DATE;

UPDATE service_lines
SET service_date = 
    CASE 
        WHEN initial_date LIKE '%-%' THEN STR_TO_DATE(SUBSTRING_INDEX(initial_date, '-', 1), '%Y%m%d')
        ELSE STR_TO_DATE(initial_date, '%Y%m%d')
    END;
    
Alter table rafvue.`patient_diagnosis` 
ADD COLUMN service_date DATE DEFAULT NULL;
 
set sql_safe_updates= 0;
update rafvue.`patient_diagnosis` pd set service_date = 
(
  select service_date 
    from service_lines sl
    where sl.id = pd.service_line_id
);


ALTER TABLE `patient_diagnosis` ADD INDEX `idx_provider_ref_id` (`provider_ref_id`);

SET SQL_SAFE_UPDATES = 0;
UPDATE speciality
SET provider_taxonomy_code = TRIM(provider_taxonomy_code);

ALTER TABLE `speciality`
ADD INDEX `idx_provider_taxonomy_code` (`provider_taxonomy_code`);

ALTER TABLE `patient_diagnosis` ADD COLUMN `speciality` VARCHAR(255) DEFAULT NULL;

UPDATE `patient_diagnosis` pd
LEFT JOIN (
    SELECT `provider_taxonomy_code`, GROUP_CONCAT(DISTINCT `speciality` ORDER BY `id` SEPARATOR ',') AS aggregated_speciality
    FROM `speciality`
    GROUP BY `provider_taxonomy_code`
) s ON pd.`provider_ref_id` = s.`provider_taxonomy_code`
SET pd.`speciality` = IFNULL(s.aggregated_speciality, NULL);


ALTER TABLE `Final_Patients`
ADD COLUMN `most_recent_date` DATE DEFAULT NULL;

UPDATE `Final_Patients` fp
JOIN (
    SELECT mrn, MAX(service_date) AS max_service_date
    FROM service_lines
    GROUP BY mrn
) AS sl ON fp.mrn = sl.mrn
SET fp.most_recent_date = sl.max_service_date;

# Set Patient type: Discontinued, Continued, New

ALTER TABLE `rafvue`.`Final_Patients`
ADD COLUMN `visited_2023` INT DEFAULT 0,
ADD COLUMN `visited_2022` INT DEFAULT 0,
ADD COLUMN `patient_type` VARCHAR(50) DEFAULT NULL;

UPDATE rafvue.Final_Patients
SET visited_2023 = 1
WHERE mrn IN (
    SELECT mrn
    FROM service_lines
    WHERE YEAR(service_date) = 2023
);

UPDATE rafvue.Final_Patients
SET visited_2023 = 0
WHERE mrn NOT IN (
    SELECT mrn
    FROM service_lines
    WHERE YEAR(service_date) = 2023
);

UPDATE rafvue.Final_Patients
SET visited_2022 = 1
WHERE mrn IN (
    SELECT mrn
    FROM service_lines
    WHERE YEAR(service_date) = 2022
);

UPDATE rafvue.Final_Patients
SET visited_2022 = 0
WHERE mrn NOT IN (
    SELECT mrn
    FROM service_lines
    WHERE YEAR(service_date) = 2022
);


UPDATE rafvue.Final_Patients
SET patient_type =
    CASE
        WHEN visited_2023 = 1 AND visited_2022 = 0 THEN 'new'
        WHEN visited_2023 = 0 AND visited_2022 = 1 THEN 'discontinued'
        WHEN visited_2023 = 1 AND visited_2022 = 1 THEN 'continued'
    END;



ALTER TABLE `rafvue`.`Final_Patients` 
ADD COLUMN `Reviewer` VARCHAR(45),
ADD COLUMN `additional_notes` TEXT,
ADD COLUMN `case_status` INT DEFAULT NULL,
ADD COLUMN `edit_date` DATETIME NULL AFTER `additional_notes`,
ADD COLUMN `user_id` VARCHAR(45) NULL AFTER `edit_date`,
ADD COLUMN `user_name` VARCHAR(75) NULL AFTER `user_id`,
ADD COLUMN `closed_by_username` VARCHAR(75)DEFAULT  NULL,
ADD COLUMN `closed_date` DATE DEFAULT NULL,
ADD COLUMN `closed_by_user_id` VARCHAR(45) NULL AFTER `closed_date`,
ADD COLUMN `reviewer_id` INT DEFAULT NULL,
ADD COLUMN `qr_status` varchar(50) DEFAULT NULL,
ADD COLUMN `quality_reviewer` VARCHAR(75) NULL AFTER `closed_by_user_id`,
ADD COLUMN `quality_reviewer_id` VARCHAR(45) NULL AFTER `quality_reviewer`,
ADD COLUMN `quality_review_date` DATETIME NULL AFTER `quality_reviewer_id`,
ADD COLUMN `quality_reviewer_completed` VARCHAR(45) NULL AFTER `quality_review_date`,
ADD COLUMN `quality_reviewer_assigned_date` DATETIME NULL AFTER `quality_reviewer_completed`,
ADD COLUMN `reviewer_assigned_date` DATETIME NULL AFTER `quality_reviewer_assigned_date`,
ADD COLUMN `follow_up_date` DATETIME NULL AFTER `qr_status`,
ADD COLUMN `follow_up_completed_date` DATETIME NULL AFTER `follow_up_date`,
ADD COLUMN `follow_up_status` VARCHAR(150) NULL AFTER `follow_up_date`,
ADD COLUMN `follow_up` VARCHAR(150) NULL AFTER `follow_up_status`,
ADD column `potential_raf_hierarchy_2023` double default null,
ADD column `potential_raf_interaction_2023` double default null,
ADD column `potential_raf_2023` double default null,
ADD column `potential_raf_hierarchy_2022` double default null,
ADD column `potential_raf_interaction_2022` double default null,
ADD column `potential_raf_2022` double default null,
ADD COLUMN  `selected_criteria_name` varchar(255) DEFAULT NULL,
ADD COLUMN `post_hcc_count` double DEFAULT NULL,
ADD COLUMN `last_review_date` date DEFAULT NULL,
ADD COLUMN `follow_up_status_edit_date` varchar(150) DEFAULT NULL,
ADD COLUMN `follow_up_status_notes` varchar(150) DEFAULT NULL;


ALTER TABLE `hcc_2022`
ADD COLUMN `post_review_icd` VARCHAR(255) DEFAULT NULL,
ADD COLUMN `post_review_hcc` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_category` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_weight` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_acute_chronic` VARCHAR(255) DEFAULT NULL;

ALTER TABLE `hcc_2023`
ADD COLUMN `post_review_icd` VARCHAR(255) DEFAULT NULL,
ADD COLUMN `post_review_hcc` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_category` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_weight` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_acute_chronic` VARCHAR(255) DEFAULT NULL;



-- to create the awv_status column in the serviceline 
ALTER TABLE rafvue.service_lines
ADD COLUMN awv_status varchar(1) DEFAULT NULL;

-- disable the safe mode
SET SQL_SAFE_UPDATES = 0;

UPDATE rafvue.service_lines AS sl
LEFT JOIN (
  SELECT
    sl.id,
    CASE
      WHEN awv.CPT IS NULL THEN '1' 
      ELSE '0'
    END AS awv_status  
  FROM
    service_lines sl
    LEFT JOIN awv_codes awv ON
      SUBSTRING_INDEX(sl.sv2_initial_hcpcs_code, '|', -1) = awv.CPT OR
      SUBSTRING_INDEX(sl.sv1_cpt_code_info, '|', -1) = awv.CPT
) AS temp ON sl.id = temp.id
SET sl.awv_status = temp.awv_status;

-- to update the awv_status in Final_patients
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE Final_Patients
ADD COLUMN awv_status BOOLEAN;


UPDATE Final_Patients fp
JOIN (
    SELECT sl.mrn,
           CASE WHEN SUM(CASE WHEN sl.awv_status = '1' THEN 1 ELSE 0 END) > 0 THEN '1' ELSE '0' END AS awv_status
    FROM service_lines sl
    GROUP BY sl.mrn
) sl_agg ON fp.mrn = sl_agg.mrn
SET fp.awv_status = sl_agg.awv_status
WHERE fp.mrn IN (SELECT mrn FROM service_lines);


CREATE TABLE `calendar` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `end` datetime DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `allDay` varchar(255) DEFAULT NULL,
  `backgroundColor` varchar(20) DEFAULT NULL,
  `subject` text,
  `user` varchar(255) DEFAULT NULL,
  `added_by` varchar(255) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ;

ALTER TABLE `rafvue`.`patient_diagnosis` 
ADD COLUMN `status` VARCHAR(45) NULL AFTER `service_date`,
ADD COLUMN `edit_date` DATETIME NULL AFTER `status`,
ADD COLUMN `user_id` VARCHAR(45) NULL AFTER `edit_date`,
ADD COLUMN `user_name` VARCHAR(75) NULL AFTER `user_id`,
ADD COLUMN `qr_approved` VARCHAR(75) NULL AFTER `user_name`,
ADD COLUMN `follow_up_status` VARCHAR(150) NULL AFTER `qr_approved`,
ADD COLUMN `follow_up_status_edit_date` DATETIME NULL DEFAULT NULL AFTER `follow_up_status`,
ADD COLUMN `follow_up_status_notes` TEXT NULL DEFAULT NULL AFTER `follow_up_status_edit_date`,
ADD COLUMN  `review_status` int DEFAULT NULL,
ADD COLUMN `verify_status` int DEFAULT NULL,
ADD COLUMN `patient_name` varchar(45) DEFAULT NULL,
ADD COLUMN  `npi_number` varchar(255) DEFAULT NULL;


#Add patient name

UPDATE rafvue.patient_diagnosis AS pd
JOIN rafvue.Final_Patients AS fp ON pd.mrn = fp.mrn
SET pd.patient_name = fp.full_name;

#add npi number

UPDATE rafvue.patient_diagnosis AS pd
JOIN rafvue.rendering_provider AS rp ON pd.transaction_id = rp.transaction_id AND pd.mrn = rp.mrn
SET pd.npi_number = rp.npi_number;

Drop table  if exists rafvue.patients_icd10_status;
CREATE TABLE rafvue.patients_icd10_status (
    id INT NOT NULL AUTO_INCREMENT,
    mrn VARCHAR(255) DEFAULT NULL,
    diagnosis_code VARCHAR(255) DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    `hcc_v24` double DEFAULT NULL,
    `hcc_weight_24` double DEFAULT NULL,
    `hcc_v28` double DEFAULT NULL,
    `hcc_weight_28` double DEFAULT NULL,
    icd_count_2023 int DEFAULT NULL,
    icd_count_2022 int DEFAULT NULL,
    `service_date` date DEFAULT NULL,
    reviewer_activity VARCHAR(255) DEFAULT NULL,
    case_action VARCHAR(255) DEFAULT NULL,
    reason VARCHAR(255) DEFAULT NULL,
    icd_10 VARCHAR(255) DEFAULT NULL,
    follow_up VARCHAR(255) DEFAULT NULL,
    `qr_status` varchar(255)  DEFAULT NULL,
    `qr_action` varchar(255)  DEFAULT NULL,
    `qr_reason` varchar(255)  DEFAULT NULL,
    `qr_icd10` varchar(255)  DEFAULT NULL,
    `qr_follow-up` varchar(255)  DEFAULT NULL,
    `rationale` text  DEFAULT NULL,
     PRIMARY KEY (`id`),
     KEY `idx_pat_icd10_status_mrn` (`mrn`)
);


INSERT INTO rafvue.patients_icd10_status (
    mrn,
    diagnosis_code,
    description,
    `hcc_v24`,
    `hcc_weight_24`,
    `hcc_v28`,
    `hcc_weight_28`,
    icd_count_2023,
    icd_count_2022,
    service_date
) 
SELECT
    DISTINCT mrn,
    diagnosis_code,
    description,
    hcc_v24,
    hcc_weight_24,
    hcc_v28,
    hcc_weight_28,
    SUM(CASE WHEN YEAR(service_date) LIKE '%2023%' THEN 1 ELSE 0 END) AS icd_count_2023,
    SUM(CASE WHEN YEAR(service_date) LIKE '%2022%' THEN 1 ELSE 0 END) AS icd_count_2022,
    MAX(service_date)
FROM
    patient_diagnosis
GROUP BY
    mrn, diagnosis_code, description, hcc_v24, hcc_weight_24, hcc_v28, hcc_weight_28



    
ALTER TABLE Final_Patients
ADD COLUMN total_hcc INT;

set sql_safe_updates = 0;
UPDATE Final_Patients fp
SET fp.total_hcc = (
    SELECT COUNT(DISTINCT pis.hcc_v24)
    FROM rafvue.patients_icd10_status pis
    WHERE pis.mrn = fp.mrn
);

SET sql_safe_updates = 0;
UPDATE Final_Patients fp
SET fp.hccs_open = (
    SELECT COUNT(distinct pis.hcc_v24)
    FROM rafvue.patients_icd10_status pis
    WHERE pis.mrn = fp.mrn 
    AND pis.reviewer_activity IS NULL);

ALTER TABLE Final_Patients
ADD COLUMN hccs_open INT;

ALTER TABLE Final_Patients
ADD COLUMN hccs_2023 INT;

SET sql_safe_updates = 0;
UPDATE Final_Patients fp
SET fp.hccs_2023 = (
    SELECT COUNT(distinct pis.hcc_v24)
    FROM rafvue.patient_diagnosis pis
    WHERE pis.mrn = fp.mrn 
    AND pis.service_date like "%2023%");
    
ALTER TABLE Final_Patients
ADD COLUMN hccs_2022 INT;

SET sql_safe_updates = 0;
UPDATE Final_Patients fp
SET fp.hccs_2022 = (
    SELECT COUNT(distinct pis.hcc_v24)
    FROM rafvue.patient_diagnosis pis
    WHERE pis.mrn = fp.mrn 
    AND pis.service_date like "%2022%");

ALTER TABLE Final_Patients
ADD COLUMN payers TEXT;

UPDATE Final_Patients fp
JOIN (
    SELECT mrn, GROUP_CONCAT(DISTINCT PayerName SEPARATOR ',') AS PayerNames
    FROM rafvue.included_subscriber
    GROUP BY mrn
) AS subquery ON fp.mrn = subquery.mrn
SET fp.payers = subquery.PayerNames;


ALTER TABLE `Final_Patients`
ADD COLUMN  `pre_hcc_count` int DEFAULT NULL AFTER selected_criteria_name,
ADD COLUMN  `v28_hccs_2023` int DEFAULT NULL,
ADD COLUMN `v28_hccs_2022` int DEFAULT NULL,
ADD COLUMN  `2023_raf_v28` double DEFAULT NULL,
ADD COLUMN `2022_raf_v28` double DEFAULT NULL;

SET sql_safe_updates = 0;
UPDATE Final_Patients fp
SET fp.v28_hccs_2023 = (
    SELECT COUNT(distinct pis.hcc_v28)
    FROM rafvue.patient_diagnosis pis
    WHERE pis.mrn = fp.mrn 
    AND pis.service_date like "%2023%");

SET sql_safe_updates = 0;
UPDATE Final_Patients fp
SET fp.v28_hccs_2022 = (
    SELECT COUNT(distinct pis.hcc_v28)
    FROM rafvue.patient_diagnosis pis
    WHERE pis.mrn = fp.mrn 
    AND pis.service_date like "%2022%");



