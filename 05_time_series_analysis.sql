-- ============================================================
-- Date Range: July 2024 to May 2025 (11 months)
-- Note: June 2025 excluded (incomplete month - only 24 days)
-- ============================================================


-- ============================================================
-- 5.1 : MONTHLY TREND ANALYSIS
-- ============================================================

SELECT
    brand,
    TO_CHAR(campaign_date, 'YYYY-MM')                                       AS year_month,
    TO_CHAR(campaign_date, 'Mon YYYY')                                      AS month_name,
    COUNT(campaign_id)                                                      AS total_campaigns,
    SUM(impressions)                                                        AS total_impressions,
    SUM(clicks)                                                             AS total_clicks,
    SUM(conversions)                                                        AS total_conversions,
    SUM(revenue)                                                            AS total_revenue,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)     AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)     AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)     AS roas
FROM all_campaigns
GROUP BY brand, year_month, month_name
ORDER BY brand, year_month ASC;


-- ============================================================
-- 5.2 : QUARTERLY ANALYSIS (Indian Fiscal Year)
-- Q1 FY = Jul-Sep | Q2 FY = Oct-Dec
-- Q3 FY = Jan-Mar | Q4 FY = Apr-Jun
-- ============================================================

SELECT
    brand,
    CASE
        WHEN EXTRACT(MONTH FROM campaign_date) IN (7,8,9)    THEN 'Q1 FY (Jul-Sep)'
        WHEN EXTRACT(MONTH FROM campaign_date) IN (10,11,12) THEN 'Q2 FY (Oct-Dec)'
        WHEN EXTRACT(MONTH FROM campaign_date) IN (1,2,3)    THEN 'Q3 FY (Jan-Mar)'
        WHEN EXTRACT(MONTH FROM campaign_date) IN (4,5,6)    THEN 'Q4 FY (Apr-Jun)'
    END                                                                     AS fiscal_quarter,
    CASE
        WHEN EXTRACT(MONTH FROM campaign_date) IN (7,8,9)    THEN 1
        WHEN EXTRACT(MONTH FROM campaign_date) IN (10,11,12) THEN 2
        WHEN EXTRACT(MONTH FROM campaign_date) IN (1,2,3)    THEN 3
        WHEN EXTRACT(MONTH FROM campaign_date) IN (4,5,6)    THEN 4
    END                                                                     AS quarter_order,
    COUNT(campaign_id)                                                      AS total_campaigns,
    SUM(impressions)                                                        AS total_impressions,
    SUM(clicks)                                                             AS total_clicks,
    SUM(conversions)                                                        AS total_conversions,
    SUM(revenue)                                                            AS total_revenue,
    ROUND(SUM(clicks)::NUMERIC / NULLIF(SUM(impressions), 0) * 100, 2)     AS ctr_percent,
    ROUND(SUM(conversions)::NUMERIC / NULLIF(SUM(clicks), 0) * 100, 2)     AS cvr_percent,
    ROUND(SUM(revenue)::NUMERIC / NULLIF(SUM(acquisition_cost), 0), 2)     AS roas,
    ROUND(SUM(revenue) / NULLIF(COUNT(campaign_id), 0), 2)                 AS revenue_per_campaign
FROM all_campaigns
GROUP BY brand, fiscal_quarter, quarter_order
ORDER BY brand, quarter_order ASC;
