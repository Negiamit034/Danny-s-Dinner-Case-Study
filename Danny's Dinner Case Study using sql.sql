CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select distinct(customer_id),sum(m.price) as total_amount from menu m inner join sales s on s.product_id=m.product_id group by customer_id order by total_amount desc ;

-- 2. How many days has each customer visited the restaurant?
select * from sales;

select customer_id,count(distinct order_date) from sales group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT product_name, customer_id, ranking,order_date
FROM (
    SELECT m.product_name, s.customer_id,s.order_date,
           Dense_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS ranking
    FROM menu m
    INNER JOIN sales s ON s.product_id = m.product_id
) ranked_data
WHERE ranking = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name,count(m.product_name) as count from menu m inner join
sales s on m.product_id=s.product_id group by m.product_name order by count desc limit 1 ;

-- 5. Which item was the most popular for each customer?

select s.customer_id,count(m.product_name),m.product_name,dense_rank() over(partition by product_name)  from menu m inner join
sales s on m.product_id=s.product_id;


-- 6. Which item was purchased first by the customer after they became a member?
select * from members;
select * from sales;
select * from menu;

WITH ranking AS (
 SELECT *, 
 DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date)
 FROM sales s
 JOIN members m
 USING (customer_id)
 WHERE s.order_date >= m.join_date
)
SELECT customer_id, order_date, product_name FROM ranking
JOIN menu 
USING (product_id)
WHERE dense_rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH ranking AS (
   SELECT *,
     DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC)
   FROM sales s
   JOIN members m
   USING (customer_id)
   WHERE s.order_date < m.join_date
 )
SELECT customer_id, order_date, product_name 
FROM ranking 
JOIN menu
USING (product_id)
WHERE dense_rank = 1;
-- 8. What is the total items and amount spent for each member before they became a member?

SELECT customer_id, COUNT(DISTINCT(product_id)) as total_items, 
  SUM(price) as amount_spent 
FROM sales s
JOIN members m
USING (customer_id)
JOIN menu
USING (product_id)
WHERE s.order_date < m.join_date
GROUP BY customer_id;
