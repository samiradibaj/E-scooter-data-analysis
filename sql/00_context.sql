----------------------------------------------------------------------
-- CONTEXT
-- Snowflake dialect. Trip-level dataset, anonymised.
-- Data source used locally in this repo:
--   APPLICANTS.SAMIRA_D.RIDE_DATA_CLEANED  (cleaned version)
-- Columns:
--   RIDE_HASH, USER_HASH, SCOOTER_HASH,
--   START_TIME_LOCAL, END_TIME_LOCAL,
--   START_LAT, START_LONG, END_LAT, END_LONG,
--   RIDE_DURATION (minutes), TRIP_DISTANCE (km), PRICE (EUR),
--   DAY_OF_WEEK_NUM, DAY_ABBR, DAY_TYPE2 (Weekday/Weekend),
--   PREVIOUS_END_TIME, IDLE_TIME_MINUTES,
--   START_HOUR, START_WEEK, START_MONTH
-- City: Berlin (lat ~52.39–52.61, lon ~13.13–13.71)
-- Date range: 2019-06-21 to 2019-10-07
----------------------------------------------------------------------

-- Reusable base view: drop obviously trivial cancel-like rides
CREATE OR REPLACE VIEW V_RIDES AS
SELECT *
FROM   APPLICANTS.SAMIRA_D.RIDE_DATA_CLEANED
WHERE  NOT (TRIP_DISTANCE < 0.05 AND RIDE_DURATION < 2)   -- filter unlock-then-cancel
   AND RIDE_DURATION BETWEEN 0.5 AND 120;                 -- guardrails
