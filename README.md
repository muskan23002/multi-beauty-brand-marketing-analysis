# 🛍️ Multi-Brand Beauty Marketing Campaign Analysis Using SQL

![Project Banner](https://raw.githubusercontent.com/muskan23002/multi-beauty-brand-marketing-analysis/main/banner.png)

## Project Overview

This project involves a comprehensive analysis of marketing campaign performance data across **three major Indian beauty brands — Nykaa, Purplle, and Tira** — using SQL. The goal is to extract actionable marketing insights and answer real-world business questions based on the dataset.

The following README provides a detailed account of the project's objectives, business problems, SQL queries, findings, and conclusions.

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat-square)
![Domain](https://img.shields.io/badge/Domain-Marketing%20Analytics-pink)

---

## Objectives

- Analyze marketing KPIs (CTR, CVR, ROAS, CPL, CPC) across brands, campaign types, and channels
- Identify the most efficient customer segments and languages for each brand
- Perform monthly and quarterly time series analysis
- Answer 10 real-world business questions a marketing manager would ask
- Build a final enriched view for Power BI dashboard (coming soon)

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

**Step 1 — Individual Brand Tables (3 tables, identical structure)**

> Note: Same schema applies to `purplle_campaigns` and `tira_campaigns`

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

-- Same structure for:
CREATE TABLE purplle_campaigns ( ... );
CREATE TABLE tira_campaigns    ( ... );
```

**Step 2 — Master Combined Table (used for all analysis)**

> All 3 brand tables combined using UNION ALL with an additional `brand` column

```sql
CREATE TABLE all_campaigns AS
SELECT 'Nykaa'   AS brand, * FROM nykaa_campaigns
UNION ALL
SELECT 'Purplle' AS brand, * FROM purplle_campaigns
UNION ALL
SELECT 'Tira'    AS brand, * FROM tira_campaigns;
```

| Column | Type | Description |
|---|---|---|
| brand | TEXT | Nykaa / Purplle / Tira |
| campaign_id | VARCHAR(20) | Unique campaign identifier |
| campaign_type | VARCHAR(50) | Email, SEO, Paid Ads, Social Media, Influencer |
| target_audience | VARCHAR(100) | Audience targeted |
| duration | INT | Campaign length in days |
| channel_used | VARCHAR(50) | Instagram, Google, YouTube, Facebook, WhatsApp, Email |
| impressions | INT | People who saw the ad |
| clicks | INT | People who clicked |
| leads | INT | Interested prospects |
| conversions | INT | Actual purchases |
| revenue | NUMERIC(10,2) | Revenue generated |
| acquisition_cost | NUMERIC(10,2) | Ad spend |
| roi | NUMERIC(10,2) | Return on Investment |
| language | VARCHAR(50) | Hindi, English, Tamil, Bengali |
| engagement_score | NUMERIC(5,2) | Campaign engagement metric |
| customer_segment | VARCHAR(100) | College Students, Premium Shoppers, Working Women, Youth, Tier 2 City |
| campaign_date | DATE | Date campaign ran |

---

## Tools Used

| Tool | Purpose |
|---|---|
| **PostgreSQL** | Data storage, cleaning, and SQL analysis |
| **pgAdmin 4** | PostgreSQL GUI for running queries |
| **Power BI** | Interactive dashboard (coming soon) |

---

## Project Structure

```
Multi-Brand-Beauty-Campaign-Analysis/
│
├── SQL/
│   ├── 01_create_tables.sql         → Create and load brand tables
│   ├── 02_data_exploration.sql      → Null checks, duplicates, stats
│   ├── 03_combine_brands.sql        → Union all 3 brands into master table
│   ├── 04_kpi_analysis.sql          → CTR, CVR, ROAS, CPL, CPC by dimension
│   ├── 05_time_series_analysis.sql  → Monthly and quarterly trends
│   ├── 06_business_questions.sql    → 10 business questions answered
│
├── Dataset/
│   ├── nykaa_campaign_data.csv
│   ├── purplle_campaign_data.csv
│   └── tira_campaign_data.csv
│
├── PowerBI/                         → Coming Soon
│   └── dashboard.pbix
│
└── README.md
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

### Brand vs Brand — Quick Snapshot

| Metric | Nykaa | Purplle | Tira |
|---|---|---|---|
| Avg Monthly Revenue | ₹252 Cr 🥇 | ₹251 Cr | ₹250 Cr |
| Revenue Consistency | Most Volatile ❌ | Moderate ⚠️ | Most Consistent ✅ |
| Monthly Recovery Rate | 67% | 80% ✅ | 80% ✅ |
| Best Channel | Email (ROAS 1389) | Email (ROAS 1382) | Instagram (ROAS 1397) |
| Best Campaign Type | Social Media | Paid Ads | Paid Ads |
| Best Customer Segment | Working Women | College Students | Youth |
| Best Language | English | English | Tamil 🌟 |
| Best Quarter (ROAS) | Q1 FY Jul-Sep | Q3 FY Jan-Mar | Q3 FY Jan-Mar |

---

### Key Findings at a Glance

**🏆 Biggest Winner**
Tira's Youth + Instagram combination delivers ROAS of **1461** — the highest in the entire dataset across all 1,66,665 campaigns.

**📉 Biggest Surprise**
Google ranks **last in conversions for all 3 brands** — confirming beauty is a visual discovery category where search ads consistently underperform.

**⚠️ Counter-intuitive Finding**
Premium Shoppers — the most pursued customer segment — deliver the **weakest ROAS across all 3 brands**, indicating high acquisition costs that revenue cannot justify.

**📅 Universal Seasonal Pattern**
February is a structural dip month for every brand (28-day effect). March is the universal recovery month — Nykaa bounces back +10.18%, Purplle +9.38%.

**🎯 Same Campaign, Different Results**
Paid Ads is a Star ⭐ for Tira, a Converter 💰 for Purplle, and an Awareness 📢 campaign for Nykaa — proving that channel effectiveness depends on brand execution, not the channel itself.

**📺 YouTube Paradox**
YouTube ranks last in total conversions but appears in 4 of 5 top revenue campaigns — revealing a high-ticket conversion pattern where fewer people buy but spend significantly more per transaction.

> **Dataset Note:** This dataset is synthetically generated. Anomalies like identical CPL/CPC across brands were identified, flagged, and explained throughout — demonstrating real-world data validation practices.

---

## Recommendations

### For Nykaa
1. **Reduce Google ad spend** — Google ranks last in conversions and CVR for Nykaa. Reallocating this budget to Instagram or Email would generate stronger returns.
2. **Leverage Email for retention** — Email delivers Nykaa's highest ROAS (1389) and CVR (22.12%). Investing in personalised email campaigns for existing customers is the highest-efficiency strategy.
3. **Double down on Working Women segment** — Working Women deliver Nykaa's highest ROAS (1383) and CTR. Social Media campaigns targeting this segment during lunch-break hours would maximise engagement.
4. **Investigate September dip** — Nykaa shows a significant -7.98% revenue drop in September 2024 with no clear seasonal explanation. A deeper investigation into campaign quality and budget allocation during this period is recommended.
5. **Plan aggressively for March** — Nykaa's strongest MoM recovery is +10.18% in March. Front-loading March budgets would capitalise on this structural rebound window.

### For Purplle
1. **Fix Bengali campaigns urgently** — Bengali is Purplle's worst-performing language (ROAS 1335) despite being a large and engaged market. Localised content and regional influencer partnerships should be prioritised.
2. **Scale Email channel** — Email is Purplle's top channel by both conversions and ROAS (1382). Expanding the email subscriber base through sign-up incentives would directly impact revenue.
3. **Reconsider Influencer strategy** — Influencer campaigns are Purplle's weakest campaign type (ROAS 1313). Either the influencer partnerships need to be renegotiated or the budget should be shifted to Paid Ads and Email.
4. **Build Q3 FY strategy** — Purplle achieves its highest ROAS in Q3 (Jan-Mar) at 1393. A dedicated post-festive retention campaign running January through March would maximise this efficiency window.
5. **Address February vulnerability** — Purplle recorded the highest single-month decline of -9.74% in February. Pre-loading campaigns in late January to bridge the gap would reduce this structural dip.

### For Tira
1. **Invest heavily in Youth + Instagram** — This combination delivers the highest ROAS of 1461 in the entire dataset. Tira's highest growth opportunity lies in scaling this specific targeting combination aggressively.
2. **Expand Tamil language campaigns** — Tamil delivers Tira's highest ROAS (1391) and is the strongest language in the entire analysis. Deeper investment in South Indian markets through Tamil content, influencers, and regional platforms would unlock significant growth.
3. **Rebuild Influencer strategy** — Influencer campaigns are Tira's worst performer (ROAS 1345, Underperformer category). A complete audit of current influencer partnerships and pivot toward data-driven influencer selection is recommended.
4. **Leverage brand consistency as an asset** — Tira's low revenue standard deviation and 80% recovery rate show exceptional operational stability. This should be communicated as a brand strength in investor and stakeholder reporting.
5. **Scale Short campaigns** — Tira's Short (5-10 day) campaigns deliver the highest revenue per campaign (₹5,13,271). Running more frequent, brief, highly-targeted campaigns rather than long-duration broad campaigns would maximise efficiency.

---

## Conclusion

This project is an end-to-end SQL analysis of 1,66,665 marketing 
campaigns across three leading Indian beauty brands — Nykaa, Purplle, 
and Tira — built to answer real business questions.
    Using advanced PostgreSQL techniques including CTEs, Window Functions, 
UNNEST, RANK, STDDEV, and a CTR-CVR-ROAS Performance Matrix, I analyzed 
key KPIs — CTR, CVR, ROAS, CPC, and CPL — across channels, segments, 
languages, campaign types, and time periods.

Key findings:
- Tira is the most consistent and resilient brand despite being the newest
- Instagram and Email outperform Google across all 3 brands
- Youth + Instagram delivers the highest ROAS (1461) in the entire dataset  
- Marketing success depends on execution quality, not channel selection alone

Beyond querying, this project demonstrates the ability to translate business 
questions into analytical solutions, identify trends and anomalies, and 
communicate data-driven recommendations — skills that matter in any 
data analyst role.

The Power BI dashboard is coming next — because great insights deserve 
great visuals. 🚀
If you're a recruiter, hiring manager, or fellow data enthusiast — I'd love to connect and hear your thoughts! 🚀


## Author

**Muskan**
Aspiring Data Analyst | SQL • Excel • Power BI
