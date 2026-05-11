USE Daily_SQL;


CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    Category VARCHAR(50),
    Amount INT,
    City VARCHAR(50),
    Order_Date DATE
);

INSERT INTO Orders
VALUES  (1, 'Arun',    'Electronics', 45000, 'Chennai',   '2024-01-10'),
        (2, 'Meena',   'Furniture',   20000, 'Bangalore', '2024-01-12'),
        (3, 'Ravi',    'Electronics', 38000, 'Chennai',   '2024-01-15'),
        (4, 'Priya',   'Clothing',    12000, 'Hyderabad', '2024-01-18'),
        (5, 'Karthik', 'Furniture',   25000, 'Bangalore', '2024-01-20'),
        (6, 'Divya',   'Electronics', 52000, 'Chennai',   '2024-01-25'),
        (7, 'Sanjay',  'Clothing',     8000, 'Pune',      '2024-01-28'),
        (8, 'Nisha',   'Furniture',   30000, 'Chennai',   '2024-02-01'),
        (9, 'Vikram',  'Electronics', 41000, 'Hyderabad', '2024-02-05'),
        (10,'Aarthi',  'Clothing',    15000, 'Bangalore', '2024-02-10');
        
        
SELECT *
FROM Orders;


-- Day 2 : GROUP BY + Aggregation


-- Q1
-- Find the total sales amount for each Category.

SELECT Category,
	   SUM(Amount) AS Total_Amount
FROM Orders
GROUP BY Category;


-- Q2
-- Find the average Amount spent in each City.

SELECT City,
	   ROUND(AVG(Amount), 2) AS Average_Spent
FROM Orders
GROUP BY City;


-- Q3
-- Find the number of orders placed in each Category.

SELECT Category,
	   COUNT(Order_ID) AS Total_No_Of_Items
FROM Orders
GROUP BY Category;


-- Q4
-- Find the highest order Amount in each City.

SELECT City,
	   MAX(Amount) AS Highest_Amount
FROM Orders
GROUP BY City
ORDER BY MAX(Amount) DESC;

-- OR

SELECT *
FROM (
	SELECT Order_ID, City, Amount,
		   DENSE_RANK() OVER(PARTITION BY City
           ORDER BY Amount DESC) AS D_Rank
	FROM Orders
	)D
WHERE D_Rank = 1;

-- OR

WITH CTE AS (
	SELECT Order_ID, City, Amount,
		   DENSE_RANK() OVER(PARTITION BY City
           ORDER BY Amount DESC) AS D_Rank
    FROM Orders
    )
SELECT *
FROM CTE
WHERE D_Rank = 1;


-- Q5
-- Find the minimum and maximum Amount for each Category.

SELECT Category,
	   MIN(Amount) AS Minimum_Amount,
       MAX(Amount) AS Maximum_Amount
FROM Orders
GROUP BY Category;


-- Q6
-- Find the total sales Amount for each City
-- but show only cities where total sales is greater than 70000.

SELECT City,
	   SUM(Amount) AS Total_Amount
FROM Orders
GROUP BY City
HAVING SUM(Amount) > 70000;


-- Bonus Debugging Question

SELECT Category, SUM(Amount)
FROM Orders;

-- What is wrong with this query?
-- Rewrite it correctly.

-- Answer

SELECT Category, 
	   SUM(Amount)
FROM Orders
GROUP BY Category;