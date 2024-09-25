-- MySQL dump 10.13  Distrib 8.0.32, for Win64 (x86_64)
--
-- Host: localhost    Database: rafvue
-- ------------------------------------------------------
-- Server version	8.0.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `isa`
--

DROP TABLE IF EXISTS `isa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `isa` (
  `id` int NOT NULL AUTO_INCREMENT,
  `AuthorizationInformationQualifier` varchar(255) DEFAULT NULL,
  `AuthorizationInformation` varchar(255) DEFAULT NULL,
  `SecurityInformationQualifier` varchar(255) DEFAULT NULL,
  `SecurityInformation` varchar(255) DEFAULT NULL,
  `InterchangeIDQualifierSender` varchar(255) DEFAULT NULL,
  `InterchangeSenderID` varchar(255) DEFAULT NULL,
  `InterchangeIDQualifierReceiver` varchar(255) DEFAULT NULL,
  `InterchangeReceiverID` varchar(255) DEFAULT NULL,
  `InterchangeDate` varchar(255) DEFAULT NULL,
  `InterchangeTime` varchar(255) DEFAULT NULL,
  `InterchangeControlStandardsIdentifier` varchar(255) DEFAULT NULL,
  `InterchangeControlVersionNumber` varchar(255) DEFAULT NULL,
  `InterchangeControlNumber` varchar(255) DEFAULT NULL,
  `AcknowledgmentRequested` varchar(255) DEFAULT NULL,
  `UsageIndicator` varchar(255) DEFAULT NULL,
  `ComponentElementSeparator` varchar(255) DEFAULT NULL,
  `FunctionalIdentifierCode` varchar(255) DEFAULT NULL,
  `ApplicationSenderCode` varchar(255) DEFAULT NULL,
  `ApplicationReceiverCode` varchar(255) DEFAULT NULL,
  `Date` varchar(255) DEFAULT NULL,
  `Time` varchar(255) DEFAULT NULL,
  `GroupControlNumber` varchar(255) DEFAULT NULL,
  `ResponsibleAgencyCode` varchar(255) DEFAULT NULL,
  `VersionReleaseIndustryIdentifierCode` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ControlNumber` varchar(255) DEFAULT NULL,
  `ImplementationConventionReference` varchar(255) DEFAULT NULL,
  `HierarchicalStructureCode` varchar(255) DEFAULT NULL,
  `TransactionSetPurposeCode` varchar(255) DEFAULT NULL,
  `ReferenceIdentification` varchar(255) DEFAULT NULL,
  `Date` varchar(255) DEFAULT NULL,
  `Time` varchar(255) DEFAULT NULL,
  `TransactionTypeCode` varchar(255) DEFAULT NULL,
  `transaction_id` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_id_UNIQUE` (`transaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `submitter`
--

DROP TABLE IF EXISTS `submitter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `submitter` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `EntityTypeQualifier` varchar(255) DEFAULT NULL,
  `OrganizationName` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `IdentificationCodeQualifier` varchar(255) DEFAULT NULL,
  `IdentificationCode` varchar(255) DEFAULT NULL,
  `CommunicationContact` varchar(255) DEFAULT NULL,
  `TelephoneNumber` varchar(255) DEFAULT NULL,
  `FaxNumber` varchar(255) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `receiver`
--

DROP TABLE IF EXISTS `receiver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `receiver` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `EntityTypeQualifier` varchar(255) DEFAULT NULL,
  `OrganizationName` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `IdentificationCodeQualifier` varchar(255) DEFAULT NULL,
  `IdentificationCode` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `billing_provider`
--

DROP TABLE IF EXISTS `billing_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `billing_provider` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `EntityTypeQualifier` varchar(255) DEFAULT NULL,
  `ProviderCode` varchar(255) DEFAULT NULL,
  `ReferenceIdentificationQualifier` varchar(255) DEFAULT NULL,
  `ReferenceIdentification` varchar(255) DEFAULT NULL,
  `OrganizationName` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `IdentificationCodeQualifier` varchar(255) DEFAULT NULL,
  `IdentificationCode` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `State` varchar(255) DEFAULT NULL,
  `PostalCode` varchar(255) DEFAULT NULL,
  `ReferenceCodeQualifier` varchar(255) DEFAULT NULL,
  `ReferenceCode` varchar(255) DEFAULT NULL,
  `CommunicationContact` varchar(255) DEFAULT NULL,
  `Telephone` varchar(255) DEFAULT NULL,
  `FaxNumber` varchar(255) DEFAULT NULL,
  `Email` varchar(255) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pay_to_address`
--

DROP TABLE IF EXISTS `pay_to_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pay_to_address` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(60) DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `billing_provider_id` int DEFAULT NULL,
  `EntityType` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `State` varchar(255) DEFAULT NULL,
  `PostalCode` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscriber`
--

DROP TABLE IF EXISTS `subscriber`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriber` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `PayerResponsibilityCode` varchar(255) DEFAULT NULL,
  `RelationshipCode` varchar(255) DEFAULT NULL,
  `ReferralTypeCode` varchar(255) DEFAULT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `InsuranceTypeCode` varchar(255) DEFAULT NULL,
  `CoordinationBenefitCode` varchar(255) DEFAULT NULL,
  `ResponseCode` varchar(255) DEFAULT NULL,
  `EmploymentStatusCode` varchar(255) DEFAULT NULL,
  `ClaimFilingIndicatorCode` varchar(255) DEFAULT NULL,
  `PatientRelationshipToInsured` varchar(255) DEFAULT NULL,
  `PregnencyIndicator` varchar(255) DEFAULT NULL,
  `InsuredParty` varchar(255) DEFAULT NULL,
  `LastName` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `IdentificationCodeQualifier` varchar(255) DEFAULT NULL,
  `IdentificationCode` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `State` varchar(255) DEFAULT NULL,
  `PostalCode` varchar(255) DEFAULT NULL,
  `DateTimeFormatQualifier` varchar(255) DEFAULT NULL,
  `DateOfBirth` varchar(255) DEFAULT NULL,
  `Gender` varchar(255) DEFAULT NULL,
  `PayerName` varchar(75) DEFAULT NULL,
  `PayerId` varchar(45) DEFAULT NULL,
  `Payer_Address` varchar(245) DEFAULT NULL,
  `Payer_city` varchar(75) DEFAULT NULL,
  `Payer_State` varchar(45) DEFAULT NULL,
  `Payer_PostalCode` varchar(45) DEFAULT NULL,
  `isPatient` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33295 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `PatientRelationshipToInsured` varchar(255) DEFAULT NULL,
  `DateTimeQualifier` varchar(255) DEFAULT NULL,
  `PatientDeathDate` varchar(255) DEFAULT NULL,
  `BasisOfMeasurement` varchar(255) DEFAULT NULL,
  `PatientWeight` varchar(255) DEFAULT NULL,
  `PregnencyIndicator` varchar(255) DEFAULT NULL,
  `EntityTypeQualifier` varchar(255) DEFAULT NULL,
  `LastName` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `State` varchar(255) DEFAULT NULL,
  `PostalCode` varchar(255) DEFAULT NULL,
  `DateTimeFormatQualifier` varchar(255) DEFAULT NULL,
  `DateOfBirth` varchar(255) DEFAULT NULL,
  `Gender` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33295 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Table structure for table `claims`
--

DROP TABLE IF EXISTS `claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claims` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(75) DEFAULT NULL,
  `subscriber_id` varchar(95) DEFAULT NULL,
  `ClaimIdentifier` varchar(255) DEFAULT NULL,
  `ClaimAmount` varchar(255) DEFAULT NULL,
  `PlaceHolder1` varchar(255) DEFAULT NULL,
  `PlaceHolder2` varchar(255) DEFAULT NULL,
  `PlaceofService` varchar(255) DEFAULT NULL,
  `PlaceofServiceCode` varchar(255) DEFAULT NULL,
  `ClaimFrequencyTypeCode` varchar(255) DEFAULT NULL,
  `ProviderSignatureIndicator` varchar(255) DEFAULT NULL,
  `ProviderAcceptAssignment` varchar(255) DEFAULT NULL,
  `ProviderBenefitsAssignmentCertification` varchar(255) DEFAULT NULL,
  `ReleaseofInformationCode` varchar(255) DEFAULT NULL,
  `ClientSignatureSourceCode` varchar(255) DEFAULT NULL,
  `AutoAccidentStateCode` varchar(255) DEFAULT NULL,
  `AutoAccident` varchar(255) DEFAULT NULL,
  `Employment` varchar(255) DEFAULT NULL,
  `OtherAccident` varchar(255) DEFAULT NULL,
  `SpecialProgramCode` varchar(255) DEFAULT NULL,
  `DelayReasonCode` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `claim_date_time_period`
--

DROP TABLE IF EXISTS `claim_date_time_period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claim_date_time_period` (
  `id` int NOT NULL AUTO_INCREMENT,
  `claims_id` int DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `Qualifier` varchar(255) DEFAULT NULL,
  `Format` varchar(255) DEFAULT NULL,
  `Date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `claims_reference`
--

DROP TABLE IF EXISTS `claims_reference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claims_reference` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(75) DEFAULT NULL,
  `subscriber_id` varchar(95) DEFAULT NULL,
  `claims_id` int DEFAULT NULL,
  `ReferenceIdentificationQualifier` varchar(255) DEFAULT NULL,
  `ReferenceIdentification` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hcc_codes`
--

DROP TABLE IF EXISTS `hcc_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hcc_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(95) DEFAULT NULL,
  `subscriber_id` varchar(95) DEFAULT NULL,
  `DiagnosisCodeQualifier` varchar(255) DEFAULT NULL,
  `DiagnosisCode` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `physician`
--

DROP TABLE IF EXISTS `physician`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `physician` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(75) DEFAULT NULL,
  `subscriber_id` varchar(95) DEFAULT NULL,
  `EntityTypeQualifier` varchar(255) DEFAULT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `IdentificationCodeQualifier` varchar(255) DEFAULT NULL,
  `IdentificationCode` varchar(255) DEFAULT NULL,
  `ProviderCode` varchar(255) DEFAULT NULL,
  `ReferenceIdentificationQualifier` varchar(255) DEFAULT NULL,
  `ReferenceIdentification` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `service_facility_location`
--

DROP TABLE IF EXISTS `service_facility_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_facility_location` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(255) DEFAULT NULL,
  `EntityTypeQualifier` varchar(255) DEFAULT NULL,
  `OrganizationName` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `IdentificationCodeQualifier` varchar(255) DEFAULT NULL,
  `IdentificationCode` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `State` varchar(255) DEFAULT NULL,
  `PostalCode` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27524 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_lines`
--

DROP TABLE IF EXISTS `service_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_lines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(95) DEFAULT NULL,
  `sv2_procedure_code` varchar(255) DEFAULT NULL,
  `sv2_initial_hcpcs_code` varchar(255) DEFAULT NULL,
  `sv2_initial_amount` varchar(255) DEFAULT NULL,
  `sv2_initial_unit` varchar(255) DEFAULT NULL,
  `sv2_initial_quantity` varchar(255) DEFAULT NULL,
  `sv1_cpt_code_info` varchar(255) DEFAULT NULL,
  `sv1_charge_amount` varchar(255) DEFAULT NULL,
  `sv1_basis_for_measurement` varchar(255) DEFAULT NULL,
  `sv1_quantity` varchar(255) DEFAULT NULL,
  `sv1_facilitycode` varchar(255) DEFAULT NULL,
  `sv1_diagnosis_code_pointer` varchar(255) DEFAULT NULL,
  `initial_date_qualifier` varchar(255) DEFAULT NULL,
  `initial_date_format` varchar(255) DEFAULT NULL,
  `initial_date` varchar(255) DEFAULT NULL,
  `reference_qualifier` varchar(255) DEFAULT NULL,
  `reference_id` varchar(255) DEFAULT NULL,
  `identification_code_of_payer` varchar(255) DEFAULT NULL,
  `svd_amount` varchar(255) DEFAULT NULL,
  `svd_hcpcs_code` varchar(255) DEFAULT NULL,
  `svd_procedure_code` varchar(255) DEFAULT NULL,
  `svd_quantity` varchar(255) DEFAULT NULL,
  `reason_code` varchar(255) DEFAULT NULL,
  `claim_adjustment_monetary_amount` varchar(255) DEFAULT NULL,
  `qualifier` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `drug_identification_qualifier` varchar(255) DEFAULT NULL,
  `drug_identification_code` varchar(255) DEFAULT NULL,
  `drug_unit_count` varchar(255) DEFAULT NULL,
  `drug_unit` varchar(255) DEFAULT NULL,
  `rendering_provider_npi_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33497 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rendering_provider`
--

DROP TABLE IF EXISTS `rendering_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rendering_provider` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(95) DEFAULT NULL,
  `service_line_id` int DEFAULT NULL,
  `entity_type_qualifier` varchar(255) DEFAULT NULL,
  `entity_type` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `middle_name` varchar(255) DEFAULT NULL,
  `prefix` varchar(255) DEFAULT NULL,
  `suffix` varchar(255) DEFAULT NULL,
  `identification_code_qualifier` varchar(255) DEFAULT NULL,
  `npi_number` varchar(255) DEFAULT NULL,
  `prv_provider_code` varchar(255) DEFAULT NULL,
  `prv_reference_identification_qualifier` varchar(255) DEFAULT NULL,
  `prv_reference_identification` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33497 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `secondary_payer`
--

DROP TABLE IF EXISTS `secondary_payer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `secondary_payer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(255) DEFAULT NULL,
  `subscriber_id` varchar(75) DEFAULT NULL,
  `PayerResponsibilityCode` varchar(255) DEFAULT NULL,
  `RelationshipCode` varchar(255) DEFAULT NULL,
  `ReferralTypeCode` varchar(255) DEFAULT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `InsuranceTypeCode` varchar(255) DEFAULT NULL,
  `CoordinationBenefitCode` varchar(255) DEFAULT NULL,
  `ResponseCode` varchar(255) DEFAULT NULL,
  `QualifierCode` varchar(255) DEFAULT NULL,
  `MonetaryAmount` varchar(255) DEFAULT NULL,
  `EmploymentStatusCode` varchar(255) DEFAULT NULL,
  `ClaimFilingIndicatorCode` varchar(255) DEFAULT NULL,
  `ProviderBenefitsAssignmentCertification` varchar(255) DEFAULT NULL,
  `ReleaseofInformationCode` varchar(255) DEFAULT NULL,
  `AttachmentTypeCode` varchar(255) DEFAULT NULL,
  `AttachmentDescription` varchar(255) DEFAULT NULL,
  `AttachmentEntityIdentifierCode` varchar(255) DEFAULT NULL,
  `AttachmentIdentificationCode` varchar(255) DEFAULT NULL,
  `FreeformInformation` varchar(255) DEFAULT NULL,
  `InsuredParty` varchar(255) DEFAULT NULL,
  `LastName` varchar(255) DEFAULT NULL,
  `FirstName` varchar(255) DEFAULT NULL,
  `MiddleName` varchar(255) DEFAULT NULL,
  `Prefix` varchar(255) DEFAULT NULL,
  `Suffix` varchar(255) DEFAULT NULL,
  `IdentificationCodeQualifier` varchar(255) DEFAULT NULL,
  `IdentificationCode` varchar(255) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `City` varchar(255) DEFAULT NULL,
  `State` varchar(255) DEFAULT NULL,
  `PostalCode` varchar(255) DEFAULT NULL,
  `DateTimeFormatQualifier` varchar(255) DEFAULT NULL,
  `DateOfBirth` varchar(255) DEFAULT NULL,
  `Gender` varchar(255) DEFAULT NULL,
  `PayerName` varchar(75) DEFAULT NULL,
  `PayerId` varchar(45) DEFAULT NULL,
  `Payer_Address` varchar(245) DEFAULT NULL,
  `Payer_city` varchar(75) DEFAULT NULL,
  `Payer_State` varchar(45) DEFAULT NULL,
  `Payer_PostalCode` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33295 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;