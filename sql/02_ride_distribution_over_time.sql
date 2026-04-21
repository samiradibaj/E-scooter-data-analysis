----------------------------------------------------------------------
-- Q2. Ride distribution over time.
----------------------------------------------------------------------

-- 2a. By hour of day
SELECT
    START_HOUR,
    COUNT(*)          AS rides,
    SUM(PRICE)        AS revenue_eur,
    AVG(PRICE)        AS avg_price,
    AVG(RIDE_DURATION) AS avg_duration_min
FROM V_RIDES
GROUP BY 1
ORDER BY 1;

-- 2b. By day of week
SELECT
    DAY_OF_WEEK_NUM,
    DAY_ABBR,
    DAY_TYPE2,
    COUNT(*)                 AS rides,
    COUNT(DISTINCT USER_HASH) AS riders,
    SUM(PRICE)               AS revenue_eur
FROM V_RIDES
GROUP BY 1,2,3
ORDER BY 1;

-- 2c. By week of year
SELECT
    START_WEEK,
    DATE_TRUNC('week', MIN(START_TIME_LOCAL))  AS week_start,
    COUNT(*)                                    AS rides,
    COUNT(DISTINCT USER_HASH)                   AS riders,
    COUNT(DISTINCT SCOOTER_HASH)                AS scooters,
    SUM(PRICE)                                  AS revenue_eur
FROM V_RIDES
GROUP BY 1
ORDER BY 1;

-- 2d. By calendar month
SELECT
    TO_CHAR(START_TIME_LOCAL, 'YYYY-MM')       AS year_month,
    COUNT(*)                                    AS rides,
    COUNT(DISTINCT USER_HASH)                   AS riders,
    COUNT(DISTINCT SCOOTER_HASH)                AS scooters,
    SUM(PRICE)                                  AS revenue_eur,
    AVG(PRICE)                                  AS avg_price,
    AVG(RIDE_DURATION)                          AS avg_duration
FROM V_RIDES
GROUP BY 1
ORDER BY 1;

-- 2e. Hour-of-day × day-of-week heat matrix
SELECT
    START_HOUR,
    DAY_ABBR,
    COUNT(*) AS rides
FROM V_RIDES
GROUP BY 1,2
ORDER BY 1, CASE DAY_ABBR WHEN 'Mon' THEN 1 WHEN 'Tue' THEN 2 WHEN 'Wed' THEN 3
                           WHEN 'Thu' THEN 4 WHEN 'Fri' THEN 5 WHEN 'Sat' THEN 6
                           WHEN 'Sun' THEN 7 END;
