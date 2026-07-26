-- Calculate Total Sales Per Month and Running total Sales Over Time

select * from gold.fact_sales

--month wise 

select 
order_date,
total_sales,
sum(total_sales) over (partition by order_date order by order_date) as running_total_sales,
avg(average_price) over (partition by order_date order by order_date) as moving_average_price
from (
select 
datetrunc(month, order_date) as order_date, 
sum(sales_amount) as total_sales,
avg(price) as average_price
from gold.fact_sales
where order_date is not null
group by datetrunc(month, order_date)
) t 
order by order_date

--year wise

select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sales,
avg(avg_price) over (order by order_date) as moving_average_price
from (
select 
datetrunc(year, order_date) as order_date, 
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by datetrunc(year, order_date)
) t 
order by order_date
