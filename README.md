RFM Customer Segmentation Analysis
Project Overview
This project performs RFM (Recency, Frequency, Monetary) analysis on 2025 sales data to segment customers into actionable groups using Google BigQuery for data transformation and Power BI for visualization.

Project Files
FileDescriptionrfm_analysis.sqlAll BigQuery SQL — data prep, metrics, scoring, and segmentationvisualization.pbixPower BI dashboard with RFM segment charts and customer-level visuals

SQL Pipeline
Step 1 — Consolidate Monthly Sales
Appends all 12 monthly tables into one unified sales2025 table using UNION ALL.
Step 2 — Calculate RFM Metrics (rfm_metrics)
Groups by CustomerID and calculates:

Recency — days since last order
Frequency — total orders placed
Monetary — total spend
r_rank / f_rank / m_rank — ROW_NUMBER() rankings per dimension

Step 3 — Assign Decile Scores (rfm_scores)
Uses NTILE(10) to score each customer 1–10 per dimension (10 = best).
Step 4 — Total Score (rfm_total_scores)
sql(r_score + f_score + m_score) AS rfm_total_score  -- Range: 3 to 30
Step 5 — Segment Assignment (rfm_segments_final)
Score RangeSegment28 – 30🏆 Champions24 – 27⭐ Loyal VIPs20 – 23🌱 Potential Loyalist16 – 19🔼 Promising12 – 15💬 Engaged8 – 11⚠️ Requires Attention4 – 7🔻 At Risk0 – 3💤 Lost / Inactive

Source Data Schema
ColumnTypeDescriptionCustomerIDSTRING / INTUnique customer identifierOrderDateDATEDate the order was placedOrderValueFLOAT / NUMERICTotal value of the order

How to Run

Open BigQuery console for project rfm-analysis-491423
Run rfm_analysis.sql top to bottom — views must run in order
Verify all 4 views exist in the sales dataset
Open visualization.pbix in Power BI Desktop and refresh data
