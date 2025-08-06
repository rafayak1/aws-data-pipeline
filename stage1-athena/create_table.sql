-- stage1-athena/create_table.sql

CREATE TABLE IF NOT EXISTS healthcare.facilities (
  facility_id string,
  facility_name string,
  employee_count int,
  services array<string>,
  location struct<address:string,city:string,state:string,zip:string>,
  labs array<struct<lab_name:string,certifications:array<string>>>,
  accreditation array<struct<accreditation_body:string,accreditation_id:string,valid_until:string>>
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'ignore.malformed.json' = 'true'
)
LOCATION 's3://'"$BUCKET"'/raw/'
TBLPROPERTIES (
  'has_encrypted_data'='false'
);