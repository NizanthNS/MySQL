USE Daily_SQL;

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    Category VARCHAR(50),
    Amount INT,
    Order_Date DATE
);

INSERT INTO Orders
VALUES  (1, 'Arun',    'Electronics', 45000, '2024-01-10'),
        (2, 'Meena',   'Furniture',   20000, '2024-01-12'),
        (3, 'Ravi',    'Electronics', 38000, '2024-01-15'),
        (4, 'Priya',   'Clothing',    12000, '2024-01-18'),
        (5, 'Karthik', 'Furniture',   25000, '2024-01-20'),
        (6, 'Divya',   'Electronics', 52000, '2024-01-25'),
        (7, 'Sanjay',  'Clothing',     8000, '2024-01-28'),
        (8, 'Nisha',   'Furniture',   30000, '2024-02-01'),
        (9, 'Vikram',  'Electronics', 41000, '2024-02-05'),
        (10,'Aarthi',  'Clothing',    15000, '2024-02-10');
        
SELECT *
FROM Orders;
        

-- Day 9 : CTEs (Common Table Expressions)


-- Q1
-- Create a CTE to show all orders
-- where Amount is greater than 30000.

WITH CTE AS (
	SELECT Order_ID, Category, Amount
    FROM Orders
    WHERE Amount > 30000
	)
SELECT *
FROM CTE;


-- Q2
-- Using a CTE,
-- find the average Amount of all orders.

WITH CTE AS (
	SELECT Order_ID, Amount
    FROM Orders
	)
SELECT *,
	   AVG(Amount) OVER() AS Average
FROM CTE;


-- Q3
-- Create a CTE that ranks customers
-- based on Amount in descending order.

WITH CTE AS (
	SELECT Customer_Name, Amount
    FROM Orders
    )
SELECT *,
	   RANK() OVER(ORDER BY Amount DESC) AS Rank_
FROM CTE;


-- Q4
-- Using a CTE,
-- show the highest Amount order from each Category.

WITH CTE AS (
	SELECT Category, Amount,
		   DENSE_RANK() OVER(PARTITION BY Category
           ORDER BY Amount DESC) AS D_Rank
	FROM Orders
    )
SELECT *
FROM CTE
WHERE D_Rank = 1;


-- Q5
-- Create a CTE to calculate total sales
-- for each Category,
-- then show only categories with total sales > 70000.

WITH CTE AS (
	SELECT Category, 
		   SUM(Amount) AS Total_Sales
	FROM Orders
    GROUP BY Category
    )
SELECT *
FROM CTE
WHERE Total_Sales > 70000;


-- Q6
-- Using multiple CTEs:
-- 1. Find total sales per Category
-- 2. Find average of those category totals
-- 3. Show categories whose total sales
--    are greater than the overall category average

WITH CTE AS (
	SELECT Category, 
		   SUM(Amount) AS Total_Sales
	FROM Orders
    GROUP BY Category
),
CTE2 AS (
	SELECT *,
		   AVG(Total_Sales) OVER() AS Average
    FROM CTE
	)
SELECT *
FROM CTE2
WHERE Total_Sales > Average;


-- Bonus Debugging Question

WITH Sales_CTE AS (
    SELECT Category,
           SUM(Amount)
    FROM Orders
)

SELECT *
FROM Sales_CTE;

-- What is wrong with this query?
-- Rewrite it correctly.

-- ANSWER

WITH Sales_CTE AS (
    SELECT Category,
           SUM(Amount) AS Total
    FROM Orders
    GROUP BY Category
)

SELECT *
FROM Sales_CTE;