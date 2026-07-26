/* Segment products into cost ranges and count how many products fall into each segment */

select * from gold.dim_products

with product_segments as (
select 
product_key,
product_name,
cost,
case
	when cost < 100 then 'Below 100'
	when cost between 100 and 500 then '100-500'
	when cost between 500 and 1000 then '500-1000'
	else 'Above 1000'
end as cost_range
from gold.dim_products
)

select 
cost_range,
count(product_key) as total_products
from product_segments 
group by cost_range
order by total_products desc 



/* Group customers into three segments based on their spending behavior:
	VIP: customers with at least 12 moths of history and spending more than euro5,000
	Regular: customers with at least 12 moths of history euro5,000 or less
	New: customers with a lifespan less than 12 months
And find the total number of customers by each group */

select * from gold.fact_sales
select * from gold.dim_customers


with customer_spending as (
select 
c.customer_key,
sum(s.sales_amount) as total_spendings,
min(s.order_date) as first_order,
max(s.order_date) as last_order,
datediff(month, min(s.order_date), max(s.order_date)) as life_span
from gold.fact_sales as s left join gold.dim_customers as c
on s.customer_key = c.customer_key
group by c.customer_key
)

select 
customer_segment,
count(customer_key) as total_customers
from 
(
select 
customer_key,
case 
	when life_span >= 12 and total_spendings > 5000 then 'VIP'
	when life_span >= 12 and total_spendings <= 5000 then 'Regular'
	else 'New'
end as customer_segment
from customer_spending
) t 
group by customer_segment
order by total_customers desc
