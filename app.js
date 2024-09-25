// Import required modules
const express = require("express");
require('dotenv').config();

// Create an instance of Express
const app = express();

// Define routes and middleware here
// Define a simple route
app.get("/", (req, res) => {
  res.send("Hello, Express!");
});

//(require('./insert.js'));
//(require('./convert.js'));
//(require('./mysql_push.js'));
const mysql = require("mysql2/promise");
const fs = require("fs"); // For reading the JSON file

// Create a MySQL connection
const dbConfig = {
  host: "localhost",
  user: "root",
  password: process.env.database_password,
  database: "rafvue",
};

// Load JSON data from file

const dataAll = JSON.parse(
  fs.readFileSync("xl213869f8_230415_i5.837.json", "utf-8")
);

const data = dataAll.ISA.Transaction;

async function insertData() {
  const connection = await mysql.createConnection(dbConfig);
  // Insert the ISA record
  const result = await connection.execute(
    `
    INSERT INTO isa (
      AuthorizationInformationQualifier,
      AuthorizationInformation,
      SecurityInformationQualifier,
      SecurityInformation,
      InterchangeIDQualifierSender,
      InterchangeSenderID,
      InterchangeIDQualifierReceiver,
      InterchangeReceiverID,
      InterchangeDate,
      InterchangeTime,
      InterchangeControlStandardsIdentifier,
      InterchangeControlVersionNumber,
      InterchangeControlNumber,
      AcknowledgmentRequested,
      UsageIndicator,
      ComponentElementSeparator,
      FunctionalIdentifierCode,
      ApplicationSenderCode,
      ApplicationReceiverCode,
      Date,
      Time,
      GroupControlNumber,
      ResponsibleAgencyCode,
      VersionReleaseIndustryIdentifierCode
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)`,
    [
      dataAll.ISA.AuthorizationInformationQualifier || null,
      dataAll.ISA.AuthorizationInformation || null,
      dataAll.ISA.SecurityInformationQualifier || null,
      dataAll.ISA.SecurityInformation || null,
      dataAll.ISA.InterchangeIDQualifierSender || null,
      dataAll.ISA.InterchangeSenderID || null,
      dataAll.ISA.InterchangeIDQualifierReceiver || null,
      dataAll.ISA.InterchangeReceiverID || null,
      dataAll.ISA.InterchangeDate || null,
      dataAll.ISA.InterchangeTime || null,
      dataAll.ISA.InterchangeControlStandardsIdentifier || null,
      dataAll.ISA.InterchangeControlVersionNumber || null,
      dataAll.ISA.InterchangeControlNumber || null,
      dataAll.ISA.AcknowledgmentRequested || null,
      dataAll.ISA.UsageIndicator || null,
      dataAll.ISA.ComponentElementSeparator || null,
      dataAll.ISA.FunctionalIdentifierCode || null,
      dataAll.ISA.ApplicationSenderCode || null,
      dataAll.ISA.ApplicationReceiverCode || null,
      dataAll.ISA.Date || null,
      dataAll.ISA.Time || null,
      dataAll.ISA.GroupControlNumber || null,
      dataAll.ISA.ResponsibleAgencyCode || null,
      dataAll.ISA.VersionReleaseIndustryIdentifierCode || null,
    ]
  );
  const isa_id = result[0].insertId;
  console.log(`ISA inserted successfully with id ${isa_id}`);

  for (i = 0; i < data.length; i++) {
    try {
      const transaction_id = data[i].ControlNumber + isa_id;
      // Insert Transaction
      const transaction_result = await connection.execute(
        `
        INSERT INTO transaction (
          ControlNumber,
          ImplementationConventionReference,
          HierarchicalStructureCode,
          TransactionSetPurposeCode,
          ReferenceIdentification,
          Date,
          Time,
          TransactionTypeCode,
          transaction_id
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          data[i].ControlNumber || null,
          data[i].ImplementationConventionReference || null,
          data[i].HierarchicalStructureCode || null,
          data[i].TransactionSetPurposeCode || null,
          data[i].ReferenceIdentification || null,
          data[i].Date || null,
          data[i].Time || null,
          data[i].TransactionTypeCode || null,
          transaction_id || null,
        ]
      );
      console.log(
        `transaction ${i} inserted successfully with transaction id: ${transaction_id}`
      );

      //Add Subscriber
      const subscriber = data[i].Subscriber;

      var {
        PayerResponsibilityCode,
        RelationshipCode,
        ReferralTypeCode,
        Name,
        InsuranceTypeCode,
        CoordinationBenefitCode,
        ResponseCode,
        EmploymentStatusCode,
        ClaimFilingIndicatorCode,
        PatientRelationshipToInsured,
        PregnencyIndicator,
        InsuredParty,
        LastName,
        FirstName,
        MiddleName,
        Prefix,
        Suffix,
        IdentificationCodeQualifier,
        IdentificationCode,
        Address,
        City,
        State,
        PostalCode,
        DateTimeFormatQualifier,
        DateOfBirth,
        Gender,
        PayerInformation: {
          PayerName,
          PayerId,
          Address: payer_Address,
          City: payer_City,
          State: payer_State,
          PostalCode: payer_Zip,
        },
      } = subscriber;

      if (!DateOfBirth) {
        DateOfBirth = null;
      }
      if (!Gender) {
        Gender = null;
      }
      if (!DateTimeFormatQualifier) {
        DateTimeFormatQualifier = null;
      }
      if (!payer_Address) {
        payer_Address = null;
      }
      if (!payer_City) {
        payer_City = null;
      }
      if (!payer_State) {
        payer_State = null;
      }
      if (!payer_Zip) {
        payer_Zip = null;
      }

      const uniqueSubscriberID = `${FirstName}-${LastName}-${DateOfBirth}`;
      var isPatient = (subscriber.Patient !== undefined) ? 'N' : 'Y';

      // Insert data into the service_lines table
      subscriber_values = [
        transaction_id || null,
        uniqueSubscriberID || null,
        PayerResponsibilityCode || null,
        RelationshipCode || null,
        ReferralTypeCode || null,
        Name || null,
        InsuranceTypeCode || null,
        CoordinationBenefitCode || null,
        ResponseCode || null,
        EmploymentStatusCode || null,
        ClaimFilingIndicatorCode || null,
        PatientRelationshipToInsured || null,
        PregnencyIndicator || null,
        InsuredParty || null,
        LastName || null,
        FirstName || null,
        MiddleName || null,
        Prefix || null,
        Suffix || null,
        IdentificationCodeQualifier || null,
        IdentificationCode || null,
        Address || null,
        City || null,
        State || null,
        PostalCode || null,
        DateTimeFormatQualifier || null,
        DateOfBirth || null,
        Gender || null,
        PayerName || null,
        PayerId || null,
        payer_Address || null,
        payer_City || null,
        payer_State || null,
        payer_Zip || null,
        isPatient ,
      ];


      await connection.execute(
        `
          INSERT INTO subscriber (
            transaction_id,
            subscriber_id,
            PayerResponsibilityCode,
            RelationshipCode,
            ReferralTypeCode,
            Name,
            InsuranceTypeCode,
            CoordinationBenefitCode,
            ResponseCode,
            EmploymentStatusCode,
            ClaimFilingIndicatorCode,
            PatientRelationshipToInsured,
            PregnencyIndicator,
            InsuredParty,
            LastName,
            FirstName,
            MiddleName,
            Prefix,
            Suffix,
            IdentificationCodeQualifier,
            IdentificationCode,
            Address,
            City,
            State,
            PostalCode,
            DateTimeFormatQualifier,
            DateOfBirth,
            Gender,
            PayerName,
            PayerId,
            Payer_Address,
            Payer_city,
            Payer_State,
            Payer_PostalCode,
            isPatient
          ) VALUES(?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?)`,
        subscriber_values
      );

      console.log(`subscriber ${i} inserted successfully`);

      // adding patient for this subscriber
      if (subscriber.Patient !== undefined) {
        await connection.execute(
          `
            INSERT INTO patient (
              transaction_id,
              subscriber_id,
              PatientRelationshipToInsured,
              DateTimeQualifier,
              PatientDeathDate,
              BasisOfMeasurement,
              PatientWeight,
              PregnencyIndicator,
              EntityTypeQualifier,
              LastName,
              FirstName,
              MiddleName,
              Prefix,
              Suffix,
              Address,
              City,
              State,
              PostalCode,
              DateTimeFormatQualifier,
              DateOfBirth,
              Gender
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            transaction_id,
            uniqueSubscriberID,
            subscriber.Patient.PatientRelationshipToInsured || null,
            subscriber.Patient.DateTimeQualifier || null,
            subscriber.Patient.PatientDeathDate || null,
            subscriber.Patient.BasisOfMeasurement || null,
            subscriber.Patient.PatientWeight || null,
            subscriber.Patient.PregnencyIndicator || null,
            subscriber.Patient.EntityTypeQualifier || null,
            subscriber.Patient.LastName || null,
            subscriber.Patient.FirstName || null,
            subscriber.Patient.MiddleName || null,
            subscriber.Patient.Prefix || null,
            subscriber.Patient.Suffix || null,
            subscriber.Patient.Address || null,
            subscriber.Patient.City || null,
            subscriber.Patient.State || null,
            subscriber.Patient.PostalCode || null,
            subscriber.Patient.DateTimeFormatQualifier || null,
            subscriber.Patient.DateOfBirth || null,
            subscriber.Patient.Gender || null,
          ]
        );
        console.log(`subscriber patient information ${i} added successfully.`);
      }

      // Check if the connection is closed
      if (connection.state === "disconnected") {
        console.log("Connection is closed.");
      } else {
        console.log("Connection is open.");
      }

      // adding claim for this subscriber
      if (subscriber.Claims !== undefined) {
        const claim_result = await connection.execute(
          `
            INSERT INTO claims (
              transaction_id,
              subscriber_id,
              ClaimIdentifier,
              ClaimAmount,
              PlaceHolder1,
              PlaceHolder2,
              PlaceofService,
              PlaceofServiceCode,
              ClaimFrequencyTypeCode,
              ProviderSignatureIndicator,
              ProviderAcceptAssignment,
              ProviderBenefitsAssignmentCertification,
              ReleaseofInformationCode,
              ClientSignatureSourceCode,
              AutoAccidentStateCode,
              AutoAccident,
              Employment,
              OtherAccident,
              SpecialProgramCode,
              DelayReasonCode
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            transaction_id || null,
            uniqueSubscriberID || null,
            subscriber.Claims.ClaimIdentifier || null,
            subscriber.Claims.ClaimAmount || null,
            subscriber.Claims.PlaceHolder1 || null,
            subscriber.Claims.PlaceHolder2 || null,
            subscriber.Claims.PlaceofService || null,
            subscriber.Claims.PlaceofServiceCode || null,
            subscriber.Claims.ClaimFrequencyTypeCode || null,
            subscriber.Claims.ProviderSignatureIndicator || null,
            subscriber.Claims.ProviderAcceptAssignment || null,
            subscriber.Claims.ProviderBenefitsAssignmentCertification || null,
            subscriber.Claims.ReleaseofInformationCode || null,
            subscriber.Claims.ClientSignatureSourceCode || null,
            subscriber.Claims.AutoAccidentStateCode || null,
            subscriber.Claims.AutoAccident || null,
            subscriber.Claims.Employment || null,
            subscriber.Claims.OtherAccident || null,
            subscriber.Claims.SpecialProgramCode || null,
            subscriber.Claims.DelayReasonCode || null,
          ]
        );
        const claim_id = claim_result[0].insertId;
        console.log(
          `claim for transaction ${i} abd submitter_id: ${uniqueSubscriberID} with claim_id: ${claim_id} inserted successfully`
        );

        if (subscriber.Claims.DTP !== undefined) {
          for (const data of subscriber.Claims.DTP) {
            await connection.execute(
              `
              INSERT INTO claim_date_time_period (
                claims_id,
                subscriber_id,
                Qualifier,
                Format,
                Date
                ) VALUES (?, ?, ?, ?, ?)
                `,
              [
                claim_id,
                uniqueSubscriberID,
                data.Qualifier || null,
                data.Format || null,
                data.Date || null,
              ]
            );
          }
          console.log(
            `dtp for transaction ${i} and claim: ${claim_id} inserted successfully`
          );
        }

        if (subscriber.Claims.ReferenceInformation !== undefined) {
          for (const reference of subscriber.Claims.ReferenceInformation) {
            await connection.execute(
              `
              INSERT INTO claims_reference (
                transaction_id,
                subscriber_id,
                claims_id,
                ReferenceIdentificationQualifier,
                ReferenceIdentification
                ) VALUES (?, ?, ?, ?, ?)
                `,
              [
                transaction_id,
                uniqueSubscriberID,
                claim_id,
                reference.ReferenceIdentificationQualifier || null,
                reference.ReferenceIdentification || null,
              ]
            );
          }
          console.log(
            `reference information for transaction ${i} and claim: ${claim_id} inserted successfully`
          );
        }
      }

      if (subscriber.HccCodes !== undefined) {
        const HccData = subscriber.HccCodes;
        for (const item of HccData) {
          const { DiagnosisCodeQualifier, DiagnosisCode } = item;

          await connection.execute(
            "INSERT INTO hcc_codes (transaction_id, subscriber_id, DiagnosisCodeQualifier, DiagnosisCode) VALUES (?, ?, ?, ?)",
            [
              transaction_id,
              uniqueSubscriberID,
              DiagnosisCodeQualifier || null,
              DiagnosisCode || null,
            ]
          );
        }
        console.log(`HCC  for transaction ${i} data inserted successfully!`);
      }

      if (subscriber.Physician !== undefined) {
        //physician
        var physicianFirstName = subscriber.Physician.FirstName
          ? subscriber.Physician.FirstName
          : null;
        var physicianMiddleName = subscriber.Physician.MiddleName
          ? subscriber.Physician.MiddleName
          : null;
        var physicianLastName = subscriber.Physician.Name
          ? subscriber.Physician.Name
          : null;
        var physicianPrefix = subscriber.Physician.Prefix
          ? subscriber.Physician.Prefix
          : null;
        var physicianSuffix = subscriber.Physician.Suffix
          ? subscriber.Physician.Suffix
          : null;

        await connection.execute(
          `
              INSERT INTO physician (transaction_id, subscriber_id, EntityTypeQualifier, Name, FirstName, MiddleName, Prefix, Suffix, IdentificationCodeQualifier, IdentificationCode, ProviderCode, ReferenceIdentificationQualifier, ReferenceIdentification) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            transaction_id,
            uniqueSubscriberID,
            subscriber.Physician.EntityTypeQualifier || null,
            physicianLastName,
            physicianFirstName,
            physicianMiddleName,
            physicianPrefix,
            physicianSuffix,
            subscriber.Physician.IdentificationCodeQualifier || null,
            subscriber.Physician.IdentificationCode || null,
            subscriber.Physician.ProviderCode || null,
            subscriber.Physician.ReferenceIdentificationQualifier || null,
            subscriber.Physician.ReferenceIdentification || null,
          ]
        );
        console.log(
          `physician for transaction ${i} and subscriber_id: ${uniqueSubscriberID} inserted successfully`
        );
      }

      if (subscriber.ServiceFacilityLocation !== undefined) {
        await connection.execute(
          `
            INSERT INTO service_facility_location (
              transaction_id,
              subscriber_id,
              EntityTypeQualifier,
              OrganizationName,
              FirstName,
              MiddleName,
              Prefix,
              Suffix,
              IdentificationCodeQualifier,
              IdentificationCode,
              Address,
              City,
              State,
              PostalCode
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            transaction_id,
            uniqueSubscriberID,
            subscriber.ServiceFacilityLocation.EntityTypeQualifier || null,
            subscriber.ServiceFacilityLocation.OrganizationName || null,
            subscriber.ServiceFacilityLocation.FirstName || null,
            subscriber.ServiceFacilityLocation.MiddleName || null,
            subscriber.ServiceFacilityLocation.Prefix || null,
            subscriber.ServiceFacilityLocation.Suffix || null,
            subscriber.ServiceFacilityLocation.IdentificationCodeQualifier ||
              null,
            subscriber.ServiceFacilityLocation.IdentificationCode || null,
            subscriber.ServiceFacilityLocation.Address || null,
            subscriber.ServiceFacilityLocation.City || null,
            subscriber.ServiceFacilityLocation.State || null,
            subscriber.ServiceFacilityLocation.PostalCode || null,
          ]
        );
        console.log(
          `service facility for transaction ${i} and subscriber_id: ${uniqueSubscriberID} inserted successfully`
        );
      }

      if (subscriber.ServiceLines !== undefined) {
        const serviceLineData = subscriber.ServiceLines;
        for (const item of serviceLineData) {
          const {
            sv2_procedure_code,
            sv2_initial_hcpcs_code,
            sv2_initial_amount,
            sv2_initial_unit,
            sv2_initial_quantity,
            sv1_cpt_code_info,
            sv1_charge_amount,
            sv1_basis_for_measurement,
            sv1_quantity,
            sv1_facilitycode,
            sv1_diagnosis_code_pointer,
            initial_date_qualifier,
            initial_date_format,
            initial_date,
            reference_qualifier,
            reference_id,
            identification_code_of_payer,
            svd_amount,
            svd_hcpcs_code,
            svd_procedure_code,
            svd_quantity,
            reason_code,
            claim_adjustment_monetary_amount,
            qualifier,
            value,
            drug_identification_qualifier,
            drug_identification_code,
            drug_unit_count,
            drug_unit,
          } = item;

          rendering_provider_npi_number = item.rendering_provider
            ? item.rendering_provider.npi_number
            : null;

          // Insert data into the service_lines table
          const service_line_result = await connection.execute(
            `
              INSERT INTO service_lines (
                transaction_id,
                subscriber_id,
                sv2_procedure_code,
                sv2_initial_hcpcs_code,
                sv2_initial_amount,
                sv2_initial_unit,
                sv2_initial_quantity,
                sv1_cpt_code_info,
                sv1_charge_amount,
                sv1_basis_for_measurement,
                sv1_quantity,
                sv1_facilitycode,
                sv1_diagnosis_code_pointer,
                initial_date_qualifier,
                initial_date_format,
                initial_date,
                reference_qualifier,
                reference_id,
                identification_code_of_payer,
                svd_amount,
                svd_hcpcs_code,
                svd_procedure_code,
                svd_quantity,
                reason_code,
                claim_adjustment_monetary_amount,
                qualifier,
                value,
                drug_identification_qualifier,
                drug_identification_code,
                drug_unit_count,
                drug_unit,
                rendering_provider_npi_number
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ? ,?,?,?)`,
            [
              transaction_id || null,
              uniqueSubscriberID || null,
              sv2_procedure_code || null,
              sv2_initial_hcpcs_code || null,
              sv2_initial_amount || null,
              sv2_initial_unit || null,
              sv2_initial_quantity || null,
              sv1_cpt_code_info || null,
              sv1_charge_amount || null,
              sv1_basis_for_measurement || null,
              sv1_quantity || null,
              sv1_facilitycode || null,
              sv1_diagnosis_code_pointer || null,
              initial_date_qualifier || null,
              initial_date_format || null,
              initial_date || null,
              reference_qualifier || null,
              reference_id || null,
              identification_code_of_payer || null,
              svd_amount || null,
              svd_hcpcs_code || null,
              svd_procedure_code || null,
              svd_quantity || null,
              reason_code || null,
              claim_adjustment_monetary_amount || null,
              qualifier || null,
              value || null,
              drug_identification_qualifier || null,
              drug_identification_code || null,
              drug_unit_count || null,
              drug_unit || null,
              rendering_provider_npi_number || null,
            ]
          );

          const service_line_id = service_line_result[0].insertId;
          console.log(
            `Service line with id: ${service_line_id} data inserted successfully!`
          );

          if (item.rendering_provider !== undefined) {
            await connection.execute(
              `
                INSERT INTO rendering_provider (
                  transaction_id,
                  subscriber_id,
                  service_line_id,
                  entity_type_qualifier,
                  entity_type,
                  last_name,
                  first_name,
                  middle_name,
                  prefix,
                  suffix,
                  identification_code_qualifier,
                  npi_number,
                  prv_provider_code,
                  prv_reference_identification_qualifier,
                  prv_reference_identification
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                `,
              [
                transaction_id,
                uniqueSubscriberID,
                service_line_id,
                item.rendering_provider.entity_type_qualifier || null,
                item.rendering_provider.entity_type || null,
                item.rendering_provider.last_name || null,
                item.rendering_provider.first_name || null,
                item.rendering_provider.middle_name || null,
                item.rendering_provider.prefix || null,
                item.rendering_provider.suffix || null,
                item.rendering_provider.identification_code_qualifier || null,
                item.rendering_provider.npi_number || null,
                item.rendering_provider.prv_provider_code || null,
                item.rendering_provider
                  .prv_reference_identification_qualifier || null,
                item.rendering_provider.prv_reference_identification || null,
              ]
            );
          }
        }
      }

      if (data[i].SecondaryPayer !== undefined) {
        for (const payer of data[i].SecondaryPayer) {
          await connection.execute(
            `
            INSERT INTO secondary_payer (
              transaction_id,
              subscriber_id,
              PayerResponsibilityCode,
              RelationshipCode,
              ReferralTypeCode,
              Name,
              InsuranceTypeCode,
              CoordinationBenefitCode,
              ResponseCode,
              QualifierCode,
              MonetaryAmount,
              EmploymentStatusCode,
              ClaimFilingIndicatorCode,
              ProviderBenefitsAssignmentCertification,
              ReleaseofInformationCode,
              AttachmentTypeCode,
              AttachmentDescription,
              AttachmentEntityIdentifierCode,
              AttachmentIdentificationCode,
              FreeformInformation,
              InsuredParty,
              LastName,
              FirstName,
              MiddleName,
              Prefix,
              Suffix,
              IdentificationCodeQualifier,
              IdentificationCode,
              Address,
              City,
              State,
              PostalCode,
              DateTimeFormatQualifier,
              DateOfBirth,
              Gender,
              PayerName,
              PayerId,
              Payer_Address,
              Payer_city,
              Payer_State,
              Payer_PostalCode
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            `,
            [
              transaction_id,
              uniqueSubscriberID,
              payer.RelationshipCode || null,
              payer.PayerResponsibilityCode || null,
              payer.ReferralTypeCode || null,
              payer.Name || null,
              payer.InsuranceTypeCode || null,
              payer.CoordinationBenefitCode || null,
              payer.ResponseCode || null,
              payer.QualifierCode || null,
              payer.MonetaryAmount || null,
              payer.EmploymentStatusCode || null,
              payer.ClaimFilingIndicatorCode || null,
              payer.ProviderBenefitsAssignmentCertification || null,
              payer.ReleaseofInformationCode || null,
              payer.AttachmentTypeCode || null,
              payer.AttachmentDescription || null,
              payer.AttachmentEntityIdentifierCode || null,
              payer.AttachmentIdentificationCode || null,
              payer.FreeformInformation || null,
              payer.InsuredParty || null,
              payer.LastName || null,
              payer.FirstName || null,
              payer.MiddleName || null,
              payer.Prefix || null,
              payer.Suffix || null,
              payer.IdentificationCodeQualifier || null,
              payer.IdentificationCode || null,
              payer.Address || null,
              payer.City || null,
              payer.State || null,
              payer.PostalCode || null,
              payer.DateTimeFormatQualifier || null,
              payer.DateOfBirth || null,
              payer.Gender || null,
              payer.PayerInformation.PayerName || null,
              payer.PayerInformation.PayerId || null,
              payer.PayerInformation.Address || null,
              payer.PayerInformation.city || null,
              payer.PayerInformation.State || null,
              payer.PayerInformation.PostalCode || null,
            ]
          );
        }
      }

            //Add the submitter
            await connection.execute(
              `
              INSERT INTO submitter (
                transaction_id,
                subscriber_id,
                EntityTypeQualifier,
                OrganizationName,
                FirstName,
                MiddleName,
                Prefix,
                Suffix,
                IdentificationCodeQualifier,
                IdentificationCode,
                CommunicationContact,
                TelephoneNumber,
                FaxNumber,
                Email  
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?)`,
              [
                transaction_id || null,
                uniqueSubscriberID,
                data[i].Submitter.EntityTypeQualifier || null,
                data[i].Submitter.OrganizationName || null,
                data[i].Submitter.FirstName || null,
                data[i].Submitter.MiddleName || null,
                data[i].Submitter.Prefix || null,
                data[i].Submitter.Suffix || null,
                data[i].Submitter.IdentificationCodeQualifier || null,
                data[i].Submitter.IdentificationCode || null,
                data[i].Submitter.CommunicationContact || null,
                data[i].Submitter.TelephoneNumber || null,
                data[i].Submitter.FaxNumber || null,
                data[i].Submitter.Email || null,
              ]
            );
      
            console.log(`submitter ${i} inserted successfully`);
      
            //Add the receiver
            await connection.execute(
              `
              INSERT INTO receiver (
                transaction_id,
                subscriber_id,
                EntityTypeQualifier,
                OrganizationName,
                FirstName,
                MiddleName,
                Prefix,
                Suffix,
                IdentificationCodeQualifier,
                IdentificationCode
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
              [
                transaction_id || null,
                uniqueSubscriberID,
                data[i].Receiver.EntityTypeQualifier || null,
                data[i].Receiver.OrganizationName || null,
                data[i].Receiver.FirstName || null,
                data[i].Receiver.MiddleName || null,
                data[i].Receiver.Prefix || null,
                data[i].Receiver.Suffix || null,
                data[i].Receiver.IdentificationCodeQualifier || null,
                data[i].Receiver.IdentificationCode || null,
              ]
            );
      
            console.log(`receiver ${i} inserted successfully`);
      
            const billing_provider_result = await connection.execute(
              `
              INSERT INTO billing_provider (
                transaction_id,
                subscriber_id,
                EntityTypeQualifier,
                ProviderCode,
                ReferenceIdentificationQualifier,
                ReferenceIdentification,
                OrganizationName,
                FirstName,
                MiddleName,
                Prefix,
                Suffix,
                IdentificationCodeQualifier,
                IdentificationCode,
                Address,
                City,
                State,
                PostalCode,
                ReferenceCodeQualifier,
                ReferenceCode,
                CommunicationContact,
                Telephone,
                FaxNumber,
                Email
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
              [
                transaction_id,
                uniqueSubscriberID,
                data[i].BillingProvider.EntityTypeQualifier || null,
                data[i].BillingProvider.ProviderCode || null,
                data[i].BillingProvider.ReferenceIdentificationQualifier || null,
                data[i].BillingProvider.ReferenceIdentification || null,
                data[i].BillingProvider.OrganizationName || null,
                data[i].BillingProvider.FirstName || null,
                data[i].BillingProvider.MiddleName || null,
                data[i].BillingProvider.Prefix || null,
                data[i].BillingProvider.Suffix || null,
                data[i].BillingProvider.IdentificationCodeQualifier || null,
                data[i].BillingProvider.IdentificationCode || null,
                data[i].BillingProvider.Address || null,
                data[i].BillingProvider.City || null,
                data[i].BillingProvider.State || null,
                data[i].BillingProvider.PostalCode || null,
                data[i].BillingProvider.ReferenceCodeQualifier || null,
                data[i].BillingProvider.ReferenceCode || null,
                data[i].BillingProvider.CommunicationContact || null,
                data[i].BillingProvider.Telephone || null,
                data[i].BillingProvider.FaxNumber || null,
                data[i].BillingProvider.Email || null,
              ]
            );
            const billing_provider_id = billing_provider_result[0].insertId;
            console.log(
              `billing provider ${i} with id: ${billing_provider_id} inserted successfully`
            );
      
            //Add pay to address
            await connection.execute(
              `
              INSERT INTO pay_to_address (
                transaction_id,
                subscriber_id,
                billing_provider_id,
                EntityType,
                Address,
                City,
                State,
                PostalCode
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
              [
                transaction_id,
                uniqueSubscriberID,
                billing_provider_id,
                data[i].BillingProvider.PayToAddress.EntityType || null,
                data[i].BillingProvider.PayToAddress.Address || null,
                data[i].BillingProvider.PayToAddress.City || null,
                data[i].BillingProvider.PayToAddress.State || null,
                data[i].BillingProvider.PayToAddress.PostalCode || null,
              ]
            );
            console.log(`pay to address ${i} inserted successfully`);

      console.log(`subscriber data for transaction ${i} inserted successfully`);
    } catch (error) {
      console.log(error);
    }
  }
}

insertData();

// Start the Express server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
