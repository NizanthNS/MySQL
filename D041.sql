USE Daily_SQL;


CREATE TABLE Sales_Records (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Product VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Sales_Records
VALUES
    (1, 'Arun',  'Laptop',   '2024-01-01', 50000),
    (2, 'Arun',  'Mouse',    '2024-01-10', 2000),
    (3, 'Arun',  'Keyboard', '2024-03-15', 3000),
    (4, 'Meena', 'Laptop',   '2024-01-05', 55000),
    (5, 'Meena', 'Mouse',    '2024-02-01', 2500),
    (6, 'Meena', 'Keyboard', '2024-02-20', 3500),
    (7, 'Ravi',  'Laptop',   '2024-01-02', 60000),
    (8, 'Ravi',  'Mouse',    '2024-04-01', 1500),
    (9, 'Priya', 'Laptop',   '2024-01-03', 62000),
    (10,'Priya', 'Mouse',    '2024-01-20', 1800),
    (11,'Priya', 'Keyboard', '2024-02-10', 3200);
    

SELECT *
FROM Sales_Records;


-- Q1 (Warm-up)
-- Find highest order amount

SELECT Order_ID, Customer_Name, Product, Amount
FROM Sales_Records
ORDER BY Amount DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT Order_ID, Customer_Name, Product, Amount,
		   RANK() OVER(ORDER BY Amount DESC) AS Rank_
	FROM Sales_Records
    )T
WHERE Rank_ = 1;

-- OR

WITH CTE AS (
	SELECT Order_ID, Customer_Name, Product, Amount
    FROM Sales_Records
)
SELECT *
FROM CTE
WHERE Amount = (
	SELECT MAX(Amount)
    FROM CTE
);

-- OR 

SELECT Order_ID, Customer_Name, Product, Amount
FROM Sales_Records
WHERE Amount = (
	SELECT MAX(Amount)
    FROM (
		SELECT Order_ID, Customer_Name, Product, Amount
		FROM Sales_Records
	)T
);


-- Q2
-- Find 2nd highest order amount

WITH CTE AS (
	SELECT Order_ID, Customer_Name, Product, Amount,
    DENSE_RANK() OVER(ORDER BY Amount DESC) AS D_Rank
    FROM Sales_Records
)
SELECT *
FROM CTE
WHERE D_Rank = 2;

-- OR

SELECT *
FROM (
	SELECT Order_ID, Customer_Name, Product, Amount,
		   DENSE_RANK() OVER(ORDER BY Amount DESC) AS D_Rank
	FROM Sales_Records
    )T
WHERE D_Rank = 2;

-- OR

SELECT MAX(Amount) AS Second_Highest_Amount
FROM Sales_Records
WHERE Amount < (
	SELECT MAX(Amount) 
	FROM Sales_Records
    );


-- Q3 (Date logic 🔥)
-- Customers who made another purchase within 60 days

WITH CTE AS (
	SELECT Customer_Name, Order_Date,
		   LAG(Order_Date) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous
	FROM Sales_Records
)
SELECT *
FROM (
	SELECT *,
		   DATEDIFF(Order_Date, Previous) AS Difference
	FROM CTE
)R
WHERE Previous IS NOT NULL
AND Difference <= 60;

-- OR

WITH CTE AS (
	SELECT Customer_Name, Order_Date,
		   LAG(Order_Date) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous
	FROM Sales_Records
)
SELECT DISTINCT Customer_Name,
	   DATEDIFF(Order_Date, Previous) AS Difference
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Order_Date, Previous) <= 60;


-- Q4
-- Find total amount spent per customer and rank them

WITH CTE AS (
	SELECT Customer_Name,
		   SUM(Amount) AS Total
	FROM Sales_Records
    GROUP BY Customer_Name
)
SELECT *,
	   RANK() OVER(ORDER BY Total DESC) AS Rank_
FROM CTE;

-- OR

SELECT *,
	   RANK() OVER(ORDER BY Total DESC) AS Rank_
FROM (
	SELECT Customer_Name,
		   SUM(Amount) AS Total
	FROM Sales_Records
    GROUP BY Customer_Name
)T;


-- Q5 (Debug 🚨)
-- What is wrong? Fix it

SELECT Customer_Name,
       SUM(Amount) AS Total
FROM Sales_Records
WHERE SUM(Amount) > 50000
GROUP BY Customer_Name;

-- OR

SELECT Customer_Name,
	   SUM(Amount) AS Total
FROM Sales_Records
GROUP BY Customer_Name
HAVING SUM(Amount) > 50000;


-- Q6 (Slight twist 🔥)
-- Find top customer per product (highest total per product)

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Product
		   ORDER BY Total DESC) AS Rank_
	FROM (
		SELECT Customer_Name, Product, 
			   SUM(Amount) AS Total
		FROM Sales_Records
        GROUP BY Customer_Name, Product
	)T
)R
WHERE Rank_ = 1;

-- OR

WITH CTE AS (
	SELECT Customer_Name, Product, 
		   SUM(Amount) AS Total
	FROM Sales_Records
	GROUP BY Customer_Name, Product
)
SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Product
           ORDER BY Total DESC) AS Rank_
	FROM CTE
    )T
WHERE Rank_ = 1;
	