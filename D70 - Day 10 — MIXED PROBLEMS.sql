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
    Category VARCHAR(50),
    Amount INT,
    Order_Date DATE
);

INSERT INTO Orders
VALUES  (101, 1, 'Electronics', 45000, '2024-01-10'),
        (102, 2, 'Furniture',   20000, '2024-01-12'),
        (103, 1, 'Accessories',  3000, '2024-01-15'),
        (104, 3, 'Furniture',    7000, '2024-01-18'),
        (105, 5, 'Electronics', 52000, '2024-01-20'),
        (106, 2, 'Clothing',    12000, '2024-01-22'),
        (107, 4, 'Electronics', 41000, '2024-01-25'),
        (108, 5, 'Furniture',   25000, '2024-01-28'),
        (109, 7, 'Electronics', 30000, '2024-02-01');
        

SELECT *
FROM Customers;

SELECT *
FROM Orders;


-- Day 10 : Mixed Problems (Real-World Style)


-- Q1
-- Show customer names along with their total order Amount,
-- ordered from highest spender to lowest.

WITH CTE AS (
	SELECT C.Customer_Name,
		   COALESCE(SUM(O.Amount), 0) AS Total_Order_Amount
	FROM Customers C
    LEFT JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_Name
)
SELECT *
FROM CTE
ORDER BY Total_Order_Amount DESC;


-- Q2
-- Find customers who have placed more than 1 order.

WITH CTE AS (
	SELECT C.Customer_Name,
		   COUNT(O.Order_ID) AS Total_Order
	FROM Customers C
    INNER JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Order > 1;


-- Q3
-- Show the highest order Amount for each Category.

SELECT Category,
       MAX(Amount) AS Highest_Order_Amount
FROM Orders
GROUP BY Category;
			   

-- Q4
-- Show customers who spent more than
-- the average spending of all customers.

WITH CTE AS (
	SELECT C.Customer_Name, 
		   SUM(O.Amount) AS Total_Amount
	FROM Customers C
    INNER JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_Name
),
CTE2 AS (
	SELECT *,
		   ROUND(AVG(Total_Amount) OVER(), 2) AS Average
	FROM CTE
)
SELECT *
FROM CTE2
WHERE Total_Amount > Average;


-- Q5
-- Show the top spending customer
-- in each City.

WITH CTE AS (
    SELECT C.Customer_Name, C.City,
           SUM(O.Amount) AS Total_Spent
    FROM Customers C
    INNER JOIN Orders O
        ON C.Customer_ID = O.Customer_ID
    GROUP BY C.Customer_Name, C.City
)
SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER(PARTITION BY City
		   ORDER BY Total_Spent DESC) AS D_Rank
    FROM CTE
) D
WHERE D_Rank = 1;


-- Q6
-- Show orders that do not have a matching customer.

SELECT O.Order_ID, Category, Amount
FROM Orders O
LEFT JOIN Customers C
	ON O.Customer_ID = C.Customer_ID
WHERE C.Customer_ID IS NULL;


-- Bonus Challenge
-- Create a query that shows:
-- 1. Customer_Name
-- 2. Total Amount spent
-- 3. Rank based on total spending
-- ordered from highest spender to lowest.

WITH CTE AS (
	SELECT C.Customer_Name,
		   SUM(O.Amount) AS Total_Spent
	FROM Customers C
    INNER JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_Name
)
SELECT *,
	   RANK() OVER(ORDER BY Total_Spent DESC) AS Rank_
FROM CTE;
