CREATE TABLE Customers_Data (
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customers_Data 
VALUES	(1, 'Arun', 'Chennai'),
		(2, 'Meena', 'Madurai'),
		(3, 'Ravi', 'Coimbatore'),
		(4, 'Priya', 'Chennai');


CREATE TABLE Products_Data (
    Product_ID INT,
    Product_Name VARCHAR(50),
    Price INT
);

INSERT INTO Products_Data 
VALUES	(101, 'Laptop', 50000),
		(102, 'Mobile', 20000),
		(103, 'Tablet', 30000),
		(104, 'Headphones', 5000);


CREATE TABLE Orders_Data (
    Order_ID INT,
    Customer_ID INT,
    Product_ID INT,
    Order_Date DATE,
    Quantity INT
);

INSERT INTO Orders_Data 
VALUES	(1, 1, 101, '2024-01-01', 1),
		(2, 1, 102, '2024-01-10', 2),
		(3, 2, 103, '2024-01-05', 1),
		(4, 2, 104, '2024-02-01', 3),
		(5, 3, 101, '2024-01-15', 1),
		(6, 3, 104, '2024-02-20', 2),
		(7, 4, 102, '2024-01-25', 1),
		(8, 4, 103, '2024-03-01', 1);


SELECT * 
FROM Customers_Data;

SELECT * 
FROM Products_Data;

SELECT * 
FROM Orders_Data;


-- Get complete order details (Customer Name, Product Name, Quantity, Order Date)

SELECT C.Customer_Name,
	   P.Product_Name,
       O.Quantity,
       O.Order_Date
FROM Orders_Data O
JOIN Customers_Data C 
	ON O.Customer_ID = C.Customer_ID
JOIN Products_Data P 
	ON O.Product_ID = P.Product_ID;


-- Find total amount spent by each customer

SELECT C.Customer_Name,
	   SUM(O.Quantity * P.Price) AS Total_Spent
FROM Orders_Data O
JOIN Customers_Data C 
	ON O.Customer_ID = C.Customer_ID
JOIN Products_Data P 
	ON O.Product_ID = P.Product_ID
GROUP BY C.Customer_Name;


-- Find total quantity sold for each product

SELECT P.Product_Name,
	   SUM(O.Quantity) AS Total_Quantity
FROM Orders_Data O
JOIN Products_Data P 
	ON O.Product_ID = P.Product_ID
GROUP BY P.Product_Name;


-- Find customers who purchased 'Laptop'

SELECT DISTINCT C.Customer_Name
FROM Orders_Data O
JOIN Customers_Data C 
	ON O.Customer_ID = C.Customer_ID
JOIN Products_Data P 
	ON O.Product_ID = P.Product_ID
WHERE P.Product_Name = 'Laptop';


-- Find the highest spending customer

SELECT C.Customer_Name,
	   SUM(O.Quantity * P.Price) AS Total_Spent
FROM Orders_Data O
JOIN Customers_Data C 
	ON O.Customer_ID = C.Customer_ID
JOIN Products_Data P 
	ON O.Product_ID = P.Product_ID
GROUP BY C.Customer_Name
ORDER BY Total_Spent DESC
LIMIT 1;