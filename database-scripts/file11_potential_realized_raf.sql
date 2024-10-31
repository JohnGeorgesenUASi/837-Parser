ALTER TABLE rafvue.hcc_codes_eligible
ADD COLUMN UASI_HCC INT DEFAULT NULL,
ADD COLUMN AcuteChronic VARCHAR(50) DEFAULT NULL,
ADD COLUMN weight DOUBLE DEFAULT NULL;
 
set sql_safe_updates=0;
UPDATE rafvue.hcc_codes_eligible AS hce
JOIN rafvue.`Complete HCC Codes and Weights` AS complete
ON hce.DiagnosisCode = complete.DiagnosisCode 
SET hce.UASI_HCC = complete.`CMS-HCC Model Category V24`,
hce.AcuteChronic = complete.`Acute / Chronic`,
hce.weight = complete.`HCC Weight`;
 
ALTER TABLE rafvue.hcc_codes_eligible
ADD COLUMN ITAC_Category INT DEFAULT NULL;
 
set sql_safe_updates=0;
UPDATE rafvue.hcc_codes_eligible AS hce
JOIN rafvue.ITAC_Hierarchies AS ih
ON hce.UASI_HCC = ih.HCC_group AND UASI_HCC IS NOT NULL
SET hce.ITAC_Category = complete.ITAC_category;

drop table if exists rafvue.post_raf_score;
CREATE TABLE rafvue.post_raf_score as
SELECT *
FROM rafvue.hcc_codes_eligible
GROUP BY mrn, DiagnosisCode, DiagnosisCodeQualifier, serviceYear;

ALTER TABLE `post_raf_score`
ADD COLUMN `post_review_icd` VARCHAR(255) DEFAULT NULL,
ADD COLUMN `post_review_hcc` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_category` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_weight` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_acute_chronic` VARCHAR(255) DEFAULT NULL;

#V28 Tables

create table rafvue_v28.hcc_codes as SELECT * FROM rafvue.hcc_codes;


drop table if exists rafvue_v28.hcc_codes_eligible;
create table rafvue_v28.hcc_codes_eligible as
select hc.* from rafvue_v28.hcc_codes hc inner join rafvue_v28.Final_Patients fp on 
hc.mrn = fp.mrn where hc.serviceYear> 2021;


ALTER TABLE rafvue_v28.hcc_codes_eligible
ADD COLUMN UASI_HCC INT DEFAULT NULL,
ADD COLUMN AcuteChronic VARCHAR(50) DEFAULT NULL,
ADD COLUMN weight DOUBLE DEFAULT NULL;
 
set sql_safe_updates=0;
UPDATE rafvue_v28.hcc_codes_eligible AS hce
JOIN rafvue_v28.`Complete HCC Codes and Weights` AS complete
ON hce.DiagnosisCode = complete.DiagnosisCode 
SET hce.UASI_HCC = complete.`CMS-HCC Model Category V28`,
hce.AcuteChronic = complete.`Acute / Chronic`,
hce.weight = complete.`HCC Weight`;
 
ALTER TABLE rafvue_v28.hcc_codes_eligible
ADD COLUMN ITAC_Category INT DEFAULT NULL;
 
set sql_safe_updates=0;
UPDATE rafvue_v28.hcc_codes_eligible AS hce
JOIN rafvue_v28.ITAC_Hierarchies AS ih
ON hce.UASI_HCC = ih.HCC_group AND UASI_HCC IS NOT NULL
SET hce.ITAC_Category = ih.ITAC_category;

drop table if exists rafvue_v28.post_raf_score;
CREATE TABLE rafvue_v28.post_raf_score as
SELECT *
FROM rafvue_v28.hcc_codes_eligible
GROUP BY mrn, DiagnosisCode, DiagnosisCodeQualifier,serviceYear;

ALTER TABLE rafvue_v28.`post_raf_score`
ADD COLUMN `post_review_icd` VARCHAR(255) DEFAULT NULL,
ADD COLUMN `post_review_hcc` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_category` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_weight` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_acute_chronic` VARCHAR(255) DEFAULT NULL;

ALTER TABLE rafvue.`post_raf_score`
ADD COLUMN `post_review_icd` VARCHAR(255) DEFAULT NULL,
ADD COLUMN `post_review_hcc` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_category` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_weight` DOUBLE DEFAULT NULL,
ADD COLUMN `post_review_acute_chronic` VARCHAR(255) DEFAULT NULL,
ADD COLUMN `post_qr_icd` VARCHAR(255) DEFAULT NULL,
ADD COLUMN `post_qr_hcc` DOUBLE DEFAULT NULL,
ADD COLUMN `post_qr_category` DOUBLE DEFAULT NULL,
ADD COLUMN `post_qr_weight` DOUBLE DEFAULT NULL,
ADD COLUMN `post_qr_acute_chronic` VARCHAR(255) DEFAULT NULL;
