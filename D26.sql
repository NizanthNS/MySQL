CREATE DATABASE Sales;

USE Sales;

CREATE TABLE Sales (
    Sale_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50),
    Amount INT,
    Sale_Date DATE
);

INSERT INTO Sales 
VALUES	(1, 'Arun', 'Electronics', 500, '2024-01-01'),
		(2, 'Meena', 'Electronics', 700, '2024-01-02'),
		(3, 'Arun', 'Electronics', 300, '2024-01-03'),
		(4, 'Ravi', 'Clothing', 400, '2024-01-01'),
		(5, 'Priya', 'Clothing', 600, '2024-01-02'),
		(6, 'Ravi', 'Clothing', 200, '2024-01-03'),
		(7, 'Meena', 'Electronics', 800, '2024-01-04');

SELECT *
FROM Sales;


-- Assign a row number to each sale (highest amount first)

SELECT *,
	   ROW_NUMBER() OVER(ORDER BY Amount DESC) AS Row_Num
FROM Sales;


-- Rank sales within each department by amount

SELECT *,
	   RANK() OVER(PARTITION BY Department
       ORDER BY Amount DESC) AS Rank_
FROM Sales;


-- Show rank and dense rank for sales by amount

SELECT *,
	   RANK() OVER(ORDER BY Amount DESC) AS Rank_,
       DENSE_RANK() OVER(ORDER BY Amount DESC) AS D_Rank
FROM Sales;


-- Running total of sales ordered by date

SELECT *,
	   SUM(Amount) OVER(ORDER BY Sale_Date) AS Running_Total
FROM Sales;


-- Running total of sales for each employee

SELECT *,
	   SUM(Amount) OVER(PARTITION BY Employee_NAME
       ORDER BY Sale_Date) AS Running_Total_Emp
FROM Sales;

-- Get the highest sale per department

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Department
           ORDER BY Amount DESC) AS Rank_
	FROM Sales
        ) T
WHERE Rank_ = 1;
