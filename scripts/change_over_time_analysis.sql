-- Analyze Sales Performance Over Time

select * from gold.fact_sales 

select 
year(order_date) as order_year,
month(order_date) as order_month,
sum(sales_amount)  as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date) , month(order_date)
order by year(order_date) , month(order_date)
