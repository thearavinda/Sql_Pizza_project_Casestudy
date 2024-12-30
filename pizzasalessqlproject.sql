create database pizzahut ;
use pizzahut;

select * from order_details ;
select * from orders ;
select * from pizza_types ;
select * from pizzas ;

-- Retrieve the total number of orders placed.

select count(distinct(order_id))  from orders ;

-- Calculate the total revenue generated from pizza sales.

select sum(o.quantity * p.price) as total_revenue_generated
from order_details o
left join pizzas p
on o.pizza_id = p.pizza_id ;

-- Identify the highest-priced pizza.

select pt.name, p.price as highest_priced_pizza
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
order by p.price desc limit 1 ;

-- using window function rank()

select * from (
select pt.name, p.price as highest_priced_pizza,
rank() over(order by p.price desc) rnk
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id ) k
where k.rnk <2 ;

-- Identify the most common pizza size ordered.

select  count(distinct(o.order_id)) as numberoforders, sum(o.quantity) as quantity, p.size
from order_details o
join pizzas p
on o.pizza_id = p.pizza_id
group by p.size 
order by numberoforders desc ;


-- List the top 5 most ordered pizza types along with their quantities.

select  p.name, sum(o.quantity) as quantity
from order_details o
join pizzas pi
on o.pizza_id = pi.pizza_id
join pizza_types p
on pi.pizza_type_id = p.pizza_type_id
group by p.name 
order by quantity desc 
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select sum(o.quantity) as total_quantity, pt.category
from order_details o
join pizzas p
on o.pizza_id = p.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.category ;

-- Determine the distribution of orders by hour of the day.

select hour(time) as houroftheday, count(distinct(order_id)) as numberoforders
from orders
group by houroftheday 
order by  numberoforders desc ;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(distinct(pizza_type_id)) as numberoforders
from pizza_types
group by category ;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg( totalquantity),0) from 
(select o.date , sum(od.quantity) as totalquantity
from order_details od
 join orders o
 on od.order_id = o.order_id
group by o.date) as quantity_in_a_day ;

-- Determine the top 3 most ordered pizza types based on revenue.

select sum(od.quantity * p.price) as revenue, pt.name
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by revenue desc 
limit 3 ;

-- Calculate the percentage contribution of each pizza type to total revenue .

select pt.name as pizza_type_name, SUM(p.price * od.quantity) as total_revenue,
(SUM(p.price * od.quantity) / (select SUM(p.price * od.quantity) 
								from order_details od
								join pizzas p on od.pizza_id = p.pizza_id)) * 100 as percentage_contribution
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.pizza_type_id, pt.name
order by percentage_contribution desc;
    
-- Analyze the cumulative revenue generated over time.

select   o.date, o.time, SUM(p.price * od.quantity) as revenue,
    SUM(SUM(p.price * od.quantity)) over (order by o.date, o.time) as cumulative_revenue
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join orders o on od.order_id = o.order_id
group by o.date, o.time
order by o.date, o.time;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select o.date, o.time, SUM(p.price * od.quantity) as revenue,
SUM(SUM(p.price * od.quantity)) over (order by o.date, o.time) AS cumulative_revenue
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join orders o on od.order_id = o.order_id
group by o.date, o.time
order by o.date, o.time;

