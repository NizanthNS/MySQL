USE Daily_SQL;


CREATE TABLE Fun_Orders (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Product VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Fun_Orders
VALUES
    (1, 'Arun',  'Laptop',   '2024-01-01', 50000),
    (2, 'Arun',  'Mouse',    '2024-01-02', 2000),
    (3, 'Arun',  'Keyboard', '2024-02-15', 3000),
    (4, 'Meena', 'Laptop',   '2024-01-01', 55000),
    (5, 'Meena', 'Mouse',    '2024-01-20', 2500),
    (6, 'Ravi',  'Keyboard', '2024-01-10', 4000),
    (7, 'Ravi',  'Mouse',    '2024-01-25', 1500);
    
SELECT *
FROM Fun_Orders;


-- Q1
-- Find each customer’s FIRST purchase

SELECT *
FROM (
	SELECT Customer_Name, Product, Order_Date, Amount,
		   ROW_NUMBER() OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Row_Num
	FROM Fun_Orders
    )R
WHERE Row_Num = 1;

-- OR

SELECT Customer_Name,
       MIN(Order_Date) AS First_Purchase
FROM Fun_Orders
GROUP BY Customer_Name;


-- Q2
-- Find each customer’s LAST purchase

SELECT *
FROM (
	SELECT Customer_Name, Product, Order_Date, Amount,
		   ROW_NUMBER() OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date DESC) AS Row_Num
	FROM Fun_Orders
    )R
WHERE Row_Num = 1;

-- OR

SELECT Customer_Name,
       MAX(Order_Date) AS Last_Purchase
FROM Fun_Orders
GROUP BY Customer_Name;


-- Q3 (fun twist 🔥)
-- Customers whose LAST purchase amount is greater than their FIRST purchase

WITH First_Purchase AS (
	SELECT *
    FROM (
		SELECT Customer_Name, Product, Order_Date, Amount,
			   ROW_NUMBER() OVER(PARTITION BY Customer_Name
			   ORDER BY Order_Date) AS Row_Num
		FROM Fun_Orders
	)T
WHERE Row_Num = 1
),
Last_Purchase AS (
	SELECT *
    FROM (
		SELECT Customer_Name, Product, Order_Date, Amount,
			   ROW_NUMBER() OVER(PARTITION BY Customer_Name
			   ORDER BY Order_Date DESC) AS Row_Num
		FROM Fun_Orders
	)R
WHERE Row_Num = 1
)
SELECT F.Customer_Name, F.Amount, F.Order_Date
FROM First_Purchase F
INNER JOIN Last_Purchase L
	ON F.Customer_Name = L.Customer_Name
WHERE L.Amount > F.Amount;
    
    
-- Q4 (tiny brain teaser 🧠)
-- Product with lowest total sales

SELECT Product,
	   SUM(Amount) AS Total_Sales
FROM Fun_Orders
GROUP BY Product
ORDER BY SUM(Amount)
LIMIT 1;

-- OR 

WITH CTE AS (
	SELECT Product,
		   SUM(Amount) AS Total_Sales
	FROM Fun_Orders
	GROUP BY Product
)
SELECT *
FROM CTE
WHERE Total_Sales = (
	SELECT MIN(Total_Sales)
    FROM CTE
);

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Sales ASC) AS Rnk
	FROM (
			SELECT Product,
				   SUM(Amount) AS Total_Sales
			FROM Fun_Orders
			GROUP BY Product
		)T
)R
WHERE Rnk = 1;