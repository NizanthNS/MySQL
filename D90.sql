USE Daily_SQL;


-- DATASET

CREATE TABLE Customer_Purchases (
    Purchase_ID INT,
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    Purchase_Date DATE,
    Product_Category VARCHAR(30),
    Amount INT,
    Store_City VARCHAR(30)
);

INSERT INTO Customer_Purchases 
VALUES	(1,101,'Alice','2024-01-01','Electronics',1200,'Chennai'),
		(2,101,'Alice','2024-01-02','Electronics',800,'Chennai'),
		(3,101,'Alice','2024-01-03','Books',300,'Chennai'),
		(4,101,'Alice','2024-01-07','Books',500,'Madurai'),

		(5,102,'Bob','2024-01-01','Clothing',700,'Coimbatore'),
		(6,102,'Bob','2024-01-05','Electronics',1500,'Coimbatore'),
		(7,102,'Bob','2024-01-06','Books',400,'Coimbatore'),

		(8,103,'Charlie','2024-01-02','Electronics',2000,'Chennai'),
		(9,103,'Charlie','2024-01-03','Books',500,'Chennai'),
		(10,103,'Charlie','2024-01-04','Books',600,'Madurai'),
		(11,103,'Charlie','2024-01-05','Clothing',900,'Madurai'),

		(12,104,'David','2024-01-01','Books',250,'Trichy'),
		(13,104,'David','2024-01-08','Electronics',1800,'Trichy'),

		(14,105,'Emma','2024-01-03','Clothing',1000,'Chennai'),
		(15,105,'Emma','2024-01-04','Clothing',1200,'Chennai'),
		(16,105,'Emma','2024-01-05','Electronics',2500,'Chennai');

SELECT *
FROM Customer_Purchases;     

-- Q1
-- Show each customer's total purchases, total amount spent,
-- and average purchase amount.

SELECT Customer_ID, Customer_Name,
	   COUNT(Purchase_ID) AS Total_Purchases,
       SUM(Amount) AS Total_Amount_Spent,
       ROUND(AVG(Amount), 2) AS Average_Purchase_Amount
FROM Customer_Purchases
GROUP BY Customer_ID, Customer_Name;


-- Q2
-- Show each product category's total purchases and total revenue.

SELECT Product_Category,
	   COUNT(Purchase_ID) AS Total_Purchases,
       SUM(Amount) AS Total_Revenue
FROM Customer_Purchases
GROUP BY Product_Category;


-- Q3
-- Find the top 3 customers by total amount spent.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Amount_Spent DESC) AS D_Rank
	FROM (
		SELECT Customer_ID, Customer_Name,
			   SUM(Amount) AS Total_Amount_Spent
		FROM Customer_Purchases
		GROUP BY Customer_ID, Customer_Name
	)H
)D
WHERE D_Rank <= 3;


-- Q4
-- Find customers who made a purchase within 2 days
-- of their previous purchase.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name, Purchase_Date,
		   LAG(Purchase_Date) OVER(PARTITION BY Customer_ID
           ORDER BY Purchase_Date, Purchase_ID) AS Previous
	FROM Customer_Purchases
)
SELECT DISTINCT Customer_ID, Customer_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Purchase_Date, Previous) <= 2;


-- Q5
-- Find customers whose total spending is greater than
-- the average spending of all customers.

SELECT Customer_ID, Customer_Name,
       SUM(Amount) AS Total_Amount_Spent
FROM Customer_Purchases
GROUP BY Customer_ID, Customer_Name
HAVING SUM(Amount) > (
	SELECT AVG(Total_Amount_Spent)
    FROM (
		SELECT Customer_ID, Customer_Name,
			   SUM(Amount) AS Total_Amount_Spent
		FROM Customer_Purchases
		GROUP BY Customer_ID, Customer_Name
	)A
);


-- BONUS
-- Find each customer's longest consecutive purchase streak.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Longest_Streak

WITH CTE AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Customer_ID
           ORDER BY Purchase_Date) AS RN
	FROM Customer_Purchases
),
CTE2 AS (
SELECT *,
	   DATE_SUB(Purchase_Date, INTERVAL RN DAY) AS Gp
FROM CTE
),
CTE3 AS (
	SELECT Customer_ID, Customer_Name,
		   COUNT(*) AS Streak
	FROM CTE2
    GROUP BY Customer_ID, Customer_Name, Gp
)
SELECT DISTINCT Customer_ID, Customer_Name,
	   MAX(Streak) AS Longest_Streak
FROM CTE3
GROUP BY Customer_ID, Customer_Name
HAVING MAX(Streak) >= 3;