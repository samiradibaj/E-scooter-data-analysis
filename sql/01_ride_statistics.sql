----------------------------------------------------------------------
-- Q1. Ride statistics: totals, averages, costs.
----------------------------------------------------------------------

-- 1a. Headline totals & averages
SELECT
    COUNT(*)                                                   AS total_rides,
    COUNT(DISTINCT USER_HASH)                                  AS unique_riders,
    COUNT(DISTINCT SCOOTER_HASH)                               AS unique_scooters,
    SUM(PRICE)                                                 AS total_revenue_eur,
    ROUND(AVG(PRICE), 2)                                       AS avg_price_per_ride,
    ROUND(MEDIAN(PRICE), 2)                                    AS median_price_per_ride,
    ROUND(AVG(RIDE_DURATION), 2)                               AS avg_duration_min,
    ROUND(MEDIAN(RIDE_DURATION), 2)                            AS median_duration_min,
    ROUND(AVG(TRIP_DISTANCE), 3)                               AS avg_distance_km,
    ROUND(MEDIAN(TRIP_DISTANCE), 3)                            AS median_distance_km,
    ROUND(AVG(PRICE) / NULLIF(AVG(RIDE_DURATION),0), 3)        AS avg_price_per_minute_eur,
    ROUND(AVG(TRIP_DISTANCE) / NULLIF(AVG(RIDE_DURATION)/60.0,0), 2) AS avg_speed_kmh,
    ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT USER_HASH),0), 2)   AS rides_per_rider,
    ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT SCOOTER_HASH),0), 2) AS rides_per_scooter
FROM V_RIDES;

-- 1b. Same metrics split by weekday / weekend
SELECT
    DAY_TYPE2,
    COUNT(*)                                                AS rides,
    COUNT(DISTINCT USER_HASH)                               AS riders,
    ROUND(AVG(PRICE), 2)                                    AS avg_price,
    ROUND(AVG(RIDE_DURATION), 2)                            AS avg_duration,
    ROUND(AVG(TRIP_DISTANCE), 3)                            AS avg_distance,
    ROUND(SUM(PRICE), 2)                                    AS revenue
FROM V_RIDES
GROUP BY 1
ORDER BY 1;

-- 1c. Scooter utilisation: active hours per scooter over the period
WITH active AS (
    SELECT SCOOTER_HASH,
           SUM(RIDE_DURATION)/60.0 AS active_hours
    FROM V_RIDES
    GROUP BY 1
), obs_days AS (
    SELECT DATEDIFF('day', MIN(START_TIME_LOCAL), MAX(START_TIME_LOCAL)) AS d
    FROM V_RIDES
)
SELECT
    ROUND(AVG(active_hours), 1)                                       AS avg_active_hours_per_scooter,
    ROUND(MEDIAN(active_hours), 1)                                    AS median_active_hours_per_scooter,
    ROUND(AVG(active_hours) / NULLIF((SELECT d FROM obs_days),0), 2)  AS avg_active_hours_per_scooter_per_day,
    ROUND(AVG(active_hours) / (NULLIF((SELECT d FROM obs_days),0)*24.0) * 100, 2) AS avg_utilisation_pct
FROM active;
