USE Daily_SQL;


CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customers
VALUES  (1, 'Arun',    'Chennai'),
        (2, 'Meena',   'Bangalore'),
        (3, 'Ravi',    'Hyderabad'),
        (4, 'Priya',   'Pune'),
        (5, 'Divya',   'Chennai');
        
        
CREATE TABLE Orders_Data (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Order_Amount INT,
    Order_Date DATE
);

INSERT INTO Orders_Data
VALUES  (101, 1, 12000, '2024-01-01'),
        (102, 2, 18000, '2024-01-05'),
        (103, 1, 15000, '2024-01-10'),
        (104, 3, 22000, '2024-01-11'),
        (105, 2, 25000, '2024-01-20'),
        (106, 1, 17000, '2024-01-22'),
        (107, 4, 30000, '2024-02-01'),
        (108, 5, 28000, '2024-02-05'),
        (109, 3, 26000, '2024-02-10'),
        (110, 2, 21000, '2024-02-14');
        
SELECT *
FROM Customers;

SELECT *
FROM Orders_Data;
        

-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each customer along with:
-- 1. Total Order_Amount
-- 2. Total number of orders
-- ordered by Total Order_Amount descending.

WITH CTE AS (
	SELECT C.Customer_Name,
		   SUM(O.Order_Amount) AS Total_Order_Amount,
		   COUNT(O.Order_ID) AS Total_Order
	FROM Customers C
	INNER JOIN Orders_Data O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_Name
)
SELECT *
FROM CTE
ORDER BY Total_Order_Amount DESC;


-- Q2
-- Find customers whose total spending
-- is greater than the average spending of all customers.

WITH CTE AS (
	SELECT C.Customer_Name,
		   SUM(O.Order_Amount) AS Total_Order_Amount
	FROM Customers C
	INNER JOIN Orders_Data O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Order_Amount > (
	SELECT AVG(Total_Order_Amount)
    FROM CTE
);


-- Q3
-- Show the highest spending customer
-- based on total spending.

WITH CTE AS (
	SELECT C.Customer_Name,
		   SUM(O.Order_Amount) AS Total_Order_Amount
	FROM Customers C
	INNER JOIN Orders_Data O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Order_Amount = (
	SELECT MAX(Total_Order_Amount)
    FROM CTE
);

-- OR

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Order_Amount DESC) AS D_Rank
	FROM (
		SELECT C.Customer_Name,
			   SUM(O.Order_Amount) AS Total_Order_Amount
		FROM Customers C
		INNER JOIN Orders_Data O
			ON C.Customer_ID = O.Customer_ID
		GROUP BY C.Customer_Name
	)D
)M
WHERE D_Rank = 1;

-- OR

SELECT C.Customer_Name,
	   SUM(O.Order_Amount) AS Total_Order_Amount
FROM Customers C
INNER JOIN Orders_Data O
	ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_Name
HAVING SUM(O.Order_Amount) = (
	SELECT MAX(Total_Order_Amount)
    FROM (
		SELECT C.Customer_Name,
			   SUM(O.Order_Amount) AS Total_Order_Amount
		FROM Customers C
		INNER JOIN Orders_Data O
			ON C.Customer_ID = O.Customer_ID
		GROUP BY C.Customer_Name
	)M
);


-- Q4
-- Show customers who placed more than 1 order
-- within the same month.

SELECT C.Customer_Name,
       YEAR(O.Order_Date) AS Year_,
       MONTH(O.Order_Date) AS Month_,
       COUNT(O.Order_ID) AS Total_Order
FROM Customers C
INNER JOIN Orders_Data O
    ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_Name, YEAR(O.Order_Date), MONTH(O.Order_Date)
HAVING COUNT(O.Order_ID) > 1;


-- Q5
-- Show each order along with:
-- 1. Previous order amount of that customer
-- 2. Difference between current and previous order amount

WITH CTE AS (
	SELECT C.Customer_Name, O.Order_Amount,
		   LAG(O.Order_Amount) OVER(PARTITION BY C.Customer_ID
           ORDER BY O.Order_Date) AS Previous_Amount
	FROM Customers C
	INNER JOIN Orders_Data O
		ON C.Customer_ID = O.Customer_ID
)
SELECT *,
	   Order_Amount - Previous_Amount AS Difference
FROM CTE
WHERE Previous_Amount IS NOT NULL;
	

-- Q6 (Date Logic)
-- Find customers who placed another order
-- within 15 days of their previous order.

WITH CTE AS (
	SELECT C.Customer_Name, O.Order_Date,
		   LAG(O.Order_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY O.Order_Date) AS Previous
	FROM Customers C
	INNER JOIN Orders_Data O
		ON C.Customer_ID = O.Customer_ID
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Order_Date, Previous) <= 15;


-- Bonus Challenge
-- Show:
-- 1. Customer_Name
-- 2. First Order Date
-- 3. Latest Order Date
-- 4. Total Days Between First and Latest Order

SELECT C.Customer_Name,
       MIN(O.Order_Date) AS First_Order_Date,
       MAX(O.Order_Date) AS Latest_Order_Date,
       DATEDIFF(MAX(O.Order_Date), MIN(O.Order_Date)) AS Total_Days
FROM Customers C
JOIN Orders_Data O
    ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_Name;