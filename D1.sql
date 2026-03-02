CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    C_Name VARCHAR(50),
    city VARCHAR(50),
    age INT
);


Alter Table Customers
RENAME Column C_Name To Customer_Name;


Select *
From Customers;


CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product VARCHAR(50),
    amount INT,
    order_date DATE
);


Select *
From Orders;


INSERT INTO Customers 
VALUES	(1, 'Arun', 'Chennai', 28),
		(2, 'Meena', 'Madurai', 24),
		(3, 'Ravi', 'Coimbatore', 35),
		(4, 'Priya', 'Chennai', 30),
		(5, 'Karthik', 'Salem', 40),
		(6, 'Divya', 'Madurai', 27);
        

INSERT INTO Orders 
VALUES		(101, 1, 'Laptop', 60000, '2024-01-10'),
			(102, 2, 'Mobile', 20000, '2024-01-12'),
			(103, 1, 'Headphones', 3000, '2024-01-15'),
			(104, 3, 'Tablet', 25000, '2024-02-01'),
			(105, 4, 'Laptop', 65000, '2024-02-10'),
			(106, 2, 'Mouse', 1000, '2024-02-12'),
			(107, 5, 'Monitor', 15000, '2024-02-20'),
			(108, 6, 'Keyboard', 2000, '2024-03-01'),
			(109, 3, 'Mobile', 18000, '2024-03-05'),
			(110, 1, 'Monitor', 14000, '2024-03-07');


Select *
From Customers;


Select *
From Orders;


-- 1. Show all customers from Chennai

Select *
From Customers
WHERE city = 'Chennai';


-- 2. Show all orders above ₹20,000

Select *
From Orders
WHERE amount > 20000;


-- 3. List names of customers who ordered a Laptop

Select customer_name
From Customers
INNER JOIN Orders
	ON Customers.customer_id = Orders.customer_id
    WHERE product = 'Laptop';


-- 4. Find total amount spent by each customer

SELECT Customers.customer_name, Customers.customer_id, SUM(Orders.amount) AS Total_spent
FROM Customers
INNER JOIN Orders
ON Customers.customer_id = Orders.customer_id
GROUP BY Customers.customer_name, Customers.customer_id;
    

-- 5. Show the highest order amount

Select MAX(amount) As Highest_Order_Amount
From Orders;


-- 6. Show customers who never placed an order

SELECT Customers.customer_name, Customers.customer_id
FROM Customers
LEFT JOIN Orders
ON Customers.customer_id = Orders.customer_id
WHERE Orders.order_id IS NULL;


-- 7. Count total number of orders per city

Select Customers.city, COUNT(Orders.order_id) AS Total_number_of_orders_per_city
From Customers
INNER JOIN Orders
	ON Customers.customer_id = Orders.customer_id
    GROUP BY Customers.city;


-- 8. Show the second highest order amount

Select MAX(amount) AS Second_Highest_Order
From Orders
WHERE amount < (Select MAX(amount) From Orders);


-- 9. Find the youngest customer

Select *
From Customers
ORDER BY AGE ASC
LIMIT 1;

-- OR

Select *
From Customers
WHERE age = (Select MIN(age) From Customers);


-- 10. Show total revenue generated in February 2024

SELECT SUM(amount) AS Total_February_Revenue
FROM Orders
WHERE order_date BETWEEN '2024-02-01' AND '2024-02-29';

-- OR

SELECT SUM(amount) AS Total_February_Revenue
FROM Orders
WHERE MONTH(order_date) = 2
AND YEAR(order_date) = 2024;