SET @previous_year = 2022;
SET @current_year = 2023;

INSERT INTO ITAC_Analysis (HCC, HCC_Name, Weights)
SELECT HCC, HCC_Name, Weights
FROM hcc_weights;


set sql_safe_updates=0;
UPDATE ITAC_Analysis ia
JOIN `St Lukes Analysis` sla ON ia.HCC = sla.HCC
SET ia.AcuteChronic = sla.`Acute / Chronic`;


set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(*) AS HCC_Count
    FROM recap
    WHERE serviceYear = @previous_year
    GROUP BY UASI_HCC
) AS recap_counts ON ia.HCC = recap_counts.UASI_HCC
SET ia.HCC_Count_2022 = IFNULL(recap_counts.HCC_Count, 0);

set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(DISTINCT mrn) AS Distinct_Patients
    FROM recap
    WHERE serviceYear = @previous_year
    GROUP BY UASI_HCC
) AS patient_counts ON ia.HCC = patient_counts.UASI_HCC
SET ia.total_patients_2022 = IFNULL(patient_counts.Distinct_Patients, 0);


set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(*) AS HCC_Count
    FROM recap
    WHERE serviceYear = @current_year
    GROUP BY UASI_HCCv28_hccs_2023
) AS recap_counts ON ia.HCC = recap_counts.UASI_HCC
SET ia.HCC_Count_2023 = IFNULL(recap_counts.HCC_Count, 0);

set sql_safe_updates =0;
UPDATE ITAC_Analysis ia
LEFT JOIN (
    SELECT 
        UASI_HCC, 
        COUNT(DISTINCT mrn) AS Distinct_Patients
    FROM recap
    WHERE serviceYear = @current_year
    GROUP BY UASI_HCC
) AS patient_counts ON ia.HCC = patient_counts.UASI_HCC
SET ia.total_patients_2023 = IFNULL(patient_counts.Distinct_Patients, 0);


set sql_safe_updates = 0;
UPDATE rafvue.ITAC_Analysis itac
LEFT JOIN (
    SELECT
        itac.HCC AS HCC,
        itac.HCC_Name AS HCC_Name,
        COUNT(CASE WHEN FIND_IN_SET(itac.HCC, fp.recaptured_hccs) > 0 THEN 1 END) AS Patient_Count
    FROM
        rafvue.ITAC_Analysis itac
    LEFT JOIN
        rafvue.Final_Patients fp ON 1=1
    GROUP BY
        itac.HCC, itac.HCC_Name
) subquery ON itac.HCC = subquery.HCC
SET itac.total_recapture = subquery.Patient_Count;


set sql_safe_updates = 0;
UPDATE rafvue.ITAC_Analysis itac
SET itac.recapture_percentage = ((itac.total_recapture / (SELECT COUNT(*) FROM Final_Patients)) * 100);
