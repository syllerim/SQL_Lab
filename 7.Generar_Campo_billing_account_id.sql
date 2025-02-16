SELECT
  ivd.calls_ivr_id,
  ivd.billing_account_id,
FROM `keepcoding.ivr_detail` AS ivd
QUALIFY ROW_NUMBER()
  OVER(
    PARTITION BY CAST(ivd.calls_ivr_id AS STRING) 
    ORDER BY 
      IF(ivd.billing_account_id IS NOT NULL AND ivd.billing_account_id != 'UNKNOWN', 1, 2),
      ivd.module_sequece DESC, 
      ivd.step_sequence DESC
  ) = 1
ORDER BY ivd.calls_ivr_id ASC;