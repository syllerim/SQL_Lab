-- Version con query temporal ayuda a que sea mas legible
WITH ivr_detail_flag AS (
  SELECT
    ivd.calls_ivr_id,
    IF(ivd.module_name = 'AVERIA_MASIVA', 1, 0) AS flag_massive_breakdown
  FROM `keepcoding.ivr_detail` AS ivd
)
SELECT
  calls_ivr_id,
  IF(SUM(flag_massive_breakdown) > 0, 1, 0) AS masiva_lg
FROM ivr_detail_flag
GROUP BY calls_ivr_id
ORDER BY calls_ivr_id;

-- Version sin usar query temporal
SELECT
  ivd.calls_ivr_id,
  IF(SUM(IF(ivd.module_name = 'AVERIA_MASIVA', 1, 0)) > 0, 1, 0) AS masiva_lg
FROM `keepcoding.ivr_detail` AS ivd
GROUP BY ivd.calls_ivr_id
ORDER BY ivd.calls_ivr_id ASC;