USE Daily_SQL;


CREATE TABLE Orders_Data (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Orders_Data 
VALUES	(1, 'Arun',  '2024-01-01', 20000),
		(2, 'Arun',  '2024-01-10', 15000),
		(3, 'Arun',  '2024-02-05', 20000),
		(4, 'Meena', '2024-01-03', 30000),
		(5, 'Meena', '2024-01-20', 25000),
		(6, 'Meena', '2024-03-01', 10000),
		(7, 'Ravi',  '2024-01-02', 40000),
		(8, 'Ravi',  '2024-02-15', 10000),
		(9, 'Priya', '2024-01-05', 25000),
		(10,'Priya', '2024-01-25', 30000);
        
SELECT *
FROM Orders_Data;
        
	
-- Q1 (Warm-up)
-- Find total amount spent per customer

SELECT Customer_Name,
	   SUM(Amount) AS Total_Amount
FROM Orders_Data
GROUP BY Customer_Name;


-- Q2 (Running total 🔁)
-- Calculate running total of amount per customer by date

SELECT Customer_Name, Order_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Order_Date) AS Running_Total
FROM Orders_Data;

-- OR

SELECT Customer_Name, Order_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Order_Date 
       ROWS BETWEEN UNBOUNDED 
       PRECEDING AND CURRENT ROW) AS Running_Total
FROM Orders_Data;


-- Q3 (Within 30 days 🔥)
-- Find customers who made another purchase within 30 days (use LAG)

WITH CTE AS (
	SELECT Customer_Name, Order_Date, Amount,
		   LAG(Order_Date) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous_Date
	FROM Orders_Data
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Order_Date, Previous_Date) <= 30;


-- Q4 (Self JOIN 🔥)
-- Same as Q3 but using self join

WITH CTE AS (
	SELECT A.Customer_Name, A.Order_Date
	FROM Orders_Data A
	JOIN Orders_Data B
		ON A.Customer_Name = B.Customer_Name AND
	A.Order_Date > B.Order_Date AND
    DATEDIFF(A.Order_Date, B.Order_Date) <= 30
)
SELECT DISTINCT Customer_Name
FROM CTE;

-- OR

SELECT DISTINCT A.Customer_Name
FROM Orders_Data A
JOIN Orders_Data B
  ON A.Customer_Name = B.Customer_Name
  AND A.Order_Date > B.Order_Date
  AND DATEDIFF(A.Order_Date, B.Order_Date) BETWEEN 1 AND 30;


-- Q5 (Window ranking)
-- Rank customers based on total spending

SELECT *,
	   DENSE_RANK() OVER(
	   ORDER BY Total_Amount DESC) AS D_Rank
FROM (
	SELECT Customer_Name,
		   SUM(Amount) AS Total_Amount
	FROM Orders_Data
	GROUP BY Customer_Name
)T;

-- OR

WITH CTE AS (
	SELECT Customer_Name,
		   SUM(Amount) AS Total_Amount
	FROM Orders_Data
	GROUP BY Customer_Name
)
SELECT *,
	   DENSE_RANK() OVER(
	   ORDER BY Total_Amount DESC) AS D_Rank
FROM CTE;


-- Q6 (Final boss 🚀)
-- For each customer, find the first order 
-- where their running total exceeded 50000

WITH CTE AS (
	SELECT Customer_Name, Order_Date, Amount,
		   SUM(Amount) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date 
		   ROWS BETWEEN UNBOUNDED 
		   PRECEDING AND CURRENT ROW) AS Running_Total
	FROM Orders_Data
), 
CTE2 AS (
	SELECT Customer_Name, Order_Date, Amount, Running_Total
	FROM CTE
	WHERE Running_Total > 50000
)
SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Row_Num
	FROM CTE2
)R
WHERE Row_Num = 1;