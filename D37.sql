CREATE DATABASE Daily_SQL;

USE Daily_SQL;


CREATE TABLE Sales_Data (
    Sale_ID INT,
    Customer_Name VARCHAR(50),
    Category VARCHAR(50),
    Sale_Date DATE,
    Amount INT
);

INSERT INTO Sales_Data 
VALUES  
    (1, 'Arun',  'Electronics', '2024-01-01', 5000),
    (2, 'Arun',  'Electronics', '2024-01-03', 3000),
    (3, 'Arun',  'Furniture',   '2024-01-05', 7000),
    (4, 'Meena', 'Electronics', '2024-01-02', 6000),
    (5, 'Meena', 'Furniture',   '2024-01-06', 8000),
    (6, 'Ravi',  'Electronics', '2024-01-04', 2000),
    (7, 'Ravi',  'Furniture',   '2024-01-07', 4000),
    (8, 'Priya', 'Electronics', '2024-01-08', 9000);

SELECT *
FROM Sales_Data;


-- Show sales where Amount > average of that Category

-- Method 1: Window Function

SELECT *
FROM (
	SELECT Sale_ID, Category, Amount,
		   AVG(Amount) OVER(PARTITION BY Category) AS Average
	FROM Sales_Data
)T
WHERE Amount > Average;


-- Method 2: CTE

WITH CTE AS (
	SELECT Sale_ID, Category, Amount,
		   AVG(Amount) OVER(PARTITION BY Category) AS Average
	FROM Sales_Data
)
SELECT *
FROM CTE
WHERE Amount > Average;


-- Method 3: Correlated Subquery

SELECT Sale_ID, Category, Amount
FROM Sales_Data O1
WHERE Amount > (
	SELECT AVG(Amount)
    FROM Sales_Data O2
    WHERE O1.Category = O2.Category
);


CREATE TABLE Orders_Data (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Category VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Orders_Data 
VALUES  
    (1, 'Arun',  'Electronics', '2024-01-01', 5000),
    (2, 'Arun',  'Electronics', '2024-01-03', 3000),
    (3, 'Arun',  'Furniture',   '2024-01-05', 7000),
    (4, 'Meena', 'Electronics', '2024-01-02', 6000),
    (5, 'Meena', 'Furniture',   '2024-01-06', 8000),
    (6, 'Ravi',  'Electronics', '2024-01-04', 2000),
    (7, 'Ravi',  'Furniture',   '2024-01-07', 4000),
    (8, 'Priya', 'Electronics', '2024-01-08', 9000);

SELECT *
FROM Orders_Data;


-- Step 1: Total per customer per category

SELECT Customer_Name, Category,
	   SUM(Amount) AS Total
FROM Orders_Data
GROUP BY Customer_Name, Category;


-- Step 2: Rank within category

WITH CTE AS (
	SELECT Customer_Name, Category,
		   SUM(Amount) AS Total
	FROM Orders_Data
	GROUP BY Customer_Name, Category
)
SELECT *,
	   RANK() OVER(PARTITION BY Category
       ORDER BY Total DESC) AS Rank_
FROM CTE;


-- Step 3: Filter top 1

WITH CTE AS (
	SELECT Customer_Name, Category,
		   SUM(Amount) AS Total
	FROM Orders_Data
	GROUP BY Customer_Name, Category
),
CTE2 AS (
	SELECT *,
		   RANK() OVER(PARTITION BY Category
		   ORDER BY Total DESC) AS Rank_
	FROM CTE
)
SELECT *
FROM CTE2
WHERE Rank_ = 1;


-- Step 4: Add difference from category average

WITH CTE AS (
	SELECT Customer_Name, Category,
		   SUM(Amount) AS Total
	FROM Orders_Data
	GROUP BY Customer_Name, Category
),
CTE2 AS (
	SELECT *,
		   RANK() OVER(PARTITION BY Category
		   ORDER BY Total DESC) AS Rank_,
           AVG(Total) OVER(PARTITION BY Category) AS Average
	FROM CTE
)
SELECT *,
	   Total - Average AS Difference
FROM CTE2
WHERE Rank_ = 1;
