CREATE DATABASE Customers;

USE Customers;

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO Customers 
VALUES	(1, 'Arun'),
		(2, 'Meena'),
		(3, 'Ravi'),
		(4, 'Priya');


CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Order_Date DATE
);

INSERT INTO Orders 
VALUES	(101, 1, '2024-01-01'),
		(102, 1, '2024-01-05'),
		(103, 2, '2024-01-03'),
		(104, 3, '2024-01-04');


CREATE TABLE Order_Details (
    Detail_ID INT PRIMARY KEY,
    Order_ID INT,
    Product VARCHAR(50),
    Amount INT
);

INSERT INTO Order_Details 
VALUES	(1, 101, 'Laptop', 50000),
		(2, 101, 'Mouse', 1000),
		(3, 102, 'Keyboard', 2000),
		(4, 103, 'Laptop', 55000),
		(5, 104, 'Mouse', 1200),
		(6, 104, 'Keyboard', 2500);


SELECT *
FROM Customers;

SELECT *
FROM Orders;

SELECT *
FROM Order_Details;


-- Find total amount spent by each customer

SELECT Customers.Customer_ID,
	   Customers.Name,
       COALESCE(SUM(Order_Details.Amount),0) AS Total_Amount
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
LEFT JOIN Order_Details
	ON Orders.Order_ID = Order_Details.Order_ID
GROUP BY Customers.Customer_ID, Customers.Name;


-- Find the customer who spent the most

SELECT Customers.Customer_ID,
	   Customers.Name,
       SUM(Order_Details.Amount) AS Total_Amount
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Order_Details
	ON Orders.Order_ID = Order_Details.Order_ID
GROUP BY Customers.Customer_ID, Customers.Name
ORDER BY Total_Amount DESC
LIMIT 1;

-- OR

WITH CTE AS (
	SELECT Customers.Customer_ID,
		   Customers.Name,
           SUM(Order_Details.Amount) AS Total_Amount
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Order_Details
		ON Orders.Order_ID = Order_Details.Order_ID
	GROUP BY Customers.Customer_ID, Customers.Name
)
SELECT *
FROM CTE
WHERE Total_Amount = (
	SELECT MAX(Total_Amount)
    FROM CTE
    );

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Amount DESC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Name,
			   SUM(Order_Details.Amount) AS Total_Amount
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Order_Details
			ON Orders.Order_ID = Order_Details.Order_ID
		GROUP BY Customers.Customer_ID, Customers.Name
	)T
)R
WHERE Rank_ = 1;


-- -- Find the customer who spent the least

SELECT Customers.Customer_ID,
	   Customers.Name,
       COALESCE(SUM(Order_Details.Amount), 0) AS Total_Amount
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
LEFT JOIN Order_Details
	ON Orders.Order_ID = Order_Details.Order_ID
GROUP BY Customers.Customer_ID, Customers.Name
ORDER BY Total_Amount ASC
LIMIT 1;

-- OR

WITH CTE AS (
	SELECT Customers.Customer_ID,
		   Customers.Name,
           COALESCE(SUM(Order_Details.Amount), 0) AS Total_Amount
	FROM Customers
	LEFT JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	LEFT JOIN Order_Details
		ON Orders.Order_ID = Order_Details.Order_ID
	GROUP BY Customers.Customer_ID, Customers.Name
)
SELECT *
FROM CTE
WHERE Total_Amount = (
	SELECT MIN(Total_Amount)
    FROM CTE
    );

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Amount ASC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Name,
			   COALESCE(SUM(Order_Details.Amount), 0) AS Total_Amount
		FROM Customers
		LEFT JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		LEFT JOIN Order_Details
			ON Orders.Order_ID = Order_Details.Order_ID
		GROUP BY Customers.Customer_ID, Customers.Name
	)T
)R
WHERE Rank_ = 1;


-- Find the second highest spending customer

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Amount DESC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Name,
			   SUM(Order_Details.Amount) AS Total_Amount
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Order_Details
			ON Orders.Order_ID = Order_Details.Order_ID
		GROUP BY Customers.Customer_ID, Customers.Name
	)T
)R
WHERE Rank_ = 2;

-- OR

WITH CTE AS (
	SELECT Customers.Customer_ID,
		   Customers.Name,
           SUM(Order_Details.Amount) AS Total_Amount
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Order_Details
		ON Orders.Order_ID = Order_Details.Order_ID
	GROUP BY Customers.Customer_ID, Customers.Name
)
SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Amount DESC) AS Rank_
	FROM CTE
)T
WHERE Rank_ = 2;


-- Difference from average customer spend

WITH CTE AS (
	SELECT Customers.Customer_ID,
		   Customers.Name,
           SUM(Order_Details.Amount) AS Total_Amount
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Order_Details
		ON Orders.Order_ID = Order_Details.Order_ID
	GROUP BY Customers.Customer_ID, Customers.Name
)
SELECT *,
	   AVG(Total_Amount) OVER() AS Average,
	   Total_Amount - AVG(Total_Amount) OVER() AS Difference
FROM CTE;


-- For each customer, find their highest value order

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Customer_ID 
           ORDER BY Total_Amount DESC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Name,
               Orders.Order_ID,
			   SUM(Order_Details.Amount) AS Total_Amount
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Order_Details
			ON Orders.Order_ID = Order_Details.Order_ID
		GROUP BY Customers.Customer_ID, Customers.Name, Orders.Order_ID
	)T
)R
WHERE Rank_ = 1;

-- OR

WITH CTE AS (
		SELECT Customers.Customer_ID,
			   Customers.Name,
               Orders.Order_ID,
			   SUM(Order_Details.Amount) AS Total_Amount
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Order_Details
			ON Orders.Order_ID = Order_Details.Order_ID
		GROUP BY Customers.Customer_ID, Customers.Name, Orders.Order_ID
)
SELECT *
FROM (
    SELECT *,
		   RANK() OVER(PARTITION BY Customer_ID 
           ORDER BY Total_Amount DESC) AS Rank_
    FROM CTE
) T
WHERE Rank_ = 1;
    

		