USE Daily_SQL;

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customers
VALUES  (1, 'Arun',   'Chennai'),
        (2, 'Meena',  'Bangalore'),
        (3, 'Ravi',   'Hyderabad'),
        (4, 'Priya',  'Chennai'),
        (5, 'Divya',  'Bangalore');
        

CREATE TABLE Food_Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Restaurant_Name VARCHAR(50),
    Order_Amount INT,
    Order_Date DATE
);

INSERT INTO Food_Orders
VALUES  (101, 1, 'Pizza Hub',      450, '2024-01-02'),
        (102, 1, 'Burger Point',   300, '2024-01-05'),
        (103, 2, 'Pizza Hub',      700, '2024-01-08'),
        (104, 3, 'Spicy Kitchen',  900, '2024-01-10'),
        (105, 1, 'Pizza Hub',      650, '2024-01-14'),
        (106, 4, 'Burger Point',   500, '2024-01-18'),
        (107, 5, 'Spicy Kitchen',  750, '2024-01-22'),
        (108, 3, 'Pizza Hub',      850, '2024-02-01'),
        (109, 2, 'Burger Point',   400, '2024-02-04'),
        (110, 4, 'Pizza Hub',      950, '2024-02-08'),
        (111, 5, 'Spicy Kitchen',  600, '2024-02-11'),
        (112, 1, 'Pizza Hub',      1000,'2024-02-15');
        

SELECT *
FROM Customers;

SELECT *
FROM Food_Orders;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each customer along with:
-- 1. Total Orders
-- 2. Total Amount Spent
-- 3. Average Order Amount
-- ordered by Total Amount Spent descending.

SELECT C.Customer_ID, C.Customer_Name,
	   COUNT(F.Order_ID) AS Total_Orders,
       SUM(F.Order_Amount) AS Total_Amount_Spent,
       ROUND(AVG(F.Order_Amount), 2) AS Average_Order_Amount
FROM Customers C
INNER JOIN Food_Orders F
	ON C.Customer_ID = F.Customer_ID
GROUP BY C.Customer_ID, C.Customer_Name
ORDER BY Total_Amount_Spent DESC;


-- Q2
-- Find customers whose total spending
-- is greater than the average total spending
-- of all customers.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name,
		   SUM(F.Order_Amount) AS Total_Amount_Spent
	FROM Customers C
	INNER JOIN Food_Orders F
		ON C.Customer_ID = F.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Amount_Spent > (
	SELECT AVG(Total_Amount_Spent)
    FROM CTE
);


-- Q3
-- Show the highest spending customer
-- in each City.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, C.City,
		   SUM(F.Order_Amount) AS Total_Amount_Spent
	FROM Customers C
	INNER JOIN Food_Orders F
		ON C.Customer_ID = F.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name, C.City
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY City
           ORDER BY Total_Amount_Spent DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank = 1;


-- Q4
-- Show restaurants that received orders
-- more than once within the same month.

SELECT Restaurant_Name,
	   COUNT(Order_ID) AS Total_Orders,
       YEAR(Order_Date) AS Year_,
       MONTH(Order_Date) AS Month_
FROM Food_Orders
GROUP BY Restaurant_Name, MONTH(Order_Date), YEAR(Order_Date)
HAVING COUNT(Order_ID) > 1;


-- Q5
-- Show each food order along with:
-- 1. Previous Order_Amount of that customer
-- 2. Difference from previous Order_Amount
-- 3. Running total spending of that customer

WITH CTE AS (
	SELECT Order_ID, Customer_ID, Order_Amount, Order_Date,
		   LAG(Order_Amount) OVER(PARTITION BY Customer_ID
           ORDER BY Order_Date) AS Previous_Order_Amount,
           SUM(Order_Amount) OVER(PARTITION BY Customer_ID
           ORDER BY Order_Date) AS Running_Total
	FROM Food_Orders
),
CTE2 AS (
	SELECT *,
		   Order_Amount - Previous_Order_Amount AS Difference
	FROM CTE
    WHERE Previous_Order_Amount IS NOT NULL
)
SELECT Order_ID, Order_Date, Previous_Order_Amount, 
	   Order_Amount, Running_total, Difference
FROM CTE2;


-- Q6 (Date Logic)
-- Find customers who placed another order
-- within 7 days of their previous order.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, F.Order_Date,
		   LAG(F.Order_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY F.Order_Date, F.Order_ID) AS Previous_Date
	FROM Customers C
	INNER JOIN Food_Orders F
		ON C.Customer_ID = F.Customer_ID
)
SELECT DISTINCT Customer_ID, Customer_Name
FROM CTE 
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Order_Date, Previous_Date) <= 7;


-- Bonus Challenge
-- Show:
-- 1. Customer_Name
-- 2. First Order_Date
-- 3. Latest Order_Date
-- 4. Total Orders
-- 5. Total Amount Spent
-- 6. Average Days Between Orders

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, 
		   F.Order_Date, F.Order_ID, F.Order_Amount,
           LAG(F.Order_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY F.Order_Date, F.Order_ID) AS Previous_Date
	FROM Customers C
	INNER JOIN Food_Orders F
		ON C.Customer_ID = F.Customer_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Order_Date, Previous_Date) AS Days_Gap
	FROM CTE
),
CTE3 AS (
	SELECT Customer_ID, Customer_Name,
		   MIN(Order_Date) AS First_Order_Date,
           MAX(Order_Date) AS Latest_Order_Date,
           COUNT(Order_ID) AS Total_Orders,
           SUM(Order_Amount) AS Total_Amount_Spent,
           ROUND(AVG(Days_Gap), 2) AS Average_Days_Between_Orders
	FROM CTE2
    GROUP BY Customer_ID, Customer_Name
)
SELECT Customer_Name, First_Order_Date, Latest_Order_Date,
	   Total_Orders, Total_Amount_Spent, Average_Days_Between_Orders
FROM CTE3;