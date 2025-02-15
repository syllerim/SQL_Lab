SELECT
  ivd.calls_ivr_id,
  ivd.calls_phone_number AS customer_phone,
FROM `keepcoding.ivr_detail` AS ivd
WHERE 
  ivd.calls_phone_number IS NOT NULL
  AND ivd.calls_phone_number != 'UNKNOWN'
QUALIFY ROW_NUMBER()
  OVER(
    PARTITION BY CAST(ivd.calls_ivr_id AS STRING) 
    ORDER BY ivd.module_sequece DESC, ivd.step_sequence DESC
  ) = 1
ORDER BY ivd.calls_ivr_id ASC;