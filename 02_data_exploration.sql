-- ============================================================
-- 2.1 : PREVIEW DATA
-- ============================================================

SELECT * FROM nykaa_campaigns   LIMIT 5;
SELECT * FROM purplle_campaigns LIMIT 5;
SELECT * FROM tira_campaigns    LIMIT 5;


-- ============================================================
-- 2.2 : CHECK COLUMN NAMES AND DATA TYPES
-- ============================================================

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'nykaa_campaigns';


-- ============================================================
-- 2.3 : CHECK FOR NULL VALUES
-- ============================================================

SELECT
    COUNT(*)                                                    AS total_rows,
    COUNT(*) FILTER (WHERE campaign_id IS NULL)                 AS null_campaign_id,
    COUNT(*) FILTER (WHERE campaign_type IS NULL)               AS null_campaign_type,
    COUNT(*) FILTER (WHERE channel_used IS NULL)                AS null_channel,
    COUNT(*) FILTER (WHERE impressions IS NULL)                 AS null_impressions,
    COUNT(*) FILTER (WHERE clicks IS NULL)                      AS null_clicks,
    COUNT(*) FILTER (WHERE conversions IS NULL)                 AS null_conversions,
    COUNT(*) FILTER (WHERE revenue IS NULL)                     AS null_revenue,
    COUNT(*) FILTER (WHERE roi IS NULL)                         AS null_roi,
    COUNT(*) FILTER (WHERE campaign_date IS NULL)               AS null_date
FROM nykaa_campaigns;
-- Run same for purplle_campaigns and tira_campaigns


-- ============================================================
-- 2.4 : CHECK FOR DUPLICATE CAMPAIGN IDs
-- ============================================================

SELECT campaign_id, COUNT(*) AS count
FROM nykaa_campaigns
GROUP BY campaign_id
HAVING COUNT(*) > 1;
-- Run same for purplle_campaigns and tira_campaigns


-- ============================================================
-- 2.5 : CHECK DISTINCT VALUES IN KEY COLUMNS
-- ============================================================

SELECT DISTINCT campaign_type   FROM nykaa_campaigns;
SELECT DISTINCT channel_used    FROM nykaa_campaigns;
SELECT DISTINCT customer_segment FROM nykaa_campaigns;
SELECT DISTINCT language        FROM nykaa_campaigns;


-- ============================================================
-- 2.6 : CHECK DATE RANGE
-- ============================================================

SELECT
    MIN(campaign_date) AS oldest_date,
    MAX(campaign_date) AS latest_date
FROM nykaa_campaigns;
-- Run same for purplle_campaigns and tira_campaigns


-- ============================================================
-- 2.7 : BASIC STATISTICS ON NUMERIC COLUMNS
-- ============================================================

SELECT
    ROUND(AVG(impressions), 0)   AS avg_impressions,
    ROUND(AVG(clicks), 0)        AS avg_clicks,
    ROUND(AVG(conversions), 0)   AS avg_conversions,
    ROUND(AVG(revenue), 0)       AS avg_revenue,
    ROUND(AVG(roi), 2)           AS avg_roi,
    MIN(revenue)                 AS min_revenue,
    MAX(revenue)                 AS max_revenue
FROM nykaa_campaigns;
