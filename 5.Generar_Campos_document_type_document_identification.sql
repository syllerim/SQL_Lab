-- Usando ROW_NUMBER y una query temporal
-- WITH ivr_clients_identified AS (
--   SELECT
--     ROW_NUMBER() OVER(
--       PARTITION BY CAST(ivd.calls_ivr_id AS STRING) 
--       ORDER BY ivd.module_sequece DESC, ivd.step_sequence DESC
--     ) AS rn,
--     ivd.calls_ivr_id,
--     ivd.document_type,
--     ivd.document_identification
--   FROM `keepcoding.ivr_detail` AS ivd
--   WHERE 
--     ivd.document_type IS NOT NULL
--     AND ivd.document_type != 'UNKNOWN'
--     AND ivd.document_identification IS NOT NULL 
--     AND ivd.document_identification != 'UNKNOWN'
-- )
-- SELECT 
--     calls_ivr_id,
--     document_type,
--     document_identification
-- FROM ivr_clients_identified
-- WHERE rn = 1
-- ORDER BY calls_ivr_id;

-- Prefiero usar QUALIFY ROW_NUMBER() que es mas óptimo
SELECT
  ivd.calls_ivr_id,
  ivd.document_type,
  ivd.document_identification
FROM `keepcoding.ivr_detail` AS ivd
WHERE 
  ivd.document_type IS NOT NULL
  AND ivd.document_type != 'UNKNOWN'
  AND ivd.document_identification IS NOT NULL 
  AND ivd.document_identification != 'UNKNOWN'
QUALIFY ROW_NUMBER()
  OVER(
    PARTITION BY CAST(ivd.calls_ivr_id AS STRING) 
    ORDER BY ivd.module_sequece DESC, ivd.step_sequence DESC
  ) = 1
ORDER BY ivd.calls_ivr_id ASC;