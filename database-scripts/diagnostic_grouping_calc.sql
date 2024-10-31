-- calculation for v24
set sql_safe_updates =0;
UPDATE diagnostic_grouping dg
SET dg.total_2022_v24 = (
    SELECT 
        COUNT(DISTINCT p.mrn)
		FROM post_raf_score p WHERE FIND_IN_SET(p.UASI_HCC, REPLACE(dg.hcc_v24, ' ', '')) > 0 AND p.serviceYear = 2022
);

SET sql_safe_updates = 0;
SET @total_sum = (SELECT SUM(total_2022_v24) FROM diagnostic_grouping);

UPDATE diagnostic_grouping dg
SET dg.percent_2022_v24 = (dg.total_2022_v24 / @total_sum) * 100;

set sql_safe_updates =0;
UPDATE diagnostic_grouping dg
SET dg.total_2023_v24 = (
    SELECT 
        COUNT(DISTINCT p.mrn)
		FROM post_raf_score p WHERE FIND_IN_SET(p.UASI_HCC, REPLACE(dg.hcc_v24, ' ', '')) > 0 AND p.serviceYear = 2023
);

SET sql_safe_updates = 0;
SET @sum_2023_v24 = (SELECT SUM(total_2023_v24) FROM diagnostic_grouping);

UPDATE diagnostic_grouping dg
SET dg.percent_2023_v24 = (dg.total_2023_v24 / @sum_2023_v24) * 100;

-- calculation for v28
set sql_safe_updates =0;
UPDATE diagnostic_grouping dg
SET dg.total_2022_v28 = (
    SELECT 
        COUNT(DISTINCT p.mrn)
		FROM post_raf_score p WHERE FIND_IN_SET(p.UASI_HCC, REPLACE(dg.hcc_v28, ' ', '')) > 0 AND p.serviceYear = 2022
);

SET sql_safe_updates = 0;
SET @total_sum = (SELECT SUM(total_2022_v28) FROM diagnostic_grouping);

UPDATE diagnostic_grouping dg
SET dg.percent_2022_v28 = (dg.total_2022_v28 / @total_sum) * 100;

set sql_safe_updates =0;
UPDATE diagnostic_grouping dg
SET dg.total_2023_v28 = (
    SELECT 
        COUNT(DISTINCT p.mrn)
		FROM post_raf_score p WHERE FIND_IN_SET(p.UASI_HCC, REPLACE(dg.hcc_v28, ' ', '')) > 0 AND p.serviceYear = 2023
);

SET sql_safe_updates = 0;
SET @sum_2023_v28 = (SELECT SUM(total_2023_v28) FROM diagnostic_grouping);

UPDATE diagnostic_grouping dg
SET dg.percent_2023_v28 = (dg.total_2023_v28 / @sum_2023_v28) * 100;

