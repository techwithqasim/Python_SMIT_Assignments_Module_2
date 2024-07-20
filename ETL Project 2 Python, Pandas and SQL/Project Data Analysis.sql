-- CREATE DATABASE EDA;

-- USE EDA;

-- SELECT * FROM df_orders;

-- DROP TABLE df_orders;

CREATE TABLE df_orders (
		order_id INT PRIMARY KEY,
		order_date DATE,
		ship_mode VARCHAR(20),
		segment VARCHAR(20),
		country VARCHAR(20),
		city VARCHAR(20),
		state VARCHAR(20),
		postal_code VARCHAR(20),
		region VARCHAR(20),
		category VARCHAR(20),
		sub_category VARCHAR(20),
		product_id VARCHAR(50),
		quantity INT,
		discount DECIMAL(7,2),
		sale_price DECIMAL(7,2),
		profit DECIMAL(7,2));

SELECT * FROM df_orders;

-- FIND TOP 10 HIGHEST REVENUE GENERATING PRODUCTS

SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;

-- FIND TOP 5 HIGHEST SELLING PRODUCTS IN EACH REGION

SELECT region, product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY region,product_id
ORDER BY region,sales DESC;

-- -- FIND TOP 5 HIGHEST SELLING PRODUCTS IN EACH REGION WITH CTE

WITH CTE AS (
SELECT region, product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY region,product_id)
SELECT * FROM (
SELECT *
, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
FROM CTE) A
WHERE rn<=5

-- find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023

with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
--order by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month



--for each category which month had highest sales 
with cte as (
select category,format(order_date,'yyyyMM') as order_year_month
, sum(sale_price) as sales 
from df_orders
group by category,format(order_date,'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1






--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc