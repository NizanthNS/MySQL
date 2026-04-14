CREATE DATABASE Sales;

USE Sales;


CREATE TABLE Sales (
    Sale_ID INT,
    Customer_Name VARCHAR(50),
    Category VARCHAR(50),
    Sale_Date DATE,
    Amount INT
);

INSERT INTO Sales 
VALUES	(1, 'Arun', 'Electronics', '2024-01-01', 5000),
		(2, 'Arun', 'Electronics', '2024-01-05', 3000),
		(3, 'Arun', 'Furniture', '2024-01-10', 7000),
		(4, 'Meena', 'Electronics', '2024-01-03', 6000),
		(5, 'Meena', 'Furniture', '2024-01-08', 8000),
		(6, 'Ravi', 'Electronics', '2024-01-02', 2000),
		(7, 'Ravi', 'Furniture', '2024-01-09', 4000),
		(8, 'Priya', 'Electronics', '2024-01-04', 9000);
        

SELECT *
FROM Sales;


-- Q1
-- Show customer_name, category, amount,
-- and running total of sales per customer (by date)

SELECT Customer_Name, Category, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Sale_Date) AS Running_Total
FROM Sales;


-- Q2
-- Show customer_name, category,
-- total sales per customer per category

SELECT Customer_Name, Category,
	   SUM(Amount) AS Total_Amount
FROM Sales
GROUP BY customer_name, Category;


-- Q3
-- Show top 2 highest sales per category

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Category
           ORDER BY Amount DESC) AS Rank_
	FROM Sales
	)R
WHERE Rank_ <=2;

-- Q4
-- Show highest sale per customer (no ties, only 1 row per customer)

SELECT *
FROM (
	SELECT *,
		   Row_Number() OVER(PARTITION BY Customer_Name
           ORDER BY Amount DESC) AS Row_Num
	FROM Sales
)R
WHERE Row_Num = 1;


-- Q5 (Important)
-- Show customer_name, category, amount,
-- and flag if the sale is ABOVE average for that category ('YES'/'NO')

SELECT Customer_Name,
	   Category,
       Amount,
       CASE
			WHEN Amount > AVG(Amount) OVER(PARTITION BY Category)
            THEN 'YES'
            ELSE 'NO'
	   END AS Above_average
FROM Sales;


-- Q6 (Tricky)
-- Show customers whose total sales are in the TOP 2 overall

SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(ORDER BY Total_Amount DESC) AS Row_Num
	FROM (
		SELECT Customer_Name,
			   SUM(Amount) AS Total_Amount
		FROM Sales
        GROUP BY Customer_Name
        )R
	)T
WHERE Row_Num <= 2;