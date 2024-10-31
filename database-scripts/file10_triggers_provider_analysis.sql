DROP TABLE IF EXISTS `provider_analysis`;
CREATE TABLE `provider_analysis` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `npi_number` VARCHAR(255) DEFAULT NULL,
  `full_name` VARCHAR(255) DEFAULT NULL,
  `accepted_documentation` INT,
  `accepted_communication` INT,
  `not_accepted` INT,
  `no_provider_response` INT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8192 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `provider_analysis` (`npi_number`, `full_name`)
SELECT DISTINCT `npi_number`, `full_name`
FROM `rendering_provider` where npi_number is not null or full_name is not null;

DROP TRIGGER IF EXISTS update_accepted_documentation_insert;
DROP TRIGGER IF EXISTS update_accepted_documentation_update;
DROP TRIGGER IF EXISTS update_accepted_documentation_delete;

-- Triggers to create for 'Provider documentation closes query'

DELIMITER //
CREATE TRIGGER update_accepted_documentation_insert
AFTER INSERT ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.accepted_documentation = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Provider documentation closes query'
    );
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_accepted_documentation_update
AFTER UPDATE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.accepted_documentation = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Provider documentation closes query'
    );
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_accepted_documentation_delete
AFTER DELETE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.accepted_documentation = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Provider documentation closes query'
    );
END;
//

DELIMITER ;

DROP TRIGGER IF EXISTS update_accepted_communication_insert;
DROP TRIGGER IF EXISTS update_accepted_communication_update;
DROP TRIGGER IF EXISTS update_accepted_communication_delete;

DELIMITER //
CREATE TRIGGER update_accepted_communication_insert
AFTER INSERT ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.accepted_communication = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Provider communicates accepted query'
    );
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_accepted_communication_update
AFTER UPDATE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.accepted_communication = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Provider communicates accepted query'
    );
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_accepted_communication_delete
AFTER DELETE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.accepted_communication = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Provider communicates accepted query'
    );
END;
//

DELIMITER ;

DROP TRIGGER IF EXISTS update_query_not_accepted_insert;
DROP TRIGGER IF EXISTS update_query_not_accepted_update;
DROP TRIGGER IF EXISTS update_query_not_accepted_delete;


DELIMITER //
CREATE TRIGGER update_query_not_accepted_insert
AFTER INSERT ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.not_accepted = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Query not accepted'
    );
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_query_not_accepted_update
AFTER UPDATE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.not_accepted = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Query not accepted'
    );
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_query_not_accepted_delete
AFTER DELETE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.not_accepted = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'Query not accepted'
    );
END;
//

DELIMITER ;


DROP TRIGGER IF EXISTS update_no_provider_response_insert;
DROP TRIGGER IF EXISTS update_no_provider_response_update;
DROP TRIGGER IF EXISTS update_no_provider_response_delete;


DELIMITER //
CREATE TRIGGER update_no_provider_response_insert
AFTER INSERT ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.no_provider_response = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'No provider response'
    )
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_no_provider_response_update
AFTER UPDATE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.no_provider_response = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'No provider response'
    );
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER update_no_provider_response_delete
AFTER DELETE ON case_review
FOR EACH ROW
BEGIN
    UPDATE provider_analysis pa
    SET pa.no_provider_response = (
        SELECT COUNT(cr.id)
        FROM case_review cr
        WHERE pa.full_name = cr.provider
        AND cr.followup_query_outcome = 'No provider response'
    );
END;
//

DELIMITER ;

DROP TRIGGER IF EXISTS update_claim_status_insert;
DROP TRIGGER IF EXISTS update_claim_status_update;
DROP TRIGGER IF EXISTS update_claim_status_delete;

ALTER TABLE `provider_analysis`
ADD COLUMN `not_started` INT DEFAULT 0,
ADD COLUMN `in_progress` INT DEFAULT 0,
ADD COLUMN `closed` INT DEFAULT 0;



DELIMITER //
CREATE TRIGGER update_claim_status_insert
AFTER INSERT ON `case_review`
FOR EACH ROW
BEGIN
    -- Update the counts for each status in provider_analysis after insert
    UPDATE provider_analysis
    SET not_started = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'Not Started'),
        in_progress = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'In Progress'),
        closed = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'Closed');
END//
DELIMITER ;


DELIMITER //
CREATE TRIGGER update_claim_status_delete
AFTER DELETE ON `case_review`
FOR EACH ROW
BEGIN
    -- Update the counts for each status in provider_analysis after delete
    UPDATE provider_analysis
    SET not_started = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'Not Started'),
        in_progress = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'In Progress'),
        closed = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'Closed');
END//
DELIMITER ;


DELIMITER //
CREATE TRIGGER update_claim_status_update
AFTER UPDATE ON `case_review`
FOR EACH ROW
BEGIN
    -- Update the counts for each status in provider_analysis after update
    UPDATE provider_analysis
    SET not_started = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'Not Started'),
        in_progress = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'In Progress'),
        closed = (SELECT COUNT(*) FROM case_review WHERE follow_up_status = 'Closed');
END//
DELIMITER ;