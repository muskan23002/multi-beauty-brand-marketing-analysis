-- ============================================================
-- PROJECT  : Multi-Brand Beauty Marketing Campaign Analysis
-- FILE     : 06_business_questions.sql
-- PURPOSE  : Answer 10 real-world business questions
-- AUTHOR   : Muskan
-- TOOL     : PostgreSQL
-- ============================================================


-- ============================================================
-- BQ1 : Which campaign type works best for each customer segment?
-- ============================================================

SELECT
    brand,
    customer_segment,
    campaign_type,
    COUNT(campaign_id)                                                      AS total_campaigns,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)     AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)     AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)     AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                 AS revenue_per_campaign
FROM all_campaigns
GROUP BY brand, customer_segment, campaign_type
ORDER BY brand, customer_segment, roas DESC;


-- ============================================================
-- BQ2 : Which channel drives most conversions per brand?
-- ============================================================

SELECT
    brand,
    TRIM(UNNEST(STRING_TO_ARRAY(channel_used, ',')))                        AS single_channel,
    COUNT(campaign_id)                                                      AS total_campaigns,
    SUM(conversions)                                                        AS total_conversions,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)     AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)     AS roas,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(COUNT(campaign_id), 0), 2)    AS conversions_per_campaign
FROM all_campaigns
GROUP BY brand, single_channel
ORDER BY brand, total_conversions DESC;


-- ============================================================
-- BQ3 : Top 5 performing campaigns overall by revenue
-- ============================================================

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
    ROUND(clicks::NUMERIC / NULLIF(impressions, 0) * 100, 2)               AS ctr_percent,
    ROUND(conversions::NUMERIC / NULLIF(clicks, 0) * 100, 2)               AS cvr_percent,
    ROUND(revenue::NUMERIC / NULLIF(acquisition_cost, 0), 2)               AS roas,
    RANK() OVER (ORDER BY revenue DESC)                                     AS revenue_rank
FROM all_campaigns
ORDER BY revenue DESC
LIMIT 5;


-- ============================================================
-- BQ4 : Which brand is most consistent performer across all months?
-- ============================================================

SELECT
    brand,
    ROUND(AVG(monthly_revenue), 2)                                          AS avg_monthly_revenue,
    ROUND(MAX(monthly_revenue), 2)                                          AS best_month_revenue,
    ROUND(MIN(monthly_revenue), 2)                                          AS worst_month_revenue,
    ROUND(MAX(monthly_revenue) - MIN(monthly_revenue), 2)                  AS revenue_gap,
    ROUND(STDDEV(monthly_revenue), 2)                                       AS revenue_stddev,
    COUNT(year_month)                                                       AS months_tracked
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


-- ============================================================
-- BQ5 : Which customer segment + channel combination gives best ROAS?
-- ============================================================

SELECT
    brand,
    customer_segment,
    TRIM(UNNEST(STRING_TO_ARRAY(channel_used, ',')))                        AS single_channel,
    COUNT(campaign_id)                                                      AS total_campaigns,
    SUM(conversions)                                                        AS total_conversions,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)     AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)     AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)     AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                 AS revenue_per_campaign
FROM all_campaigns
GROUP BY brand, customer_segment, single_channel
ORDER BY brand, roas DESC;


-- ============================================================
-- BQ6 : Month over Month revenue growth — which brand grew fastest?
-- ============================================================

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
        LAG(total_revenue) OVER (
            PARTITION BY brand
            ORDER BY year_month
        )                                    AS prev_month_revenue,
        ROUND(
            (total_revenue - LAG(total_revenue) OVER (
                PARTITION BY brand
                ORDER BY year_month
            ))::NUMERIC / NULLIF(LAG(total_revenue) OVER (
                PARTITION BY brand
                ORDER BY year_month
            ), 0) * 100
        , 2)                                 AS mom_growth_percent
    FROM monthly_revenue
)
SELECT *
FROM mom_growth
ORDER BY brand, year_month ASC;


-- ============================================================
-- BQ7 : CTR vs CVR vs ROAS conflict matrix
-- Categorizes each campaign type into performance buckets
-- ============================================================

WITH ctr_cvr_analysis AS (
    SELECT
        brand,
        campaign_type,
        COUNT(campaign_id)                                                  AS total_campaigns,
        ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2) AS ctr_percent,
        ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2) AS cvr_percent,
        ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2) AS roas
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
    c.brand,
    c.campaign_type,
    c.total_campaigns,
    c.ctr_percent,
    c.cvr_percent,
    c.roas,
    a.avg_ctr,
    a.avg_cvr,
    a.avg_roas,
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
    END                                                                     AS campaign_category
FROM ctr_cvr_analysis c
CROSS JOIN avg_values a
ORDER BY c.brand, c.roas DESC;


-- ============================================================
-- BQ8 : Which language performs best across all brands?
-- ============================================================

SELECT
    brand,
    language,
    COUNT(campaign_id)                                                      AS total_campaigns,
    SUM(impressions)                                                        AS total_impressions,
    SUM(conversions)                                                        AS total_conversions,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)     AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)     AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)     AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                 AS revenue_per_campaign
FROM all_campaigns
GROUP BY brand, language
ORDER BY brand, roas DESC;


-- ============================================================
-- BQ9 : Which campaign duration drives best performance?
-- ============================================================

SELECT
    brand,
    CASE
        WHEN duration BETWEEN 5  AND 10 THEN '1. Short (5-10 days)'
        WHEN duration BETWEEN 11 AND 17 THEN '2. Medium (11-17 days)'
        WHEN duration BETWEEN 18 AND 24 THEN '3. Long (18-24 days)'
        WHEN duration BETWEEN 25 AND 30 THEN '4. Extra Long (25-30 days)'
    END                                                                     AS duration_bucket,
    COUNT(campaign_id)                                                      AS total_campaigns,
    ROUND(AVG(duration), 1)                                                 AS avg_duration_days,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)     AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)     AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)     AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                 AS revenue_per_campaign,
    ROUND(AVG(engagement_score), 2)                                         AS avg_engagement_score
FROM all_campaigns
GROUP BY brand, duration_bucket
ORDER BY brand, duration_bucket ASC;


-- ============================================================
-- BQ10 : Which brand recovers fastest after a low revenue month?
-- ============================================================

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
        brand,
        year_month,
        month_name,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY brand ORDER BY year_month
        )                                    AS prev_revenue,
        LEAD(total_revenue) OVER (
            PARTITION BY brand ORDER BY year_month
        )                                    AS next_revenue
    FROM monthly_revenue
),
recovery_analysis AS (
    SELECT
        brand,
        year_month,
        month_name,
        total_revenue,
        prev_revenue,
        next_revenue,
        CASE
            WHEN total_revenue < prev_revenue AND next_revenue > total_revenue
                THEN 'Recovered Next Month'
            WHEN total_revenue < prev_revenue AND next_revenue <= total_revenue
                THEN 'Stayed Down'
            WHEN total_revenue >= prev_revenue
                THEN 'No Drop'
        END                                  AS recovery_status
    FROM with_lag
    WHERE prev_revenue IS NOT NULL
)
SELECT *
FROM recovery_analysis
ORDER BY brand, year_month ASC;
