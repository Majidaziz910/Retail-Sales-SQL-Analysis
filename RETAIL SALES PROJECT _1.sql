####  Retail Store Analysis
 
CREATE DATABASE PROJECT_1;
CREATE TABLE PROJECT_1.Retail_sales
	( 
        transactions_id INT,
        sale_date DATE,
	    sale_time TIME,
		customer_id INT,
	    gender VARCHAR(10),
	    age INT,
		category VARCHAR(20),
	    quantiy INT,
	    price_per_unit FLOAT,
	    cogs FLOAT,
		total_sale FLOAT
    );

## SHOW TABLES 
SELECT * FROM retail_sales
limit 100;

## total count check 
SELECT  COUNT(*)  FROM retail_sales;

## check Null Values 
SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL OR transactions_id = 0
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL OR customer_id = 0
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantiy IS NULL OR quantiy = 0
    OR price_per_unit IS NULL OR price_per_unit = 0
    OR cogs IS NULL OR cogs = 0
    OR total_sale IS NULL OR total_sale = 0;


## DELETE NULL AND ZERO VALUES ---
## Disable safe mode first ---
SET SQL_SAFE_UPDATES = 0;
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL OR TRIM(transactions_id) = '0' OR transactions_id = 0
    OR quantiy IS NULL OR TRIM(quantiy) = '0' OR quantiy = 0
    OR price_per_unit IS NULL OR TRIM(price_per_unit) = '0' OR price_per_unit = 0
    OR cogs IS NULL OR TRIM(cogs) = '0' OR cogs = 0
    OR total_sale IS NULL OR TRIM(total_sale) = '0' OR total_sale = 0;

## Check the count again ---
SELECT COUNT(*) FROM retail_sales;

## DATA EXPLORATION ---
USE project_1;

## How many total records do we have?
SELECT COUNT(*) as total_records FROM retail_sales;

## How many unique customers are there?
SELECT COUNT(DISTINCT customer_id) as unique_customers FROM retail_sales;

## What are the product categories?
SELECT DISTINCT category FROM retail_sales;

## DATA analysis ,busniess problem and answers ---


-- Q.1: Write a SQL query to retrieve all columns for sales made on '2022-11-05'.
-- Q.2: Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022.
-- Q.3: Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4: Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5: Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6: Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7: Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
-- Q.8: Write a SQL query to find the top 5 customers based on the highest total sales.
-- Q.9: Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10: Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17).

##  1. Sales on a specific date
##  Q.1: Retrieve all columns for sales made on '2022-11-05'.

SELECT * FROM retail_sales 
WHERE sale_date = '2022-11-05';


## 2. Specific Category and High Quantity
## Q.2: Transactions where category is 'Clothing' and quantity sold is more than 10 in Nov-2022.

SELECT * FROM retail_sales
WHERE category = 'Clothing' 
  AND quantiy >= 4  -- Adjusted based on your likely data distribution
  AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';

## 3. Total Sales by Category
## Q.3: Calculate the total sales (total_sale) for each category.

SELECT category, SUM(total_sale) AS net_sale
FROM retail_sales
GROUP BY category;


## 4. Average Age by Category
## Q.4: Find the average age of customers who purchased items from the 'Beauty' category.

SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';


## 5. High Value Transactions
## Q.5: Find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000;


##  6. Transactions by Gender and Category
##  Q.6: Find the total number of transactions made by each gender in each category.

SELECT category, gender, COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;


## 7. Best Selling Month
## Q.7: Calculate the average sale for each month. Find out the best selling month in each year.

SELECT year, month, avg_sale FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank_num
    FROM retail_sales
    GROUP BY 1, 2
) as t1
WHERE rank_num = 1;


## 8. Top 5 Customers
## Q.8: Find the top 5 customers based on the highest total sales.

SELECT customer_id, SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;

## 9. Unique Customers by Category
## Q.9: Find the number of unique customers who purchased items from each categor y.

SELECT category, COUNT(DISTINCT customer_id) AS unique_cx
FROM retail_sales
GROUP BY category;


## 10. Sales by Shift
## Q.10: Create shifts (Morning, Afternoon, Evening) and count the number of orders.

WITH hourly_sales AS (
    SELECT *,
        CASE 
            WHEN HOUR(sale_time) < 12 THEN 'Morning'
            WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hourly_sales
GROUP BY shift;
