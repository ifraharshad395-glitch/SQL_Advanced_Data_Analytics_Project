/* Analyze the yearly performance of the products by comparing their sales to both the average sales performance and 
the previous year's sales */

select * from gold.fact_sales
select * from gold.dim_products


with yearly_product_sales as (
select 
year(s.order_date) as order_year, 
p.product_name,
sum(s.sales_amount) as current_sales
from gold.fact_sales as s left join gold.dim_products as p 
on s.product_key = p.product_key
where s.order_date is not null
group by year(s.order_date), p.product_name 
)

select 
order_year,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) as avg_sales,
(current_sales - avg(current_sales) over(partition by product_name)) as diff_avg,
case 
	when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'Below Average'
	when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above Average'
	else 'Average'
end as avg_change,
lag(current_sales) over(partition by product_name order by order_year) as previous_year_sales,
(current_sales - lag(current_sales) over(partition by product_name order by order_year)) as diff_previous_sales,
case 
	when current_sales - lag(current_sales) over(partition by product_name order by order_year) < 0 then 'Decrease'
	when current_sales - lag(current_sales) over(partition by product_name order by order_year) > 0 then 'Increase'
	else 'No change'
end as previous_year_change
from yearly_product_sales
order by product_name, order_year
