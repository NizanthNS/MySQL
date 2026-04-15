CREATE TABLE Transactions (
    Txn_ID INT,
    Customer_Name VARCHAR(50),
    City VARCHAR(50),
    Txn_Date DATE,
    Amount INT
);

INSERT INTO Transactions 
VALUES	(1, 'Arun', 'Chennai', '2024-01-01', 5000),
		(2, 'Arun', 'Chennai', '2024-01-03', 3000),
		(3, 'Arun', 'Mumbai', '2024-01-05', 7000),
		(4, 'Meena', 'Chennai', '2024-01-02', 6000),
		(5, 'Meena', 'Mumbai', '2024-01-06', 8000),
		(6, 'Ravi', 'Chennai', '2024-01-04', 2000),
		(7, 'Ravi', 'Mumbai', '2024-01-07', 4000),
		(8, 'Priya', 'Chennai', '2024-01-08', 9000);
        

SELECT *
FROM Transactions;


-- Q1
-- Show customer_name, txn_date, amount,
-- and running total per customer (by date)

SELECT Customer_Name, Txn_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Txn_Date) AS Running_Total
FROM Transactions;


-- Q2
-- Show city and total transaction amount

SELECT City,
	   SUM(Amount) AS Total_Transaction_Amount
FROM Transactions
GROUP BY City;


-- Q3 (Trap)
-- Show customer_name, city, amount,
-- and rank transactions within each city (highest first)
-- ❗ No unnecessary GROUP BY

SELECT Customer_Name, City, Amount,
	   RANK() OVER(PARTITION BY City
       ORDER BY Amount DESC) AS Rank_
FROM Transactions;


-- Q4 (Important)
-- Show customer_name, city,
-- total amount per customer per city,
-- and rank customers within each city based on total amount

SELECT  *,
	    RANK() OVER(PARTITION BY City
        ORDER BY Total_Amount DESC) AS Rank_
FROM (
	SELECT Customer_Name, City,
		   SUM(Amount) AS Total_Amount
	FROM Transactions
    GROUP BY Customer_Name, City
)T;

-- OR

WITH CTE AS (
	SELECT Customer_Name, City,
		   SUM(Amount) AS Total_Amount
	FROM Transactions
    GROUP BY Customer_Name, City
)
SELECT *,
	   RANK() OVER(PARTITION BY City
	   ORDER BY Total_Amount DESC) AS Rank_
FROM CTE;


-- Q5 (Precision)
-- Show ONLY the top 2 transactions per city
-- ❗ If tie → include both

WITH CTE AS (
	SELECT City, Amount,
		   RANK() OVER(PARTITION BY City
		   ORDER BY Amount DESC) AS Rank_
	FROM Transactions
)
SELECT *
FROM CTE
WHERE Rank_ <=2;

-- OR

SELECT *
FROM (
	SELECT City, Amount,
		   RANK() OVER(PARTITION BY City
		   ORDER BY Amount DESC) AS Rank_
	FROM Transactions
) T
WHERE Rank_ <=2;


-- Q6 (Filtering Trap)
-- Show transactions where amount is ABOVE the average of that city
-- ❗ Don’t use WHERE incorrectly

WITH CTE AS (
	SELECT Txn_ID,
		   City,
		   Amount,
		   AVG(Amount) OVER(PARTITION BY City) AS Average
	FROM Transactions
)
SELECT *
FROM CTE
WHERE Amount > Average;
	