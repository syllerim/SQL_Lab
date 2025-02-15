-- Version con tabla temporal.
WITH ivr_detail_flag AS (
  SELECT
    ivd.calls_ivr_id,
    IF(ivd.step_name = 'CUSTOMERINFOBYDNI.TX' AND ivd.step_result = 'OK', 1, 0) AS info_by_dni
  FROM `keepcoding.ivr_detail` AS ivd
)
SELECT
  calls_ivr_id,
  IF(SUM(info_by_dni) > 0, 1, 0) AS info_by_dni_lg
FROM ivr_detail_flag
GROUP BY calls_ivr_id
ORDER BY calls_ivr_id ASC;

-- Version sin tabla temporal.
SELECT
  ivd.calls_ivr_id,
  IF(SUM(IF(ivd.step_name = 'CUSTOMERINFOBYDNI.TX' AND ivd.step_result = 'OK', 1, 0)) > 0, 1, 0) AS info_by_dni_lg
FROM `keepcoding.ivr_detail` AS ivd
GROUP BY ivd.calls_ivr_id 
ORDER BY ivd.calls_ivr_id ASC;