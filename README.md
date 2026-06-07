# 🛍️ Multi-Brand Beauty Marketing Campaign Analysis Using SQL

## Project Overview

This project involves a comprehensive analysis of marketing campaign performance data across **three major Indian beauty brands — Nykaa, Purplle, and Tira** — using SQL. The goal is to extract actionable marketing insights and answer real-world business questions based on the dataset.

The following README provides a detailed account of the project's objectives, business problems, SQL queries, findings, and conclusions.

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-In%20Progress-orange)
![Domain](https://img.shields.io/badge/Domain-Marketing%20Analytics-pink)

---

## Objectives

- Analyze marketing KPIs (CTR, CVR, ROAS, CPL, CPC) across brands, campaign types, and channels
- Identify the most efficient customer segments and languages for each brand
- Perform monthly and quarterly time series analysis
- Answer 10 real-world business questions a marketing manager would ask

---

## Dataset

The data for this project is sourced from Kaggle:
**[Multi-Brand Marketing Campaign Performance Dataset](https://www.kaggle.com/datasets/sshriya08/multi-brand-marketing-campaign-performance-dataset)**

### Dataset Details

| Property | Details |
|---|---|
| Brands | Nykaa, Purplle, Tira |
| Rows | 55,555 per brand (1,66,665 total) |
| Time Period | July 2024 — May 2025 |
| Format | CSV (3 separate files, one per brand) |

### Schema

```sql
CREATE TABLE nykaa_campaigns (
    campaign_id        VARCHAR(20),
    campaign_type      VARCHAR(50),
    target_audience    VARCHAR(100),
    duration           INT,
    channel_used       VARCHAR(50),
    impressions        INT,
    clicks             INT,
    leads              INT,
    conversions        INT,
    revenue            NUMERIC(10,2),
    acquisition_cost   NUMERIC(10,2),
    roi                NUMERIC(10,2),
    language           VARCHAR(50),
    engagement_score   NUMERIC(5,2),
    customer_segment   VARCHAR(100),
    campaign_date      DATE
);
```

---

## KPI Framework

| KPI | Formula | Meaning |
|---|---|---|
| CTR | Clicks / Impressions × 100 | Ad visibility effectiveness |
| CVR | Conversions / Clicks × 100 | Purchase intent strength |
| ROAS | Revenue / Acquisition Cost | Return on ad spend |
| CPL | Acquisition Cost / Leads | Cost to acquire one lead |
| CPC | Acquisition Cost / Clicks | Cost per click |

---

## Business Problems and Solutions

### BQ1 — Which campaign type works best for each customer segment?

**Objective:** Identify the optimal campaign type for each customer segment to guide targeted marketing strategy.

```sql
SELECT
    brand,
    customer_segment,
    campaign_type,
    COUNT(campaign_id)                                                            AS total_campaigns,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)           AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)           AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)           AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                       AS revenue_per_campaign
FROM all_campaigns
GROUP BY brand, customer_segment, campaign_type
ORDER BY brand, customer_segment, roas DESC;
```

**Finding:** Tira's Youth segment via Paid Ads delivers the highest ROAS of 1486 in the entire dataset. No single campaign type dominates across all segments — confirming the need for segment-specific strategies.

---

### BQ2 — Which channel drives most conversions per brand?

**Objective:** Determine which platform generates the most purchases for each brand to guide channel investment decisions.

```sql
SELECT
    brand,
    TRIM(UNNEST(STRING_TO_ARRAY(channel_used, ',')))                              AS single_channel,
    COUNT(campaign_id)                                                            AS total_campaigns,
    SUM(conversions)                                                              AS total_conversions,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)           AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)           AS roas,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(COUNT(campaign_id), 0), 2)          AS conversions_per_campaign
FROM all_campaigns
GROUP BY brand, single_channel
ORDER BY brand, total_conversions DESC;
```

**Finding:** Google consistently ranks last in conversions for all 3 brands — confirming beauty is a visual discovery category. Instagram leads for Nykaa and Tira while Email leads for Purplle.

---

### BQ3 — Top 5 performing campaigns overall by revenue

**Objective:** Identify star campaigns to study their characteristics and replicate their success.

```sql
SELECT
    brand,
    campaign_id,
    campaign_type,
    channel_used,
    customer_segment,
    campaign_date,
    impressions,
    clicks,
    conversions,
    revenue,
    ROUND(clicks::NUMERIC / NULLIF(impressions, 0) * 100, 2)                     AS ctr_percent,
    ROUND(conversions::NUMERIC / NULLIF(clicks, 0) * 100, 2)                     AS cvr_percent,
    ROUND(revenue::NUMERIC / NULLIF(acquisition_cost, 0), 2)                     AS roas,
    RANK() OVER (ORDER BY revenue DESC)                                           AS revenue_rank
FROM all_campaigns
ORDER BY revenue DESC
LIMIT 5;
```

**Finding:** Top campaigns achieve CTR of 14-15% and CVR of 40-46% — nearly double the dataset average of 8.5% CTR and 22% CVR. YouTube appears in 4 of 5 top campaigns despite ranking last in total conversions — revealing a high-ticket conversion pattern.

---

### BQ4 — Which brand is most consistent performer across all months?

**Objective:** Measure revenue consistency using standard deviation to identify the most reliable brand.

```sql
SELECT
    brand,
    ROUND(AVG(monthly_revenue), 2)                                                AS avg_monthly_revenue,
    ROUND(MAX(monthly_revenue), 2)                                                AS best_month_revenue,
    ROUND(MIN(monthly_revenue), 2)                                                AS worst_month_revenue,
    ROUND(MAX(monthly_revenue) - MIN(monthly_revenue), 2)                         AS revenue_gap,
    ROUND(STDDEV(monthly_revenue), 2)                                             AS revenue_stddev,
    COUNT(year_month)                                                             AS months_tracked
FROM (
    SELECT
        brand,
        TO_CHAR(campaign_date, 'YYYY-MM')   AS year_month,
        SUM(revenue)                         AS monthly_revenue
    FROM all_campaigns
    WHERE campaign_date < '2025-06-01'
    GROUP BY brand, year_month
) AS monthly_summary
GROUP BY brand
ORDER BY revenue_stddev ASC;
```

**Finding:** Tira is the most consistent brand with the lowest standard deviation (₹6.47 Cr) and smallest revenue gap (₹17.5 Cr) — remarkable stability for a brand launched in 2023. Nykaa generates highest revenue but is most volatile (stddev ₹9.49 Cr).

---

### BQ5 — Which customer segment + channel combination gives best ROAS?

**Objective:** Find the perfect targeting combination — which customer to target on which platform — for maximum return.

```sql
SELECT
    brand,
    customer_segment,
    TRIM(UNNEST(STRING_TO_ARRAY(channel_used, ',')))                              AS single_channel,
    COUNT(campaign_id)                                                            AS total_campaigns,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)           AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)           AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)           AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                       AS revenue_per_campaign
FROM all_campaigns
GROUP BY brand, customer_segment, single_channel
ORDER BY brand, roas DESC;
```

**Finding:** Tira's Youth + Instagram delivers the highest ROAS of 1461 across the entire dataset. Facebook consistently underperforms for Youth across all brands — confirming platform demographic shift toward Instagram and WhatsApp.

---

### BQ6 — Month over Month revenue growth — which brand grew fastest?

**Objective:** Track revenue momentum month by month to identify growth trends and slowdowns.

```sql
WITH monthly_revenue AS (
    SELECT
        brand,
        TO_CHAR(campaign_date, 'YYYY-MM')   AS year_month,
        TO_CHAR(campaign_date, 'Mon YYYY')  AS month_name,
        SUM(revenue)                         AS total_revenue
    FROM all_campaigns
    WHERE campaign_date < '2025-06-01'
    GROUP BY brand, year_month, month_name
),
mom_growth AS (
    SELECT
        brand,
        year_month,
        month_name,
        total_revenue,
        LAG(total_revenue) OVER (PARTITION BY brand ORDER BY year_month) AS prev_month_revenue,
        ROUND(
            (total_revenue - LAG(total_revenue) OVER (
                PARTITION BY brand ORDER BY year_month
            ))::NUMERIC / NULLIF(LAG(total_revenue) OVER (
                PARTITION BY brand ORDER BY year_month
            ), 0) * 100
        , 2) AS mom_growth_percent
    FROM monthly_revenue
)
SELECT * FROM mom_growth
ORDER BY brand, year_month ASC;
```

**Finding:** February is a universal dip month across all brands (structural 28-day effect). March delivers the strongest recovery — Nykaa at +10.18%, Purplle at +9.38%. Purplle recorded the single largest MoM decline of -9.74% in February 2025.

---

### BQ7 — CTR vs CVR vs ROAS conflict matrix

**Objective:** Categorize each campaign type into performance buckets to identify awareness vs conversion campaigns.

```sql
WITH ctr_cvr_analysis AS (
    SELECT
        brand,
        campaign_type,
        COUNT(campaign_id)                                                        AS total_campaigns,
        ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)       AS ctr_percent,
        ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)       AS cvr_percent,
        ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)       AS roas
    FROM all_campaigns
    GROUP BY brand, campaign_type
),
avg_values AS (
    SELECT
        ROUND(AVG(ctr_percent), 2) AS avg_ctr,
        ROUND(AVG(cvr_percent), 2) AS avg_cvr,
        ROUND(AVG(roas), 2)        AS avg_roas
    FROM ctr_cvr_analysis
)
SELECT
    c.brand, c.campaign_type, c.total_campaigns,
    c.ctr_percent, c.cvr_percent, c.roas,
    a.avg_ctr, a.avg_cvr, a.avg_roas,
    CASE
        WHEN c.ctr_percent >= a.avg_ctr AND c.cvr_percent >= a.avg_cvr
            THEN 'Star - High CTR + High CVR'
        WHEN c.ctr_percent >= a.avg_ctr AND c.cvr_percent < a.avg_cvr AND c.roas > a.avg_roas
            THEN 'Hidden Gem - High CTR + Low CVR + High ROAS'
        WHEN c.ctr_percent >= a.avg_ctr AND c.cvr_percent < a.avg_cvr
            THEN 'Awareness - High CTR + Low CVR'
        WHEN c.ctr_percent < a.avg_ctr AND c.cvr_percent >= a.avg_cvr
            THEN 'Converter - Low CTR + High CVR'
        WHEN c.ctr_percent < a.avg_ctr AND c.cvr_percent < a.avg_cvr AND c.roas > a.avg_roas
            THEN 'Sleeper - Low CTR + Low CVR + High ROAS'
        ELSE 'Underperformer - Low CTR + Low CVR'
    END AS campaign_category
FROM ctr_cvr_analysis c
CROSS JOIN avg_values a
ORDER BY c.brand, c.roas DESC;
```

**Finding:** Paid Ads performs differently for each brand — Star for Tira, Converter for Purplle, Awareness for Nykaa — demonstrating that channel effectiveness depends on brand execution quality. Social Media is the most consistently strong campaign type, never falling below Hidden Gem status.

---

### BQ8 — Which language performs best across all brands?

**Objective:** Identify which language campaign generates the highest ROAS to guide regional marketing investment.

```sql
SELECT
    brand,
    language,
    COUNT(campaign_id)                                                            AS total_campaigns,
    SUM(impressions)                                                              AS total_impressions,
    SUM(conversions)                                                              AS total_conversions,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)           AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)           AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)           AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                       AS revenue_per_campaign
FROM all_campaigns
GROUP BY brand, language
ORDER BY brand, roas DESC;
```

**Finding:** Tamil is Tira's strongest language with ROAS of 1391 — suggesting strong South India market penetration. English leads for Nykaa and Purplle but ranks last for Tira — confirming brand-specific regional audience differences.

---

### BQ9 — Which campaign duration drives best performance?

**Objective:** Determine the optimal campaign length for each brand to maximize ROAS and revenue per campaign.

```sql
SELECT
    brand,
    CASE
        WHEN duration BETWEEN 5  AND 10 THEN '1. Short (5-10 days)'
        WHEN duration BETWEEN 11 AND 17 THEN '2. Medium (11-17 days)'
        WHEN duration BETWEEN 18 AND 24 THEN '3. Long (18-24 days)'
        WHEN duration BETWEEN 25 AND 30 THEN '4. Extra Long (25-30 days)'
    END                                                                           AS duration_bucket,
    COUNT(campaign_id)                                                            AS total_campaigns,
    ROUND(AVG(duration), 1)                                                       AS avg_duration_days,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)           AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)           AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)           AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                       AS revenue_per_campaign,
    ROUND(AVG(engagement_score), 2)                                               AS avg_engagement_score
FROM all_campaigns
GROUP BY brand, duration_bucket
ORDER BY brand, duration_bucket ASC;
```

**Finding:** Extra Long campaigns (25-30 days) deliver highest ROAS for Nykaa and Tira. Purplle peaks with Long campaigns (18-24 days). Tira's Short campaigns generate the highest revenue per campaign — indicating extremely high-quality brief targeted campaigns.

---

### BQ10 — Which brand recovers fastest after a low revenue month?

**Objective:** Measure brand resilience by tracking how quickly each brand bounces back from a revenue dip.

```sql
WITH monthly_revenue AS (
    SELECT
        brand,
        TO_CHAR(campaign_date, 'YYYY-MM')   AS year_month,
        TO_CHAR(campaign_date, 'Mon YYYY')  AS month_name,
        SUM(revenue)                         AS total_revenue
    FROM all_campaigns
    WHERE campaign_date < '2025-06-01'
    GROUP BY brand, year_month, month_name
),
with_lag AS (
    SELECT
        brand, year_month, month_name, total_revenue,
        LAG(total_revenue)  OVER (PARTITION BY brand ORDER BY year_month) AS prev_revenue,
        LEAD(total_revenue) OVER (PARTITION BY brand ORDER BY year_month) AS next_revenue
    FROM monthly_revenue
),
recovery_analysis AS (
    SELECT
        brand, year_month, month_name, total_revenue, prev_revenue, next_revenue,
        CASE
            WHEN total_revenue < prev_revenue AND next_revenue > total_revenue
                THEN 'Recovered Next Month'
            WHEN total_revenue < prev_revenue AND next_revenue <= total_revenue
                THEN 'Stayed Down'
            WHEN total_revenue >= prev_revenue
                THEN 'No Drop'
        END AS recovery_status
    FROM with_lag
    WHERE prev_revenue IS NOT NULL
)
SELECT * FROM recovery_analysis
ORDER BY brand, year_month ASC;
```

**Finding:** Purplle and Tira both achieve an 80% monthly recovery rate vs Nykaa's 67%. Tira uniquely avoided consecutive declining months entirely — the most resilient brand. All 3 brands recovered from February's structural dip in March.

---

## Findings and Conclusions

- **Brand Consistency:** Tira is the most consistent brand despite being the newest — lowest revenue standard deviation and highest recovery rate
- **Channel Strategy:** Email dominates for Nykaa and Purplle; Instagram leads for Tira — no universal channel winner
- **Best Segment:** Youth is the highest-value segment for Tira; Working Women for Nykaa; College Students for Purplle
- **Campaign Type:** Paid Ads delivers the highest ROAS for Purplle and Tira; Social Media for Nykaa
- **Language:** Tamil is Tira's secret weapon; English leads for Nykaa and Purplle
- **Seasonality:** February is a universal structural dip; March is a universal recovery month across all 3 brands
- **Dataset Note:** This dataset is synthetically generated — anomalies such as identical CPL/CPC across brands and absence of festive season spikes reflect this. All findings are presented with appropriate context

---

## Project Structure

```
Multi-Brand-Beauty-Campaign-Analysis/
│
├── SQL/
│   ├── 01_create_tables.sql
│   ├── 02_data_exploration.sql
│   ├── 03_combine_brands.sql
│   ├── 04_kpi_analysis.sql
│   ├── 05_time_series_analysis.sql
│   ├── 06_business_questions.sql
│   └── 07_powerbi_view.sql
│
├── Dataset/
│   ├── nykaa_campaign_data.csv
│   ├── purplle_campaign_data.csv
│   └── tira_campaign_data.csv
│
├── PowerBI/              (Coming Soon)
│   └── dashboard.pbix
│
└── README.md
```

---

## Tools Used

- **PostgreSQL** — Data storage, cleaning, and SQL analysis
- **pgAdmin 4** — PostgreSQL GUI
- **Power BI** — Interactive dashboard (coming soon)

---

## Author

**Muskan**
Aspiring Data Analyst | SQL • Excel • Power BI
