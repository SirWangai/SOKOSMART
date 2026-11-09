-- Retail Sales & Customer Intelligence Analysis for Duka Smart Electronics
-- This file contains all 46 SQL queries answering the business questions for the assignment.

-- Q1: Retrieve all customer records
select * from customers;

-- Q2: Display customer names, cities, and segments
select customer_name, city, customer_segment from customers;

-- Q3: Find customers living in Nairobi
select * from customers where city = 'Nairobi';

-- Q4: Find customers registered after January 1, 2025
select * from customers where registration_date > '2025-01-01';

-- Q5: Display all unique customer cities
select distinct city from customers;

-- Q6: Retrieve the 10 most recent orders
select * from orders order by order_date desc limit 10;

-- Q7: Find orders with unit prices above KSh 10,000
select * from orders where unit_price > 10000;

-- Q8: Find customers whose names start with A
select * from customers where customer_name like 'A%';

-- Q9: Retrieve orders with quantities between 2 and 5
select * from orders where quantity between 2 and 5;

-- Q10: Find orders paid through M-Pesa
select * from orders where payment_method = 'M-Pesa';

-- Q11: Count all customers.
select count(customer_id) from customers;

-- Q12: Count all orders.
select count(order_id) from orders;

-- Q13: Calculate completed-order revenue.
select round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as total_revenue 
from orders 
where order_status = 'Completed';

-- Q14: Calculate the average completed-order value.
select round(avg(quantity * unit_price * (1 - discount / 100.0)), 2) as avg_order_value 
from orders 
where order_status = 'Completed';

-- Q15: Find the highest and lowest product prices.
select max(unit_price) as highest_price, min(unit_price) as lowest_price 
from orders;

-- Q16: Calculate revenue by product category.
select product_category, round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as category_revenue 
from orders 
where order_status = 'Completed' 
group by product_category;

-- Q17: Count customers by city.
select city, count(customer_id) as customer_count 
from customers 
group by city;

-- Q18: Calculate quantity sold by product.
select product_name, sum(quantity) as total_quantity 
from orders 
group by product_name;

-- Q19: Find categories generating more than KSh 100,000 in revenue.
select product_category, round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as category_revenue 
from orders 
where order_status = 'Completed' 
group by product_category 
having sum(quantity * unit_price * (1 - discount / 100.0)) > 100000;

-- Q20: Calculate the percentage of cancelled orders.
select round(count(*) filter (where order_status = 'Cancelled') * 100.0 / count(*), 2) as cancelled_percentage 
from orders;

-- Q21: Display orders with customer names and cities.
select o.order_id, o.order_date, c.customer_name, c.city 
from orders o 
join customers c on o.customer_id = c.customer_id;

-- Q22: Calculate total spending by customer.
select c.customer_name, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as total_spent 
from customers c 
join orders o on c.customer_id = o.customer_id 
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name;

-- Q23: Identify customers who have never ordered.
select c.customer_name 
from customers c 
left join orders o on c.customer_id = o.customer_id 
where o.order_id is null;

-- Q24: Find the 10 highest-spending customers.
select c.customer_name, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as total_spent 
from customers c 
join orders o on c.customer_id = o.customer_id 
where o.order_status = 'Completed' 
group by c.customer_id, c.customer_name 
order by total_spent desc 
limit 10;

-- Q25: Calculate revenue by customer city.
select c.city, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as city_revenue 
from customers c 
join orders o on c.customer_id = o.customer_id 
where o.order_status = 'Completed' 
group by c.city;

-- Q26: Identify customers with more than five orders.
select c.customer_name, count(o.order_id) as total_orders 
from customers c 
join orders o on c.customer_id = o.customer_id 
group by c.customer_id, c.customer_name 
having count(o.order_id) > 5;

-- Q27: Calculate average customer spending by segment.
-- note: average spending is defined as the total revenue from completed orders per customer, averaged across all purchasing customers in a segment.
/* Evaluated on completed orders only (`order_status = 'Completed'`).
* SUM(quantity * unit_price * (1 - discount / 100.0)) per active purchasing customer.
* The outer query averages these individual customer totals across each
* Customer segments considered (`VIP`, `Corporate`, `Retail`).
*/
with customer_totals as (
    select c.customer_segment, c.customer_id, sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spent
    from customers c
    join orders o on c.customer_id = o.customer_id
    where o.order_status = 'Completed'
    group by c.customer_segment, c.customer_id
)
select customer_segment, round(avg(total_spent), 2) as avg_customer_spending
from customer_totals
group by customer_segment;

-- Q28: Identify the most popular category among VIP customers.
-- note: "popular" is defined here as the highest number of units sold (quantity) in completed orders.
select o.product_category, sum(o.quantity) as total_units_sold
from customers c
join orders o on c.customer_id = o.customer_id
where c.customer_segment = 'VIP' and o.order_status = 'Completed'
group by o.product_category
order by total_units_sold desc
limit 1;

-- Q29: Find customers spending above the average total spending per purchasing customer.
with customer_totals as (
    select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spent
    from customers c
    join orders o on c.customer_id = o.customer_id
    where o.order_status = 'Completed'
    group by c.customer_id, c.customer_name
)
select customer_name, round(total_spent, 2) as total_spent
from customer_totals
where total_spent > (select avg(total_spent) from customer_totals);

-- Q30: Find products priced above the overall average unit price.
select distinct product_name, unit_price
from orders
where unit_price > (select avg(unit_price) from orders);

-- Q31: Use a CTE to identify the three highest-revenue months.
with monthly_revenue as (
    select date_trunc('month', order_date) as order_month, 
           sum(quantity * unit_price * (1 - discount / 100.0)) as revenue
    from orders
    where order_status = 'Completed'
    group by date_trunc('month', order_date)
)
select order_month, round(revenue, 2) as total_revenue
from monthly_revenue
order by revenue desc
limit 3;

-- Q32: Find customers purchasing from at least three categories.
select c.customer_name, count(distinct o.product_category) as categories_bought
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having count(distinct o.product_category) >= 3;

-- Q33: Use a CTE to calculate category revenue, cost, profit, and profit margin.
with category_financials as (
    select product_category,
           sum(quantity * unit_price * (1 - discount / 100.0)) as revenue,
           sum(quantity * cost_price) as cost
    from orders
    where order_status = 'Completed'
    group by product_category
)
select product_category,
       round(revenue, 2) as revenue,
       round(cost, 2) as cost,
       round(revenue - cost, 2) as profit,
       round(((revenue - cost) / nullif(revenue, 0)) * 100.0, 2) as profit_margin_percent
from category_financials;

-- Q34: Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.
with global_latest_date as (
    select max(order_date) as max_date from orders
),
customer_latest_order as (
    select customer_id, max(order_date) as latest_order
    from orders
    where order_status = 'Completed'
    group by customer_id
)
select c.customer_name, clo.latest_order
from customer_latest_order clo
join customers c on clo.customer_id = c.customer_id
cross join global_latest_date gld
where (gld.max_date - clo.latest_order) > 90;

-- Q35: Rank customers by spending using RANK().
with customer_spending as (
    select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spent
    from customers c
    join orders o on c.customer_id = o.customer_id
    where o.order_status = 'Completed'
    group by c.customer_id, c.customer_name
)
select customer_name, 
       round(total_spent, 2) as total_spent,
       rank() over (order by total_spent desc) as spending_rank
from customer_spending;

-- Q36: Number each customer's orders by recency using ROW_NUMBER().
select customer_id, order_id, order_date,
       row_number() over (partition by customer_id order by order_date desc) as order_recency
from orders;

-- Q37: Rank products within categories using DENSE_RANK().
with product_revenue as (
    select product_category, product_name, sum(quantity * unit_price * (1 - discount / 100.0)) as total_revenue
    from orders
    where order_status = 'Completed'
    group by product_category, product_name
)
select product_category, product_name, 
       round(total_revenue, 2) as total_revenue,
       dense_rank() over (partition by product_category order by total_revenue desc) as category_rank
from product_revenue;

-- Q38: Calculate cumulative monthly revenue.
with monthly_revenue as (
    select date_trunc('month', order_date) as order_month,
           sum(quantity * unit_price * (1 - discount / 100.0)) as revenue
    from orders
    where order_status = 'Completed'
    group by date_trunc('month', order_date)
)
select order_month, 
       round(revenue, 2) as monthly_revenue,
       round(sum(revenue) over (order by order_month), 2) as cumulative_revenue
from monthly_revenue;

-- Q39: Compare monthly revenue using LAG().
with monthly_revenue as (
    select date_trunc('month', order_date) as order_month,
           sum(quantity * unit_price * (1 - discount / 100.0)) as revenue
    from orders
    where order_status = 'Completed'
    group by date_trunc('month', order_date)
)
select order_month, 
       round(revenue, 2) as current_month_revenue,
       round(lag(revenue) over (order by order_month), 2) as previous_month_revenue
from monthly_revenue;

-- Q40: Calculate month-over-month revenue growth (%).
with monthly_revenue as (
    select date_trunc('month', order_date) as order_month,
           sum(quantity * unit_price * (1 - discount / 100.0)) as revenue
    from orders
    where order_status = 'Completed'
    group by date_trunc('month', order_date)
),
mom_revenue as (
    select order_month, revenue,
           lag(revenue) over (order by order_month) as prev_revenue
    from monthly_revenue
)
select order_month, 
       round(revenue, 2) as revenue,
       round(((revenue - prev_revenue) / nullif(prev_revenue, 0)) * 100.0, 2) as growth_percentage
from mom_revenue;

-- Q41: Divide customers into four spending groups using NTILE(4).
with customer_spending as (
    select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as total_spent
    from customers c
    join orders o on c.customer_id = o.customer_id
    where o.order_status = 'Completed'
    group by c.customer_id, c.customer_name
)
select customer_name, 
       round(total_spent, 2) as total_spent,
       ntile(4) over (order by total_spent desc) as spending_group
from customer_spending;

-- Q42: Calculate each category's share of total revenue using window functions.
with category_revenue as (
    select product_category, sum(quantity * unit_price * (1 - discount / 100.0)) as revenue
    from orders
    where order_status = 'Completed'
    group by product_category
)
select product_category, 
       round(revenue, 2) as category_revenue,
       round((revenue / sum(revenue) over ()) * 100.0, 2) as revenue_share_percent
from category_revenue;

-- Q43: Create a monthly_sales_summary view (month, orders, revenue, cost, profit). Then SELECT from it.
create or replace view monthly_sales_summary as
select date_trunc('month', order_date) as order_month,
       count(order_id) as total_orders,
       round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as revenue,
       round(sum(quantity * cost_price), 2) as cost,
       round(sum(quantity * unit_price * (1 - discount / 100.0)) - sum(quantity * cost_price), 2) as profit
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date);

select * from monthly_sales_summary;

-- Q44: Create a PostgreSQL function that returns completed-order revenue for a supplied customer ID. Show it working for one customer and for an ID that does not exist.
create or replace function get_customer_revenue(p_customer_id integer)
returns numeric language plpgsql as $$
declare v_revenue numeric;
begin
    select coalesce(sum(quantity * unit_price * (1 - discount / 100.0)), 0)
    into v_revenue
    from orders
    where customer_id = p_customer_id and order_status = 'Completed';
    
    return round(v_revenue, 2);
end;


-- show it working for an existing customer (e.g., customer_id 1)
select get_customer_revenue(1);

-- show it working for a non-existent customer (should return 0)
select get_customer_revenue(9999);

-- Q45: Segment customers into High, Medium and Low Value. 
-- thresholds chosen: High >= 100,000 KSh, Medium >= 50,000 KSh, Low < 50,000 KSh. 
-- these round thresholds were chosen to effectively group typical retail spending, separating bulk/premium buyers from occasional accessory shoppers.
with customer_revenue as (
    select c.customer_id, c.customer_name, 
           coalesce(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 0) as total_spent
    from customers c
    left join orders o on c.customer_id = o.customer_id and o.order_status = 'Completed'
    group by c.customer_id, c.customer_name
)
select customer_name, 
       round(total_spent, 2) as total_spent,
       case 
           when total_spent >= 100000 then 'High'
           when total_spent >= 50000 then 'Medium'
           else 'Low' 
       end as value_segment
from customer_revenue;

-- Q46: Produce a management report: the top five customers, top five products, the most profitable category, and the lowest-revenue month.

-- part 1: top five customers
select c.customer_name, round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as revenue
from customers c
join orders o on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_name
order by revenue desc
limit 5;

-- part 2: top five products
select product_name, round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as revenue
from orders
where order_status = 'Completed'
group by product_name
order by revenue desc
limit 5;

-- part 3: most profitable category
select product_category, 
       round(sum(quantity * unit_price * (1 - discount / 100.0)) - sum(quantity * cost_price), 2) as profit
from orders
where order_status = 'Completed'
group by product_category
order by profit desc
limit 1;

-- part 4: lowest-revenue month
select date_trunc('month', order_date) as order_month, 
       round(sum(quantity * unit_price * (1 - discount / 100.0)), 2) as revenue
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date)
order by revenue asc
limit 1;
