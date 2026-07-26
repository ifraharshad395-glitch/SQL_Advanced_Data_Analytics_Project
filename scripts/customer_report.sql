/*
Customer Report
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
*/

create or alter view gold.report_customers as
with base_query as (
select 
s.order_number, 
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
datediff(year, c.birthdate, getdate()) as customer_age
from gold.fact_sales as s left join gold.dim_customers as c 
on s.customer_key = c.customer_key
where order_date is not null
) 
, customer_aggregation as (
select 
customer_key,
customer_number,
customer_name,
customer_age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(order_date) as last_order_date,
datediff(month, min(order_date), max(order_date)) as life_span
from base_query
group by 
	customer_key,
	customer_number,
	customer_name,
	customer_age
)

select 
customer_key,
customer_number,
customer_name,
customer_age,
case 
	when life_span >= 12 and total_sales > 5000 then 'VIP'
	when life_span >= 12 and total_sales <= 5000 then 'Regular'
	else 'New'
end as customer_segment,
last_order_date,
datediff(month, last_order_date, getdate()) as recency,
case
	when customer_age < 20 then 'Underage'
	when customer_age between 20 and 29 then '20-29'
	when customer_age between 30 and 39 then '30-39'
	when customer_age between 40 and 49 then '40-49'
	else '50 and above'
end as age_group,
total_orders,
total_sales,
total_quantity,
total_products,
life_span,
total_sales / total_orders as avg_order_value,
case 
	when life_span = 0 then total_sales
	else total_sales / life_span
end as avg_monthly_spend
from customer_aggregation

select * from gold.report_customers
