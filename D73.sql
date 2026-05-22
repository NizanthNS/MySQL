USE Daily_SQL;

CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(50),
    Category VARCHAR(50),
    Price INT
);

INSERT INTO Products
VALUES  (1, 'Laptop',      'Electronics', 70000),
        (2, 'Mouse',       'Electronics', 1500),
        (3, 'Keyboard',    'Electronics', 2500),
        (4, 'Chair',       'Furniture',   5000),
        (5, 'Table',       'Furniture',   12000),
        (6, 'Sofa',        'Furniture',   30000),
        (7, 'T-Shirt',     'Clothing',    1200),
        (8, 'Jeans',       'Clothing',    2500);
        

CREATE TABLE Sales_Data (
    Sale_ID INT PRIMARY KEY,
    Product_ID INT,
    Quantity INT,
    Sale_Date DATE
);

INSERT INTO Sales_Data
VALUES  (101, 1, 1, '2024-01-01'),
        (102, 2, 3, '2024-01-02'),
        (103, 1, 1, '2024-01-10'),
        (104, 3, 2, '2024-01-15'),
        (105, 4, 1, '2024-01-18'),
        (106, 5, 2, '2024-01-20'),
        (107, 6, 1, '2024-02-01'),
        (108, 2, 4, '2024-02-05'),
        (109, 7, 5, '2024-02-10'),
        (110, 8, 2, '2024-02-12'),
        (111, 1, 1, '2024-02-15'),
        (112, 5, 1, '2024-02-18');
        

SELECT *
FROM Products;

SELECT *
FROM Sales_Data;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each Category along with:
-- 1. Total Quantity sold
-- 2. Total Revenue
-- ordered by Total Revenue descending.

SELECT P.Category,
       SUM(S.Quantity) AS Total_Quantity_Sold,
       SUM(P.Price * S.Quantity) AS Total_Revenue
FROM Products P
INNER JOIN Sales_Data S
    ON P.Product_ID = S.Product_ID
GROUP BY P.Category
ORDER BY Total_Revenue DESC;


-- Q2
-- Find products whose total revenue
-- is greater than the average revenue
-- of all products.

WITH CTE AS (
    SELECT P.Product_Name,
           SUM(P.Price * S.Quantity) AS Total_Revenue
    FROM Products P
    INNER JOIN Sales_Data S
        ON P.Product_ID = S.Product_ID
    GROUP BY P.Product_Name
)
SELECT *
FROM CTE
WHERE Total_Revenue > (
    SELECT AVG(Total_Revenue)
    FROM CTE
);


-- Q3
-- Show the highest revenue-generating product
-- in each Category.

SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER(PARTITION BY Category
		   ORDER BY Total_Revenue DESC) AS D_Rank
    FROM (
        SELECT P.Product_Name,
               P.Category,
               SUM(P.Price * S.Quantity) AS Total_Revenue
        FROM Products P
        INNER JOIN Sales_Data S
            ON P.Product_ID = S.Product_ID
        GROUP BY P.Product_Name, P.Category
    ) D
) M
WHERE D_Rank = 1;


-- Q4
-- Show products that were sold
-- more than once within the same month.

SELECT P.Product_Name,
	   COUNT(P.Product_ID) AS Total_Products,
       YEAR(S.Sale_Date) AS Year_,
       MONTH(S.Sale_Date) AS Month_
FROM Products P
INNER JOIN Sales_Data S
	ON P.Product_ID = S.Product_ID
GROUP BY P.Product_Name, YEAR(S.Sale_Date), 
		 MONTH(S.Sale_Date)
HAVING COUNT(S.Product_ID) > 1;


-- Q5
-- Show each sale along with:
-- 1. Previous sale date of that product
-- 2. Difference in days from previous sale

WITH CTE AS (
	SELECT S.Sale_ID, P.Product_Name, S.Sale_Date,
		   LAG(S.Sale_Date) OVER(PARTITION BY P.Product_ID
           ORDER BY S.Sale_Date) AS Previous_Sale_Date
	FROM Products P
	INNER JOIN Sales_Data S
		ON P.Product_ID = S.Product_ID
)
SELECT DISTINCT Product_Name, Sale_ID,
	   Sale_Date, Previous_Sale_Date,
	   DATEDIFF(Sale_Date, Previous_Sale_Date) AS Days_Diff
FROM CTE
WHERE Previous_Sale_Date IS NOT NULL;


-- Q6 (Date Logic)
-- Find products that were sold again
-- within 10 days of their previous sale.

WITH CTE AS (
	SELECT P.Product_Name, S.Sale_Date,
		   LAG(S.Sale_Date) OVER(PARTITION BY P.Product_ID
           ORDER BY S.Sale_Date) AS Previous
	FROM Products P
	INNER JOIN Sales_Data S
		ON P.Product_ID = S.Product_ID
)
SELECT DISTINCT Product_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Sale_Date, Previous) <= 10;


-- Bonus Challenge
-- Show:
-- 1. Product_Name
-- 2. First Sale Date
-- 3. Latest Sale Date
-- 4. Total Sales Records
-- 5. Total Revenue
-- 6. Total Days Between First and Latest Sale

SELECT P.Product_ID, P.Product_Name,
	   MIN(S.Sale_Date) AS First_Sale_Date,
       MAX(S.Sale_Date) AS Last_Sale_Date,
       COUNT(P.Product_ID) AS Total_Sales_Records,
       SUM(P.Price * S.Quantity) AS Total_Revenue,
       DATEDIFF(MAX(S.Sale_Date), MIN(S.Sale_Date)) AS Days
FROM Products P
INNER JOIN Sales_Data S
	ON P.Product_ID = S.Product_ID
GROUP BY P.Product_ID, P.Product_Name;