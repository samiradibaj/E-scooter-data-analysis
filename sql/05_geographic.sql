----------------------------------------------------------------------
-- Q5. Geographic analysis.
-- Strategy: bin start/end locations to a 0.005° grid (~350m × 550m at Berlin latitude).
--           Compute demand (starts), supply availability (ends), and net flow per cell.
--           Also compute an H3-like origin/destination flow.
----------------------------------------------------------------------

-- 5a. Start-location density (demand)
SELECT
    ROUND(START_LAT / 0.005)  * 0.005  AS lat_bin,
    ROUND(START_LONG / 0.005) * 0.005  AS lon_bin,
    COUNT(*)                            AS starts,
    COUNT(DISTINCT SCOOTER_HASH)        AS unique_scooters,
    COUNT(DISTINCT USER_HASH)           AS unique_riders,
    SUM(PRICE)                          AS revenue_eur,
    AVG(PRICE)                          AS avg_price,
    AVG(RIDE_DURATION)                  AS avg_duration
FROM V_RIDES
GROUP BY 1,2
ORDER BY starts DESC;

-- 5b. End-location density (supply availability / re-balancing opportunities)
SELECT
    ROUND(END_LAT / 0.005)  * 0.005   AS lat_bin,
    ROUND(END_LONG / 0.005) * 0.005   AS lon_bin,
    COUNT(*)                           AS ends
FROM V_RIDES
GROUP BY 1,2
ORDER BY ends DESC;

-- 5c. Net flow per cell (ends − starts). Positive ⇒ supply accumulates; negative ⇒ depletion.
WITH starts AS (
    SELECT ROUND(START_LAT / 0.005) * 0.005 AS lat_bin,
           ROUND(START_LONG / 0.005) * 0.005 AS lon_bin,
           COUNT(*) AS starts
    FROM V_RIDES GROUP BY 1,2
), ends AS (
    SELECT ROUND(END_LAT / 0.005) * 0.005 AS lat_bin,
           ROUND(END_LONG / 0.005) * 0.005 AS lon_bin,
           COUNT(*) AS ends
    FROM V_RIDES GROUP BY 1,2
)
SELECT
    COALESCE(s.lat_bin, e.lat_bin) AS lat_bin,
    COALESCE(s.lon_bin, e.lon_bin) AS lon_bin,
    COALESCE(s.starts, 0)          AS starts,
    COALESCE(e.ends,   0)          AS ends,
    COALESCE(e.ends,0) - COALESCE(s.starts,0) AS net_flow
FROM starts s
FULL OUTER JOIN ends e USING (lat_bin, lon_bin)
ORDER BY ABS(net_flow) DESC;

-- 5d. Top origin→destination cell flows (aggregated OD matrix)
SELECT
    ROUND(START_LAT / 0.005)  * 0.005  AS o_lat,
    ROUND(START_LONG / 0.005) * 0.005  AS o_lon,
    ROUND(END_LAT   / 0.005)  * 0.005  AS d_lat,
    ROUND(END_LONG  / 0.005)  * 0.005  AS d_lon,
    COUNT(*)                            AS trips,
    AVG(TRIP_DISTANCE)                  AS avg_distance_km,
    AVG(RIDE_DURATION)                  AS avg_duration_min
FROM V_RIDES
GROUP BY 1,2,3,4
HAVING COUNT(*) >= 20
ORDER BY trips DESC
LIMIT 200;

-- 5e. Average idle time to next ride by cell (redeploy candidate areas)
SELECT
    ROUND(START_LAT / 0.005)  * 0.005 AS lat_bin,
    ROUND(START_LONG / 0.005) * 0.005 AS lon_bin,
    COUNT(*) AS starts,
    AVG(IDLE_TIME_MINUTES) AS avg_idle_min,
    MEDIAN(IDLE_TIME_MINUTES) AS median_idle_min
FROM V_RIDES
WHERE IDLE_TIME_MINUTES IS NOT NULL
GROUP BY 1,2
HAVING COUNT(*) >= 50
ORDER BY median_idle_min DESC;
