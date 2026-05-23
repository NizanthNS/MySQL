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
    Order_Amount INT,
    Order_Date DATE
);

INSERT INTO Orders
VALUES  (101, 1, 12000, '2024-01-01'),
        (102, 2, 18000, '2024-01-03'),
        (103, 1, 15000, '2024-01-10'),
        (104, 3, 22000, '2024-01-15'),
        (105, 2, 25000, '2024-01-20'),
        (106, 1, 17000, '2024-02-01'),
        (107, 4, 30000, '2024-02-05'),
        (108, 5, 28000, '2024-02-10'),
        (109, 3, 26000, '2024-02-14'),
        (110, 2, 21000, '2024-02-20'),
        (111, 1, 19000, '2024-03-01'),
        (112, 5, 32000, '2024-03-08');
        

SELECT *
FROM Customers;


SELECT *
FROM Orders;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each customer along with:
-- 1. Total Orders
-- 2. Total Spending
-- 3. Average Order Amount
-- ordered by Total Spending descending.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name,
		   COUNT(O.Order_ID) AS Total_Orders,
           SUM(O.Order_Amount) AS Total_Spending,
           ROUND(AVG(O.Order_Amount), 2) AS Average_Order_Amount
	FROM Customers C
    INNER JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name
)
SELECT *
FROM CTE
ORDER BY Total_Spending DESC;


-- Q2
-- Find customers whose total spending
-- is greater than the overall average customer spending.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name,
           SUM(O.Order_Amount) AS Total_Spending
	FROM Customers C
    INNER JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Spending > (
	SELECT AVG(Total_Spending)
    FROM CTE
);


-- Q3
-- Show the top spending customer
-- in each City.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, C.City,
           SUM(O.Order_Amount) AS Total_Spending
	FROM Customers C
    INNER JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name, C.City
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY City
		   ORDER BY Total_Spending DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank = 1;


-- Q4
-- Show monthly revenue:
-- 1. Year
-- 2. Month
-- 3. Total Revenue
-- ordered by Year and Month.

WITH CTE AS (
	SELECT YEAR(Order_Date) AS Year_,
		   MONTH(Order_Date) AS Month_,
           SUM(Order_Amount) AS Total_Revenue
	FROM Orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT *
FROM CTE
ORDER BY Year_, Month_;


-- Q5
-- Show each order along with:
-- 1. Previous order amount of that customer
-- 2. Difference from previous order amount
-- 3. Running total spending of that customer

WITH CTE AS (
	SELECT Order_ID, Order_Amount,
		   LAG(Order_Amount) OVER(PARTITION BY Customer_ID
           ORDER BY Order_Date) AS Previous_Order_Amount,
           SUM(Order_Amount) OVER(PARTITION BY Customer_ID
           ORDER BY Order_Date) AS Running_Total
	FROM Orders 
)
SELECT *,
	   Order_Amount - Previous_Order_Amount AS Difference
FROM CTE
WHERE Previous_Order_Amount IS NOT NULL;


-- Q6 (Date Logic)
-- Find customers who placed consecutive orders
-- within 15 days of their previous order.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, O.Order_Date,
           LAG(O.Order_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY O.Order_Date) AS Previous_Date
	FROM Customers C
    INNER JOIN Orders O
		ON C.Customer_ID = O.Customer_ID
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Order_Date, Previous_Date) <= 15;


-- Bonus Challenge
-- Show:
-- 1. Customer_Name
-- 2. First Order Date
-- 3. Latest Order Date
-- 4. Total Orders
-- 5. Total Spending
-- 6. Average Days Between Orders

WITH CTE AS (
    SELECT C.Customer_ID,
           C.Customer_Name,
           O.Order_Date,
           LAG(O.Order_Date) OVER(PARTITION BY C.Customer_ID
		   ORDER BY O.Order_Date) AS Previous_Order_Date
    FROM Customers C
    INNER JOIN Orders O
        ON C.Customer_ID = O.Customer_ID
),
CTE2 AS (
    SELECT Customer_ID,
           Customer_Name,
           Order_Date,
           Previous_Order_Date,
           DATEDIFF(Order_Date,Previous_Order_Date) AS Days_Gap
    FROM CTE
    WHERE Previous_Order_Date IS NOT NULL
)
SELECT Customer_ID,
       Customer_Name,
       MIN(Order_Date) AS First_Order_Date,
       MAX(Order_Date) AS Latest_Order_Date,
       COUNT(Order_Date) AS Total_Orders,
       AVG(Days_Gap) AS Average_Days_Between_Orders
FROM CTE2
GROUP BY Customer_ID, Customer_Name;