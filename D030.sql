CREATE DATABASE Sales;

USE Sales;


CREATE TABLE Sales (
    Sale_ID INT,
    Employee_Name VARCHAR(50),
    Region VARCHAR(50),
    Amount INT
);

INSERT INTO Sales 
VALUES	(1, 'Arun', 'North', 5000),
		(2, 'Arun', 'North', 7000),
		(3, 'Meena', 'North', 6000),
		(4, 'Ravi', 'South', 4000),
		(5, 'Ravi', 'South', 3000),
		(6, 'Priya', 'South', 8000),
		(7, 'Kiran', 'North', 6500);

SELECT *
FROM Sales;
        

-- Q1
-- Show region and total sales

SELECT Region,
	   SUM(Amount) AS Total_Sales
FROM Sales
GROUP BY Region;


-- Q2
-- Show employee_name, region, amount,
-- and total sales of that region (for each row)

SELECT Employee_Name, Region, Amount,
	   SUM(AMOUNT) OVER(PARTITION BY Region) AS Total_Sales_Region
FROM Sales;


-- Q3
-- Show employee_name, region, amount,
-- and rank of employee within region (highest sale first)

SELECT *
FROM (
	SELECT Employee_Name, Region, Amount,
		   RANK() OVER(PARTITION BY Region
		   ORDER BY Amount DESC) AS Rank_
	FROM Sales
)T
WHERE Rank_ = 1;


-- Q4
-- Show employee_name, region,
-- total sales per employee,
-- and rank employees within region based on total sales

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Region
		   ORDER BY Total_Amount DESC) AS Rank_
	FROM (
		SELECT Employee_Name, Region, 
			   SUM(Amount) AS Total_Amount
		FROM Sales
		GROUP BY Employee_Name, Region
	)R
)T
WHERE Rank_ = 1