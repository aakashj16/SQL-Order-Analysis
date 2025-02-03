-- customer lifetime value
select
oc.customer_id, concat(oc.customer_first_name, " ", oc.customer_last_name) as customer_name, sum(oi.product_quantity * p.product_price) as customer_lifetime_value
from online_customers as oc
join order_header as oh on oc.customer_id = oh.customer_id
join order_items as oi on oh.order_id = oi.order_id
join products as p on oi.product_id = p.product_id
group by oc.customer_id, customer_name
order by customer_lifetime_value desc;

-- top 10 highest spending customers this quarter
select
oc.customer_id, concat(oc.customer_first_name, " ", oc.customer_last_name) as customer_name, sum(oi.product_quantity * p.product_price) as total_purchase_value
from online_customers as oc
join order_header as oh on oc.customer_id = oh.customer_id
join order_items as oi on oh.order_id = oi.order_id
join products as p on oi.product_id = p.product_id
where (year(oh.order_date) = year("2024-12-31")) and (quarter(oh.order_date) = quarter("2024-12-31"))
group by oc.customer_id, customer_name
order by total_purchase_value desc
limit 10;

-- average order value by customer segment
select
case
	when oc.customer_gender = "M" then "Male"
    when oc.customer_gender = "F" then "Female"
    else "Others"
end as customer_gender,
sum(oi.product_quantity * p.product_price) as total_revenue,
round(sum(oi.product_quantity * p.product_price) * 100 / sum(sum(oi.product_quantity * p.product_price)) over(), 2) as percentage_total_revenue
from online_customers as oc
join order_header as oh on oc.customer_id = oh.customer_id
join order_items as oi on oh.order_id = oi.order_id
join products as p on oi.product_id = p.product_id
group by customer_gender
order by total_revenue desc;

-- customer retention: customers who placed at least 2 orders this year
select
oc.customer_id, concat(oc.customer_first_name, " ", oc.customer_last_name) as customer_name, count(oh.order_id) as number_of_orders
from online_customers as oc
join order_header as oh on oc.customer_id = oh.customer_id
where oh.order_status != "Cancelled" and year(oh.order_date) = year("2024-12-31")
group by oc.customer_id, customer_name
having number_of_orders >= 2
order by oc.customer_id asc;

-- churned customers
with cte as
(
	select
	oc.customer_id, concat(oc.customer_first_name, " ", oc.customer_last_name) as customer_name, oc.customer_email_id,
	datediff("2024-12-31", max(oh.order_date)) as days_since_last_order
	from online_customers as oc
	join order_header as oh on oc.customer_id = oh.customer_id
	group by oc.customer_id, customer_name
	having days_since_last_order > 90
	order by oc.customer_id
)
select
customer_id, customer_name, customer_email_id
from cte;

-- products with highest sales volume this quarter
select 
p.product_id, sum(oi.product_quantity) as total_quantity_ordered
from products as p
join order_items as oi on p.product_id = oi.product_id
join order_header as oh on oi.order_id = oh.order_id
where year(oh.order_date) = year("2024-12-31") and quarter(oh.order_date) = quarter("2024-12-31")
group by p.product_id
order by total_quantity_ordered desc
limit 10;

-- products with highest revenue this quarter
select
p.product_id, sum(oi.product_quantity * p.product_price) as total_revenue
from products as p
join order_items as oi on p.product_id = oi.product_id
join order_header as oh on oi.order_id = oh.order_id
where year(oh.order_date) = year("2024-12-31") and quarter(oh.order_date) = quarter("2024-12-31")
group by p.product_id
order by total_revenue desc
limit 10;

-- order cancellation rate this year
with cte as
(
	select count(order_id) as total_orders
    from order_header
    where year(order_date) = year("2024-12-31")
)
select
month_name, number_of_orders_cancelled,
round(number_of_orders_cancelled * 100 / (select total_orders from cte), 2) as percentage_orders_cancelled
from
(
	select
	month(order_date) as month_, monthname(order_date) as month_name, count(order_id) as number_of_orders_cancelled
	from order_header
	where order_status = "Cancelled" and year(order_date) = year("2024-12-31")
	group by month_, month_name
	order by month_ asc
) as x;

-- potential stockout risk
select
p.product_id, sum(oi.product_quantity) as total_quantity_ordered_last_month, p.product_quantity_available
from products as p
join order_items as oi on p.product_id = oi.product_id
join order_header as oh on oi.order_id = oh.order_id
where year(order_date) = year(2024-12-13) and month(order_date) = month("2024-12-31") - 1
group by product_id
having total_quantity_ordered_last_month > product_quantity_available
order by total_quantity_ordered_last_month desc;

-- average order value by product category
select
pc.product_class_description, round(avg(p.product_price * oi.product_quantity), 2) as average_order_value
from products as p
join product_class as pc on p.product_class_code = pc.product_class_code
join order_items as oi on p.product_id = oi.product_id
join order_header as oh on oi.order_id = oh.order_id
group by pc.product_class_description
order by average_order_value desc;

-- number of orders catered by each shipper
select
s.shipper_name, count(order_id) as number_of_orders,
round(count(order_id) * 100 / sum(count(order_id)) over(), 2) as percentage_orders
from shipper as s
join order_header as oh on s.shipper_id = oh.shipper_id
group by s.shipper_name
order by number_of_orders desc;

-- pending deliveries of last month
select
s.shipper_name, count(oh.order_id) as pending_deliveries_last_month
from order_header as oh
join shipper as s on oh.shipper_id = s.shipper_id
where year(oh.order_date) = year("2024-12-31") and month(oh.order_date) = month("2024-12-31") - 1 and oh.order_status = "Pending"
group by s.shipper_name
order by pending_deliveries_last_month desc;

-- underpriced products
with 
product_sales as
(
	select
    product_id, sum(product_quantity) as total_quantity_sold
    from order_items
    group by product_id
),
average_category_price as
(
	select
    p.product_class_code, avg(p.product_price) as average_price
    from products as p
    join product_class as pc on p.product_class_code = pc.product_class_code
    group by p.product_class_code
),
high_sales_below_average_price as
(
	select
    ps.product_id, ps.total_quantity_sold, p.product_price, p.product_class_code, acp.average_price, acp.product_class_code as class_code
    from products as p
    join product_sales as ps on p.product_id = ps.product_id
    join average_category_price as acp on p.product_class_code = acp.product_class_code
    where ps.total_quantity_sold > 
    (
		select
        avg(total_quantity_sold) 
        from product_sales
    )
	and p.product_price < acp.average_price
)
select
pc.product_class_description, p.product_id, p.product_price, p.product_quantity_available, 
hsbap.total_quantity_sold, round(hsbap.average_price, 2) as average_class_price
from high_sales_below_average_price as hsbap
join products as p on hsbap.product_id = p.product_id
join product_class as pc on p.product_class_code = pc.product_class_code
order by pc.product_class_description asc, hsbap.total_quantity_sold desc;

-- expected revenues from a price increase for the top-selling products this quarter
select
oi.product_id, sum(oi.product_quantity) as total_quantity_ordered, p.product_price, sum(oi.product_quantity * product_price) as total_revenue_this_quarter,
round(p.product_price * 1.10, 2) as increased_price, round(sum(oi.product_quantity * product_price * 1.1), 2) as expected_revenue
from order_items as oi
join order_header as oh on oi.order_id = oh.order_id
join products as p on oi.product_id = p.product_id
where year(order_date) = year("2024-12-31") and quarter(order_date) = quarter("2024-12-31")
group by oi.product_id
order by total_quantity_ordered desc
limit 25;

-- 	dashboard: current month customer order history
create view current_month_dashboard as
(
	select
	oh.order_date, oh.order_id, oc.customer_id, concat(oc.customer_first_name, " ", oc.customer_last_name) as customer_name, sum(oi.product_quantity) as cart_size,
	sum(oi.product_quantity * p.product_price) as cart_value, oh.payment_mode, s.shipper_name, oh.order_status
	from online_customers as oc
	join order_header as oh on oc.customer_id = oh.customer_id
	join order_items as oi on oh.order_id = oi.order_id
	join products as p on oi.product_id = p.product_id
	join shipper as s on oh.shipper_id = s.shipper_id
	where year(oh.order_date) = year("2024-12-31") and month(oh.order_date) = month("2024-12-31")
	group by oh.order_date, oh.order_id, oc.customer_id, customer_name
	order by oh.order_date asc, order_id asc
);

-- dashboard: weekly sales trend
create view weekly_sales_trend as
(
	with cte as
	(
		select
		weekofyear(oh.order_date) as week_of_year, count(oi.order_id) as number_of_orders, sum(oi.product_quantity) as total_products_sold, 
		sum(oi.product_quantity * p.product_price) as total_revenue,
		lead(sum(oi.product_quantity * p.product_price)) over(order by weekofyear(oh.order_date) desc) as previous_week_revenue
		from order_header as oh
		join order_items as oi on oh.order_id = oi.order_id
		join products as p on oi.product_id = p.product_id
		where year(oh.order_date) = year("2024-12-31")
		group by week_of_year
		order by week_of_year desc
	)
	select 
	week_of_year, number_of_orders, total_products_sold, total_revenue, round((total_revenue / previous_week_revenue - 1) * 100, 2) as percentage_weekly_change
	from cte
);

-- stored procedure: total revenue for a specific customer between specific dates
create procedure customer_revenue(in p_customer_id int, p_start_date date, p_end_date date)
(
	select
	oc.customer_id, concat(oc.customer_first_name, " ", oc.customer_last_name) as customer_name, sum(oi.product_quantity * p.product_price) as total_revenue
	from online_customers as oc
	join order_header as oh on oc.customer_id = oh.customer_id
	join order_items as oi on oh.order_id = oi.order_id
	join products as p on oi.product_id = p.product_id
	where oc.customer_id = p_customer_id and oh.order_date between p_start_date and p_end_date
    group by oc.customer_id
);

-- example usage: customer_revenue
call customer_revenue(76, "2024-12-01", "2024-12-31");

-- moving average: number of order
with daily_orders as
(
	select
    order_date, count(order_id) as order_count
    from order_header
    group by order_date
)
select
order_date, order_count,
round(avg(order_count) over(order by order_date rows between 6 preceding and current row)) as 7_day_moving_average
from daily_orders
group by order_date;

-- moving avergae: sales
with daily_sales as
(
select
	oh.order_date, sum(oi.product_quantity * p.product_price) as total_sales
	from order_header as oh
	join order_items as oi on oh.order_id = oi.order_id
	join products as p on oi.product_id = p.product_id
	group by oh.order_date
	order by oh.order_date
)
select
order_date, total_sales,
round(avg(total_sales) over(order by order_date asc rows between 6 preceding and current row), 2) as 7_day_moving_average
from daily_sales
group by order_date;