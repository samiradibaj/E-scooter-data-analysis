----------------------------------------------------------------------
-- Q3. Rolling averages (weekly and monthly).
----------------------------------------------------------------------

-- 3a. Daily series with 7-day and 28-day rolling averages (rides, revenue, unique riders)
WITH daily AS (
    SELECT
        DATE(START_TIME_LOCAL)        AS ride_date,
        COUNT(*)                      AS rides,
        COUNT(DISTINCT USER_HASH)     AS riders,
        COUNT(DISTINCT SCOOTER_HASH)  AS scooters,
        SUM(PRICE)                    AS revenue_eur,
        AVG(PRICE)                    AS avg_price,
        AVG(RIDE_DURATION)            AS avg_duration
    FROM V_RIDES
    GROUP BY 1
)
SELECT
    ride_date,
    rides,
    riders,
    scooters,
    revenue_eur,
    avg_price,
    avg_duration,
    AVG(rides)       OVER (ORDER BY ride_date ROWS BETWEEN 6  PRECEDING AND CURRENT ROW) AS rides_ma_7d,
    AVG(rides)       OVER (ORDER BY ride_date ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) AS rides_ma_28d,
    AVG(revenue_eur) OVER (ORDER BY ride_date ROWS BETWEEN 6  PRECEDING AND CURRENT ROW) AS revenue_ma_7d,
    AVG(revenue_eur) OVER (ORDER BY ride_date ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) AS revenue_ma_28d,
    AVG(riders)      OVER (ORDER BY ride_date ROWS BETWEEN 6  PRECEDING AND CURRENT ROW) AS riders_ma_7d,
    AVG(avg_price)   OVER (ORDER BY ride_date ROWS BETWEEN 6  PRECEDING AND CURRENT ROW) AS avg_price_ma_7d,
    AVG(avg_duration)OVER (ORDER BY ride_date ROWS BETWEEN 6  PRECEDING AND CURRENT ROW) AS avg_duration_ma_7d
FROM daily
ORDER BY ride_date;

-- 3b. Weekly aggregates with 4-week rolling average
WITH weekly AS (
    SELECT
        DATE_TRUNC('week', START_TIME_LOCAL) AS week_start,
        COUNT(*)                              AS rides,
        COUNT(DISTINCT USER_HASH)             AS riders,
        SUM(PRICE)                            AS revenue_eur,
        AVG(PRICE)                            AS avg_price
    FROM V_RIDES
    GROUP BY 1
)
SELECT
    week_start,
    rides,
    riders,
    revenue_eur,
    avg_price,
    AVG(rides)       OVER (ORDER BY week_start ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS rides_ma_4w,
    AVG(revenue_eur) OVER (ORDER BY week_start ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS revenue_ma_4w,
    AVG(riders)      OVER (ORDER BY week_start ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS riders_ma_4w
FROM weekly
ORDER BY week_start;

-- 3c. Monthly aggregates with 3-month rolling average
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', START_TIME_LOCAL) AS month_start,
        COUNT(*)                               AS rides,
        COUNT(DISTINCT USER_HASH)              AS riders,
        SUM(PRICE)                             AS revenue_eur
    FROM V_RIDES
    GROUP BY 1
)
SELECT
    month_start,
    rides,
    riders,
    revenue_eur,
    AVG(rides)       OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rides_ma_3m,
    AVG(revenue_eur) OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS revenue_ma_3m
FROM monthly
ORDER BY month_start;
