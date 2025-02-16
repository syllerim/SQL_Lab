CREATE OR REPLACE TABLE keepcoding.ivr_summary AS (
  WITH cte_client_identification AS(
    -- Ejercicio 5
    SELECT
      ivd.calls_ivr_id,
      ivd.document_type,
      ivd.document_identification
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
    ORDER BY ivd.calls_ivr_id ASC
  ),
  cte_client_phone_number AS(
    -- Ejercicio 6
    SELECT
      ivd.calls_ivr_id,
      ivd.calls_phone_number AS customer_phone,
    FROM `keepcoding.ivr_detail` AS ivd
    QUALIFY ROW_NUMBER()
      OVER(
        PARTITION BY CAST(ivd.calls_ivr_id AS STRING) 
        ORDER BY 
          IF(ivd.calls_phone_number IS NOT NULL AND ivd.calls_phone_number != 'UNKNOWN', 1, 2),
          ivd.module_sequece DESC, 
          ivd.step_sequence DESC
      ) = 1
    ORDER BY ivd.calls_ivr_id ASC
  ),
  cte_billing_account AS (
    -- Ejercicio 7
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
    ORDER BY ivd.calls_ivr_id ASC
  ),
  cte_recall_analysis AS (
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
      ORDER BY calls_phone_number, calls_ivr_id
  )
  SELECT
    ivd.calls_ivr_id AS ivr_id,
    ivd.calls_phone_number AS phone_number,
    ivd.calls_ivr_result AS ivr_result,
    CASE 
        WHEN ivd.calls_vdn_label LIKE 'ATC%' THEN 'FRONT'
        WHEN ivd.calls_vdn_label LIKE 'TECH%' THEN 'TECH'
        WHEN ivd.calls_vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
        ELSE 'RESTO'
      END AS vdn_aggregation,
    ivd.calls_start_date AS start_date,
    ivd.calls_end_date AS end_date,
    ivd.calls_total_duration AS total_duration,
    ivd.calls_customer_segment AS customer_segment,
    ivd.calls_ivr_language AS ivr_language,
    COUNT(DISTINCT ivd.module_sequece) AS steps_module,
    ARRAY_AGG(DISTINCT calls_module_aggregation) AS module_aggregation,
    cci.document_type,
    cci.document_identification,
    ccp.customer_phone,
    cba.billing_account_id,
    IF(SUM(IF(ivd.module_name = 'AVERIA_MASIVA', 1, 0)) > 0, 1, 0) AS masiva_lg,
    IF(SUM(IF(ivd.step_name = 'CUSTOMERINFOBYPHONE.TX' AND ivd.step_result = 'OK', 1, 0)) > 0, 1, 0) AS info_by_phone_lg,
    IF(SUM(IF(ivd.step_name = 'CUSTOMERINFOBYDNI.TX' AND ivd.step_result = 'OK', 1, 0)) > 0, 1, 0) AS info_by_dni_lg,
    cra.repeated_phone_24H,
    cra.cause_recall_phone_24H

  FROM `keepcoding.ivr_detail` AS ivd
  INNER JOIN cte_client_identification AS cci
  ON ivd.calls_ivr_id = cci.calls_ivr_id

  INNER JOIN cte_client_phone_number AS ccp
  ON ivd.calls_ivr_id = ccp.calls_ivr_id

  INNER JOIN cte_billing_account cba
  ON ivd.calls_ivr_id = cba.calls_ivr_id

  INNER JOIN cte_recall_analysis cra
  ON ivd.calls_ivr_id = cra.calls_ivr_id

  GROUP BY 
    ivd.calls_ivr_id, 
    ivd.calls_phone_number, 
    ivd.calls_ivr_result, 
    vdn_aggregation, 
    ivd.calls_start_date, 
    ivd.calls_end_date, 
    ivd.calls_total_duration, 
    ivd.calls_customer_segment, 
    ivd.calls_ivr_language, 
    cci.document_type, 
    cci.document_identification, 
    ccp.customer_phone, 
    cba.billing_account_id, 
    cra.repeated_phone_24H, 
    cra.cause_recall_phone_24H
  ORDER BY
    ivd.calls_ivr_id
)