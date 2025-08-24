-- create database called 'retail_db'
CREATE DATABASE retail_db;


-- create table called 'retail_sales'
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

-- create a retail sales
select * from retail_sales;

-- To count 
select count(*) from retail_sales;

ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;


-- Data Cleaning
select * from retail_sales
WHERE 
	transactions_id is null
	or 
	sale_date is null
	or
	sale_time is null
	or
	customer_id is null
	or
	gender is null
	or
	category is null
	or
	quantity is null
	or
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null;

-- Missing values
delete from retail_sales
WHERE 
	transactions_id is null
	or 
	sale_date is null
	or
	sale_time is null
	or
	customer_id is null
	or
	gender is null
	or
	category is null
	or
	quantity is null
	or
	price_per_unit is null
	or
	cogs is null
	or
	total_sale is null;

-- Data Exploration

-- 1. How many sales we have?
select count(*) as total_sales from retail_sales;

-- 2. How many unique customers we have?
select count(distinct customer_id) from retail_sales;

-- 3. How many unique category we have?
select distinct category from retail_sales;

-- Data Analysis and Business Key Problems & Answers

-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05
select * from retail_sales
where sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
select * from retail_sales
where category = 'Clothing' 
and quantity >= 4
and sale_date between '2022-11-01' and '2022-11-30';

-- 3. Write a SQL query to calculate the total sales (total_sale) for each category.
select category, sum(total_sale) as total_sales, count(*) as total_orders from retail_sales
group by category;

-- 4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select round(avg(age), 2) as avg_age 
from retail_sales 
where category = 'Beauty';

-- 5. Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales
where total_sale > 1000;

-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select category, gender, count(transactions_id) as total_trans
from retail_sales
group by category, gender
order by category;

-- 7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
with avg_sale as
(
	select 
		extract(year from sale_date) as year,
		extract(month from sale_date) as month, 
		avg(total_sale) as avg_sale
	from retail_sales
	group by year, month
), 
rnk as
(
	select  
		year, 
		month, 
		avg_sale, 
		rank() over (partition by year order by avg_sale desc) as rnk 
	from avg_sale
) select 
	year, 
	month, 
	avg_sale 
from rnk
where rnk = 1;

-- 8. **Write a SQL query to find the top 5 customers based on the highest total sales**
select customer_id, sum(total_sale) as total_sales 
from retail_sales
group by customer_id
order by total_sales desc
limit 5;

-- 9. Write a SQL query to find the number of unique customers who purchased items from each category.
select category, count(distinct customer_id) as customers from retail_sales
group by category;

-- 10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
with hourly_sales as
(
	select *,
		case 
			when extract(hour from sale_time) < 12 then 'Morning' 
			when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
			else 'Evening'
		end as shift
	from retail_sales
) select shift, count(*) as total_orders from hourly_sales group by shift;

-- 11. Which age group (e.g., <25, 25-40, 40-60, 60+)spends the most?
with age_group_sales as
(
	select *,
		case 
			when age < 25 then 'Under 25'
			when age between 25 and 40 then '25 - 40'
			when age between 40 and 60 then '40 - 60'
			else 'Above 60'
		end as age_group
	from retail_sales
) select age_group, sum(total_sale) as total_sales
from age_group_sales
group by age_group;

-- 12. Which product category generates the highest total profit, and what is the average profit per unit for each category?
select 
	category, 
	sum(total_sale - cogs) as total_profit,
	avg((total_sale - cogs) / quantity) as avg_profit_per_unit
from retail_sales
group by category
order by total_profit desc;


-- END OF PROJECT