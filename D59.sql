USE Daily_SQL;

SELECT *
FROM Customer_Info;

SELECT *
FROM Sales_Records;


-- Q1
-- Find customers whose total spending is higher than
-- the average spending of customers in their city

WITH CTE AS (
	SELECT C.Customer_Name, C.City,
		   SUM(S.Amount) AS Total_Spent
	FROM Customer_Info C
    INNER JOIN Sales_Records S
		ON C.Customer_Name = S.Customer_Name
	GROUP BY C.Customer_Name, C.City
)
SELECT *
FROM (
	SELECT *,
	       AVG(Total_Spent) OVER(PARTITION BY City) AS Average_Spent
	FROM CTE
)A
WHERE Total_Spent > Average_Spent;


-- Q2
-- Show the second highest order amount for each customer

SELECT *
FROM (
	SELECT Customer_Name, Amount,
		   DENSE_RANK() OVER(PARTITION BY Customer_Name
		   ORDER BY Amount DESC) AS D_Rank
	FROM Sales_Records
)R
WHERE D_Rank = 2;


-- Q3
-- Find customers whose every order amount is greater
-- than 5000

SELECT Customer_Name
FROM Sales_Records
GROUP BY Customer_Name
HAVING MIN(Amount) > 5000;


-- Q4
-- Show customers whose latest order is their highest order

WITH CTE AS (
	SELECT Customer_Name, Amount, Order_Date,
		   ROW_NUMBER() OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date DESC) AS Row_Num
	FROM Sales_Records
),
CTE2 AS (
	SELECT Customer_Name, 
		   MAX(Amount) AS Max_Amount
    FROM Sales_Records
    GROUP BY Customer_Name
)
SELECT C1.Customer_Name,
	   C1.Amount,
       C2.Max_Amount
FROM CTE C1
INNER JOIN CTE2 C2
	ON C1.Customer_Name = C2.Customer_Name
WHERE Row_Num = 1
AND C1.Amount = C2.Max_Amount;


-- Q5
-- Find products that were purchased on consecutive days

WITH CTE AS (
	SELECT Product, Order_Date,
		   LAG(Order_Date) OVER(PARTITION BY Product
           ORDER BY Order_Date) AS Previous_Date
	FROM Sales_Records
)
SELECT DISTINCT Product
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Order_Date, Previous_Date) = 1;


-- Q6
-- Show customers whose spending trend is decreasing
-- compared to previous orders

WITH CTE AS (
	SELECT DISTINCT Customer_Name, Amount,
		   LAG(Amount) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous_Amount
	FROM Sales_Records
)
SELECT *
FROM CTE
WHERE Amount < Previous_Amount;


-- Q7
-- Find the first order where customer crossed 100000 total spending

WITH CTE AS (
    SELECT Customer_Name, Order_Date, Amount,
           SUM(Amount) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Running_Total
    FROM Sales_Records
),
CTE2 AS (
    SELECT *,
           LAG(Running_Total) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous_Total
    FROM CTE
)
SELECT Customer_Name, Order_Date, Running_Total
FROM CTE2
WHERE Running_Total >= 100000
AND (Previous_Total < 100000 OR Previous_Total IS NULL);


-- Q8
-- Show customers who purchased all available products

SELECT Customer_Name,
       COUNT(DISTINCT Product) AS Total_Items
FROM Sales_Records 
GROUP BY Customer_Name
HAVING COUNT(DISTINCT Product) = (
    SELECT COUNT(DISTINCT Product)
    FROM Sales_Records
);


-- Q9
-- Find customers whose average order amount is increasing over time

WITH CTE AS (
    SELECT Customer_Name, Order_Date, Amount,
           AVG(Amount) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Running_Avg
    FROM Sales_Records
),
CTE2 AS (
    SELECT *,
           LAG(Running_Avg) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous_Avg
    FROM CTE
)
SELECT Customer_Name
FROM CTE2
GROUP BY Customer_Name
HAVING COUNT(*) = COUNT(
    CASE
        WHEN Previous_Avg IS NULL OR Running_Avg > Previous_Avg
        THEN 1
    END
);


-- Q10 (boss 😏)
-- Find customers with at least 3 increasing consecutive orders

WITH CTE AS (
    SELECT Customer_Name, Order_Date,
           LAG(Order_Date, 1) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous1,
           LAG(Order_Date, 2) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous2
    FROM Sales_Records
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous1 IS NOT NULL
AND Previous2 IS NOT NULL
AND DATEDIFF(Order_Date, Previous1) = 1
AND DATEDIFF(Previous1, Previous2) = 1;