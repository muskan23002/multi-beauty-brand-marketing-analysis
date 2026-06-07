-- ============================================================
-- STEP 1 : CREATE COMBINED MASTER TABLE
-- Using UNION ALL to preserve all rows from all 3 brands
-- Adding 'brand' column to identify each brand's data
-- ============================================================

CREATE TABLE all_campaigns AS
SELECT 'Nykaa'   AS brand, * FROM nykaa_campaigns
UNION ALL
SELECT 'Purplle' AS brand, * FROM purplle_campaigns
UNION ALL
SELECT 'Tira'    AS brand, * FROM tira_campaigns;


-- ============================================================
-- STEP 2 : VERIFY COMBINED TABLE
-- Total should be 166,665 rows (55,555 x 3 brands)
-- Each brand should show exactly 55,555 rows
-- ============================================================

-- Total row count
SELECT COUNT(*) AS total_rows FROM all_campaigns;

-- Row count per brand
SELECT brand, COUNT(*) AS total_rows
FROM all_campaigns
GROUP BY brand
ORDER BY brand;
