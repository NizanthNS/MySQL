USE Daily_SQL;

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customers
VALUES  (1, 'Arun',   'Chennai'),
        (2, 'Meena',  'Bangalore'),
        (3, 'Ravi',   'Mumbai'),
        (4, 'Priya',  'Chennai'),
        (5, 'Divya',  'Delhi');
        

CREATE TABLE Subscription_Data (
    Subscription_ID INT PRIMARY KEY,
    Customer_ID INT,
    Plan_Name VARCHAR(50),
    Amount INT,
    Start_Date DATE
);

INSERT INTO Subscription_Data
VALUES  (101, 1, 'Basic',   500,  '2024-01-01'),
        (102, 1, 'Premium', 1200, '2024-01-10'),
        (103, 2, 'Basic',   500,  '2024-01-05'),
        (104, 3, 'Gold',    2000, '2024-01-08'),
        (105, 1, 'Gold',    2000, '2024-01-18'),
        (106, 4, 'Basic',   500,  '2024-01-15'),
        (107, 5, 'Premium', 1200, '2024-01-20'),
        (108, 3, 'Gold',    2000, '2024-01-25'),
        (109, 2, 'Premium', 1200, '2024-02-01'),
        (110, 4, 'Gold',    2000, '2024-02-06'),
        (111, 5, 'Premium', 1200, '2024-02-10'),
        (112, 1, 'Basic',   500,  '2024-02-15');


SELECT *
FROM Customers;

SELECT *
FROM Subscription_Data;
        

-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each customer along with:
-- 1. Total subscriptions
-- 2. Total Amount spent
-- 3. Average subscription Amount
-- ordered by Total Amount spent descending.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name,
		   COUNT(S.Subscription_ID) AS Total_subscriptions,
           SUM(S.Amount) AS Total_Amount_spent,
           ROUND(AVG(S.Amount), 2) AS Average_subscription_Amount
	FROM Customers C
    INNER JOIN Subscription_Data S
		ON C.Customer_ID = S.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name
)
SELECT *
FROM CTE
ORDER BY Total_Amount_spent DESC;


-- Q2
-- Find customers whose total spending
-- is greater than the average spending
-- of all customers.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name,
           SUM(S.Amount) AS Total_Amount_spent
	FROM Customers C
    INNER JOIN Subscription_Data S
		ON C.Customer_ID = S.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Amount_spent > (
	SELECT AVG(Total_Amount_spent)
    FROM CTE
);


-- Q3
-- Show the highest spending customer
-- in each City.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY City
           ORDER BY Total_Amount_spent DESC) AS D_Rank
	FROM (
		SELECT C.Customer_ID, C.Customer_Name, C.City,
			   SUM(S.Amount) AS Total_Amount_spent
		FROM Customers C
		INNER JOIN Subscription_Data S
			ON C.Customer_ID = S.Customer_ID
		GROUP BY C.Customer_ID, C.Customer_Name, C.City
	)D
)M
WHERE D_Rank = 1;


-- Q4
-- Show plans that were subscribed to
-- more than once within the same month.

SELECT Plan_Name,
       COUNT(Subscription_ID) AS Total_Subscriptions,
       YEAR(Start_Date) AS Year_,
       MONTH(Start_Date) AS Month_
FROM Subscription_Data
GROUP BY Plan_Name, YEAR(Start_Date), MONTH(Start_Date)
HAVING COUNT(Subscription_ID) > 1;


-- Q5
-- Show each subscription along with:
-- 1. Previous subscription Amount of that customer
-- 2. Difference from previous subscription Amount
-- 3. Running total spending of that customer

WITH CTE AS (
	SELECT Subscription_ID, Plan_Name, Start_Date, Amount,
		   LAG(Amount) OVER(PARTITION BY Customer_ID
           ORDER BY Start_Date) AS Previous_Amount,
           SUM(Amount) OVER(PARTITION BY Customer_ID
           ORDER BY Start_Date) AS Running_Total
	FROM Subscription_Data
)
SELECT *,
	   Amount - Previous_Amount AS Difference
FROM CTE
WHERE Previous_Amount IS NOT NULL;


-- Q6 (Date Logic)
-- Find customers who subscribed again
-- within 10 days of their previous subscription.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, S.Start_Date,
		   LAG(S.Start_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY S.Start_Date) AS Previous
	FROM Customers C
    INNER JOIN Subscription_Data S
		ON C.Customer_ID = S.Customer_ID
)
SELECT DISTINCT Customer_Name, Customer_ID
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Start_Date, Previous) <= 10;


-- Bonus Challenge
-- Show:
-- 1. Customer_Name
-- 2. First Subscription Date
-- 3. Latest Subscription Date
-- 4. Total Subscriptions
-- 5. Total Amount Spent
-- 6. Average Days Between Subscriptions

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name,
		   S.Start_Date, S.Subscription_ID, S.Amount,
		   LAG(S.Start_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY S.Start_Date) AS Previous_Date
	FROM Customers C
    INNER JOIN Subscription_Data S
		ON C.Customer_ID = S.Customer_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Start_Date, Previous_Date) AS Days_Gap
	FROM CTE
)
SELECT Customer_ID, Customer_Name,
	   MIN(Start_Date) AS First_Subscription_Date,
       MAX(Start_Date) AS Last_Subscription_Date,
       COUNT(Subscription_ID) Total_Subscriptions,
       SUM(Amount) Total_Amount_Spent,
       ROUND(AVG(Days_Gap), 2) AS Average_Days
FROM CTE2
GROUP BY Customer_ID, Customer_Name;