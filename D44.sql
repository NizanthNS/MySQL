USE Daily_SQL;


CREATE TABLE Sales_Records ( 
	Order_ID INT, 
	Customer_Name VARCHAR(50), 
    Product VARCHAR(50), 
    Order_Date DATE, 
    Amount INT );

INSERT INTO Sales_Records 
VALUES 	(1, 'Arun', 'Laptop', '2024-01-01', 50000), 
		(2, 'Arun', 'Mouse', '2024-01-10', 2000), 
		(3, 'Arun', 'Keyboard', '2024-03-15', 3000), 
        (4, 'Meena', 'Laptop', '2024-01-05', 55000), 
        (5, 'Meena', 'Mouse', '2024-02-01', 2500), 
        (6, 'Meena', 'Keyboard', '2024-02-20', 3500), 
        (7, 'Ravi', 'Laptop', '2024-01-02', 60000), 
        (8, 'Ravi', 'Mouse', '2024-04-01', 1500), 
        (9, 'Priya', 'Laptop', '2024-01-03', 62000), 
        (10,'Priya', 'Mouse', '2024-01-20', 1800), 
        (11,'Priya', 'Keyboard', '2024-02-10', 3200);
        

CREATE TABLE Customer_Info (
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customer_Info
VALUES	('Arun', 'Chennai'),
		('Meena', 'Madurai'),
		('Ravi', 'Coimbatore'),
		('Priya', 'Chennai');
        
SELECT *
FROM Sales_Records;

SELECT *
FROM Customer_Info;


-- Q1 (Warm-up JOIN)
-- Show all orders along with customer city

SELECT Customer_Info.City,
	   Sales_Records.Product,
	   Sales_Records.Order_ID,
       Sales_Records.Order_Date,
       Sales_Records.Amount
FROM Customer_Info
INNER JOIN Sales_Records
	ON Sales_Records.Customer_Name = Customer_Info.Customer_Name;


-- Q2 (JOIN + Aggregation)
-- Find total amount spent per city

SELECT Customer_Info.City,
       SUM(Sales_Records.Amount) AS Total_Amount
FROM Customer_Info
INNER JOIN Sales_Records
	ON Sales_Records.Customer_Name = Customer_Info.Customer_Name
GROUP BY Customer_Info.City;


-- Q3 (Date Logic + JOIN 🔥)
-- Customers who made another purchase within 60 days + their city

WITH CTE AS (
	SELECT I.Customer_Name,
		   I.City,
		   S.Order_Date,
		   LAG(S.Order_Date) OVER(PARTITION BY I.Customer_Name
		   ORDER BY S.Order_Date) AS Previous_Purchase
	FROM Customer_Info I
    INNER JOIN Sales_Records S
		ON I.Customer_Name = S.Customer_Name
)
SELECT *,
	   DATEDIFF(Order_Date, Previous_Purchase) AS Difference
FROM CTE
WHERE Previous_Purchase IS NOT NULL
AND DATEDIFF(Order_Date, Previous_Purchase) <= 60;


-- Q4 (JOIN + Ranking 🔥)
-- Find top customer per city (highest total spend)

WITH CTE AS (
	SELECT I.Customer_Name,
		   I.City,
           SUM(S.Amount) AS Total_Spent
	FROM Customer_Info I
    INNER JOIN Sales_Records S
		ON I.Customer_Name = S.Customer_Name
	GROUP BY I.Customer_Name, I.City
)
SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY City
		   ORDER BY Total_Spent DESC) AS Rnk
	FROM CTE
	)T
WHERE Rnk = 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY City
           ORDER BY Total_Spent DESC) AS Rnk
	FROM (
		SELECT I.Customer_Name,
			   I.City,
			   SUM(S.Amount) AS Total_Spent
		FROM Customer_Info I
		INNER JOIN Sales_Records S
			ON I.Customer_Name = S.Customer_Name
		GROUP BY I.Customer_Name, I.City
	)R
)T
WHERE Rnk = 1;


-- Q5 (Twist 🧠)
-- Find city with highest total sales

SELECT I.City,
       SUM(S.Amount) AS Total_Amount
FROM Customer_Info I
INNER JOIN Sales_Records S
	ON S.Customer_Name = I.Customer_Name
GROUP BY I.City
HAVING Total_Amount = (
	SELECT MAX(Total_Amount)
    FROM (
		SELECT I.City,
			   SUM(S.Amount) AS Total_Amount
		FROM Customer_Info I
		INNER JOIN Sales_Records S
			ON S.Customer_Name = I.Customer_Name
		GROUP BY I.City
	)T
);

-- OR

WITH CTE AS (
	SELECT I.City,
		   SUM(S.Amount) AS Total_Amount
	FROM Customer_Info I
	INNER JOIN Sales_Records S
		ON S.Customer_Name = I.Customer_Name
	GROUP BY I.City
)
SELECT *
FROM CTE
WHERE Total_Amount = (
	SELECT MAX(Total_Amount)
    FROM CTE
);

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Amount DESC) AS Rnk
	FROM (
		SELECT I.City,
			   SUM(S.Amount) AS Total_Amount
		FROM Customer_Info I
		INNER JOIN Sales_Records S
			ON S.Customer_Name = I.Customer_Name
		GROUP BY I.City
	)T
)R
WHERE Rnk = 1;


-- Q6 (Slight twist 🔥)
-- Find 2nd highest spending customer per city

WITH CTE AS (
	SELECT I.Customer_Name,
		   I.City,
           SUM(S.Amount) AS Total_Spent
	FROM Customer_Info I
    INNER JOIN Sales_Records S
		ON I.Customer_Name = S.Customer_Name
	GROUP BY I.Customer_Name, I.City
)
SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY City
		   ORDER BY Total_Spent DESC) AS Rnk
	FROM CTE
	)T
WHERE Rnk = 2;


-- Q7 (Fun 🧠)
-- Find customers who bought in MORE THAN 1 category (Product)

SELECT Customer_Name,
	   COUNT(DISTINCT Product) AS Total_Purchase
FROM Sales_Records
GROUP BY Customer_Name
HAVING COUNT(DISTINCT Product) > 1;


-- Q8 (Join + Filter 🔥)
-- Find customers from Chennai who spent more than 50000 total

WITH CTE AS (
	SELECT I.Customer_Name, 
		   I.City,
		   SUM(S.Amount) AS Total_Amount
	FROM Customer_Info I
	INNER JOIN Sales_Records S
		ON S.Customer_Name = I.Customer_Name
	GROUP BY I.Customer_Name, I.City
)
SELECT *
FROM CTE
WHERE City = 'Chennai'
AND Total_Amount > 50000;


-- Q9 (Date + Join 🔥)
-- Find customers whose FIRST purchase was in January + their city

WITH CTE AS (
	SELECT I.Customer_Name,
		   I.City,
		   S.Order_Date,
		   RANK() OVER(PARTITION BY I.Customer_Name
		   ORDER BY S.Order_Date) AS Rnk
	FROM Customer_Info I
    INNER JOIN Sales_Records S
		ON I.Customer_Name = S.Customer_Name
)
SELECT *
FROM CTE
WHERE MONTH(Order_Date) = 1
AND Rnk = 1;
               

-- Q10 (Challenge 🚀)
-- For each city, find the customer whose LAST purchase is the highest amount

WITH CTE AS (
    SELECT I.Customer_Name,
           I.City,
           S.Amount,
           S.Order_Date,
           ROW_NUMBER() OVER(PARTITION BY I.Customer_Name
		   ORDER BY S.Order_Date DESC) AS Row_Num
    FROM Customer_Info I
    JOIN Sales_Records S
      ON I.Customer_Name = S.Customer_Name
),
CTE2 AS (
    SELECT *
    FROM CTE
    WHERE Row_Num = 1   -- keep only last purchases
),
CTE3 AS (
    SELECT *,
           RANK() OVER(PARTITION BY City
		   ORDER BY Amount DESC) AS Rnk
    FROM CTE2
)
SELECT *
FROM CTE3
WHERE Rnk = 1;
