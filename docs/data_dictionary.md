# Data dictionary

Each row of the source table is one completed e-scooter ride.

| Column | Type | Description |
| --- | --- | --- |
| RIDE_ID | string | Unique ride identifier |
| USER_HASH | string | Hashed rider id |
| SCOOTER_HASH | string | Hashed scooter id |
| START_TIME_LOCAL | timestamp | Ride start, local time (Berlin) |
| END_TIME_LOCAL | timestamp | Ride end, local time (Berlin) |
| RIDE_DURATION | float | Duration in minutes |
| TRIP_DISTANCE | float | Trip distance in km |
| START_LAT, START_LONG | float | Start coordinates |
| END_LAT, END_LONG | float | End coordinates |
| PRICE | float | Price paid in EUR |
| IDLE_TIME_MINUTES | float | Minutes since the scooter's previous ride ended (NULL on first observed ride) |
| START_HOUR | int | Hour of day (0-23) |
| START_WEEK | int | ISO week of year |
| DAY_OF_WEEK_NUM | int | 1 = Monday ... 7 = Sunday |
| DAY_ABBR | string | Mon / Tue / Wed ... |
| DAY_TYPE2 | string | 'weekday' / 'weekend' |

## Cleaning rules applied in V_RIDES

- Drop rows where distance < 0.05 km AND duration < 2 min (cancel-like).
- Drop rows with null timestamps or null coordinates.
- Clip start coordinates to Berlin bounding box (52.39-52.61 lat, 13.13-13.71 lon) for geospatial cuts.

## Known caveats

- Dataset covers one summer season (21 Jun - 07 Oct 2019, ~16 weeks).
- Later acquisition cohorts have fewer observation weeks; any LTV comparison across cohorts must be aligned to a common N-week window.
- Fleet size is treated as the number of distinct scooters observed in the period. If the operator scaled the fleet mid-period, utilisation is a lower bound.
