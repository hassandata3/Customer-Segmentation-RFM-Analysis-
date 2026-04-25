
-- EXPLORE DATA

SELECT *
from INFORMATION_SCHEMA.TABLES


SELECT *
from INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ecommerce_cust'

UPDATE dbo.ecommerce_cust
SET customer_gender = 'Preferred not to say'
WHERE customer_gender = 'Other'

SELECT *
FROM dbo.ecommerce_customers

SELECT DISTINCT product_category from dbo.ecommerce_customers
SELECT DISTINCT payment_method from dbo.ecommerce_customers

SELECT 
MIN(order_date) as first_order,
MAX(order_date) as last_order,
DATEDIFF(YEAR ,MIN(order_date),MAX(order_date)) as years_range
FROM dbo.ecommerce_customers

SELECT 
MIN(customer_age) as youngest_cust , MAX(customer_age) as oldest_cust
FROM dbo.ecommerce_customers

SELECT payment_method  ,count(customer_id) as cust_count
FROM dbo.ecommerce_customers
group by payment_method 
order by cust_count desc

SELECT product_category  ,count(customer_id) as cust_count
FROM dbo.ecommerce_customers
group by product_category
order by cust_count desc

Select 
year(order_date) as order_yaer,
month(order_date) as order_month ,
SUM(order_value_usd) as total_sales,
COUNT(DISTINCT customer_id) as total_customers       
from dbo.ecommerce_customers
where order_date is not null
group by year(order_date) ,month(order_date)
order by year(order_date) ,month(order_date)

Select 
DATETRUNC(MONTH, order_date) as order_date,
SUM(order_value_usd) as total_sales,
COUNT(DISTINCT customer_id) as total_customers
from dbo.ecommerce_customers
where order_date is not null
group by DATETRUNC(MONTH, order_date)
order by DATETRUNC(MONTH, order_date)



----- RFM seg
Create view rfm_seg as
WITH rfm_1 as
(
SELECT 
customer_id ,
   DATEDIFF( day , MAX(order_date) , '2025-01-01') AS recency ,
     COUNT(*) AS frequency ,
       ROUND(SUM(order_value_usd) , 2) as monetary ,
         MIN(order_date)                                             AS first_order_date,
           MAX(order_date)                                             AS last_order_date
FROM dbo.ecommerce_customers
group by customer_id
) ,
rfm_2 as (
SELECT * , 
ROW_NUMBER() OVER(ORDER BY recency asc ) r_rank ,
ROW_NUMBER() OVER(ORDER BY frequency desc ) f_rank ,
ROW_NUMBER() OVER(ORDER BY monetary desc ) m_rank 
FROM rfm_1) ,
rfm_3 as
(
SELECT * , 
NTILE(10) OVER(ORDER BY r_rank asc ) r_score ,
NTILE(10) OVER(ORDER BY f_rank asc ) f_score ,
NTILE(10) OVER(ORDER BY m_rank asc ) m_score
FROM rfm_2) ,
rfm_4 as
(
SELECT 
customer_id , recency , frequency , monetary , r_score , f_score , m_score ,
(r_score + f_score + m_score) as rfm_total_score
FROM rfm_3
) ,
rfm_5 as
(
SELECT customer_id , recency , frequency , monetary , r_score , f_score , m_score , rfm_total_score ,
CASE
    WHEN rfm_total_score >= 28 THEN 'Champions'
    WHEN rfm_total_score >= 24 THEN 'Loyal'
    WHEN rfm_total_score >= 20 THEN 'Potential Loyalists'
    WHEN rfm_total_score >= 16 THEN 'Promising'
    WHEN rfm_total_score >= 12 THEN 'Engaged'
    WHEN rfm_total_score >= 8 THEN 'Requires Attention'
    WHEN rfm_total_score >= 4 THEN 'At Risk'
    ELSE 'Lost'
END as rfm_seg
FROM rfm_4
)
SELECT *
FROM rfm_5




----- General seg
Create view general_seg as
SELECT customer_id , customer_age ,
CASE 
    when customer_age <= 24 then '18-24'
    when customer_age <= 34 then '25-34'
    when customer_age <= 44 then '35-44'
    when customer_age <= 54 then '45-54'
    when customer_age <= 64 then '55-64'
    else '65-69' end as age_groups,
customer_gender , payment_method , product_category , order_value_usd 
from ecommerce_customers 


