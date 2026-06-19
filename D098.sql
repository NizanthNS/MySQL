USE Daily_SQL;

-- DATASET

CREATE TABLE Store_Visits (
    Visit_ID INT PRIMARY KEY,
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    Visit_Date DATE,
    Store_Location VARCHAR(50),
    Purchase_Amount INT,
    Membership_Type VARCHAR(20)
);

INSERT INTO Store_Visits 
VALUES	(1,101,'Alice','2024-01-01','Chennai',1200,'Gold'),
		(2,101,'Alice','2024-01-02','Chennai',800,'Gold'),
		(3,101,'Alice','2024-01-03','Bangalore',1500,'Gold'),
		(4,101,'Alice','2024-01-07','Chennai',500,'Gold'),

		(5,102,'Bob','2024-01-01','Mumbai',700,'Silver'),
		(6,102,'Bob','2024-01-05','Mumbai',900,'Silver'),
		(7,102,'Bob','2024-01-06','Delhi',1100,'Silver'),

		(8,103,'Charlie','2024-01-02','Chennai',2000,'Gold'),
		(9,103,'Charlie','2024-01-03','Chennai',1800,'Gold'),
		(10,103,'Charlie','2024-01-04','Bangalore',1600,'Gold'),
		(11,103,'Charlie','2024-01-05','Mumbai',1400,'Gold'),

		(12,104,'David','2024-01-01','Delhi',400,'Bronze'),
		(13,104,'David','2024-01-08','Delhi',600,'Bronze'),

		(14,105,'Emma','2024-01-03','Mumbai',2200,'Gold'),
		(15,105,'Emma','2024-01-04','Mumbai',2100,'Gold'),
		(16,105,'Emma','2024-01-05','Chennai',2300,'Gold');
        
SELECT *
FROM Store_Visits;

-- Q1
-- Show each customer's total visits,
-- total purchase amount, and average purchase amount.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Total_Visits
-- Total_Purchase_Amount
-- Average_Purchase_Amount

SELECT Customer_ID, Customer_Name,
	   COUNT(Visit_ID) AS Total_Visits,
       SUM(Purchase_Amount) AS Total_Purchase_Amount,
       ROUND(AVG(Purchase_Amount), 2) AS Average_Purchase_Amount
FROM Store_Visits
GROUP BY Customer_ID, Customer_Name;


-- Q2
-- Show each store location's total visits
-- and total purchase amount.
--
-- Return:
-- Store_Location
-- Total_Visits
-- Total_Purchase_Amount

SELECT Store_Location,
	   COUNT(Visit_ID) AS Total_Visits,
       SUM(Purchase_Amount) AS Total_Purchase_Amount
FROM Store_Visits
GROUP BY Store_Location;


-- Q3
-- Find the top 3 customers by total purchase amount.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Total_Purchase_Amount

WITH CTE AS (
	SELECT Customer_ID, Customer_Name,
		   SUM(Purchase_Amount) AS Total_Purchase_Amount
	FROM Store_Visits
	GROUP BY Customer_ID, Customer_Name
),
CTE2 AS (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Purchase_Amount DESC) AS D_Rank
	FROM CTE
)
SELECT Customer_ID, Customer_Name, Total_Purchase_Amount
FROM CTE2
WHERE D_Rank <= 3;


-- Q4
-- Find customers who visited within 2 days
-- of their previous visit.
--
-- Return:
-- Customer_ID
-- Customer_Name

WITH CTE AS (
	SELECT Customer_ID, Customer_Name, Visit_Date,
		   LAG(Visit_Date) OVER(PARTITION BY Customer_ID
           ORDER BY Visit_Date, Visit_ID) AS Previous
	FROM Store_Visits
)
SELECT DISTINCT Customer_ID, Customer_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Visit_Date, Previous) <= 2;


-- Q5
-- Find customers whose total purchase amount is greater
-- than the average total purchase amount of all customers.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Total_Purchase_Amount

WITH CTE AS (
	SELECT Customer_ID, Customer_Name,
		   SUM(Purchase_Amount) AS Total_Purchase_Amount
	FROM Store_Visits
	GROUP BY Customer_ID, Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Purchase_Amount > (
	SELECT AVG(Total_Purchase_Amount)
    FROM CTE
);


-- BONUS
-- Find customers who have more than one visit streak.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Total_Streaks
--
-- Note:
-- Ignore duplicate visit dates if a customer
-- has multiple visits on the same day.
--
-- Return only customers having at least 2 streaks.

WITH CTE AS (
	SELECT DISTINCT Customer_ID, Customer_Name, Visit_Date
    FROM Store_Visits
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Customer_ID
           ORDER BY Visit_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Visit_Date, INTERVAL RN DAY) AS GK
	FROM CTE2
),
CTE4 AS (
	SELECT Customer_ID, Customer_Name,
		   COUNT(*) AS Streak
	FROM CTE3
    GROUP BY Customer_ID, Customer_Name, GK
)
SELECT Customer_ID, Customer_Name,
	   COUNT(*) AS Total_Streaks
FROM CTE4
GROUP BY Customer_ID, Customer_Name
HAVING COUNT(*) >= 2;