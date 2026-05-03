USE Daily_SQL;

CREATE TABLE Sales_Records (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Product VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Sales_Records 
VALUES	(1, 'Arun',  'Laptop',   '2024-01-01', 50000),
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
        
CREATE TABLE Customer_Info (
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customer_Info 
VALUES	('Arun', 'Chennai'),
		('Meena', 'Mumbai'),
		('Ravi', 'Chennai'),
		('Priya', 'Delhi'),
		('Karan', 'Mumbai'),
		('Sneha', 'Chennai'),
		('Vikram','Delhi'),
		('Anu', 'Bangalore'),
		('Raj', 'Mumbai'),
		('Divya', 'Chennai');

SELECT *
FROM Sales_Records;

SELECT *
FROM Customer_Info;


-- Q1
-- Show all orders with customer city

SELECT S.Customer_Name,
	   S.Order_ID, 
	   S.Product, 
       S.Order_Date, 
       S.Amount,
       C.City
FROM Sales_Records S
INNER JOIN Customer_Info C
	ON S.Customer_Name = C.Customer_Name;


-- Q2
-- Show total amount spent per city

SELECT C.City,
	   SUM(S.Amount) AS Total_Amount
FROM Customer_Info C
LEFT JOIN Sales_Records S
	ON S.Customer_Name = C.Customer_Name
GROUP BY C.City;


-- Q3
-- Show number of orders per city

SELECT C.City,
	   COUNT(S.Order_ID) AS Total_No_Of_Orders
FROM Sales_Records S
INNER JOIN Customer_Info C
	ON S.Customer_Name = C.Customer_Name
GROUP BY C.City;


-- Q4
-- Show customers who made purchases (only those in Sales_Records)

SELECT DISTINCT C.Customer_Name
FROM Customer_Info C
INNER JOIN Sales_Records S
	ON C.Customer_Name = S.Customer_Name;


-- Q5
-- Show all customers including those who never purchased

SELECT DISTINCT C.Customer_Name
FROM Customer_Info C
LEFT JOIN Sales_Records S
	ON C.Customer_Name = S.Customer_Name;


-- Q6 (twist 🔥)
-- Show customers who never made a purchase

SELECT DISTINCT C.Customer_Name
FROM Customer_Info C
LEFT JOIN Sales_Records S
	ON C.Customer_Name = S.Customer_Name
WHERE S.Order_ID IS NULL;


-- Q7 (important 🚨)
-- Show total amount spent per customer with city

SELECT C.Customer_Name,
	   C.City,
	   COALESCE(SUM(S.Amount), 0) AS Total_Amount
FROM Customer_Info C
LEFT JOIN Sales_Records S
	ON S.Customer_Name = C.Customer_Name
GROUP BY C.Customer_Name, C.City;


-- Q8 (combo 🔥)
-- Show city-wise highest spender

WITH CTE AS (
	SELECT C.Customer_Name, C.City,
		   SUM(S.Amount) AS Total_Spent
	FROM Customer_Info C
	INNER JOIN Sales_Records S
		ON C.Customer_Name = S.Customer_Name
	GROUP BY C.Customer_Name, C.City
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY City
		   ORDER BY Total_Spent DESC) AS D_Rank
	FROM CTE
	)T
WHERE D_Rank = 1;


-- Q9 (thinking 🚀)
-- Show customers who bought more than 1 product

SELECT C.Customer_Name,
	   COUNT(DISTINCT S.Product) Total_No_Of_Products
FROM Customer_Info C
INNER JOIN Sales_Records S
	ON S.Customer_Name = C.Customer_Name
GROUP BY C.Customer_Name
HAVING COUNT(DISTINCT S.Product) > 1;


-- Q10 (boss level 😏)
-- Show customers whose last purchase amount is 
-- greater than their first purchase (with city)

WITH First_Purchase AS (
	SELECT *
    FROM (
		SELECT C. Customer_Name, S.Product, 
			   S.Order_Date, S.Amount, C.City,
			   ROW_NUMBER() OVER(PARTITION BY Customer_Name
			   ORDER BY Order_Date ASC) AS Row_Num
		FROM Customer_Info C
        INNER JOIN Sales_Records S
			ON S.Customer_Name = C.Customer_Name
	)T
WHERE Row_Num = 1
),
Last_Purchase AS (
	SELECT *
    FROM (
		SELECT C. Customer_Name, S.Product, 
			   S.Order_Date, S.Amount, C.City,
			   ROW_NUMBER() OVER(PARTITION BY Customer_Name
			   ORDER BY Order_Date DESC) AS Row_Num
		FROM Customer_Info C
        INNER JOIN Sales_Records S
			ON S.Customer_Name = C.Customer_Name
	)R
WHERE Row_Num = 1
)
SELECT F.Customer_Name, F.Order_Date, F.Product, F.City,
	   F.Amount AS First_Amount,
       L.Amount AS Last_Amount
FROM First_Purchase F
INNER JOIN Last_Purchase L
	ON F.Customer_Name = L.Customer_Name
WHERE L.Amount > F.Amount;