
--  append all monthly sales tables
create or replace table `rfm-analysis-491423.sales.sales2025` as
select * from `rfm-analysis-491423.sales.sales202501`
union all select * from `rfm-analysis-491423.sales.sales202502`
union all select * from `rfm-analysis-491423.sales.sales202503`
union all select * from `rfm-analysis-491423.sales.sales202504`
union all select * from `rfm-analysis-491423.sales.sales202505`
union all select * from `rfm-analysis-491423.sales.sales202506`
union all select * from `rfm-analysis-491423.sales.sales202507`
union all select * from `rfm-analysis-491423.sales.sales202508`
union all select * from `rfm-analysis-491423.sales.sales202509`
union all select * from `rfm-analysis-491423.sales.sales202510`
union all select * from `rfm-analysis-491423.sales.sales202511`
union all select * from `rfm-analysis-491423.sales.sales202512`;

-- Calculate recency, frequency, monetary, r, f, m ranks
-- combine views by CTE's
create or replace view `rfm-analysis-491423.sales.rfm_metrics`
as
with current_date as (
  select date('2026-03-06') as analysis_date --todays date
  
),
rfm as 
(
  select
  CustomerID,
  max(OrderDate) as last_order_date,
  date_diff((select analysis_date from current_date),max(OrderDate), day) as  recency,
  count(*) as frequency,
  sum(OrderValue) as monetary

  from `rfm-analysis-491423.sales.sales2025`

  group by CustomerID 
)

select 
  rfm.*,
  row_number() over(order by recency asc) as r_rank,
  row_number() over(order by frequency desc) as f_rank,
  row_number() over(order by monetary desc) as m_rank
from rfm;      




-- Assining deciles (10=best and 1=worst)
create or replace view `rfm-analysis-491423.sales.rfm_scores`
as
select 
 *,
 ntile(10) over(order by r_rank desc) as r_score,
 ntile(10) over(order by f_rank desc) as f_score,
 ntile(10) over(order by m_rank desc) as m_score

 from `rfm-analysis-491423.sales.rfm_metrics`



-- Total Scores
create or replace view `rfm-analysis-491423.sales.rfm_total_scores`
as 
select
  CustomerID,
  frequency,
  recency,
  monetary,
  r_score,
  f_score,
  m_score,
  (r_score + f_score + m_score) as rfm_total_score

from `rfm-analysis-491423.sales.rfm_scores`





-- BI ready rfm segments table

create or replace view `rfm-analysis-491423.sales.rfm_segments_final`
as 
select
  CustomerID,
  frequency,
  recency,
  monetary,
  r_score,
  f_score,
  m_score,
  rfm_total_score,
  case
    when rfm_total_score >= 28 then 'champions' 
    when rfm_total_score >= 24 then 'loyal VIPs' 
    when rfm_total_score >= 20 then 'potential loyalist' 
    when rfm_total_score >= 16 then 'promising' 
    when rfm_total_score >= 12 then 'engaged' 
    when rfm_total_score >= 8 then 'requires attention' 
    when rfm_total_score >= 4 then 'at risk'

    else 'lost/inactive' 

  end as rfm_segments

from `rfm-analysis-491423.sales.rfm_total_scores`







