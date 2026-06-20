USE Daily_SQL;


-- DATASET

CREATE TABLE Ecommerce_Orders (
    Order_ID INT,
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    Order_Date DATE,
    Product_Category VARCHAR(30),
    Order_Amount INT
);

INSERT INTO Ecommerce_Orders 
VALUES	(1,101,'Alice','2024-01-01','Electronics',500),
		(2,101,'Alice','2024-01-02','Electronics',700),
		(3,101,'Alice','2024-01-03','Fashion',300),
		(4,101,'Alice','2024-01-08','Fashion',400),

		(5,102,'Bob','2024-01-01','Fashion',200),
		(6,102,'Bob','2024-01-05','Electronics',900),
		(7,102,'Bob','2024-01-06','Fashion',300),

		(8,103,'Charlie','2024-01-02','Home',600),
		(9,103,'Charlie','2024-01-03','Home',500),
		(10,103,'Charlie','2024-01-04','Electronics',800),
		(11,103,'Charlie','2024-01-05','Fashion',200),

		(12,104,'David','2024-01-01','Home',400),
		(13,104,'David','2024-01-08','Home',700),

		(14,105,'Emma','2024-01-03','Electronics',1000),
		(15,105,'Emma','2024-01-04','Electronics',1200),
		(16,105,'Emma','2024-01-05','Fashion',500);

SELECT *
FROM Ecommerce_Orders;

-- Q1
-- Show each customer's total orders,
-- total order amount, and average order amount.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Total_Orders
-- Total_Order_Amount
-- Average_Order_Amount

SELECT Customer_ID, Customer_Name,
	   COUNT(Order_ID) AS Total_Orders,
       SUM(Order_Amount) AS Total_Order_Amount,
       ROUND(AVG(Order_Amount), 2) AS Average_Order_Amount
FROM Ecommerce_Orders
GROUP BY Customer_ID, Customer_Name;


-- Q2
-- Show each product category's total orders
-- and total revenue.
--
-- Return:
-- Product_Category
-- Total_Orders
-- Total_Revenue

SELECT Product_Category,
	   COUNT(Order_ID) AS Total_Orders,
       SUM(Order_Amount) AS Total_Revenue
FROM Ecommerce_Orders
GROUP BY Product_Category;


-- Q3
-- Find the top 3 customers by total order amount.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Total_Order_Amount

WITH CTE AS (
	SELECT Customer_ID, Customer_Name,
		   SUM(Order_Amount) AS Total_Order_Amount
	FROM Ecommerce_Orders
	GROUP BY Customer_ID, Customer_Name
),
CTE2 AS (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Order_Amount DESC) AS D_Rank
	FROM CTE
)
SELECT Customer_ID, Customer_Name, Total_Order_Amount
FROM CTE2
WHERE D_Rank <= 3;


-- Q4
-- Find customers who placed an order within 2 days
-- of their previous order.
--
-- Return:
-- Customer_ID
-- Customer_Name

WITH CTE AS (
	SELECT Customer_ID, Customer_Name, Order_Date,
		   LAG(Order_Date) OVER(PARTITION BY Customer_ID
           ORDER BY Order_Date, Order_ID) AS Previous
	FROM Ecommerce_Orders
)
SELECT DISTINCT Customer_ID, Customer_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Order_Date, Previous) <= 2;


-- Q5 (RUNNING TOTAL)
-- For each customer, show the cumulative order amount
-- after each order.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Order_Date
-- Order_Amount
-- Running_Total_Amount
--
-- Order the running total by Order_Date.

SELECT Customer_ID, Customer_Name, Order_Date, Order_Amount,
	   SUM(Order_Amount) OVER(PARTITION BY Customer_ID
       ORDER BY Order_Date) AS Running_Total_Amount
FROM Ecommerce_Orders;


-- BONUS (GAP & ISLAND)
-- Find customers whose current order streak
-- is at least 3 days.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Current_Streak
-- Start_Date
-- End_Date
--
-- Definition:
-- Current streak = streak containing the customer's
-- most recent order date.
--
-- Note:
-- Ignore duplicate order dates if a customer
-- has multiple orders on the same day.

WITH CTE AS (
	SELECT DISTINCT Customer_ID, Customer_Name, Order_Date
    FROM Ecommerce_Orders
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Customer_ID
           ORDER BY Order_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Order_Date, INTERVAL RN DAY) AS GK
	FROM CTE2
),
CTE4 AS (
	SELECT Customer_ID, Customer_Name,
		   COUNT(*) AS Current_Streak,
		   MIN(Order_Date) AS Start_Date,
           MAX(Order_Date) AS End_Date
	FROM CTE3
	GROUP BY Customer_ID, Customer_Name, GK
),
CTE5 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Customer_ID
           ORDER BY End_Date DESC) AS Row_Num
	FROM CTE4
)
SELECT Customer_ID, Customer_Name,
	   Current_Streak, Start_Date, End_Date
FROM CTE5
WHERE Row_Num = 1;
    