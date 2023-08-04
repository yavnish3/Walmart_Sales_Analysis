#  Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

use walmartSales;


-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);






-- -----------------------------------------------------------------------------------------------------------------
-- ----------------------------------------- Feature Engineering  --------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------

-- time_of_day

SELECT 
    time,
    (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_day
FROM
    sales;


Alter table sales add column time_of_day varchar(20);


SET SQL_SAFE_UPDATES=0;
UPDATE sales 
SET 
    time_of_day = (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END);
SET SQL_SAFE_UPDATES=1;








-- day_name

SELECT 
    date, DAYNAME(date)
FROM
    sales;

alter table sales add column day_name varchar(10);

SET SQL_SAFE_UPDATES=0;
UPDATE sales 
SET 
    day_name = DAYNAME(date);
    







-- month_name

SELECT 
    date, MONTHNAME(date)
FROM
    sales;
    
Alter table sales add column month_name varchar(20);

SET SQL_SAFE_UPDATES=0;
UPDATE sales 
SET 
    month_name = MONTHNAME(date);
    
-- -----------------------------------------------------------------------------------------------------------------    
-- -----------------------------------------------------------------------------------------------------------------    
    
    

-- ------------------------------------------------------------------------------------------------------------------    
-- ----------------------------------  Exploratory Data Analysis (EDA) ----------------------------------------------    
-- ------------------------------------------------------------------------------------------------------------------    



-- ----------------------------------  Generic Question ------------------------------------------------------------    


# 1. How many unique cities does the data have?

SELECT DISTINCT
    city
FROM
    sales;
    
    
    
# 2. In which city is each branch?

SELECT DISTINCT
    branch
FROM
    sales;

SELECT DISTINCT
    city, branch
FROM
    sales;
    
    
    


-- -------------------------------------------  Product -------------------------------------------------------------    

-- How many unique product lines does the data have?

SELECT 
    COUNT(DISTINCT product_line) as unique_product
FROM
    sales;
    
    
    
-- What is the most common payment method?

SELECT 
    payment, COUNT(payment) AS cnt
FROM
    sales
GROUP BY payment
ORDER BY cnt DESC;



-- What is the most selling product line?

SELECT 
    product_line, COUNT(product_line) AS cnt
FROM
    sales
GROUP BY product_line
ORDER BY cnt DESC;




-- What is the total revenue by month?

SELECT 
    month_name, SUM(total) AS tl_rev
FROM
    sales
GROUP BY month_name
ORDER BY tl_rev desc;




-- What month had the largest COGS?

SELECT 
    month_name, SUM(cogs) AS tl_cogs
FROM
    sales
GROUP BY month_name
ORDER BY tl_cogs DESC
LIMIT 1;




-- What product line had the largest revenue?

SELECT 
    product_line, SUM(total) AS revenue
FROM
    sales
GROUP BY product_line
ORDER BY revenue DESC;




-- What is the city with the largest revenue?
SELECT 
    city, SUM(total) AS revenue
FROM
    sales
GROUP BY city
ORDER BY revenue DESC;





-- What product line had the largest VAT?

SELECT 
    product_line, AVG(tax_pct) AS vat
FROM
    sales
GROUP BY product_line
ORDER BY vat DESC;





-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT 
    product_line,
    CASE
        WHEN
            AVG(quantity) > (SELECT 
                    AVG(quantity) AS avg_qnty
                FROM
                    sales)
        THEN
            'Good'
        ELSE 'Bad'
    END AS remark
FROM
    sales
GROUP BY product_line;






-- Which branch sold more products than average product sold?

SELECT 
    branch, SUM(quantity) AS qty
FROM
    sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT 
        AVG(quantity)
    FROM
        sales);
        
        



-- What is the most common product line by gender?

SELECT 
    gender, product_line, COUNT(gender) AS total_cnt
FROM
    sales
GROUP BY gender , product_line
ORDER BY total_cnt DESC;





-- What is the average rating of each product line?

SELECT 
    product_line, ROUND(AVG(rating), 2) AS rat
FROM
    sales
GROUP BY product_line
ORDER BY rat DESC;




-- ------------------------------------------------------------------------------------------------------------------    
-- ------------------------------------  sales ----------------------------------------------------------------------    


-- Number of sales made in each time of the day per weekday

SELECT 
    time_of_day, COUNT(*)
FROM
    sales
WHERE
    day_name = 'Sunday'
GROUP BY time_of_day
ORDER BY COUNT(*) DESC;





-- Which of the customer types brings the most revenue?

SELECT 
    customer_type, SUM(total)
FROM
    sales
GROUP BY customer_type
ORDER BY SUM(total) DESC;





-- Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT 
    city, AVG(tax_pct) AS vat
FROM
    sales
GROUP BY city
ORDER BY vat;






-- Which customer type pays the most in VAT?

SELECT 
    customer_type, AVG(tax_pct) AS vat
FROM
    sales
GROUP BY customer_type
ORDER BY vat DESC;









-- ------------------------------------------------------------------------------------------------------------------    
-- ----------------------------------------------  Customer ---------------------------------------------------------    



-- How many unique customer types does the data have?

SELECT 
    COUNT(DISTINCT customer_type)
FROM
    sales;
    
    
    
    
    
-- How many unique payment methods does the data have?

SELECT DISTINCT
    payment
FROM
    sales;
    
    
    
    
-- What is the most common customer type?

SELECT 
    customer_type, COUNT(customer_type)
FROM
    sales
GROUP BY customer_type;






-- Which customer type buys the most?

SELECT 
    customer_type, COUNT(*)
FROM
    sales
GROUP BY customer_type;





-- What is the gender of most of the customers?

SELECT 
    gender, COUNT(*)
FROM
    sales
GROUP BY gender;





-- What is the gender distribution per branch?

SELECT 
    branch, gender, COUNT(gender) AS cntGndr
FROM
    sales
GROUP BY branch , gender
ORDER BY cntGndr DESC;




-- Which time of the day do customers give most ratings?

SELECT 
    time_of_day, AVG(rating) AS avgRat
FROM
    sales
GROUP BY time_of_day
ORDER BY avgRat DESC;







-- Which time of the day do customers give most ratings per branch?

SELECT 
    time_of_day, AVG(rating) AS avgRat
FROM
    sales
WHERE
    branch = 'C'
GROUP BY time_of_day
ORDER BY avgRat DESC;





-- Which day fo the week has the best avg ratings?

SELECT 
    day_name, AVG(rating) AS avgrt
FROM
    sales
GROUP BY day_name
ORDER BY avgrt DESC;





-- Which day of the week has the best average ratings per branch?

SELECT 
    day_name, branch, AVG(rating) AS avgrt
FROM
    sales
GROUP BY day_name , branch
ORDER BY avgrt DESC;
    
    
    
    
