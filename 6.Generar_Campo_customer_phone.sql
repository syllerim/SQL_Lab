SELECT
  ivd.calls_ivr_id,
  NULLIF(ivd.calls_phone_number, 'UNKNOWN') AS customer_phone,
FROM `keepcoding.ivr_detail` AS ivd
QUALIFY ROW_NUMBER()
  OVER(
    PARTITION BY CAST(ivd.calls_ivr_id AS STRING) 
    ORDER BY 
      IF(ivd.calls_phone_number IS NOT NULL AND ivd.calls_phone_number != 'UNKNOWN', 1, 2),
      ivd.module_sequece DESC, 
      ivd.step_sequence DESC
  ) = 1
ORDER BY ivd.calls_ivr_id ASC;
