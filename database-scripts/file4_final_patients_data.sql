Alter table billing_provider_patients
ADD COLUMN mrn varchar(255);
 
set sql_safe_updates =0;
UPDATE billing_provider_patients AS bp
LEFT JOIN claims_reference AS cr ON bp.transaction_id = cr.transaction_id
SET bp.mrn = cr.ReferenceIdentification
WHERE cr.ReferenceIdentificationQualifier = 'EA';

#Code for billing_provider_patients

drop table if exists final_patients_data;
CREATE TABLE final_patients_data AS 
SELECT 
    Final_Patients.mrn, 
    Age, 
    Final_Patients.Gender, 
    billing_provider_patients.OrganizationName AS OrganizationName, 
    ROUND(Final_Patients.raf_variance, 2) AS RafVariance, 
    recapture_count,
    included_subscriber.PayerName,
    COUNT(*) AS RepetitionCount
FROM
    Final_Patients 
    LEFT JOIN rafvue.billing_provider_patients 
        ON Final_Patients.mrn = billing_provider_patients.mrn
    LEFT JOIN included_subscriber 
        ON Final_Patients.mrn = included_subscriber.mrn
GROUP BY 
    Final_Patients.mrn, 
    Age, 
    Final_Patients.Gender, 
    billing_provider_patients.OrganizationName, 
    ROUND(Final_Patients.raf_variance, 2), 
    recapture_count,
    included_subscriber.PayerName;


ALTER TABLE final_patients_data
ADD INDEX idx_final_patients_data_mrn (mrn),
ADD INDEX idx_final_patients_data_age (Age),
ADD INDEX idx_final_patients_data_gender (Gender),
ADD INDEX idx_final_patients_data_organizationName (OrganizationName),
ADD INDEX idx_final_patients_data_rafVariance (RafVariance),
ADD INDEX idx_final_patients_data_recaptureOpportunities (recapture_count),
ADD INDEX idx_final_patients_data_payerName (PayerName);

ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `RafVarianceCategory` VARCHAR(45) NULL AFTER `recapture_count`,
ADD COLUMN `AgeRange` VARCHAR(45) NULL AFTER `RafVarianceCategory`,
ADD COLUMN `recaptureOpportunities` VARCHAR(45) NULL AFTER `AgeRange`,
ADD COLUMN `group_by` VARCHAR(500) GENERATED ALWAYS AS (concat(AgeRange, recaptureOpportunities,RafVarianceCategory,OrganizationName,PayerName)) VIRTUAL ;

set sql_safe_updates=0;
update final_patients_data set AgeRange = (CASE
      WHEN final_patients_data.Age >= 0 AND final_patients_data.Age <= 19 THEN '0-19'
      WHEN final_patients_data.Age >= 20 AND final_patients_data.Age <= 34 THEN '20-34'
      WHEN final_patients_data.Age >= 35 AND final_patients_data.Age <= 44 THEN '35-44'
      WHEN final_patients_data.Age >= 45 AND final_patients_data.Age <= 54 THEN '45-54'
	  WHEN final_patients_data.Age >= 55 AND final_patients_data.Age <= 64 THEN '55-64'
      WHEN final_patients_data.Age >= 65 THEN '65+'
      WHEN final_patients_data.Age IS NULL THEN 'None'
    END) ;

set sql_safe_updates=0;
update final_patients_data set RafVarianceCategory = (CASE
      WHEN final_patients_data.RafVariance > 0 THEN 'Positive'
      WHEN final_patients_data.RafVariance < 0 THEN 'Negative'
      WHEN final_patients_data.RafVariance = 0 THEN 'Zero'
    END);

set sql_safe_updates=0;
update final_patients_data set recaptureOpportunities = (CASE
      WHEN final_patients_data.recapture_count >= 0 AND final_patients_data.recapture_count <= 5 THEN '0-5'
      WHEN final_patients_data.recapture_count >= 6 AND final_patients_data.recapture_count <= 10 THEN '6-10'
      WHEN final_patients_data.recapture_count >= 11 AND final_patients_data.recapture_count <= 15 THEN '11-15'
      WHEN final_patients_data.recapture_count >= 16 AND final_patients_data.recapture_count < 4 THEN '16-20'
    END);
    

ALTER TABLE final_patients_data 
CHANGE COLUMN `group_by` `group_by` VARCHAR(500) GENERATED ALWAYS AS 
(concat(`AgeRange`, `recaptureOpportunities`, `RafVarianceCategory`, `OrganizationName`, `PayerName`)) VIRTUAL;

ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `raf_2023` DOUBLE NULL AFTER `RepetitionCount`;

set sql_safe_updates=0;
update final_patients_data inner join Final_Patients on final_patients_data.mrn = Final_Patients.mrn
set final_patients_data.raf_2023 = Final_Patients.raf_2023;


drop table if exists top_hcc_v24;
create table top_hcc_v24 
select count(*) as Count, mrn, hcc_v24 from patient_diagnosis where hcc_v24 is not null and 
left(service_date,4)=2023 group by mrn, hcc_v24;


ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `max_hccv_24` VARCHAR(45) NULL AFTER `raf_2023`,
ADD COLUMN `max_hccv_24_count` VARCHAR(45) NULL AFTER `max_hccv_24`;

ALTER TABLE `rafvue`.`top_hcc_v24` 
ADD COLUMN `id` INT NOT NULL AUTO_INCREMENT AFTER `hcc_v24`,
ADD PRIMARY KEY (`id`),
ADD UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE;

drop table if exists top_hcc_v24_unique;
create table top_hcc_v24_unique SELECT
    max(Count) as Count,
    mrn,
    hcc_v24 from top_hcc_v24 group by mrn, hcc_v24;
    

ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `current_year_patient` VARCHAR(2) NULL AFTER `max_hccv_24_count`;

set sql_safe_updates=0;
update final_patients_data inner join patient_diagnosis on final_patients_data.mrn = patient_diagnosis.mrn 
set current_year_patient=1 where YEAR(service_date)=2023;

ALTER TABLE `rafvue`.`top_hcc_v24` 
ADD COLUMN `Gender` VARCHAR(45) NULL AFTER `id`,
ADD COLUMN `RafVarianceCategory` VARCHAR(45) NULL AFTER `Gender`,
ADD COLUMN `AgeRange` VARCHAR(45) NULL AFTER `RafVarianceCategory`,
ADD COLUMN `Age` VARCHAR(45) NULL AFTER `AgeRange`,
ADD COLUMN `recaptureOpportunities` VARCHAR(45) NULL AFTER `Age`,
ADD COLUMN `PayerName` VARCHAR(200) NULL AFTER `recaptureOpportunities`;



set sql_safe_updates=0;
update top_hcc_v24 inner join final_patients_data on final_patients_data.mrn = top_hcc_v24.mrn
set top_hcc_v24.Gender = final_patients_data.Gender,
top_hcc_v24.RafVarianceCategory = final_patients_data.RafVarianceCategory,
top_hcc_v24.Age = final_patients_data.Age,
top_hcc_v24.recaptureOpportunities = final_patients_data.recaptureOpportunities,
top_hcc_v24.PayerName = final_patients_data.PayerName;

ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `group_by_id` VARCHAR(200) NULL AFTER `current_year_patient`;


ALTER TABLE `rafvue`.`top_hcc_v24` 
ADD COLUMN `group_by_id` VARCHAR(200) NULL AFTER `PayerName`;

set sql_safe_updates=0;
update top_hcc_v24 set group_by_id = concat(Gender,RafVarianceCategory,Age,recaptureOpportunities,PayerName);
update final_patients_data set group_by_id = concat(Gender,RafVarianceCategory,Age,recaptureOpportunities,PayerName);

ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `raf_2023_v28` VARCHAR(45) NULL AFTER `group_by_id`;

ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `ID` INT NOT NULL AUTO_INCREMENT AFTER `RAF_2023_v28`,
ADD PRIMARY KEY (`ID`),
ADD UNIQUE INDEX `ID_UNIQUE` (`ID` ASC) VISIBLE;

ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `RAFScoreCategory` VARCHAR(45) NULL AFTER `ID`;

set sql_safe_updates=0;
update final_patients_data set RAFScoreCategory = (CASE
      WHEN final_patients_data.raf_2023 <=1 THEN 'Less than 1'
      WHEN final_patients_data.raf_2023 >= 1.1 AND final_patients_data.raf_2023 <=3 THEN '1.01 - 3'
      WHEN final_patients_data.raf_2023 > 3 THEN '3 plus'
    END);  

set sql_safe_updates=0;
update final_patients_data set RAFScoreCategory = 'Less than 1' where RAFScoreCategory is null;

DROP TABLE IF EXISTS total_hcc_counts;
create table total_hcc_counts select Count, mrn, sum(COUNT) as totalHCC from top_hcc_v24 group by mrn,Count; 

  ALTER TABLE `rafvue`.`final_patients_data` 
ADD COLUMN `totalHCC` VARCHAR(45) NULL AFTER `RAFScoreCategory`;


/*set sql_safe_updates=0;
update final_patients_data inner join top_hcc_v24_2 on top_hcc_v24_2.mrn = final_patients_data.mrn
set final_patients_data.totalHCC = top_hcc_v24_2.Count;*/




















