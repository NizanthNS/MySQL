CREATE DATABASE Duplicates;


USE Duplicates;


CREATE TABLE Customers (
    Customer_ID INT,
    Name VARCHAR(50),
    City VARCHAR(50),
    Signup_Date DATE
);

INSERT INTO Customers 
VALUES	(1, 'Arun', 'Chennai', '2023-01-10'),
		(2, 'Priya', 'Bangalore', '2023-02-15'),
		(3, 'Karthik', 'Chennai', '2023-03-20'),
		(4, 'Meena', 'Mumbai', '2023-04-25'),
		(5, 'Ravi', 'Delhi', '2023-05-30'),
-- Duplicates
		(1, 'Arun', 'Chennai', '2023-01-10'),
		(2, 'Priya', 'Bangalore', '2023-02-15'),
		(3, 'Karthik', 'Chennai', '2023-03-20'),
-- Slight variation duplicates (real-world messy data)
		(3, 'Karthik', 'CHENNAI', '2023-03-20'),
		(5, 'Ravi', 'Delhi ', '2023-05-30');
        

CREATE TABLE Products (
    Product_ID INT,
    Product_Name VARCHAR(50),
    Category VARCHAR(50),
    Price INT
);

INSERT INTO Products 
VALUES	(1, 'Laptop', 'Electronics', 60000),
		(2, 'Phone', 'Electronics', 30000),
		(3, 'Shoes', 'Fashion', 2000),
		(4, 'Watch', 'Accessories', 5000),
		(5, 'Bag', 'Fashion', 1500),
-- Duplicates
		(1, 'Laptop', 'Electronics', 60000),
		(2, 'Phone', 'Electronics', 30000),
-- Slight variation duplicates
		(3, 'shoes', 'Fashion', 2000),
		(5, 'Bag ', 'Fashion', 1500);
        

CREATE TABLE Orders (
    Order_ID INT,
    Customer_ID INT,
    Order_Date DATE
);

INSERT INTO Orders 
VALUES	(1, 1, '2023-06-01'),
		(2, 2, '2023-06-03'),
		(3, 1, '2023-06-10'),
		(4, 3, '2023-06-15'),
		(5, 4, '2023-06-20'),
-- Duplicates
		(1, 1, '2023-06-01'),
		(3, 1, '2023-06-10'),
-- Variation duplicate
		(5, 4, '2023-06-20');
        
        
CREATE TABLE Order_Items (
    Order_Item_Id INT,
    Order_ID INT,
    Product_ID INT,
    Quantity INT
);

INSERT INTO Order_Items 
VALUES	(1, 1, 1, 1),
		(2, 1, 3, 2),
		(3, 2, 2, 1),
		(4, 3, 5, 3),
		(5, 4, 4, 1),
		(6, 5, 1, 1),
-- Duplicates
		(1, 1, 1, 1),
		(2, 1, 3, 2),
-- Slight variation (same logical record)
		(7, 5, 1, 1);
        
        
SELECT *
FROM Customers;

SELECT *
FROM Products;

SELECT *
FROM Orders;

SELECT *
FROM Order_Items;


SELECT DISTINCT *
FROM Customers;


UPDATE Customers
SET City = TRIM(LOWER(City));


UPDATE Customers
SET Name = TRIM(Name),
    City = TRIM(LOWER(City));


UPDATE Customers
SET City = CONCAT(
    UPPER(SUBSTRING(TRIM(City), 1, 1)),
    LOWER(SUBSTRING(TRIM(City), 2))
);
        
        
CREATE TABLE Customers_Clean AS
SELECT DISTINCT *
FROM Customers;


SELECT *
FROM Customers_Clean;  


CREATE TABLE Customers_ AS
SELECT *
FROM Customers; 


SELECT *
FROM Customers_;


SELECT Customer_ID, Name, City, Signup_Date, COUNT(*)
FROM Customers_
GROUP BY Customer_ID, Name, City, Signup_Date
HAVING COUNT(*) > 1;


SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Customer_ID, Name, City, Signup_Date
		   ORDER BY Customer_ID) AS Row_Num
	FROM Customers
) D
WHERE Row_Num > 1;


ALTER TABLE Customers
ADD ID INT AUTO_INCREMENT PRIMARY KEY;


SELECT ID, Customer_ID, Name, City, Signup_Date,
       ROW_NUMBER() OVER(
           PARTITION BY Customer_ID, Name, City, Signup_Date
           ORDER BY ID
       ) AS rn
FROM Customers_;


DELETE FROM Customers_
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Customer_ID, Name, City, Signup_Date
			   ORDER BY ID) AS rn
        FROM Customers_
    ) T
    WHERE rn > 1
);


SELECT *
FROM Customers_;


DELETE FROM Customers
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Customer_ID, Name, City, Signup_Date
			   ORDER BY ID) AS rn
        FROM Customers
    ) T
    WHERE rn > 1
);


ALTER TABLE Customers
DROP Column ID;


DROP TABLE Customers_Clean;


DROP TABLE Customers_;


SELECT *
FROM Customers;


SELECT *
FROM Products;


UPDATE Products
SET Product_Name = TRIM(Product_Name);
    

UPDATE Products
SET Product_Name = CONCAT(
    UPPER(SUBSTRING(TRIM(Product_Name), 1, 1)),
    LOWER(SUBSTRING(TRIM(Product_Name), 2))
);


ALTER TABLE Products
ADD ID INT AUTO_INCREMENT PRIMARY KEY;


CREATE TABLE Products_ AS
SELECT *
FROM Products;


SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Product_ID, Product_Name, Category, Price
		   ORDER BY Product_ID) AS Row_Num
	FROM Products_
) D
WHERE Row_Num > 1;


DELETE FROM Products_
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Product_ID, Product_Name, Category, Price
			   ORDER BY ID) AS rn
        FROM Products_
    ) T
    WHERE rn > 1
);


SELECT *
FROM Products_;


DELETE FROM Products
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Product_ID, Product_Name, Category, Price
			   ORDER BY ID) AS rn
        FROM Products
    ) T
    WHERE rn > 1
);


SELECT *
FROM Products;


ALTER TABLE Products
DROP ID;


DROP TABLE Products_;


SELECT *
FROM Products;


SELECT *
FROM Orders;


ALTER TABLE Orders
ADD ID INT AUTO_INCREMENT PRIMARY KEY;


CREATE TABLE Orders_ AS
SELECT *
FROM Orders;


SELECT *
FROM Orders_;


SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Order_ID, Customer_ID, Order_Date
		   ORDER BY ID) AS Row_Num
	FROM Orders_
) D
WHERE Row_Num > 1;


DELETE FROM Orders_
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Order_ID, Customer_ID, Order_Date
			   ORDER BY ID) AS rn
        FROM Orders_
    ) T
    WHERE rn > 1
);


SELECT *
FROM Orders_;


DELETE FROM Orders
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Order_ID, Customer_ID, Order_Date
			   ORDER BY ID) AS rn
        FROM Orders
    ) T
    WHERE rn > 1
);


SELECT *
FROM Orders;


ALTER TABLE Orders
DROP ID;


DROP TABLE Orders_;


SELECT *
FROM Order_Items;


ALTER TABLE Order_Items
ADD ID INT AUTO_INCREMENT PRIMARY KEY;


CREATE TABLE Order_Items_ AS
SELECT *
FROM Order_Items;


SELECT *
FROM Order_Items_;


SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Order_Item_ID, Order_ID, Product_ID, Quantity
		   ORDER BY ID) AS Row_Num
	FROM Order_Items_
) D
WHERE Row_Num > 1;


DELETE FROM Order_Items_
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Order_Item_ID, Order_ID, Product_ID, Quantity
			   ORDER BY ID) AS rn
        FROM Order_Items_
    ) T
    WHERE rn > 1
);


DELETE FROM Order_Items
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID,
               ROW_NUMBER() OVER(PARTITION BY Order_Item_ID, Order_ID, Product_ID, Quantity
			   ORDER BY ID) AS rn
        FROM Order_Items
    ) T
    WHERE rn > 1
);


SELECT *
FROM Order_Items;


ALTER TABLE Order_Items
DROP ID;


DROP TABLE Order_Items_;


SELECT *
FROM Customers;


SELECT *
FROM Orders;


SELECT *
FROM Products;


SELECT *
FROM Order_Items;


-- 1. List all customers from Chennai.

SELECT Customer_ID, Name, City
FROM Customers
WHERE City = 'Chennai';


-- 2. Find the total number of orders placed by each customer.

SELECT Customers.Customer_ID,
	   Customers.Name,
       COUNT(Orders.Order_ID) AS Total_Orders
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
GROUP BY Customers.Customer_ID, Customers.Name;

-- Customers who didn't placed any orders

SELECT Customers.Customer_ID,
	   Customers.Name,
       Orders.Order_ID
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
WHERE Orders.Order_ID IS NULL;


-- 3. Show all products that were never ordered.

SELECT Products.Product_ID,
	   Products.Product_Name
FROM Products
LEFT JOIN Order_Items
	ON Products.Product_ID = Order_Items.Product_ID
WHERE Order_Items.Product_ID IS NULL;


-- 4. Get all orders along with customer names.

SELECT Customers.Customer_ID,
	   Customers.Name,
	   Orders.Order_ID,
       Orders.Order_Date
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID;


-- 5. Find the total revenue generated for each order.

SELECT Order_Items.Order_ID,
       SUM(Products.Price * Order_Items.Quantity) AS Total_Revenue
FROM Products
INNER JOIN Order_Items
	ON Products.Product_ID = Order_Items.Product_ID
GROUP BY Order_Items.Order_ID
ORDER BY Total_Revenue DESC;
       

-- 6. Find the total amount spent by each customer.

SELECT Customers.Customer_ID,
	   Customers.Name,
       COALESCE(SUM(Products.Price * Order_Items.Quantity), 0) AS Total_Spent
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
LEFT JOIN Order_Items
	ON Orders.Order_ID = Order_Items.Order_ID
LEFT JOIN Products
	ON Products.Product_ID = Order_Items.Product_ID
GROUP BY Customers.Customer_ID, Customers.Name;


-- 7. List the top 3 most expensive products.

SELECT *
FROM (		
	SELECT Product_ID, Product_Name, Category, Price,
		   ROW_NUMBER() OVER(ORDER BY Price DESC) AS Row_Num
	FROM Products
)T
WHERE Row_Num <= 3;

-- OR

SELECT Product_ID, Product_Name, Category, Price
FROM Products
ORDER BY Price DESC
LIMIT 3;


-- 8. Find the most popular product (based on total quantity sold).

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total DESC) AS Rank_
	FROM (
		SELECT Products.Product_ID,
			   Products.Product_Name AS Most_Popular_Product,
               SUM(Order_Items.Quantity) AS Total
		FROM Products
        INNER JOIN Order_Items
			ON Products.Product_ID = Order_Items.Product_ID
		GROUP BY Products.Product_ID, Products.Product_Name
        )T
	)S
WHERE Rank_ = 1;


-- 9. Find customers who have placed more than 1 order.

SELECT Customers.Customer_ID,
	   Customers.Name,
       COUNT(Orders.Order_ID) AS Total_Orders
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
GROUP BY Customers.Customer_ID, Customers.Name
HAVING COUNT(Orders.Order_ID) > 1;


-- 10. Find the customer who has spent the most money.

SELECT *
FROM (
	SELECT *,
		RANK() OVER(ORDER BY Total_Spent DESC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			Customers.Name,
			SUM(Products.Price * Order_Items.Quantity) AS Total_Spent
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Order_Items
			ON Orders.Order_ID = Order_Items.Order_ID
		INNER JOIN Products
			ON Products.Product_ID = Order_Items.Product_ID
		GROUP BY Customers.Customer_ID, Customers.Name
        ) T
	)R
WHERE Rank_ = 1;







        
        
        
        