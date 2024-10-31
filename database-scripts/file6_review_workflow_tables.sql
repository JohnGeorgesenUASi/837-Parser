# Case Review Table. Whenever review is DONE, it gets into case_review

DROP TABLE IF EXISTS case_review;
CREATE TABLE `case_review` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_action` varchar(250) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `icd_10` varchar(45) DEFAULT NULL,
  `follow_up` varchar(145) DEFAULT NULL,
  `follow_up_status` varchar(145) DEFAULT NULL,
  `additional_notes` text,
  `rationale` text,
  `user_id` varchar(45) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `diagnosis_table_id` int DEFAULT NULL,
  `mrn` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `edit_date` datetime DEFAULT NULL,
  `started_time` datetime DEFAULT NULL,
  `pre_review_icd10` varchar(45) DEFAULT NULL,
  `provider` varchar(45) DEFAULT NULL,
  `speciality` varchar(45) DEFAULT NULL,
  `hcc_v24` int DEFAULT NULL,
  `patient_name` varchar(255) DEFAULT NULL,
  `followup_query_outcome` text,
  `transaction_id` varchar(95) DEFAULT NULL,
  `query_process_rate` int DEFAULT NULL,
  `npi_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `idx_case_review_mrn` (`mrn`),
  KEY `idx_case_review_hcc_v24` (`hcc_v24`),
  KEY `idx_case_review_follow_up_status` (`follow_up_status`),
  KEY `idx_case_review_mrn_hcc_v24` (`mrn`,`hcc_v24`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `case_review_edited` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_action` varchar(250) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `icd_10` varchar(45) DEFAULT NULL,
  `follow_up` varchar(145) DEFAULT NULL,
  `additional_notes` text,
  `rationale` text,
  `user_id` varchar(45) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `diagnosis_table_id` varchar(45) DEFAULT NULL,
  `mrn` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `edit_date` datetime DEFAULT NULL,
  `started_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `idx_case_review_edited_mrn` (`mrn`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS follow_up;
CREATE TABLE `follow_up` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mrn` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `diagnosis_code` varchar(255) DEFAULT NULL,
  `follow_up` varchar(255) DEFAULT NULL,
  `follow_up_status` varchar(255) DEFAULT NULL,
  `edit_date` date DEFAULT NULL,
  `rationale` text,
  `case_review_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_follow_up_mrn` (`mrn`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS quality_review;
CREATE TABLE `quality_review` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_action` varchar(250) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `icd_10` varchar(45) DEFAULT NULL,
  `follow_up` varchar(145) DEFAULT NULL,
  `follow_up_status` varchar(145) DEFAULT NULL,
  `additional_notes` text,
  `rationale` text,
  `user_id` varchar(45) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `diagnosis_table_id` int DEFAULT NULL,
  `mrn` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `edit_date` datetime DEFAULT NULL,
  `started_time` datetime DEFAULT NULL,
  `pre_review_icd10` varchar(45) DEFAULT NULL,
  `provider` varchar(45) DEFAULT NULL,
  `speciality` varchar(45) DEFAULT NULL,
  `hcc_v24` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `idx_qr_mrn` (`mrn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS quality_review_edited;
CREATE TABLE `quality_review_edited` (
  `id` int NOT NULL AUTO_INCREMENT,
  `case_action` varchar(250) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `icd_10` varchar(45) DEFAULT NULL,
  `follow_up` varchar(145) DEFAULT NULL,
  `follow_up_status` varchar(145) DEFAULT NULL,
  `additional_notes` text,
  `rationale` text,
  `user_id` varchar(45) DEFAULT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `diagnosis_table_id` int DEFAULT NULL,
  `mrn` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `edit_date` datetime DEFAULT NULL,
  `started_time` datetime DEFAULT NULL,
  `pre_review_icd10` varchar(45) DEFAULT NULL,
  `provider` varchar(45) DEFAULT NULL,
  `speciality` varchar(45) DEFAULT NULL,
  `hcc_v24` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `idx_qr_edited_mrn` (`mrn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS additional_notes;
CREATE TABLE `additional_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mrn` varchar(50) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `notes` text,
  `reviewer` varchar(255) DEFAULT NULL,
  `reviewer_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_additional_notes_mrn` (`mrn`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS case_selection_filters;
CREATE TABLE `case_selection_filters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `query_name` varchar(255) NOT NULL,
  `filters` json NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS diagnostic_grouping;
CREATE TABLE `diagnostic_grouping` (
  `id` int NOT NULL AUTO_INCREMENT,
  `diagnosis_group` varchar(255) DEFAULT NULL,
  `hcc_v24` varchar(255) DEFAULT NULL,
  `total_2022_v24` int DEFAULT NULL,
  `percent_2022_v24` double DEFAULT NULL,
  `total_2023_v24` int DEFAULT NULL,
  `percent_2023_v24` double DEFAULT NULL,
  `hcc_v28` varchar(225) DEFAULT NULL,
  `total_2022_v28` int DEFAULT NULL,
  `percent_2022_v28` double DEFAULT NULL,
  `total_2023_v28` int DEFAULT NULL,
  `percent_2023_v28` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS ITAC_Analysis;
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
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP TABLE IF EXISTS provider_details;
CREATE TABLE `provider_details` (
  `full_name` varchar(255) DEFAULT NULL,
  `prv_reference_identification` varchar(255) DEFAULT NULL,
  `speciality` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;







