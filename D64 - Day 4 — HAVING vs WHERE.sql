USE Daily_SQL;

CREATE TABLE Sales (
    Sale_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50),
    Region VARCHAR(50),
    Sales_Amount INT,
    Sale_Date DATE
);

INSERT INTO Sales
VALUES  (1, 'Arun',    'Electronics', 'South', 45000, '2024-01-10'),
        (2, 'Meena',   'Furniture',   'North', 20000, '2024-01-12'),
        (3, 'Ravi',    'Electronics', 'South', 38000, '2024-01-15'),
        (4, 'Priya',   'Clothing',    'East',  12000, '2024-01-18'),
        (5, 'Karthik', 'Furniture',   'North', 25000, '2024-01-20'),
        (6, 'Divya',   'Electronics', 'South', 52000, '2024-01-25'),
        (7, 'Sanjay',  'Clothing',    'West',   8000, '2024-01-28'),
        (8, 'Nisha',   'Furniture',   'South', 30000, '2024-02-01'),
        (9, 'Vikram',  'Electronics', 'East',  41000, '2024-02-05'),
        (10,'Aarthi',  'Clothing',    'North', 15000, '2024-02-10');
        
        
SELECT *
FROM Sales;


-- Day 4 : HAVING vs WHERE


-- Q1
-- Show Departments where the total Sales_Amount is 
-- greater than 100000.

SELECT Department,
	   SUM(Sales_Amount) AS Total_Sales
FROM Sales
GROUP BY Department
HAVING SUM(Sales_Amount) > 100000;


-- Q2
-- Show Regions where the average Sales_Amount is 
-- less than 25000.

SELECT Region,
	   ROUND(AVG(Sales_Amount), 2) AS Average
FROM Sales
GROUP BY Region
HAVING AVG(Sales_Amount) < 25000;


-- Q3
-- Find Departments having more than 2 sales records.

SELECT Department,
	   COUNT(Sale_ID) AS Sales_Record
FROM Sales
GROUP BY Department
HAVING COUNT(Sale_ID) > 2;


-- Q4
-- Show Departments where:
-- 1. Individual Sales_Amount is greater than 10000
-- 2. Total department sales is greater than 70000

SELECT Department,
       SUM(Sales_Amount) AS Total_Sales
FROM Sales
WHERE Sales_Amount > 10000
GROUP BY Department
HAVING SUM(Sales_Amount) > 70000;


-- Q5
-- Find Regions where the maximum Sales_Amount is 
-- greater than 40000.

SELECT Region,
	   MAX(Sales_Amount) AS Maximum_Sales_Amount
FROM Sales
GROUP BY Region
HAVING MAX(Sales_Amount) > 40000;


-- Q6
-- Show Departments where:
-- 1. Region is not 'West'
-- 2. Average Sales_Amount is greater than 30000

SELECT Department,
	   ROUND(AVG(Sales_Amount), 2) AS Average
FROM Sales
WHERE Region != 'West'
GROUP BY Department
HAVING AVG(Sales_Amount) > 30000;


-- Bonus Debugging Question

SELECT Department, SUM(Sales_Amount)
FROM Sales
WHERE SUM(Sales_Amount) > 70000
GROUP BY Department;

-- What is wrong with this query?
-- Rewrite it correctly.

-- ANSWER

SELECT Department, SUM(Sales_Amount)
FROM Sales
GROUP BY Department
HAVING SUM(Sales_Amount) > 70000;
