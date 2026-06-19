CREATE DATABASE Orders;

USE Orders;

CREATE TABLE Orders (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Category VARCHAR(50),
    Amount INT
);

INSERT INTO Orders 
VALUES	(1, 'Arun', 'Electronics', 5000),
		(2, 'Arun', 'Electronics', 3000),
		(3, 'Meena', 'Electronics', 7000),
		(4, 'Ravi', 'Furniture', 4000),
		(5, 'Ravi', 'Furniture', 2000),
		(6, 'Priya', 'Furniture', 9000),
		(7, 'Kiran', 'Electronics', 6000),
		(8, 'Meena', 'Furniture', 3500);

SELECT *
FROM Orders;
        

-- Q1
-- Show category and total sales

SELECT Category,
	   SUM(Amount) AS Total_Sales
FROM Orders
GROUP BY Category;


-- Q2
-- Show customer_name, category, amount,
-- and total sales of that category (for each row)

SELECT Customer_Name, Category, Amount,
	   SUM(Amount) OVER(PARTITION BY Category) AS Total_Sales
FROM Orders;


-- Q3
-- Show customer_name, category, amount,
-- and rank orders within each category (highest first)


SELECT Customer_Name, Category, Amount,
	   RANK() OVER(PARTITION BY Category
	   ORDER BY Amount DESC) AS Rank_
FROM Orders;


-- Q4
-- Show customer_name, category,
-- total sales per customer,
-- and rank customers within each category based on total sales

SELECT *,
	   RANK() OVER(PARTITION BY Category
       ORDER BY Total_Sales DESC) AS Rank_
FROM (
	SELECT Customer_Name,
		   Category,
		   SUM(Amount) AS Total_Sales
	FROM Orders
    GROUP BY Customer_Name, Category
)T;


-- Q5 (Important)
-- Show customer_name, category, amount,
-- and difference between amount and average amount of that category

SELECT Customer_Name, Category, Amount,
	   AVG(Amount) OVER(PARTITION BY Category) AS Average,
       Amount - AVG(Amount) OVER(PARTITION BY Category) AS Difference
FROM Orders;


-- Q6 (Twist)
-- Show only customers whose total sales
-- are ABOVE the average total sales of all customers

WITH CTE AS (
	SELECT Customer_Name,
		   SUM(Amount) AS Total_Sales
	FROM Orders
    GROUP BY Customer_Name
)
SELECT *
FROM CTE
WHERE  Total_Sales > (
	SELECT AVG(Total_Sales)
    FROM CTE
    );

-- OR

WITH CTE AS (
    SELECT Customer_Name,
           SUM(Amount) AS Total_Sales
    FROM Orders
    GROUP BY Customer_Name
)
SELECT *
FROM (
    SELECT *,
           AVG(Total_Sales) OVER() AS Avg_Sales
    FROM CTE
) T
WHERE Total_Sales > Avg_Sales;