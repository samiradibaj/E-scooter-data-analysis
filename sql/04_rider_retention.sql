----------------------------------------------------------------------
-- Q4. Retention: % of riders returning for 2nd, 3rd, ... N-th ride
--     plus acquisition-month cohort curves.
----------------------------------------------------------------------

-- 4a. Share of riders who complete at least N rides (N = 1..20)
WITH per_user AS (
    SELECT USER_HASH, COUNT(*) AS n_rides
    FROM V_RIDES
    GROUP BY 1
), total AS (
    SELECT COUNT(*)::FLOAT AS total_riders FROM per_user
)
SELECT
    n                                                     AS ride_number,
    SUM(CASE WHEN n_rides >= n THEN 1 ELSE 0 END)         AS riders_reaching_n,
    ROUND(SUM(CASE WHEN n_rides >= n THEN 1 ELSE 0 END)
          / (SELECT total_riders FROM total) * 100, 2)    AS pct_of_riders
FROM per_user
CROSS JOIN (SELECT COLUMN1 AS n FROM VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(15),(20))
GROUP BY n
ORDER BY n;

-- 4b. Ride-to-ride step-down (P[n+1 | n])
WITH per_user AS (
    SELECT USER_HASH, COUNT(*) AS n_rides FROM V_RIDES GROUP BY 1
), reached AS (
    SELECT n AS ride_number,
           SUM(CASE WHEN n_rides >= n THEN 1 ELSE 0 END) AS reached
    FROM per_user
    CROSS JOIN (SELECT COLUMN1 AS n FROM VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10))
    GROUP BY n
)
SELECT
    a.ride_number,
    a.reached,
    b.reached AS next_reached,
    ROUND(b.reached::FLOAT / NULLIF(a.reached,0) * 100, 2) AS step_conversion_pct
FROM reached a
LEFT JOIN reached b ON b.ride_number = a.ride_number + 1
ORDER BY a.ride_number;

-- 4c. Weekly cohort retention matrix (by acquisition month)
WITH first_ride AS (
    SELECT USER_HASH,
           MIN(START_TIME_LOCAL) AS first_ts
    FROM V_RIDES
    GROUP BY 1
), labelled AS (
    SELECT r.USER_HASH,
           TO_CHAR(f.first_ts, 'YYYY-MM')                              AS cohort_month,
           DATEDIFF('week', DATE_TRUNC('week', f.first_ts),
                           DATE_TRUNC('week', r.START_TIME_LOCAL))     AS weeks_since_first
    FROM V_RIDES r
    JOIN first_ride f ON r.USER_HASH = f.USER_HASH
)
SELECT cohort_month,
       weeks_since_first,
       COUNT(DISTINCT USER_HASH) AS active_riders
FROM labelled
WHERE weeks_since_first BETWEEN 0 AND 12
GROUP BY 1,2
ORDER BY 1,2;

-- 4d. Observed revenue per user by acquisition month
--    (careful interpretation: later cohorts have shorter windows to accumulate value)
WITH first_ride AS (
    SELECT USER_HASH,
           MIN(START_TIME_LOCAL) AS first_ts
    FROM V_RIDES
    GROUP BY 1
)
SELECT
    TO_CHAR(f.first_ts, 'YYYY-MM')                   AS cohort_month,
    COUNT(DISTINCT r.USER_HASH)                      AS riders,
    SUM(r.PRICE)                                     AS cohort_revenue,
    ROUND(SUM(r.PRICE) / COUNT(DISTINCT r.USER_HASH), 2) AS avg_observed_revenue_per_user,
    ROUND(AVG(DATEDIFF('day', f.first_ts, r.START_TIME_LOCAL)), 1)  AS avg_recency_days
FROM V_RIDES r
JOIN first_ride f USING (USER_HASH)
GROUP BY 1
ORDER BY 1;
