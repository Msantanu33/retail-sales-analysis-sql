-- SQL retail sales analysis
CREATE DATABASE da_projects;


DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales
			(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),
				age INT,
				category VARCHAR(15),
				quantiy INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
								);
-- after importing the  data 
SELECT * FROM retail_sales;	

alter table retail_sales
 rename column quantiy to quantity;

--DATA CLEANING

--checking null rows 
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	TRANSACTIONS_ID IS NULL
	OR SALE_DATE IS NULL
	OR SALE_TIME IS NULL
	OR GENDER IS NULL
	OR AGE IS NULL
	OR CATEGORY IS NULL
	OR QUANTITY IS NULL
	OR PRICE_PER_UNIT IS NULL
	OR COGS IS NULL
	OR TOTAL_SALE IS NULL;

-- removing null rows 

DELETE FROM RETAIL_SALES
WHERE
	TRANSACTIONS_ID IS NULL
	OR SALE_DATE IS NULL
	OR SALE_TIME IS NULL
	OR GENDER IS NULL
	OR AGE IS NULL
	OR CATEGORY IS NULL
	OR QUANTITY IS NULL
	OR PRICE_PER_UNIT IS NULL
	OR COGS IS NULL
	OR TOTAL_SALE IS NULL;
	
-- DATA EXPLORATION
--Number of sales:
SELECT
	COUNT(*) AS TOTAL_SALE
FROM
	RETAIL_SALES;

--Total unique customers we have
SELECT
	COUNT(DISTINCT CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM
	RETAIL_SALES

--Categories
SELECT DISTINCT
	CATEGORY FROM RETAIL_SALES;

--DATA ANALYSIS & BUSINESS KEY PROBLEMS_ANSWERS

--1.retrieve all columns for sales made on '2022-11-05'
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	SALE_DATE = '2022-11-05';
	
--2.retrieve all transactions where the category is clothing and quantity more than 4 in nov-2022

SELECT
	*
FROM
	RETAIL_SALES
WHERE
	CATEGORY = 'Clothing'
	AND QUANTITY >= 4
	AND TO_CHAR(SALE_DATE, 'yyyy-mm') = '2022-11';

--3.total no of sales for each category

select 
	category,
	sum(total_sale) as net_sale,
	count(*) as total_orders
from retail_sales
	group by category;

--4.avg age of customers purchased items from "beauty" category
SELECT
	ROUND(AVG(AGE), 2) AS AVG_AGE
FROM
	RETAIL_SALES
WHERE
	CATEGORY = 'Beauty';

--5.all transactions where total_sale is greater than 1000;
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	TOTAL_SALE >1000;
	
--6.total no of transaction(t_id) made by each gender in each category

SELECT
	CATEGORY,
	GENDER,
	COUNT(*) AS TOTAL_TRANSACTION
FROM
	RETAIL_SALES
GROUP BY
	CATEGORY,
	GENDER
ORDER BY 1;         --1:category

--7.avg sale for each month, find best selling month in each year

SELECT 
    year, 
    month, 
    avg_total_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_total_sale,
        DENSE_RANK() OVER (ORDER BY AVG(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY 
        EXTRACT(YEAR FROM sale_date),
        EXTRACT(MONTH FROM sale_date)
) AS t1
WHERE rnk = 1;

--8.top 5 customers based on the highest total sales

SELECT
	CUSTOMER_ID,
	SUM(TOTAL_SALE) AS TOTAL_SALES
FROM
	RETAIL_SALES
GROUP BY
	1
ORDER BY
	2 DESC 
LIMIT
	5;

--9.No. of unique customers who purchased items from each category

select category,
	count(distinct customer_id) as unique_customers
	from retail_sales
	group by category;

--10.Create each shift and number of orders(ex: morning<12,afternon beetween 12 & 17, evening>17)

WITH
	HOURLY_SALE AS (
		SELECT
			*,
			CASE
				WHEN EXTRACT(
					HOUR
					FROM
						SALE_TIME
				) < 12 THEN 'Morning'
				WHEN EXTRACT(
					HOUR
					FROM
						SALE_TIME
				) BETWEEN 12 AND 17  THEN 'Afernoon'
				ELSE 'Evening'
			END AS SHIFT
		FROM
			RETAIL_SALES
	)
SELECT
	SHIFT,
	COUNT(*) AS TOTAL_ORDERS
FROM
	HOURLY_SALE
GROUP BY
	SHIFT;