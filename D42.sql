USE Daily_SQL;


CREATE TABLE Orders_Data (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Orders_Data
VALUES
    (1, 'Arun',  '2024-01-01', 5000),
    (2, 'Arun',  '2024-01-10', 2000),
    (3, 'Meena', '2024-01-05', 7000),
    (4, 'Meena', '2024-02-01', 3000),
    (5, 'Ravi',  '2024-01-03', 4000);
    
    
SELECT *
FROM Orders_Data;

-- Q1
-- Find total amount per customer

SELECT Customer_Name,
	   SUM(Amount) AS Total
FROM Orders_Data
GROUP BY Customer_Name;


-- Q2
-- Find highest spender

WITH CTE AS (
	SELECT Customer_Name,
		   SUM(Amount) AS Total
	FROM Orders_Data
	GROUP BY Customer_Name
)
SELECT *
FROM CTE
WHERE Total = (
	SELECT MAX(Total)
    FROM CTE
);


-- Q3 (tiny date logic 🔥)
-- Customers who purchased again within 15 days

WITH CTE AS (
	SELECT Order_ID, Customer_Name, Order_Date,
		   LAG(Order_Date) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous_Date
	FROM Orders_Data
)
SELECT *,
	   DATEDIFF(Order_Date, Previous_Date) AS Difference
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Order_Date, Previous_Date) <= 15;


-- Q4 (super quick debug 🚨)
SELECT Customer_Name,
       COUNT(Order_ID)
FROM Orders_Data
WHERE COUNT(Order_ID) > 1
GROUP BY Customer_Name;

-- ANSWER

SELECT Customer_Name,
       COUNT(Order_ID) AS Total_Order
FROM Orders_Data
GROUP BY Customer_Name
HAVING COUNT(Order_ID) > 1;
