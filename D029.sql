CREATE TABLE Customers (
	Customer_ID INT PRIMARY KEY,
	Customer_Name VARCHAR(50),
	City VARCHAR(50)
);


CREATE TABLE Products (
	Product_ID INT PRIMARY KEY,
	Product_Name VARCHAR(50),
	Price INT
);


CREATE TABLE Orders (
	Order_ID INT PRIMARY KEY,
	Customer_ID INT,
	Product_ID INT,
	Quantity INT
);


INSERT INTO Customers 
VALUES	(1,'Arun','Chennai'),
		(2,'Meena','Mumbai'),
		(3,'Ravi','Chennai'),
		(4,'Divya','Delhi'),
		(5,'Karan','Mumbai');


INSERT INTO Products 
VALUES	(101,'Laptop',60000),
		(102,'Mobile',20000),
		(103,'Headphones',3000),
		(104,'Keyboard',2000);
        

INSERT INTO Orders 
VALUES	(1,1,101,1),
		(2,1,103,2),
		(3,2,102,1),
		(4,3,101,1),
		(5,3,104,3),
		(6,4,103,1),
		(7,2,101,1);


SELECT *
FROM Customers;

SELECT *
FROM Orders;

SELECT *
FROM Products;


-- Show all customers from Chennai.

SELECT *
FROM Customers
WHERE City = 'Chennai';

-- OR

SELECT Customer_ID, Customer_Name
FROM Customers
WHERE City = 'Chennai';


-- Show customer names and product names they ordered.

SELECT Customer_Name, Product_Name
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID;


-- Show total quantity ordered by each customer.

SELECT Customers.Customer_ID, 
	   Customers.Customer_Name, 
       SUM(Orders.Quantity) AS Total_Quantity
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
GROUP BY Customers.Customer_ID, Customers.Customer_Name;


-- Find the most expensive product.

SELECT *
FROM Products
WHERE Price = (
	SELECT MAX(Price)
    FROM Products
    );

-- OR

SELECT *
FROM Products
ORDER BY Price DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Price DESC) AS Rank_
	FROM Products
    )T
WHERE Rank_ = 1;


-- Show customers who never placed an order.

SELECT *
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
WHERE Order_ID IS NULL;

-- OR

SELECT Customers.Customer_ID,
	   Customers.Customer_Name,
       Customers.City
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
WHERE Order_ID IS NULL;


-- Count the number of orders per product.

SELECT Products.Product_ID, 
	   Products.Product_Name, 
       COUNT(Orders.Order_ID) AS Total_Orders
FROM Orders
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Products.Product_ID, Products.Product_Name;


-- Find the product ordered the most (highest total quantity).

SELECT Products.Product_ID,
	   Products.Product_Name, 
	   SUM(Orders.Quantity) AS Total_Orders
FROM Orders
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Products.Product_ID, Products.Product_Name
ORDER BY Total_Orders DESC
LIMIT 1;

-- OR

SELECT Products.Product_ID,
	   Products.Product_Name, 
	   SUM(Orders.Quantity) AS Total_Orders
FROM Orders
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Products.Product_ID, Products.Product_Name
HAVING Total_Orders = (
		SELECT MAX(Total_Orders)
        FROM ( 
			SELECT Products.Product_ID,
				   Products.Product_Name,
				   SUM(Orders.Quantity) AS Total_Orders
            FROM Orders
            INNER JOIN Products
				ON Orders.Product_ID = Products.Product_ID
            GROUP BY Products.Product_ID, Products.Product_Name
            ) T
);

-- OR

WITH CTE AS (
	SELECT Products.Product_ID,
		   Products.Product_Name, 
		   SUM(Orders.Quantity) AS Total_Orders
	FROM Orders
	INNER JOIN Products
		ON Orders.Product_ID = Products.Product_ID
	GROUP BY Products.Product_ID, Products.Product_Name
)
SELECT *
FROM CTE
WHERE Total_Orders = (
	SELECT MAX(Total_Orders)
    FROM CTE
    );
    
-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Orders DESC) AS Rank_
	FROM (
		SELECT Products.Product_ID,
			   Products.Product_Name, 
			   SUM(Orders.Quantity) AS Total_Orders
		FROM Orders
		INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
		GROUP BY Products.Product_ID, Products.Product_Name
	)T
)R
WHERE Rank_ = 1;


-- Show customers who ordered a Laptop.

SELECT Customers.Customer_ID, 
	   Customers.Customer_Name,
       Products.Product_ID,
       Products.Product_Name
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
WHERE Products.Product_Name = 'Laptop';


-- Show orders where total price > 50000.

SELECT Orders.Order_ID,
	   Orders.Customer_ID,
	   Orders.Quantity,
       Products.Price,
	   (Orders.Quantity * Products.Price) AS Total_Price
FROM Orders
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
WHERE (Orders.Quantity * Products.Price) > 50000;

-- OR

WITH CTE AS (
	SELECT Orders.Order_ID,
		   Orders.Customer_ID,
	       Orders.Quantity,
           Products.Price,
	       (Orders.Quantity * Products.Price) AS Total_Price
	FROM Orders
	INNER JOIN Products
		ON Orders.Product_ID = Products.Product_ID
)
SELECT *
FROM CTE
WHERE Total_Price > 50000;


-- Find the customer who spent the most money.


SELECT Customers.Customer_ID,
	   Customers.Customer_Name,
	   SUM(Orders.Quantity * Products.Price) AS Total_Spent
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Customers.Customer_ID, Customers.Customer_Name
HAVING Total_Spent = (
	SELECT MAX(Total_Spent)
    FROM (
		SELECT Customers.Customer_ID,
			   Customers.Customer_Name,
			   SUM(Orders.Quantity * Products.Price) AS Total_Spent
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
			GROUP BY Customers.Customer_ID, Customers.Customer_Name
		) T
);

-- OR

SELECT Customers.Customer_ID,
	   Customers.Customer_Name,
       SUM(Orders.Quantity * Products.Price) AS Total_Spent
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Customers.Customer_ID, Customers.Customer_Name
ORDER BY Total_Spent DESC
LIMIT 1;

-- OR

WITH CTE AS (
	SELECT Customers.Customer_ID,
		   Customers.Customer_Name,
		   SUM(Orders.Quantity * Products.Price) AS Total_Spent
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Products
		ON Orders.Product_ID = Products.Product_ID
	GROUP BY Customers.Customer_ID, Customers.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Spent = (
	SELECT MAX(Total_Spent)
    FROM CTE
);

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Spent DESC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Customer_Name,
			   SUM(Orders.Quantity * Products.Price) AS Total_Spent
		FROM Customers
		INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
		GROUP BY Customers.Customer_ID, Customers.Customer_Name
	)T
)R
WHERE Rank_ = 1;

