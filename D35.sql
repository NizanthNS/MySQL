CREATE TABLE Sales_Data (
    Sale_ID INT,
    Employee_Name VARCHAR(50),
    Region VARCHAR(50),
    Sale_Date DATE,
    Amount INT
);

INSERT INTO Sales_Data 
VALUES	(1, 'Arun', 'North', '2024-01-01', 5000),
		(2, 'Arun', 'North', '2024-01-03', 3000),
		(3, 'Arun', 'South', '2024-01-05', 7000),
		(4, 'Meena', 'North', '2024-01-02', 6000),
		(5, 'Meena', 'South', '2024-01-06', 8000),
		(6, 'Ravi', 'North', '2024-01-04', 2000),
		(7, 'Ravi', 'South', '2024-01-07', 4000),
		(8, 'Priya', 'North', '2024-01-08', 9000);
        
SELECT *
FROM Sales_Data;


-- Q1
-- Show employee_name, sale_date, amount,
-- and running total per employee

SELECT Employee_Name, Sale_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Employee_Name
       ORDER BY Sale_Date) AS Running_Total
FROM Sales_Data;


-- Q2
-- Show region and total sales

SELECT Region,
	   SUM(Amount) AS Total_Sales
FROM Sales_Data
GROUP BY Region;


-- Q3 (Trap)
-- Show employee_name, region, amount,
-- and rank sales within each region

SELECT Employee_Name, Region, Amount,
	   RANK() OVER(PARTITION BY Region
       ORDER BY Amount DESC) AS Rank_
FROM Sales_Data;


-- Q4 (Granularity test)
-- Show employee_name, region,
-- total sales per employee per region

SELECT Employee_Name, Region,
	   SUM(Amount) AS Total_Sales
FROM Sales_Data
GROUP BY Employee_Name, Region;


-- Q5 (Both + ranking)
-- Show employee_name, region,
-- total sales per employee per region,
-- and rank employees within each region

SELECT *,
	   RANK() OVER(PARTITION BY Region
       ORDER BY Total_Sales DESC) AS Rank_
FROM (
	SELECT Employee_Name, Region,
		   SUM(Amount) AS Total_Sales
	FROM Sales_Data
	GROUP BY Employee_Name, Region
)T;

-- OR

WITH CTE AS (
	SELECT Employee_Name, Region,
		   SUM(Amount) AS Total_Sales
	FROM Sales_Data
	GROUP BY Employee_Name, Region
)
SELECT *,
	   RANK() OVER(PARTITION BY Region
       ORDER BY Total_Sales DESC) AS Rank_
FROM CTE;


-- Q6 (Debug this wrong query)
-- What is wrong here? Fix it.

SELECT employee_name,
       SUM(amount) AS total_sales,
       RANK() OVER(PARTITION BY region ORDER BY total_sales DESC) AS rank_
FROM sales_data
GROUP BY employee_name;

-- Answer

SELECT *,
	   RANK() OVER(PARTITION BY Region
       ORDER BY Total_Sales DESC) AS Rank_
FROM (
	SELECT Employee_Name,
		   Region,
		   SUM(Amount) AS Total_Sales
	FROM Sales_Data
    GROUP BY Employee_Name, Region
)T;