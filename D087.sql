USE Daily_SQL;

-- DATASET

CREATE TABLE Bank_Transactions (
    Transaction_ID INT,
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    Transaction_Date DATE,
    Transaction_Type VARCHAR(20),
    Amount DECIMAL(10,2),
    Branch_Name VARCHAR(50)
);

INSERT INTO Bank_Transactions 
VALUES	(1,101,'Alice','2024-01-05','Deposit',5000,'Chennai'),
		(2,101,'Alice','2024-01-15','Withdrawal',1500,'Chennai'),
		(3,101,'Alice','2024-01-25','Deposit',3000,'Madurai'),

		(4,102,'Bob','2024-01-08','Deposit',7000,'Coimbatore'),
		(5,102,'Bob','2024-02-10','Withdrawal',2000,'Coimbatore'),

		(6,103,'Charlie','2024-01-10','Deposit',4000,'Chennai'),
		(7,103,'Charlie','2024-01-18','Deposit',2500,'Chennai'),
		(8,103,'Charlie','2024-01-28','Withdrawal',1000,'Madurai'),

		(9,104,'David','2024-01-12','Deposit',6000,'Trichy'),
		(10,104,'David','2024-02-20','Withdrawal',2500,'Trichy'),

		(11,105,'Emma','2024-01-20','Deposit',8000,'Chennai'),
		(12,105,'Emma','2024-02-05','Deposit',2000,'Madurai'),

		(13,106,'Frank','2024-01-25','Deposit',3500,'Coimbatore'),
		(14,106,'Frank','2024-02-01','Withdrawal',500,'Coimbatore'),
		(15,106,'Frank','2024-02-18','Deposit',1500,'Chennai');
        
SELECT *
FROM Bank_Transactions;
        

-- Q1
-- Show each customer's total transactions, total amount transacted,
-- and average transaction amount.

SELECT Customer_ID, Customer_Name,
	   COUNT(Transaction_ID) AS Total_Transactions,
       SUM(Amount) AS Total_Transaction_Amount,
       ROUND(AVG(Amount), 2) AS Average_Transaction_Amount
FROM Bank_Transactions
GROUP BY Customer_ID, Customer_Name;


-- Q2
-- Show each branch's total transactions and total transaction amount.

SELECT Branch_Name,
	   COUNT(Transaction_ID) AS Total_Transactions,
       SUM(Amount) AS Total_Transaction_Amount
FROM Bank_Transactions
GROUP BY Branch_Name;


-- Q3
-- Find the top 3 customers by total transaction amount.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name,
		   SUM(Amount) AS Total_Transaction_Amount
	FROM Bank_Transactions
	GROUP BY Customer_ID, Customer_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY 
           Total_Transaction_Amount DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 3;


-- Q4
-- Find customers who made a transaction within 15 days 
-- of their previous transaction.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name, Transaction_Date,
		   LAG(Transaction_Date) OVER(PARTITION BY Customer_ID
           ORDER BY Transaction_ID, Transaction_Date) AS Previous
	FROM Bank_Transactions
)
SELECT DISTINCT Customer_ID, Customer_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Transaction_Date, Previous) <= 15;


-- Q5
-- Find customers whose total transaction amount is greater than the
-- average total transaction amount of all customers.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name,
		   SUM(Amount) AS Total_Transaction_Amount
	FROM Bank_Transactions
	GROUP BY Customer_ID, Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Transaction_Amount > (
	SELECT AVG(Total_Transaction_Amount)
    FROM CTE
);


-- BONUS
-- For each customer, find the longest gap between two consecutive 
-- transactions.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name, Transaction_Date,
		   LAG(Transaction_Date) OVER(PARTITION BY Customer_ID
           ORDER BY Transaction_ID, Transaction_Date) AS Previous
	FROM Bank_Transactions
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Transaction_Date, Previous) AS Days_Gap
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Customer_ID
           ORDER BY Days_Gap DESC) AS D_Rank
	FROM CTE2
)
SELECT DISTINCT Customer_ID, Customer_Name, Days_Gap
FROM CTE3
WHERE D_Rank = 1;

-- OR

WITH CTE AS (
    SELECT Customer_ID, Customer_Name,
           DATEDIFF(Transaction_Date,
		   LAG(Transaction_Date) OVER(PARTITION BY Customer_ID
		   ORDER BY Transaction_Date)) AS Days_Gap
    FROM Bank_Transactions
)
SELECT Customer_ID, Customer_Name,
       MAX(Days_Gap) AS Longest_Gap
FROM CTE
GROUP BY Customer_ID, Customer_Name;