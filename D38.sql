USE Daily_SQL;


CREATE TABLE Transactions (
    Txn_ID INT,
    Customer_Name VARCHAR(50),
    Product VARCHAR(50),
    Txn_Date DATE,
    Amount INT
);

INSERT INTO Transactions 
VALUES  
    (1, 'Arun',  'Laptop',   '2024-01-01', 50000),
    (2, 'Arun',  'Mouse',    '2024-01-10', 2000),
    (3, 'Arun',  'Keyboard', '2024-02-05', 3000),
    (4, 'Meena', 'Laptop',   '2024-01-03', 55000),
    (5, 'Meena', 'Mouse',    '2024-01-20', 2500),
    (6, 'Ravi',  'Keyboard', '2024-01-15', 4000),
    (7, 'Ravi',  'Mouse',    '2024-03-01', 1500),
    (8, 'Priya', 'Laptop',   '2024-01-25', 60000),
    (9, 'Priya', 'Mouse',    '2024-02-10', 3000);

SELECT *
FROM Transactions;
    

-- Q1
-- Show running total per customer (by date)

SELECT Customer_Name, Txn_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Txn_Date) AS Running_Total
FROM Transactions;


-- Q2
-- Find customers who made at least 2 purchases

SELECT Customer_Name,
	   COUNT(Txn_ID) AS Total
FROM Transactions
GROUP BY Customer_Name
HAVING COUNT(Txn_ID) >= 2;


-- Q3 (Date Logic 🔥)
-- Find customers who made another purchase within 30 days of their previous purchase

SELECT Customer_Name, Txn_Date,
	   LAG(Txn_Date) OVER(PARTITION BY Customer_Name
       ORDER BY Txn_Date) AS Previous_Purchase
FROM Transactions;
       
-- OR

SELECT DISTINCT Customer_Name, Txn_Date
FROM Transactions
WHERE Txn_Date >= CURRENT_DATE - INTERVAL '30' DAY;

-- ANSWER

WITH CTE AS (
	SELECT Customer_Name, Txn_Date,
		   LAG(Txn_Date) OVER(PARTITION BY Customer_Name
           ORDER BY Txn_Date) AS Previous_Date
	FROM Transactions
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Txn_Date, Previous_Date) <= 30;

-- Alt

SELECT Customer_Name, Txn_Date
FROM Transactions
WHERE Txn_Date BETWEEN '2024-01-01' AND '2024-01-31';

-- Another

SELECT Customer_Name, Txn_Date
FROM Transactions
WHERE YEAR(Txn_Date) = 2024 AND
	  MONTH(Txn_Date) = 01;


-- Q4 (Debug 🚨)
-- What is wrong? Fix it.

SELECT Customer_Name,
       COUNT(*) AS Total_Txn
FROM Transactions
WHERE COUNT(*) >= 2
GROUP BY Customer_Name;

-- Answer

SELECT Customer_Name,
       COUNT(*) AS Total_Txn
FROM Transactions
GROUP BY Customer_Name
HAVING COUNT(*) >= 2;


-- Q5 (Behavior + Window 🔥)
-- For each customer, show days difference between current and previous transaction

WITH CTE AS (
	SELECT Customer_Name,
		   Txn_Date,
		   LAG(Txn_Date) OVER(PARTITION BY Customer_Name
		   ORDER BY Txn_Date) AS Previous_Date
	FROM Transactions
)
SELECT *,
	   DATEDIFF(Txn_Date, Previous_Date) AS Days_Diff
FROM CTE
WHERE Previous_Date IS NOT NULL;


-- Q6 (Advanced 🔥)
-- Find "loyal customers":
-- Customers who made 2+ purchases AND at least one purchase within 30 days gap

WITH CTE AS (
	SELECT Customer_Name, Txn_Date,
		   LAG(Txn_Date) OVER(PARTITION BY Customer_Name
		   ORDER BY Txn_Date) AS Previous_Date
	FROM Transactions
),
CTE2 AS (
	SELECT Customer_Name,
    CASE
		WHEN Previous_Date IS NOT NULL
        AND DATEDIFF(Txn_Date, Previous_Date) <= 30
        THEN 1
        ELSE 0
	END AS Within_30
    FROM CTE
)
SELECT Customer_Name
FROM CTE2
GROUP BY Customer_Name
HAVING COUNT(*) >=2 AND
	   SUM(Within_30) >=1;