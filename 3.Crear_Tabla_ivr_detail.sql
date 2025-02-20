CREATE OR REPLACE TABLE `keepcoding.ivr_detail` AS
SELECT
  ivc.ivr_id AS calls_ivr_id,
  ivc.phone_number AS calls_phone_number,
  ivc.ivr_result AS calls_ivr_result,
  ivc.vdn_label AS calls_vdn_label,
  ivc.start_date AS calls_start_date,
  FORMAT_TIMESTAMP('%Y%m%d', ivc.start_date) AS calls_start_date_id,
  ivc.end_date AS calls_end_date,
  FORMAT_TIMESTAMP('%Y%m%d', ivc.end_date) AS calls_end_date_id,
  ivc.total_duration AS calls_total_duration,
  ivc.customer_segment AS calls_customer_segment,
  ivc.ivr_language AS calls_ivr_language,
  ivc.steps_module AS calls_steps_module,
  ivc.module_aggregation AS calls_module_aggregation,
  ivm.module_sequece AS module_sequece,
  ivm.module_name AS module_name,
  ivm.module_duration AS module_duration,
  ivm.module_result AS module_result,
  ivs.step_sequence AS step_sequence,
  ivs.step_name AS step_name,
  ivs.step_result AS step_result,
  ivs.step_description_error AS step_description_error,
  ivs.document_type AS document_type,
  ivs.document_identification AS document_identification,
  ivs.customer_phone AS customer_phone,
  ivs.billing_account_id AS billing_account_id
FROM `keepcoding.ivr_calls` AS ivc
LEFT JOIN `keepcoding.ivr_modules` AS ivm
  ON ivc.ivr_id = ivm.ivr_id
LEFT JOIN `keepcoding.ivr_steps` AS ivs
  ON ivm.ivr_id = ivs.ivr_id
  AND ivm.module_sequece = ivs.module_sequece;
