# Update Reviewer Count for sna.users

SET SQL_SAFE_UPDATES =0;
UPDATE sna.users SET review_counts = 0;

#Final Patients
SET SQL_SAFE_UPDATES =0;
UPDATE Final_Patients
SET 
  Reviewer = NULL,
  additional_notes = NULL,
  edit_date = NULL,
  user_id = NULL,
  user_name = NULL,
  case_status = NULL,
  closed_by_username = NULL,
  closed_date = NULL,
  closed_by_user_id = NULL,
  quality_reviewer = NULL,
  quality_reviewer_id = NULL,
  quality_review_date = NULL,
  quality_reviewer_completed = NULL,
  quality_reviewer_assigned_date = NULL,
  reviewer_assigned_date = NULL,
  qr_status = NULL,
  follow_up_date = NULL,
  follow_up_status = NULL,
  follow_up = NULL,
  follow_up_status_edit_date = NULL,
  follow_up_status_notes = NULL,
  follow_up_completed_date = NULL,
  reviewer_id = NULL,
  selected_criteria_name = NULL,
  potential_raf_interaction_2023 = NULL,
  potential_raf_hierarchy_2023 = NULL,
  potential_raf_2023 = NULL,
  potential_raf_hierarchy_2022 = NULL,
  potential_raf_interaction_2022 = NULL,
  potential_raf_2022 = NULL,
  post_hcc_count = NULL,
  hccs_open = NULL,
  last_review_date = NULL;


#Patient Diagnosis
SET SQL_SAFE_UPDATES =0;

UPDATE patient_diagnosis
SET status = NULL,
    edit_date = NULL,
    user_id = NULL,
    user_name = NULL,
    qr_approved = NULL,
    follow_up_status = NULL,
    follow_up_status_edit_date = NULL,
    follow_up_status_notes = NULL,
    review_status = NULL,
    verify_status = NULL;


# Patient ICD10 Status
SET SQL_SAFE_UPDATES =0;

UPDATE patients_icd10_status
SET reviewer_activity = NULL,
    case_action = NULL,
    reason = NULL,
    icd_10 = NULL,
    follow_up = NULL,
    qr_status = NULL,
    qr_action = NULL,
    qr_reason = NULL,
    qr_icd10 = NULL,
   `qr_follow-up` = NULL,
    rationale = NULL;


# Case Review
SET SQL_SAFE_UPDATES =0;
DELETE  from case_review;

# Follow - Up
SET SQL_SAFE_UPDATES =0;
DELETE  from follow_up;


# PY_HCC table
SET SQL_SAFE_UPDATES =0;
UPDATE hcc_2022
SET post_review_icd = NULL,
    post_review_hcc = NULL,
    post_review_category = NULL,
    post_review_weight = NULL,
    post_review_acute_chronic = NULL;

# CY_HCC table
SET SQL_SAFE_UPDATES =0;
UPDATE hcc_2023
SET post_review_icd = NULL,
    post_review_hcc = NULL,
    post_review_category = NULL,
    post_review_weight = NULL,
    post_review_acute_chronic = NULL;
    
# CY_HCC table
SET SQL_SAFE_UPDATES =0;
UPDATE Final_Patients
SET hccs_open = total_hcc;



