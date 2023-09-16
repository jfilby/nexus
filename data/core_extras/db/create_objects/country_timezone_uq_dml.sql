REM Nexus generated DML file

ALTER TABLE country_timezone
  ADD CONSTRAINT country_timezone_uq_1 UNIQUE (country_code, timezone);

