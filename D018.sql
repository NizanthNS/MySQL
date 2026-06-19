CREATE DATABASE
Demo4;


USE Demo4;


CREATE TABLE Customers (
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);


INSERT INTO Customers 
VALUES	(101, 'Nizanth', 'Chennai'),
		(102, 'Arun', 'Mumbai'),
		(103, 'Sneha', 'Delhi');
        

CREATE TABLE Products (
    Product_ID INT,
    Product_Name VARCHAR(50),
    Price INT
);


INSERT INTO Products 
VALUES	(1, 'Laptop', 50000),
		(2, 'Phone', 20000),
		(3, 'Tablet', 30000);
        

CREATE TABLE Orders (
    Order_ID INT,
    Customer_ID INT,
    Product_ID INT,
    Order_Date DATE,
    Quantity INT
);


INSERT INTO Orders 
VALUES	(1, 101, 1, '2024-01-10', 1),
		(2, 102, 2, '2024-01-15', 2),
		(3, 101, 3, '2024-02-05', 1),
		(4, 103, 1, '2024-02-20', 1),
		(5, 101, 2, '2024-03-01', 3),
		(6, 102, 3, '2024-03-10', 1);
        

UPDATE Customers
SET City = 'Marthandam'
WHERE Customer_ID = 101;


SET SQL_SAFE_UPDATES = 0;


SELECT *
FROM Customers;


SELECT *
FROM Orders;


SELECT *
FROM Products;


-- 1. Show all orders with customer name and product name

SELECT *
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Products.Product_ID = Orders.Product_ID;


-- 2. Show total amount spent by each customer

SELECT Customers.Customer_ID,
	   Customers.Customer_Name,
       SUM(Orders.Quantity * Products.Price) AS Total_Amount
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Products.Product_ID = Orders.Product_ID
GROUP BY Customers.Customer_ID,
		 Customers.Customer_Name
ORDER BY Total_Amount DESC;


-- 3. Show total sales per month

SELECT YEAR(Order_Date) AS Year_,
	   MONTH(Order_Date) AS Month_,
       SUM(Orders.Quantity * Products.Price) AS Total_Sales
FROM Orders
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY MONTH(Order_Date) ASC;


-- 4. Show each order with total sales per customer using window function

SELECT Customers.Customer_ID,
	   Customers.Customer_Name,
       Orders.Order_ID,
       Orders.Quantity * Products.Price AS Order_Amount,
       SUM(Orders.Quantity * Products.Price) OVER(
       PARTITION BY Customers.Customer_ID) AS Total_Sales
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Products.Product_ID = Orders.Product_ID;


-- 5. Show top 2 highest spending customers

WITH CTE AS (
    SELECT Customers.Customer_ID,
           Customers.Customer_Name,
           SUM(Orders.Quantity * Products.Price) AS Order_Amount,
           RANK() OVER(
		   ORDER BY SUM(Orders.Quantity * Products.Price) DESC
           ) AS Rank_
    FROM Customers
    INNER JOIN Orders
        ON Customers.Customer_ID = Orders.Customer_ID
    INNER JOIN Products
        ON Products.Product_ID = Orders.Product_ID
    GROUP BY Customers.Customer_ID,
             Customers.Customer_Name
)
SELECT *
FROM CTE
WHERE Rank_ <= 2;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Order_Amount DESC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Customer_Name,
			   SUM(Orders.Quantity * Products.Price) AS Order_Amount
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Products
			ON Products.Product_ID = Orders.Product_ID
		GROUP BY Customers.Customer_ID,
				 Customers.Customer_Name
		) T
	) R
WHERE Rank_ <= 2;


-- 6. Show each customer's first order (based on Order_Date)

WITH CTE AS (
	SELECT Customers.Customer_ID,
		   Customers.Customer_Name,
		   Orders.Order_ID,
		   Orders.Order_Date,
		   ROW_NUMBER() OVER(PARTITION BY Customers.Customer_ID
           ORDER BY Orders.Order_Date ASC) AS Row_Num
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	
)
SELECT *
FROM CTE
WHERE Row_Num = 1;


-- 7. Show customers whose latest order amount is higher than their first order amount

WITH CTE AS (
    SELECT Customers.Customer_ID,
           Customers.Customer_Name,
           Orders.Order_ID,
           Orders.Order_Date,
           (Orders.Quantity * Products.Price) AS Amount,
           ROW_NUMBER() OVER(PARTITION BY Customers.Customer_ID
		   ORDER BY Orders.Order_Date ASC) AS First_Order,
           ROW_NUMBER() OVER(PARTITION BY Customers.Customer_ID
		   ORDER BY Orders.Order_Date DESC) AS Last_Order
	FROM Customers
    INNER JOIN Orders
        ON Customers.Customer_ID = Orders.Customer_ID
    INNER JOIN Products
        ON Products.Product_ID = Orders.Product_ID
)
SELECT Customer_ID,
       Customer_Name,
       MAX(CASE WHEN First_Order = 1 THEN Amount END) AS First_Amount,
       MAX(CASE WHEN Last_Order = 1 THEN Amount END) AS Last_Amount
FROM CTE
GROUP BY Customer_ID, Customer_Name
HAVING MAX(CASE WHEN Last_Order = 1 THEN Amount END) >
       MAX(CASE WHEN First_Order = 1 THEN Amount END);

	   

	


       















