# E-scooter trips: analysis portfolio

End-to-end analysis of 231,868 shared e-scooter rides - from SQL cleaning on Snowflake through a Jupyter EDA to a decision-oriented slide deck.

The project is framed the way a senior data scientist on a shared-mobility / last-mile marketplace would actually work: ride KPIs, temporal patterns, rolling trends, retention cohorts, geospatial imbalance, fleet utilisation, experimentation plans, and a baseline forecast.

## What's in the repo

```
e-scooter-data-analysis/
├── sql/              Snowflake queries answering five standard case questions
├── notebooks/        Full EDA notebook (figures, tables, narrative)
├── data/             CSV aggregates exported from the notebook (ready for BI)
├── figures/          Chart PNGs used in notebook and deck
├── deck/             14-slide case deck (links to the built PPTX)
└── docs/             Supporting notes
```

## Headline numbers

| Metric | Value |
| --- | --- |
| Rides | 231,868 |
| Unique riders | 81,923 |
| Unique scooters | 2,897 |
| Period | 21 Jun - 07 Oct 2019 (~16 weeks) |
| Total revenue | €1,223,872 |
| Avg price / ride | €5.28 (median €4.81) |
| Avg duration | 13.3 min (median 8.4 min) |
| Avg distance | 1.02 km (median 0.66 km) |
| Avg rides / rider | 2.83 |
| Avg rides / scooter | 80 |
| Fleet utilisation | 0.7% of week-hours active |

## Five questions, five SQL answers

All queries live in `/sql` and run against a cleaned `V_RIDES` view that drops "cancel-like" rides (distance < 0.05 km AND duration < 2 min; ~1.2% of rows).

1. **Ride statistics** (`01_ride_statistics.sql`) - totals, averages, costs, fleet utilisation, weekday / weekend split.
2. **Distribution over time** (`02_ride_distribution_over_time.sql`) - by hour, day of week, week, month, plus an hour × DOW heat matrix.
3. **Rolling averages** (`03_rolling_averages.sql`) - 7d/28d daily, 4w weekly, 3m monthly via window functions.
4. **Retention** (`04_rider_retention.sql`) - share of riders reaching the N-th ride, step-down conversion, acquisition-month cohort matrix, observed revenue per user.
5. **Geographic** (`05_geographic.sql`) - 0.005° grid (~350m × 550m) start/end density, net-flow imbalance per cell, top origin→destination flows, idle-time hotspots.

## Senior-DS analysis layered on top

The notebook goes well beyond the five case questions:

- **Cohort retention matrix** (acquisition month × weeks since first ride) with explicit window-censoring caveats.
- **Cohort LTV heuristic** and why raw LTV comparisons across months are misleading.
- **Fleet utilisation over time** and a framing of the economics as a rebalancing problem, not a demand problem.
- **Price vs. duration elasticity cut** (unlock-fee + per-minute decomposition) and an experiment design for a flat unlock-fee waiver.
- **Demand vs. supply imbalance map** - blue cells accumulate scooters, red cells deplete. Ready to feed a per-hour rebalancing score.
- **28-day Holt-Winters forecast** of rides and revenue as a sanity-check baseline (≈ €81k / 4 weeks at current trajectory).
- **Experiment design**: matched-control A/B for a next-24h re-engagement push targeting 1→2 ride conversion, plus a DiD fallback if randomisation isn't available.

## Key findings (short version)

- Short-hop transport. Median ride is 0.66 km / 8.4 min at ~€0.40/min. Closer to first-mile than commute.
- Weekday vs. weekend are different businesses. Twin commuter peaks at 08h and 17-19h; a weekend nightlife peak at 00-02h. Three supply playbooks, not one.
- Retention is the #1 lever. 54% of riders take a 2nd ride, 32% reach a 3rd, 3.5% reach a 10th. 46% never return after ride 1.
- Fleet utilisation is 0.7%. The question isn't "are scooters moving enough?" but "is the right scooter in the right place at the right time?"
- Chronic depletion zones. The net-flow map identifies a stable set of cells that bleed supply every day - route ops trucks by expected marginal rides recovered, not by distance.

## How to run

Requirements (Python 3.10+):

```bash
pip install -r requirements.txt
```

`requirements.txt` covers pandas, numpy, matplotlib, seaborn, statsmodels, pyarrow, jupyter.

### SQL

Point your Snowflake worksheet at the table holding ride-level data (one row per trip, with start/end timestamps, start/end lat-long, distance, duration, price, user hash, scooter hash). Run `00_context.sql` first to create the `V_RIDES` view, then 01-05 in order.

### Notebook

```bash
jupyter notebook notebooks/01_e_scooter_analysis.ipynb
```

All aggregates are also saved as CSVs in `/data` for people who just want to plug them into Power BI / Tableau / Looker Studio.

## Methodology notes

- Cancel-like rides (distance < 0.05 km AND duration < 2 min) are dropped in the base view. ~1.2% of rows.
- All rolling averages are computed in SQL window functions and cross-validated against the pandas rolling window in the notebook.
- Fleet utilisation is `sum(ride minutes) / (scooters × period hours × 60)`, which understates true utilisation if the fleet size varies over the period. Interpret as a lower bound.
- Cohort curves are only truthful inside the observation window - always compare aligned N-week buckets, never raw per-user revenue across cohorts with different horizons.
- Geographic binning is a 0.005° rectangular grid; for production use switch to H3 or similar to make cells equal-area.

## Deck

A 14-slide case deck summarising the analysis (title, executive summary, dataset & method, KPIs, temporal patterns, rolling averages, retention funnel, cohort curves, geo demand, net-flow imbalance, utilisation & pricing, forecast, recommendations, SQL appendix) lives at `/deck/` - see the repo's release attachments for the PPTX.

## Author

Samira Dibaj - PhD, Transport Engineering, Aalto University. Helsinki / Stockholm.

## License

MIT - see LICENSE.
