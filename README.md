# 🛍️ Multi-Brand Beauty Marketing Campaign Analysis
### SQL + Power BI | PostgreSQL | Indian Beauty Industry

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-In%20Progress-orange)
![Domain](https://img.shields.io/badge/Domain-Marketing%20Analytics-pink)

---

## 📌 Project Overview

This project analyzes marketing campaign performance across **three major Indian beauty brands** — Nykaa, Purplle, and Tira — using real-world style data covering **1,66,665 campaigns** over **12 months (July 2024 to May 2025)**.

The goal is to extract actionable marketing insights through structured SQL analysis and visualize them in a Power BI dashboard — simulating the end-to-end workflow of a data analyst in the beauty/e-commerce industry.

---

## 🎯 Business Objectives

- Compare marketing performance across 3 competing beauty brands
- Identify the most efficient campaign types, channels, and customer segments
- Analyze revenue trends over time (monthly and quarterly)
- Answer 10 real-world business questions a marketing manager would ask
- Build an interactive Power BI dashboard for stakeholder reporting

---

## 🗂️ Dataset Description

| Property | Details |
|---|---|
| Source | Kaggle — Multi-Brand Marketing Campaign Performance Dataset |
| Brands | Nykaa, Purplle, Tira |
| Rows | 55,555 per brand (1,66,665 total) |
| Time Period | July 2024 — June 2025 |
| Format | CSV (3 separate files, one per brand) |

### Columns
| Column | Description |
|---|---|
| Campaign_ID | Unique identifier per campaign |
| Campaign_Type | Email, SEO, Paid Ads, Social Media, Influencer |
| Channel_Used | Instagram, Google, YouTube, Facebook, WhatsApp, Email |
| Customer_Segment | College Students, Premium Shoppers, Working Women, Youth, Tier 2 City |
| Impressions | Number of people who saw the ad |
| Clicks | Number of people who clicked |
| Leads | Number of interested prospects |
| Conversions | Number of actual purchases |
| Revenue | Revenue generated |
| Acquisition_Cost | Ad spend |
| ROI | Return on Investment |
| Language | Hindi, English, Tamil, Bengali |
| Engagement_Score | Campaign engagement metric |
| Campaign_Date | Date campaign ran |
| Duration | Campaign length in days |

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL | Data storage, cleaning, and SQL analysis |
| pgAdmin 4 | PostgreSQL GUI |
| Power BI | Interactive dashboard (coming soon) |

---

## 📁 Project Structure

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
│   └── 07_powerbi_view.sql          → Final enriched view for Power BI
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

## 📊 Analysis Structure

### KPI Framework
| KPI | Formula | Meaning |
|---|---|---|
| CTR | Clicks / Impressions × 100 | Ad visibility effectiveness |
| CVR | Conversions / Clicks × 100 | Purchase intent strength |
| ROAS | Revenue / Acquisition Cost | Return on ad spend |
| CPL | Acquisition Cost / Leads | Cost to get one interested person |
| CPC | Acquisition Cost / Clicks | Cost per click |

### Analysis Dimensions
- Brand level (Nykaa vs Purplle vs Tira)
- Campaign Type (Email, SEO, Paid Ads, Social Media, Influencer)
- Channel (Instagram, Google, YouTube, Facebook, WhatsApp, Email)
- Customer Segment (5 segments)
- Language (Hindi, English, Tamil, Bengali)
- Campaign Duration (Short, Medium, Long, Extra Long)
- Time (Monthly and Quarterly trends)

---

## 💡 Key Insights

### Brand Performance
- All 3 brands show comparable KPIs — CTR ~8.5% and CVR ~22% — reflecting the synthetic nature of the dataset
- Tira emerges as the most **consistent** brand with lowest revenue standard deviation (₹6.47 Cr)
- Nykaa generates highest average monthly revenue but is most **volatile** (stddev ₹9.49 Cr)

### Campaign Type
- **Paid Ads** deliver highest ROAS for Purplle (1397) and Tira (1418)
- **Social Media** is Nykaa's strongest campaign type by ROAS (1386)
- **Influencer** campaigns show highest variance — Star for Nykaa but Underperformer for Tira
- **SEO** consistently underperforms across all 3 brands

### Channel Performance
- **Email** is top ROAS channel for Nykaa (1389) and Purplle (1382)
- **Instagram** leads for Tira (1397) — reflecting its visual-first brand strategy
- **Google** ranks last for all 3 brands — confirming beauty is a visual discovery category

### Customer Segments
- **Working Women** are Nykaa's most valuable segment (ROAS 1383)
- **College Students** drive Purplle's best returns (ROAS 1391)
- **Youth** is Tira's golden segment — Youth + Instagram delivers the highest ROAS (1461) in the entire dataset

### Time Trends
- **February** is a universal dip month across all brands due to shorter month (28 days)
- **March** is a universal recovery month — all 3 brands bounce back strongly
- **Q2 FY (Oct-Dec)** drives highest absolute revenue — pre-Diwali shopping period
- **Q3 FY (Jan-Mar)** delivers highest ROAS for Purplle and Tira — post-festive efficiency window

### Business Questions Highlights
- **BQ3** — Top campaign (Nykaa NY-CMP-13007) achieved CTR of 14.7% and CVR of 45.7% — nearly double the dataset average
- **BQ4** — Tira has 80% monthly recovery rate vs Nykaa's 67% — most resilient brand
- **BQ7** — CTR-CVR-ROAS matrix reveals Paid Ads performs differently for each brand — Tira (Star), Purplle (Converter), Nykaa (Awareness)
- **BQ8** — Tamil is Tira's strongest language (ROAS 1391) — suggesting strong South India market penetration
- **BQ10** — All 3 brands recovered from February dip in March — confirming structural rather than strategic cause

---

## 🔍 Analyst Notes

> **Dataset Transparency:** This dataset is synthetically generated. Several patterns (identical CPL/CPC across brands, absence of festive season spikes, unrealistically high ROAS) reflect this. All analysis is performed on the data as-is, with anomalies flagged and explained — demonstrating real-world data validation practices.

---

## 📈 Power BI Dashboard — Coming Soon

Planned dashboard pages:
- Executive Overview (KPI summary cards)
- Brand Comparison
- Campaign Type & Channel Analysis
- Customer Segment Deep Dive
- Time Series Trends

---

## 👩 Author

**Muskan**
Aspiring Data Analyst | SQL • Excel • Power BI

---

## 📂 How to Run This Project

1. Install PostgreSQL and pgAdmin
2. Create a new database
3. Run `01_create_tables.sql` to create tables
4. Update file paths in COPY commands to your local path
5. Run files in order: 01 → 02 → 03 → 04 → 05 → 06 → 07
6. Connect Power BI to `vw_marketing_analysis` view
