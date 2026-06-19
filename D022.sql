CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customers 
VALUES	(1, 'Arun', 'Chennai'),
		(2, 'Meena', 'Bangalore'),
		(3, 'Ravi', 'Chennai'),
		(4, 'Priya', 'Hyderabad');


CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Order_Date DATE
);

INSERT INTO Orders 
VALUES	(101, 1, '2024-01-10'),
		(102, 2, '2024-01-15'),
		(103, 1, '2024-02-01'),
		(104, 3, '2024-02-10'),
		(105, 4, '2024-03-05');


CREATE TABLE Order_Items (
    Item_ID INT PRIMARY KEY,
    Order_ID INT,
    Product_Name VARCHAR(50),
    Quantity INT,
    Price INT
);

INSERT INTO Order_Items 
VALUES	(1, 101, 'Pen', 2, 10),
		(2, 101, 'Book', 1, 50),
		(3, 102, 'Bag', 1, 500),
		(4, 103, 'Pen', 5, 10),
		(5, 104, 'Pencil', 10, 5),
		(6, 105, 'Book', 2, 50);
 
 
SELECT *
FROM Customers;


SELECT *
FROM Orders;


SELECT *
FROM Order_Items;
 
 
-- Get all customers from Chennai.

SELECT *
FROM Customers
WHERE City = 'Chennai';


-- List all orders placed in February 2024.

SELECT Orders.Order_ID,
       Order_Items.Product_Name,
	   Orders.Order_Date
FROM Orders
INNER JOIN Order_Items
	ON Orders.Order_ID = Order_Items.Order_ID
WHERE MONTH(Orders.Order_Date) = 2 AND
	  YEAR(Orders.Order_Date) = 2024;

-- OR

SELECT *
FROM Orders
WHERE Order_Date BETWEEN '2024-02-01' AND '2024-02-29';

-- OR

SELECT *
FROM Orders
WHERE MONTH(Order_Date) = 2 AND
	  YEAR(Order_Date) = 2024;

-- OR

SELECT *
FROM Orders
WHERE Order_Date >= '2024-02-01'
AND	  Order_Date < '2024-03-01';


-- Show all items where price > 50.

SELECT Item_ID, Product_Name, Price
FROM Order_Items
WHERE Price > 50;


-- Get all orders with customer names. (JOIN)

SELECT Customers.Customer_ID,
	   Customers.Name,
	   Orders.Order_ID,
       Orders.Order_Date
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID;


-- Find total amount for each order.

SELECT Order_ID,
	   SUM(Quantity * Price) AS Total_Amount
FROM Order_Items
GROUP BY Order_ID;
	   

-- Find total number of orders per customer.

WITH CTE AS (
	SELECT Customers.Customer_ID,
		Customers.Name,
		COUNT(Order_Items.Order_ID) AS Total_Items
	FROM Customers
	LEFT JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	LEFT JOIN Order_Items
		ON Orders.Order_ID = Order_Items.Order_ID
	GROUP BY Customers.Customer_ID,
			 Customers.Name
	)
SELECT *
FROM CTE
ORDER BY Total_Items DESC;

-- OR

WITH CTE AS (
    SELECT Customers.Customer_ID,
           Customers.Name,
           COUNT(Orders.Order_ID) AS Total_Orders
    FROM Customers
    LEFT JOIN Orders
        ON Customers.Customer_ID = Orders.Customer_ID
    GROUP BY Customers.Customer_ID,
             Customers.Name
)
SELECT *
FROM CTE
ORDER BY Total_Orders DESC;
       

-- Find total spending of each customer.

WITH CTE AS(
	SELECT Customers.Customer_ID,
		Customers.Name,
		COALESCE(SUM(Order_Items.Quantity * Order_Items.Price), 0) AS Total_Amount
	FROM Customers
	LEFT JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	LEFT JOIN Order_Items
		ON Orders.Order_ID = Order_Items.Order_ID
	GROUP BY Customers.Customer_ID,
			 Customers.Name
)
SELECT *
FROM CTE
ORDER BY Total_Amount DESC;


-- Find the customer who spent the most.

SELECT *
FROM (
	SELECT *,
		RANK() OVER(ORDER BY Total_Amount DESC) AS Rnk
	FROM (
		SELECT Customers.Customer_ID,
			Customers.Name,
			SUM(Order_Items.Quantity * Order_Items.Price) AS Total_Amount
		FROM Customers
		INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
			INNER JOIN Order_Items
		ON Orders.Order_ID = Order_Items.Order_ID
		GROUP BY Customers.Customer_ID,
				 Customers.Name
	)R
)T
WHERE Rnk = 1;
	

-- Get the most ordered product (by quantity).

WITH CTE AS (
	SELECT Product_Name,
		   SUM(Quantity) AS Total_Quantity
	FROM Order_Items
	GROUP BY Product_Name
)
SELECT *
FROM CTE
ORDER BY Total_Quantity DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Quantity DESC) AS Rnk
	FROM (
		SELECT Product_Name,
			   SUM(Quantity) AS Total_Quantity
		FROM Order_Items
		GROUP BY Product_Name
        )T
	)S
WHERE Rnk = 1;


-- Find customers who never placed any orders.

SELECT Customers.Customer_ID,
	   Customers.Name,
	   Orders.Order_ID
FROM Customers
LEFT JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
WHERE Orders.Order_ID IS NULL;

-- OR

SELECT Customer_ID, Name
FROM Customers
WHERE Customer_ID NOT IN (
    SELECT Customer_ID FROM Orders
);



