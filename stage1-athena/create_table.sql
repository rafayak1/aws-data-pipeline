CREATE EXTERNAL TABLE IF NOT EXISTS healthcare.facilities (
  facility_id STRING,
  facility_name STRING,
  employee_count INT,
  services ARRAY<STRING>,
  location STRUCT<address:STRING,city:STRING,state:STRING,zip:STRING>,
  labs ARRAY<STRUCT<lab_name:STRING,certifications:ARRAY<STRING>>>,
  accreditation ARRAY<STRUCT<accreditation_body:STRING,accreditation_id:STRING,valid_until:STRING>>
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'ignore.malformed.json'='true'
)
LOCATION 's3://'"$BUCKET"'/raw/'
TBLPROPERTIES ('has_encrypted_data'='false');