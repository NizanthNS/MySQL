CREATE DATABASE Customers;

USE Customers;


CREATE TABLE Customers (
    Customer_ID INT,
    Name VARCHAR(50)
);

CREATE TABLE Orders (
    Order_ID INT,
    Customer_ID INT,
    Order_Date DATE
);

CREATE TABLE Order_Items (
    Item_ID INT,
    Order_ID INT,
    Product VARCHAR(50),
    Amount INT
);


INSERT INTO Customers 
VALUES	(1, 'Arun'),
		(2, 'Meena'),
		(3, 'Ravi'),
		(4, 'Priya');

INSERT INTO Orders 
VALUES	(101, 1, '2024-01-10'),
		(102, 1, '2024-02-15'),
		(103, 2, '2024-01-20'),
		(104, 3, '2024-03-05');

INSERT INTO Order_Items 
VALUES	(1, 101, 'Laptop', 50000),
		(2, 101, 'Mouse', 1000),
		(3, 102, 'Keyboard', 3000),
		(4, 103, 'Phone', 55000),
		(5, 104, 'Tablet', 20000);
        

SELECT *
FROM Customers;


SELECT *
FROM Orders;


SELECT *
FROM Order_Items;
        

-- Q1
-- Show customer name and total amount spent

SELECT Customers.Name,
	   COALESCE(SUM(Order_Items.Amount), 0) AS Total_Amount
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
LEFT JOIN Order_Items
	ON Orders.Order_ID = Order_Items.Order_ID
GROUP BY Customers.Name;


-- Q2
-- Show customer name, order_id, total order amount

SELECT Customers.Name,
	   Orders.Order_ID,
	   COALESCE(SUM(Order_Items.Amount), 0) AS Total_Amount
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
LEFT JOIN Order_Items
	ON Orders.Order_ID = Order_Items.Order_ID
GROUP BY Customers.Name, Orders.Order_ID;


-- Q3
-- Show customer name, order_id, total order amount,
-- and rank orders per customer (highest first)


SELECT *,
	   RANK() OVER(PARTITION BY Customer_Name
	   ORDER BY Total_Amount DESC) AS Rank_
FROM (
	SELECT Customers.Name AS Customer_Name,
		   Orders.Order_ID,
		   COALESCE(SUM(Order_Items.Amount), 0) AS Total_Amount
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Order_Items
		ON Orders.Order_ID = Order_Items.Order_ID
	GROUP BY Customers.Name, Orders.Order_ID
)T;


-- Q4
-- Show customer name,
-- total amount spent,
-- and rank customers based on total spending

SELECT *,
	   RANK() OVER(ORDER BY Total_Amount DESC) AS Rank_
FROM (
	SELECT Customers.Name AS Customer_Name,
		   COALESCE(SUM(Order_Items.Amount), 0) AS Total_Amount
	FROM Customers
	LEFT JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	LEFT JOIN Order_Items
		ON Orders.Order_ID = Order_Items.Order_ID
	GROUP BY Customers.Name
)T;


-- Q5 (Important)
-- Show customer name, order_id, total order amount,
-- and difference from average order amount of that customer

WITH CTE AS (
	SELECT Customers.Name AS Customer_Name,
		   Orders.Order_ID,
		   SUM(Order_Items.Amount) AS Total_Amount
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Order_Items
		ON Orders.Order_ID = Order_Items.Order_ID
	GROUP BY Customers.Name, Orders.Order_ID
)
SELECT *
FROM (
	SELECT *,
		   AVG(Total_Amount) OVER(PARTITION BY Customer_Name) AS Average,
           Total_Amount - AVG(Total_Amount) OVER(PARTITION BY Customer_Name) AS Difference
	FROM CTE
    )T;


-- Q6 (Tricky)
-- Show customers who never placed any orders

SELECT Customers.Name
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
WHERE Orders.Order_ID IS NULL;