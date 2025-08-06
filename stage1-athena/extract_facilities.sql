-- Extract facility metadata plus earliest accreditation expiry date
WITH accreditation_dates AS (
  SELECT
    facility_id,
    facility_name,
    employee_count,
    cardinality(services) AS number_of_offered_services,
    date_parse(min(valid_until), '%Y-%m-%d') AS expiry_date_of_first_accreditation
  FROM healthcare.facilities
  CROSS JOIN UNNEST(accreditation) AS t(valid_until)
  GROUP BY facility_id, facility_name, employee_count
)
SELECT *
FROM accreditation_dates
ORDER BY facility_id;