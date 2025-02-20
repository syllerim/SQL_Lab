
SELECT
  ivd.calls_ivr_id,
  NULLIF(ivd.document_type, 'UNKNOWN') AS document_type,
  NULLIF(ivd.document_identification, 'UNKNOWN') AS document_identification
FROM `keepcoding.ivr_detail` AS ivd
QUALIFY ROW_NUMBER()
  OVER(
    PARTITION BY CAST(ivd.calls_ivr_id AS STRING) 
    ORDER BY 
      CASE
        WHEN document_type != 'UNKNOWN' AND document_identification != 'UNKNOWN' THEN 1
        WHEN document_identification != 'UNKNOWN' THEN 2
        WHEN document_type != 'UNKNOWN' THEN 3
        ELSE 4 
      END,
      ivd.module_sequece DESC, 
      ivd.step_sequence DESC
  ) = 1
ORDER BY ivd.calls_ivr_id ASC;
