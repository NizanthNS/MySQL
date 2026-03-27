CREATE DATABASE Demo3;


USE Demo3;


CREATE TABLE Orders (
    Order_ID INT,
    Customer_ID INT,
    Order_Date DATE,
    Amount INT
);


INSERT INTO Orders 
VALUES	(1, 101, '2024-01-10', 500),
		(2, 102, '2024-01-15', 300),
		(3, 101, '2024-02-05', 700),
		(4, 103, '2024-02-20', 200),
		(5, 101, '2024-03-01', 400),
		(6, 102, '2024-03-10', 600);
        

SELECT *
FROM Orders;


-- Using CTE, show total sales per month

WITH CTE AS (
	SELECT MONTH(Order_Date) AS Month_,
		   YEAR(Order_Date) AS Year_,
           SUM(Amount) AS Total_Sales
	FROM Orders
    GROUP BY Month_,Year_
    )
SELECT *
FROM CTE;


-- 2. Show months where total sales > average monthly sales

WITH CTE AS (
    SELECT YEAR(Order_Date) AS Year_,
           MONTH(Order_Date) AS Month_,
           SUM(Amount) AS Total_Sales
    FROM Orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT *
FROM CTE
WHERE Total_Sales > (
    SELECT AVG(Total_Sales)
    FROM CTE
);


-- 3. Show orders placed BETWEEN '2024-02-01' and '2024-03-01' using CTE

WITH CTE AS (
	SELECT Order_ID,
		   Customer_ID,
           Order_Date
	FROM Orders
    WHERE Order_Date BETWEEN '2024-02-01' AND '2024-03-01'
)
SELECT *
FROM CTE;


-- 4. Using CTE, show total sales per customer per month

WITH CTE AS (
	SELECT Customer_ID,
		   MONTH(Order_Date) AS Month_,
           YEAR(Order_Date) AS Year_,
           SUM(Amount) AS Total_Sales
	FROM Orders
    GROUP BY Customer_ID, Month_, Year_
    )
SELECT *
FROM CTE;


-- 5. Using CTE, show month-wise sales and previous month sales

WITH CTE AS (
	SELECT YEAR(Order_Date) AS Year_,
		   MONTH(Order_Date) AS Month_,
           SUM(Amount) AS Total_Sales
	FROM Orders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
    )
SELECT *,
	   LAG(Total_Sales) OVER(ORDER BY Year_, Month_) AS Previous_Month
FROM CTE;






