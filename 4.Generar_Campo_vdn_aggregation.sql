-- Verifico si todos los valores posibles de ivc.vdn_label están en mayúsculas.
-- SELECT 
--   DISTINCT ivd.calls_vdn_label
-- FROM `keepcoding.ivr_detail` AS ivd
-- WHERE ivd.calls_vdn_label != UPPER(ivd.calls_vdn_label);

-- Me gusta esta versión porque garantiza que funciona si los valores están tanto en minúsculas como en mayúsculas.
-- SELECT
--   ivd.calls_ivr_id,
--   CASE 
--     WHEN UPPER(ivd.calls_vdn_label) LIKE 'ATC%' THEN 'FRONT'
--     WHEN UPPER(ivd.calls_vdn_label) LIKE 'TECH%' THEN 'TECH'
--     WHEN UPPER(ivd.calls_vdn_label) = 'ABSORPTION' THEN 'ABSORPTION'
--     ELSE 'RESTO'
--   END AS vdn_aggregation
-- FROM `keepcoding.ivr_detail` AS ivd;

-- Pero dado que los datos ya están en mayúsculas, me evito el UPPER().
-- Si tuviese una gran cantidad de datos, mejoro rendimiento al no hacer cálculos innecesarios.
SELECT
  ivd.calls_ivr_id,
  CASE 
    WHEN ivd.calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
    WHEN ivd.calls_vdn_label LIKE 'TECH%' THEN 'TECH'
    WHEN ivd.calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
    ELSE 'RESTO'
  END AS vdn_aggregation
FROM `keepcoding.ivr_detail` AS ivd;