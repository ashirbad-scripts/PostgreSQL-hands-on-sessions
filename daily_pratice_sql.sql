-- Create table
CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(50),
    price INT
);

-- Insert data
INSERT INTO products (product_id, product_name, price) VALUES
(101, 'Laptop', 65000),
(102, 'Mobile', 25000),
(103, 'Tablet', 30000),
(101, 'Mobile', 22000),
(104, 'Laptop', 70000),
(105, 'Tablet', 28000),
(102, 'Laptop', 62000),
(103, 'Mobile', 24000),
(106, 'Laptop', 68000),
(105, 'Mobile', 26000);


-- Find the total sales amount per product.
SELECT pid, pname, SUM(price) AS total_price FROM products GROUP BY pid, pname ORDER BY total_price DESC;

-- Count how many times each customer_id appears.
SELECT pid, COUNT(*) FROM products GROUP BY pid;

-- Find the average amount spent per customer.
SELECT pid, CONCAT('Rs. ', ROUND(AVG(price), 2)) FROM products GROUP BY pid;

-- Identify the highest purchase amount for each product.
SELECT pid, MAX(price) AS highest_purchase_amount FROM products GROUP BY pid ORDER BY highest_purchase_amount DESC;


-- Create a column that labels each unique product as "High Value" if amount > 50000, else "Normal".
SELECT 
	pid,
	pname,
	SUM(price) AS total_pr
	CASE
		WHEN SUM(price) > 50000 THEN 'High Value'
		ELSE 'Normal'
	END AS Labels
FROM products
GROUP BY pid, pname
ORDER BY Labels DESC;



-- -------------------------  DAY - 2 -----------------------------
CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    order_date   DATE NOT NULL,
    customer_id  VARCHAR(10) NOT NULL,
    amount       NUMERIC(12,2) NOT NULL
);

INSERT INTO orders (order_id, order_date, customer_id, amount) VALUES
(1, '2024-01-05', 'C101', 45000),
(2, '2024-01-10', 'C102', 62000),
(3, '2024-01-15', 'C101', 30000),
(4, '2024-02-02', 'C103', 70000),
(5, '2024-02-08', 'C104', 52000),
(6, '2024-02-20', 'C102', 28000),
(7, '2024-03-01', 'C105', 90000),
(8, '2024-03-10', 'C101', 40000),
(9, '2024-03-18', 'C103', 61000),
(10, '2024-03-25', 'C104', 35000);

-- Questions
-- Find total sales per month (month-wise aggregation).
SELECT 
	TO_CHAR(order_date, 'FMMonth') AS Month_Name,
	SUM(amount) AS total_sales
FROM orders
GROUP BY
	TO_CHAR(order_date, 'FMMonth'),
	EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(MONTH FROM order_date) ASC;



-- Retrieve customers who placed more than one order in the same month.
SELECT 
	customer_id,
	TO_CHAR(order_date, 'FMMonth YYYY') AS "Month",
	COUNT(*) AS total_orders
FROM orders
GROUP BY 
	customer_id,
	TO_CHAR(order_date, 'FMMonth YYYY')
HAVING COUNT(*) > 1



-- Find the highest order amount for each month.
SELECT 
	TO_CHAR(order_date, 'FMMonth') AS "Month",
	MAX(amount) AS highest_order_amount
FROM orders
GROUP BY TO_CHAR(order_date, 'FMMonth');



-- Calculate month-over-month sales growth.
WITH monthly_sales AS (
	SELECT
		DATE_TRUNC('month', order_date) AS month_start,
		SUM(amount) AS total_sales
	FROM orders
	GROUP BY DATE_TRUNC('month', order_date)
),
monthly_details AS (
	SELECT
		TO_CHAR(month_start, 'FMMonth YYYY') AS "Month",
		total_sales,
		LAG(total_sales) OVER(ORDER BY month_start) AS prev_month_sales
	FROM monthly_sales
)
SELECT 
	*, 
	ROUND((((total_sales - prev_month_sales) / NULLIF(total_sales, 0)) * 100), 2) AS M2M_Growth
FROM monthly_details;



-- List orders placed in the last 30 days from the latest order date.
SELECT *
FROM orders
WHERE order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '30 Days'
ORDER BY order_date;


-- -------------------------  DAY - 3 -----------------------------

-- Find the first and last order date for each customer.
SELECT
	customer_id,
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
ORDER BY customer_id;



-- Calculate the average order amount per month, but only for months with more than 2 orders.
SELECT 
	TO_CHAR(order_date, 'FMMonth yyyy') AS "Month",
	COUNT(order_id) AS total_orders,
	ROUND(AVG(amount), 2) AS "Avg_Order_Amt"
FROM orders
GROUP BY TO_CHAR(order_date, 'FMMonth yyyy')
HAVING COUNT(order_id) > 2;


-- Rank orders within each month based on order_date (earliest to latest).
SELECT
	TO_CHAR(order_date, 'FMMonth yyyy') AS "Month",
	DENSE_RANK() OVER(PARTITION BY DATE_TRUNC('month', order_date) ORDER BY order_date DESC) AS "Rank",
	order_id,
	customer_id,
	amount
FROM orders;


-- Find the number of days between consecutive orders for each customer.
-- CTE (optional)
SELECT 
    customer_id,
    order_id,
    order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
    order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_between
FROM orders;


-- -------------------------  DAY - 4 -----------------------------
CREATE TABLE employees (
    emp_id       INT PRIMARY KEY,
    emp_name     VARCHAR(50) NOT NULL,
    department   VARCHAR(50) NOT NULL,
    region       VARCHAR(50) NOT NULL,
    join_date    DATE NOT NULL,
    deal_status  VARCHAR(20) NOT NULL,
    deal_amount  NUMERIC(12,2) NOT NULL
);

INSERT INTO employees (emp_id, emp_name, department, region, join_date, deal_status, deal_amount) VALUES
(1, 'Amit', 'Sales', 'North', '2022-01-15', 'Closed', 75000),
(2, 'Neha', 'Sales', 'South', '2021-11-20', 'Open', 0),
(3, 'Rahul', 'Marketing', 'East', '2023-03-05', 'Closed', 42000),
(4, 'Pooja', 'Sales', 'West', '2020-06-18', 'Lost', 0),
(5, 'Karan', 'Finance', 'North', '2019-09-10', 'Closed', 98000),
(6, 'Sneha', 'Marketing', 'South', '2022-12-01', 'Closed', 55000),
(7, 'Arjun', 'Sales', 'East', '2021-02-14', 'Open', 0),
(8, 'Meera', 'Finance', 'West', '2020-08-25', 'Closed', 61000),
(9, 'Rohan', 'Sales', 'North', '2023-01-09', 'Lost', 0),
(10, 'Anjali', 'Marketing', 'East', '2022-04-30', 'Closed', 47000),
(11, 'Vikram', 'Sales', 'South', '2019-05-17', 'Closed', 88000),
(12, 'Nisha', 'Finance', 'North', '2021-10-03', 'Open', 0),
(13, 'Suresh', 'Sales', 'West', '2022-07-19', 'Closed', 53000),
(14, 'Kavya', 'Marketing', 'North', '2020-03-11', 'Lost', 0),
(15, 'Manish', 'Finance', 'East', '2023-02-22', 'Closed', 76000),
(16, 'Deepa', 'Sales', 'South', '2021-08-08', 'Closed', 69000),
(17, 'Alok', 'Marketing', 'West', '2019-12-29', 'Open', 0),
(18, 'Priya', 'Finance', 'South', '2022-09-14', 'Closed', 84000),
(19, 'Sanjay', 'Sales', 'North', '2020-01-06', 'Closed', 92000),
(20, 'Isha', 'Marketing', 'East', '2021-06-27', 'Closed', 48000);

-- Questions
/*
	Create a column deal_category:
	High if deal_amount ≥ 80000
	Medium if 50000–79999
	Low if < 50000
*/
SELECT
	emp_id,
	emp_name,
	deal_status,
	deal_amount,
	CASE
		WHEN deal_amount >= 80000 THEN 'High'
		WHEN deal_amount BETWEEN 50000 AND 79999 THEN 'Medium'
		WHEN deal_amount < 50000 THEN 'Low'
	END AS "Deal_Category"
FROM employees;


/*
	Standardize deal_status so:
	Closed → SUCCESS
	Open → IN_PROGRESS
	Lost → FAILED
	Also Show the deal category using subquery
*/
SELECT 
	emp_id,
	emp_name,
	t.Deal_Category,
	deal_amount,
	deal_status,
	CASE
		WHEN deal_status = 'Closed' THEN 'SUCCESS'
		WHEN deal_status = 'Open' THEN 'IN_PROGRESS'
		WHEN deal_status = 'Lost' THEN 'FAILED'
		ELSE 'UNKNOWN'
		END AS final_deal_status
FROM (
	SELECT *,
	CASE
		WHEN deal_amount >= 80000 THEN 'High'
		WHEN deal_amount BETWEEN 50000 AND 79999 THEN 'Medium'
		WHEN deal_amount < 50000 THEN 'Low'
	END AS Deal_Category
FROM employees
) t;
-- Note that here subquery is redundant since main query is not depending on subquery.


-- Extract first name initial from emp_name.
SELECT
	emp_name,
	LEFT(emp_name, 1) AS initial
FROM employees;

-- note:- split_part is used to split first and last name


/*
	Create a column seniority_level using join_date:
	Senior → joined before 2021
	Mid → 2021–2022
	Junior → 2023 onwards
*/
WITH join_year AS (
	SELECT 
		*,
		EXTRACT(YEAR FROM join_date) AS joining_year
	FROM employees
)
SELECT
	emp_id, emp_name, department, region, join_date, joining_year,
	CASE 
		WHEN joining_year < 2021 THEN 'Senior'
		WHEN joining_year BETWEEN 2021 AND 2023 THEN 'Mid'
		WHEN joining_year > 2023 THEN 'Junior'
	END AS seniority_level
FROM join_year


-- Identify employees whose names start with a vowel.
SELECT 
	emp_name,
	LEFT(emp_name, 1) AS "Starting_Letter"
FROM employees
WHERE emp_name ~* '^[aeiou]';


/*
	Create a column region_code:
	North → N
	South → S
	East → E
	West → W
*/
SELECT
	emp_name, department, region,
	CASE 
		WHEN region = 'North' THEN 'N'
		WHEN region = 'East' THEN 'E'
		WHEN region = 'South' THEN 'S'
		WHEN region = 'West' THEN 'W'
	END AS region_code
FROM employees;


/*
	For Sales department only, label deals as:
	Active Pipeline if Open
	Won if Closed
	Dropped if Lost
	Replace all 0 deal amounts with NULL only for Open deals.
*/

SELECT
	emp_id, department, region, deal_amount, deal_status,
	CASE
		WHEN deal_amount = 0 AND deal_status = 'Open' THEN NULL
		WHEN deal_status = 'Open' THEN 'Active'
		WHEN deal_status = 'Closed' THEN 'Won'
		WHEN deal_status = 'Lost' THEN 'Dropped'
	END AS "Label"
FROM employees
WHERE department = 'Sales'


/*
	Display employee name in format:
	EMP_NAME (DEPARTMENT - REGION)
*/
SELECT
	CONCAT("emp_name", ' (',  "department", ' - ', "region", ')') AS Emp_Details
FROM employees;


/*
	Flag employees as Top Performer if:
	deal_status = 'Closed'
	AND deal_amount is above department average
*/

WITH dept_avg AS (
	SELECT 
		department,
		AVG(deal_amount) AS avg_deal
	FROM employees
	GROUP BY department
),
status AS (
	SELECT
		e.emp_id,
		e.emp_name,
		CASE
			WHEN e.deal_status = 'Closed' AND e.deal_amount > d.avg_deal THEN 'Top Performer'
		END AS Tier
	FROM employees e
	JOIN dept_Avg d ON e.department = d.department
)
SELECT 
	* 
FROM status 
WHERE Tier IS NOT NULL;


-- ----------------------- DAY - 05 -------------
-- Step 1: Create the table
CREATE TABLE customer_feedback (
    feedback_id     INT PRIMARY KEY,
    customer_name   VARCHAR(100),
    email           VARCHAR(255),
    feedback_text   TEXT,
    feedback_date   DATE
);

-- Step 2: Insert the records (unclean values preserved)
INSERT INTO customer_feedback (feedback_id, customer_name, email, feedback_text, feedback_date) VALUES
(1, 'rahul SHARMA', 'rahul.sharma@Gmail.com', 'product was GOOD but delivery was late', '2024-01-05'),
(2, 'Neha  Verma', 'neha.verma@yahoo.COM', 'Delivery was fast, PRODUCT quality is excellent', '2024-01-07'),
(3, 'AMIT kumar', 'amit.kumar@gmail.com', 'not satisfied with the product', '2024-01-10'),
(4, 'pooja singh', 'pooja.singh@Outlook.com', 'Customer SERVICE was helpful', '2024-01-15'),
(5, 'Karan  Mehta', 'karan.mehta@gmail.COM', 'product is okay, packaging could be better', '2024-02-01'),
(6, 'sneha PATEL', 'sneha.patel@Yahoo.com', 'LATE delivery and poor response', '2024-02-05'),
(7, 'ROHAN das', 'rohan.das@gmail.com', 'Excellent PRODUCT and fast DELIVERY', '2024-02-10'),
(8, 'Anjali  IYER', 'anjali.iyer@outlook.COM', 'delivery was delayed but support was good', '2024-02-18'),
(9, 'vikram SINGH', 'vikram.singh@gmail.com', 'VERY BAD experience', '2024-03-01'),
(10, 'Priya  nair', 'priya.nair@yahoo.com', 'product quality is good', '2024-03-05');


-- QUESTIONS :-

-- Standardize customer_name to Proper Case and remove extra spaces.
SELECT
	TRIM(INITCAP(customer_name)) AS customer_name
FROM feedback;


-- Extract email domain (gmail, yahoo, outlook) in lowercase.
SELECT
	LOWER(SPLIT_PART(email, '@', 2)) AS email_domain,
	LOWER(SPLIT_PART(SPLIT_PART(email, '@', 2), '.', 1)) AS domain
FROM feedback;


-- Create a column feedback_length showing number of characters in feedback_text.
SELECT
	LENGTH(TRIM(feedback_text)) AS feedback_length
FROM feedback;


-- Identify feedbacks that mention “delivery” (case-insensitive).
SELECT
	feedback_id,
	TRIM(INITCAP(customer_name)) AS customer_name,
	LOWER(email) AS email,
	TRIM(INITCAP(feedback_text)) AS feedback_text,
	feedback_date
FROM feedback
WHERE feedback_text LIKE '%delivery%'



-- Replace words: (late → delayed) and (bad → poor)
-- NOTE :- REPLACE DOES "BLIND STRING SUBSTITUTION"
SELECT
	INITCAP(feedback_text) AS unclean_feedback,
	INITCAP(REPLACE(REPLACE(feedback_text, 'late', 'delayed'), 'bad', 'poor')) AS feedback
FROM feedback;

-- To Update Permanetly you could do
	-- UPDATE feedback
	-- SET feedback_text = REPLACE(REPLACE(feedback_text, 'late', 'delayed'), 'bad', 'poor');



-- Create a column sentiment_flag:
	-- Negative if feedback contains (bad, poor, late)
	-- Positive if contains (good, excellent, fast)
	-- Else Neutral

-- ~* is case - insensitive
SELECT
	CASE
		WHEN feedback_text ~* '\m(bad|poor|late)|not satisfied\M' THEN 'Negative'
		WHEN feedback_text ~* '\m(good|excellent|fast)\M' THEN 'Postive'
		END AS sentiment_flag
FROM feedback;


-- Show feedback starting with bad, poor or late
SELECT *
FROM feedback
WHERE feedback_text ~* '^(bad | poor | late)';



-- Display customer_name as "SHARMA, Rahul" format.

	/* This is valid but when there are not multiple spaces between two names
	SELECT
		CONCAT(UPPER(SPLIT_PART(customer_name, ' ', 1)), ' ', INITCAP(SPLIT_PART(customer_name, ' ', 2)))
	FROM feedback;
	*/

-- It replaces all multiple spaces with a single space
	-- \s+ = one or more whitespace characters.
	-- With g, it replaces all matches in the string.
SELECT
    CONCAT(
        UPPER(SPLIT_PART(REGEXP_REPLACE(customer_name, '\s+', ' ', 'g'), ' ', 2)), -- last name
        ', ',
        INITCAP(SPLIT_PART(customer_name, ' ', 1))  -- first name
    ) AS formatted_name
FROM feedback;



-- Convert feedback_date into string format: "05-Jan-2024"
SELECT
	feedback_id,
	feedback_date,
	TO_CHAR(feedback_date, 'dd-Mon-yyyy') As formatted_date
FROM feedback;



-- Find customers whose first name length > last name length.
SELECT 
    INITCAP(REGEXP_REPLACE(customer_name, '\s+', ' ', 'g')) AS customer_name_clean,
    LENGTH(SPLIT_PART(REGEXP_REPLACE(customer_name, '\s+', ' ', 'g'), ' ', 1)) AS FN_length,
    LENGTH(SPLIT_PART(REGEXP_REPLACE(customer_name, '\s+', ' ', 'g'), ' ', 2)) AS LN_length
FROM feedback
WHERE 
	LENGTH(SPLIT_PART(REGEXP_REPLACE(customer_name, '\s+', ' ', 'g'), ' ', 1))
      > LENGTH(SPLIT_PART(REGEXP_REPLACE(customer_name, '\s+', ' ', 'g'), ' ', 2));


-- For each email domain, find the percentage of negative feedbacks.
WITH feedback_cte AS (
	SELECT 
		LOWER(SPLIT_PART(SPLIT_PART(email, '@', 2), '.', 1)) AS domain_name,
		CASE
			WHEN feedback_text ~* '\m(bad|poor|late|not satisfied)\M' THEN 1
			ELSE 0 
		END AS is_negative
	FROM feedback
)
SELECT
	domain_name,
	ROUND(100.0 * SUM(is_negative) / COUNT(*), 2) AS negative_feedback_pct
FROM feedback_cte
GROUP BY domain_name
ORDER BY negative_feedback_pct DESC;



-- ----------------------- DAY - 06 -------------

-- 1. Create a cleaned version of `email` such that:
--    * it is fully lowercase
--    * leading/trailing spaces are removed
--    * output column name: `clean_email`

SELECT
	email AS uncleaned_email,
	LOWER(TRIM(email)) AS clean_email
FROM feedback;


-- 2. Extract **username** (part before `@`) from `email` and convert it to **uppercase** and ensure there is no '.' between names.
SELECT
	email,
	UPPER(REPLACE(SPLIT_PART(email, '@', 1), '.', ' ')) AS extracted_name
FROM feedback;


-- 3. Identify feedback records where `feedback_text` **starts with** the word *“product”* (case-insensitive).
SELECT
	INITCAP(feedback_text)
FROM feedback
WHERE LOWER(feedback_text) LIKE 'product%'


-- 4. Replace **multiple consecutive spaces** in `customer_name` with a **single space**.
SELECT
	REGEXP_REPLACE(customer_name, '\s+', ' ', 'g') AS customer_name
FROM feedback;


-- 5. Find customers whose `customer_name` contains **exactly two words** (first + last name only).
-- Note:- Here all this mean the exact thing :-
	-- LOWER(TRIM(customer_name)) LIKE ~ '^[a-z]+\s[a-z]+$'	
	-- TRIM(customer_name) ~ '^[A-Za-z]+\s[A-Za-z]+$'
SELECT
	customer_name
FROM feedback
WHERE TRIM(customer_name) ~* '^[a-z]+\s[a-z]+$';



-- 6. Mask the email such that:
--    * only first 2 characters of username are visible
--    * rest replaced with `*`
--      Example: `ra****@gmail.com`
WITH masking AS (
	SELECT
		*,
		LEFT(SPLIT_PART(email, '@', 1), 2)
		|| REPEAT('*', LENGTH(SPLIT_PART(email, '@', 1)) - 2)
		|| SPLIT_PART(email, '@', 2) AS masked_email
	FROM feedback
)
SELECT
	email,
	LOWER(masked_email) AS masked_email
FROM masking;


-- 7. Extract the **month name** (January, February, …) from `feedback_date` as a string.
SELECT 
	feedback_id,
	feedback_date,
	TO_CHAR(feedback_date, 'FMMonth') AS feedback_month
FROM feedback;


-- 8. Count how many times the word **“product”** appears in each `feedback_text` (each row) (case-insensitive).
SELECT
    feedback_id,
    feedback_text,
    regexp_count(LOWER(feedback_text), 'product') AS product_count
FROM feedback
ORDER BY product_count DESC;


-- 9. Create a column `feedback_summary`:
--    * first **15 characters** of `feedback_text`
--    * append `...` if original text length > 15
SELECT
	CASE 	
		WHEN LENGTH(feedback_text) > 15 
			THEN LEFT(feedback_text, 15) || '...'
	END AS feedback_summary
FROM feedback;


-- 10. Identify feedbacks where:
--     * `email` domain is **gmail**
--     * AND `feedback_text` contains **both** `delivery` and `product` (any case)
SELECT
	INITCAP(TRIM(customer_name)) AS customer_name,
	LOWER(email) AS email,
	INITCAP(feedback_text) AS feedback_text,
	TO_CHAR(feedback_date, 'dd-Mon-yyyy') AS feedback_date
FROM feedback
WHERE 
	LOWER(email) LIKE '%@gmail%'
	AND feedback_text LIKE '%delivery%'
	AND feedback_text LIKE '%product%';



-- ----------------------- DAY - 07 ----------------------
-- Step 1: Create the table
CREATE TABLE emp_performance (
    emp_id             INT PRIMARY KEY,
    emp_name           VARCHAR(100),
    department         VARCHAR(50),
    review_date        DATE,
    performance_score  INT
);

-- Step 2: Insert the records
INSERT INTO emp_performance (emp_id, emp_name, department, review_date, performance_score) VALUES
(1, 'Rahul', 'Sales', '2024-01-10', 88),
(2, 'Neha', 'Sales', '2024-01-12', 92),
(3, 'Amit', 'Sales', '2024-01-15', 88),
(4, 'Pooja', 'Marketing', '2024-01-11', 91),
(5, 'Karan', 'Marketing', '2024-01-18', 85),
(6, 'Sneha', 'Marketing', '2024-01-20', 91),
(7, 'Arjun', 'Finance', '2024-01-09', 95),
(8, 'Meera', 'Finance', '2024-01-14', 89),
(9, 'Rohan', 'Finance', '2024-01-22', 89),
(10, 'Isha', 'Finance', '2024-01-25', 83);

-- QUESTIONS :-

-- 1. Rank employees **within each department** based on `performance_score` (highest first) using `RANK()`.
SELECT
	*,
	RANK() OVER(PARTITION BY department ORDER BY performance_score DESC) AS rnk
FROM emp_performance
ORDER BY rnk ASC;


-- 2. Assign a **dense rank** to employees **across the entire company** based on `performance_score`.
SELECT
	*,
	DENSE_RANK() OVER(ORDER BY performance_score DESC) AS rnk
FROM emp_performance
ORDER BY rnk ASC;


-- 3. For each department, display the **top performer’s score** on every row using `FIRST_VALUE()`.
SELECT
	*,
	FIRST_VALUE(performance_score) OVER(
		PARTITION BY department
		ORDER BY performance_score DESC	
	) AS top_performer_score
FROM emp_performance
ORDER BY department;


-- 4. For each department, display the **lowest performer’s score** on every row using `LAST_VALUE()`
--    *(pay attention to window frame — this is an interviewer trap).*
SELECT
	*,
	LAST_VALUE(performance_score) OVER(
		PARTITION BY department 
		ORDER BY performance_score DESC
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) AS lowest_score
FROM emp_performance
ORDER BY department;

	--NOTE :- Dont get confused with asc and desc in first and last value

	
-- 5. Divide employees **within each department** into **2 performance buckets** using `NTILE(2)`.
SELECT
	*,
	NTILE(2) OVER(PARTITION BY department ORDER BY performance_score DESC) AS performance_buckets
FROM emp_performance;


-- 6. Calculate the **previous employee’s performance score** within the same department ordered by `review_date`.
SELECT
	*,
	LAG(performance_score) OVER(PARTITION BY department ORDER BY review_date) AS prev_emp_score
FROM emp_performance;


-- 7. Calculate the **difference between current and previous performance score** within each department.
SELECT
	*,
	performance_score - LAG(performance_score) OVER(PARTITION BY department ORDER BY review_date) AS score_diff
FROM emp_performance;


-- 8. For each department, compute the **average performance score** and show it alongside each employee record.
SELECT
	*,
	ROUND(AVG(performance_score) OVER(PARTITION BY department), 2) AS dept_avg_score
FROM emp_performance;


-- 9. Assign a **row number** to employees **within each department**, ordered by `review_date`.
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY department ORDER BY review_date) AS reviewed_order
FROM emp_performance;


-- 10. Identify employees whose `performance_score` is **above their department’s average**, using a window aggregate.

-- Non- Window Version
WITH CTE AS (
	SELECT 
		department,
		AVG(performance_score) AS dept_avg
	FROM emp_performance
	GROUP BY department
)
SELECT 
	e.emp_id,
	e.performance_score,
	e.department,
	ROUND(d.dept_avg, 2)
FROM emp_performance e
JOIN CTE d ON d.department = e.department
WHERE e.performance_score > d.dept_avg;


-- Window Frame Version (better)
SELECT
	emp_id,
	emp_name,
	department,
	performance_score,
	ROUND(dept_avg, 2)
FROM (
	SELECT
		emp_id,
		emp_name,
		department,
		performance_score,
		AVG(performance_score) OVER(PARTITION BY department) AS dept_avg
	FROM emp_performance
) t
WHERE performance_score > dept_avg


































































































