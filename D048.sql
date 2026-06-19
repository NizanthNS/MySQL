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


CREATE TABLE Orders_Data (
    Order_ID INT,
    Customer_ID INT,
    Order_Date DATE,
    Amount INT
);

INSERT INTO Orders_Data 
VALUES	(1, 1, '2024-01-01', 20000),
		(2, 1, '2024-01-10', 15000),
		(3, 1, '2024-02-05', 20000),
		(4, 2, '2024-01-03', 30000),
		(5, 2, '2024-01-20', 25000),
		(6, 2, '2024-03-01', 10000),
		(7, 3, '2024-01-02', 40000),
		(8, 3, '2024-02-15', 10000),
		(9, 4, '2024-01-05', 25000),
		(10,4, '2024-01-25', 30000);

SELECT *
FROM Customers_Data;

SELECT *
FROM Orders_Data;


-- Get all orders with customer names

SELECT O.Order_ID, C.Customer_Name, O.Order_Date, O.Amount
FROM Orders_Data O
JOIN Customers_Data C
	ON O.Customer_ID = C.Customer_ID;


-- Find total amount spent by each customer

SELECT C.Customer_Name, SUM(O.Amount) AS Total_Spent
FROM Orders_Data O
JOIN Customers_Data C
	ON O.Customer_ID = C.Customer_ID
GROUP BY C.Customer_Name;


-- Find total orders for each customer

SELECT C.Customer_Name, COUNT(O.Order_ID) AS Order_Count
FROM Customers_Data C
JOIN Orders_Data O
	ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_Name;


-- Get customers who placed orders in January 2024

SELECT DISTINCT C.Customer_Name
FROM Customers_Data C
JOIN Orders_Data O
	ON C.Customer_ID = O.Customer_ID
WHERE O.Order_Date BETWEEN '2024-01-01' AND '2024-01-31';


-- Find the latest order date for each customer

SELECT C.Customer_Name, MAX(O.Order_Date) AS Latest_Order
FROM Customers_Data C
JOIN Orders_Data O
	ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_Name;