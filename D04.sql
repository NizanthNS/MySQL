CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);


CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product VARCHAR(50),
    amount INT
);


INSERT INTO Customers 
VALUES	(1,'Arun','Chennai'),
		(2,'Meena','Madurai'),
		(3,'Ravi','Coimbatore'),
		(4,'Divya','Chennai'),
		(5,'Karan','Salem'),
		(6,'Sneha','Madurai'),
		(7,'Vikram','Chennai'),
		(8,'Anita','Coimbatore');


INSERT INTO Orders 
VALUES	(101,1,'Laptop',60000),
	(102,1,'Mouse',1000),
	(103,2,'Mobile',20000),
	(104,3,'Laptop',65000),
	(105,4,'Keyboard',2000),
	(106,5,'Monitor',15000),
	(107,1,'Headphones',3000),
	(108,6,'Mobile',18000),
	(109,7,'Laptop',62000),
	(110,3,'Mouse',1200);
    

SELECT *
FROM Customers;

SELECT *
FROM Orders;


-- 1. Show all customers from Chennai

SELECT *
FROM Customers
WHERE city = 'Chennai';


-- 2. Show orders where amount is greater than 20,000

SELECT *
FROM Orders
WHERE amount > 20000;


-- 3. Show customer names and products they ordered

SELECT Customers.customer_name, Orders.product
FROM Customers
INNER JOIN Orders
	ON Customers.customer_id = Orders.customer_id;


-- 4. Find total amount spent by each customer

SELECT Customers.customer_name, Customers.customer_id, SUM(Orders.amount) AS Total_Spent
FROM Customers
INNER JOIN Orders
	ON Customers.customer_id = Orders.customer_id
    GROUP BY Customers.customer_name, Customers.customer_id;


-- 5. Find the highest order amount

SELECT *
FROM Orders
WHERE amount = (Select MAX(amount) FROM Orders);

-- OR

SELECT *
FROM Orders
ORDER BY amount DESC
LIMIT 1;


-- 6. Show customers who never placed an order

SELECT Customers.*
FROM Customers
LEFT JOIN Orders
	ON Customers.customer_id = Orders.customer_id
	WHERE Orders.order_id IS NULL;


-- 7. Count number of customers in each city

SELECT city, COUNT(*) AS No_oF_Customers_Per_City
FROM Customers
GROUP BY city;


-- 8. Find the customer who spent the most money

SELECT Customers.customer_name, Customers.customer_id, SUM(Orders.amount) AS Most_Money_Spent
FROM Customers
INNER JOIN Orders
	ON Customers.customer_id = Orders.customer_id
    GROUP BY Customers.customer_name, Customers.customer_id
    ORDER BY Most_Money_Spent DESC
    LIMIT 1;


-- 9. Show orders where amount is above the average order amount

SELECT *
FROM Orders
WHERE amount > (SELECT AVG(amount) FROM Orders);


-- 10. Find the city with the highest total order value

SELECT Customers.city, SUM(Orders.amount) AS Highest_Total
FROM Customers
INNER JOIN Orders
	ON Customers.customer_id = Orders.customer_id    
    GROUP BY Customers.city
    ORDER BY Highest_Total DESC
    LIMIT 1;


CREATE TABLE Employees (
	emp_id INT PRIMARY KEY,
	emp_name VARCHAR(50),
	department VARCHAR(50),
	salary INT
);


INSERT INTO Employees 
VALUES	(1,'Arun','IT',70000),
		(2,'Meena','HR',50000),
		(3,'Ravi','IT',80000),
		(4,'Divya','Finance',60000),
		(5,'Karan','IT',75000),
		(6,'Sneha','HR',55000),
		(7,'Vikram','Finance',90000);
        

SELECT *
FROM Employees;


-- Find the second highest salary.

SELECT MAX(salary) AS Second_Highest_Salary
FROM Employees
WHERE salary < (SELECT MAX(salary) FROM Employees);

-- OR

SELECT salary
FROM Employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;


-- Find the department with the highest average salary.

SELECT department, AVG(salary) AS Highest_average_salary
FROM Employees
GROUP BY department
ORDER BY Highest_average_salary DESC
LIMIT 1;


-- Find employees who earn more than the average salary of their department.

SELECT *
FROM Employees e
WHERE salary > (
	SELECT AVG(salary)
	FROM Employees
	WHERE department = e.department)
ORDER BY salary DESC;



