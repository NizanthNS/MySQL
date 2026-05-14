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
        (5, 'Divya',   'Chennai'),
        (6, 'Sanjay',  'Mumbai');
        

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Product_Name VARCHAR(50),
    Amount INT
);

INSERT INTO Orders
VALUES  (101, 1, 'Laptop',    75000),
        (102, 2, 'Mobile',    45000),
        (103, 1, 'Headphone', 3000),
        (104, 3, 'Chair',      7000),
        (105, 5, 'Table',     12000),
        (106, 7, 'Watch',      8000);
        
        
SELECT *
FROM Customers;


SELECT *
FROM Orders;


-- Day 5 : JOINS


-- Q1
-- Show:
-- Customer_Name
-- Product_Name
-- Amount
-- using INNER JOIN.

SELECT C.Customer_Name,
	   O.Product_Name,
       O.Amount
FROM Customers C
INNER JOIN Orders O
	ON C.Customer_ID = O.Customer_ID;


-- Q2
-- Show all customers along with their orders
-- including customers who have not placed any order.

SELECT C.Customer_Name,
	   O.Order_ID,
	   O.Product_Name
FROM Customers C
LEFT JOIN Orders O
	ON C.Customer_ID = O.Customer_ID;


-- Q3
-- Show customers who have NOT placed any orders.

SELECT C.Customer_Name
FROM Customers C
LEFT JOIN Orders O
	ON C.Customer_ID = O.Customer_ID
WHERE O.Order_ID IS NULL;


-- Q4
-- Show orders that do NOT have a matching customer.

SELECT O.Order_ID, O.Product_Name
FROM Orders O
LEFT JOIN Customers C
	ON C.Customer_ID = O.Customer_ID
WHERE C.Customer_ID IS NULL;


-- Q5
-- Show:
-- Customer_Name
-- City
-- Product_Name
-- Amount
-- for customers from Chennai.

SELECT C.Customer_Name, C.City,
	   O.Product_Name, O.Amount
FROM Customers C
INNER JOIN Orders O
	ON C.Customer_ID = O.Customer_ID
WHERE C.City = 'Chennai';


-- Q6
-- Find the total Amount spent by each customer.

SELECT C.Customer_Name,
	   COALESCE(SUM(O.Amount), 0) AS Total_Spent
FROM Customers C
LEFT JOIN Orders O
	ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_Name;


-- Bonus Debugging Question

SELECT Customer_Name, Product_Name
FROM Customers
JOIN Orders
ON Customers.Customer_ID = Orders.Order_ID;

-- What is wrong with this query?
-- Rewrite it correctly.

SELECT Customers.Customer_Name, Orders.Product_Name
FROM Customers
JOIN Orders
ON Customers.Customer_ID = Orders.Customer_ID