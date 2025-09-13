Task_A_functions

1. **Monthly Customer Rank by Spend**
   - For each month (based on `order_date`), rank customers by **total order value** in that month using `RANK()`.
   - Output: month (YYYY-MM), customer_id, total_monthly_spend, rank_in_month.

   select to_char(o.order_date, 'YYYY-MM') as month,                 	--to_char()converts order_date into year-month format
   			o.customer_id,
   			sum(p.amount) as total_monthly_spend,					 	--sum()gives total spending per cust per month
   			rank() over(partition by to_char(o.order_date, 'YYYY-MM')	--rank()function assigns a rank number to cust
   			order by sum(p.amount)desc)as rank_in_month					--order by sum(), cust are sorted by total spend in desc/asc
   from orders o
   join payments p
   		on o.order_id = p.order_id
   group by month, o.customer_id
   order by month, rank_in_month;
   
   --the simple basic query was supposed to be
   --select o.order_date, o.customer_id, p.amount
   
   --how do i know what tables to start with in SQL
   --every database has a schema(database-whole cabinet, schema-a drawer in the cabinet, tables-files in drawer)
   --identify the 'fact' table: sales-orders, customers-customers, products-products etc
   --start small: select * from tables limit 5; (it will give you a table with 5 rows)
   --tally the table and see if the table matters fro your query.
     
   
   
   
   
   
   
2. ** share of Basket per item**
	- for each order, compute each items revenue share in that order
	- item_revenue / order_total using sum() over (partition by order_id)
 
select order_id,
	product_id,
	(quantity * unit_price) as item_revenue,
	sum(quantity * unit_price) over (partition by order_id) as order_total,
	round((quantity * unit_price)/sum(quantity * unit_price) over(partition by order_id),2) as revenue_share
from order_items
order by order_id, product_id;

--sum()over(partition by) gives sum of the column keeping the original rows
--sum() only collapse the rows with same (table_id) and gives total sum 
--round()over(partition by) calculates percentage 
--in above query we calculate how many items are there in an order and how much % each items is in total.






3. **Time Between Orders (per Customer)**
   - Show days since the **previous order** for each customer using `LAG(order_date)` and `AGE()`.

   select order_id, customer_id, order_date,
   			lag(order_date) over(						-- lag() function lets you look backwards at the previous row value 
   			partition by customer_id					-- partition by restarts calculation without collapsing rows
   			order by order_date							-- arrange order by order_date
   			) as prev_order_date,
   			
   			age(order_date, lag(order_date) over(
   			partition by customer_id 
   			order by order_date)) as days_since_prev_order
   from orders o 
   order by customer_id, order_date
   
   -- so the query purpose is to 
   -- find when was each customers previous order (date?)
   -- find how many days has passed since last order.
   
   
   
   
   
   
   
   
    
4. **Product Revenue Quartiles**
   - Compute total revenue per product and assign **quartiles** using `NTILE(4)` over total revenue.

 --CTE = temporary table - it only exists while query 
with product_revenue as (											--the result is saved in temporary table "product_revenue"
	select product_id, 
		sum(quantity * unit_price) as total_revenue
	from order_items
	group by product_id)
	
	
-- this is the main query
	
select product_id,
	total_revenue,
	ntile(4) over (order by total_revenue desc) as revenue_quartile  --ntile(4) splits rows into 4 equal groups(quartiles).
from product_revenue;												--theres total 8 products. so every quarlile has 2 rows when divided equally.
   

    
   
5. **First and Last Purchase Category per Customer**
   -- For each customer, show the **first** and **most recent** product category they've bought using `FIRST_VALUE` and `LAST_VALUE` over `order_date`.
  

with customer_purchases as (
	select o.customer_id,
		   o.order_date,
		   p.category,
		   row_number()over(partition by o.customer_id order by o.order_date) as rn_asc,
		   row_number()over(partition by o.customer_id order by o.order_date desc) as rn_desc
	from orders o
	join order_items oi 
		on o.order_id = oi.order_id
	join products p 
		on oi.product_id = p.product_id)
		
select customer_id,
	   max(case when rn_asc = 1 then category end) as first_category,
	   max(case when rn_desc = 1 then category end) as last_category
	   
from customer_purchases 
group by customer_id 
order by customer_id ;


























 
   
   
   
   