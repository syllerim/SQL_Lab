WITH ranked_calls AS (
SELECT 
  calls_phone_number,
  calls_start_date,
    -- Obtengo la fecha de la llamada anterior
  LAG(calls_start_date) OVER (
    PARTITION BY calls_phone_number
    ORDER BY calls_start_date
  ) AS prev_calls_start_date,
  -- Obtengo la fecha de la siguiente llamada
  LEAD(calls_start_date) OVER (
    PARTITION BY calls_phone_number
    ORDER BY calls_start_date
  ) AS next_calls_start_date,
  -- Id de la llamada actual
  calls_ivr_id,
  --Id de la llamada anterior
  LAG(calls_ivr_id) OVER (
    PARTITION BY calls_phone_number 
    ORDER BY calls_start_date
  ) AS prev_calls_ivr_id,
  -- Id la siguiente llamada 
  LEAD(calls_ivr_id) OVER (
    PARTITION BY calls_phone_number
    ORDER BY calls_start_date
  ) AS next_calls_ivr_id
FROM `keepcoding.ivr_detail` 
-- WHERE calls_phone_number = '400001712'
)
SELECT 
  calls_ivr_id,
  -- calls_phone_number,
  -- calls_start_date,
  -- Flag que indica si calls_phone_number tiene una llamada las anteriores 24 horas
  MAX(
    IF(
      calls_ivr_id != prev_calls_ivr_id 
      AND prev_calls_start_date IS NOT NULL 
      AND TIMESTAMP_DIFF(calls_start_date, prev_calls_start_date, HOUR) <= 24, 1, 0)
  ) AS repeated_phone_24H,
  -- Flag que indica si calls_phone_number tiene una llamada las siguientes 24 horas
  MAX(
    IF(
      calls_ivr_id != next_calls_ivr_id 
      AND next_calls_start_date IS NOT NULL 
      AND TIMESTAMP_DIFF(next_calls_start_date, calls_start_date, HOUR) <= 24, 1, 0)
  ) AS cause_recall_phone_24H
FROM ranked_calls
GROUP BY calls_phone_number, calls_ivr_id
ORDER BY calls_phone_number, calls_ivr_id;