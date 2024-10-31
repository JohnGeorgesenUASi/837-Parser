

DROP TABLE IF EXISTS demo_rafvue.provider_report;
CREATE TABLE demo_rafvue.provider_report AS
SELECT 
    rp.npi_number, 
    rp.full_name,  
    speciality.provider_taxonomy_code, 
    speciality.speciality, 
    COUNT(distinct fp.mrn) as mrn_count,
    ROUND(AVG(fp.raf_2023), 3) as avg_raf_score,
    ROUND(AVG(CASE WHEN fp.recaptured_hccs IS NOT NULL THEN fp.potential_raf_2023 ELSE NULL END), 3) as avg_potential_raf_2023,
    ROUND(AVG(fp.raf_variance), 3) as avg_variance
FROM 
    rafvue.rendering_provider as rp 
LEFT JOIN 
    rafvue.speciality 
    ON rp.prv_reference_identification = speciality.provider_taxonomy_code 
LEFT JOIN 
    Final_Patients fp 
    ON rp.mrn = fp.mrn
WHERE 
    rp.npi_number IS NOT NULL
GROUP BY 
    rp.npi_number;

