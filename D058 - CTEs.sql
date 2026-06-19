USE Daily_SQL;


SELECT *
FROM Customer_Info;

SELECT * 
FROM Sales_Records;


-- Q1
-- Show total spending per customer and classify:
-- > 100000 → 'High'
-- 50000–100000 → 'Medium'
-- < 50000 → 'Low'

WITH CTE AS (
	SELECT Customer_Name,
		   SUM(Amount) AS Total_Amount
	FROM Sales_Records
    GROUP BY Customer_Name
    )
SELECT *,
CASE 
	WHEN Total_Amount > 100000 THEN 'High'
	WHEN Total_Amount BETWEEN 50000 AND 100000 THEN 'Medium'
    ELSE 'Low'
END AS Category
FROM CTE;
    


-- Q2
-- Show top 2 customers per city based on total spending

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
		   RANK() OVER(PARTITION BY City
           ORDER BY Total_Spent DESC) AS Rnk
	FROM CTE
)R
WHERE Rnk <= 2;


-- Q3
-- Find customers whose total spending is above their 
-- city average

WITH CTE AS (
    SELECT C.Customer_Name, C.City,
           SUM(S.Amount) AS Total_Spent,
           AVG(SUM(S.Amount)) OVER(
           PARTITION BY City) AS Avg_City_Spent
    FROM Customer_Info C
    JOIN Sales_Records S
        ON C.Customer_Name = S.Customer_Name
    GROUP BY C.Customer_Name, C.City
)
SELECT *
FROM CTE
WHERE Total_Spent > Avg_City_Spent;
    

-- Q4
-- Customers who purchased at least 2 different products

SELECT Customer_Name,
	   COUNT(DISTINCT Product) AS Total_Items
FROM Sales_Records
GROUP BY Customer_Name
HAVING COUNT(DISTINCT Product) >= 2;


-- Q5
-- Show each customer's first and last purchase date

SELECT Customer_Name,
		   MIN(Order_Date) AS First_Purchase_Date,
           MAX(Order_Date) AS Last_Purchase_Date
FROM Sales_Records
GROUP BY Customer_Name;

-- OR

WITH CTE AS (
    SELECT Customer_Name, Order_Date,
           ROW_NUMBER() OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date ASC) AS First_Row,
           ROW_NUMBER() OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date DESC) AS Last_Row
    FROM Sales_Records
)
SELECT Customer_Name,
       MAX(CASE WHEN First_Row = 1 THEN 
       Order_Date END) AS First_Purchase_Date,
       MAX(CASE WHEN Last_Row = 1 THEN 
       Order_Date END) AS Last_Purchase_Date
FROM CTE
GROUP BY Customer_Name;


-- Q6
-- Find customers whose last purchase is greater than 
-- their average purchase

WITH CTE AS (
    SELECT Customer_Name, Amount,
           AVG(Amount) OVER(PARTITION BY Customer_Name) AS Avg_Amount,
           ROW_NUMBER() OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date DESC) AS Row_Num
    FROM Sales_Records
)
SELECT Customer_Name, Amount AS Last_Amount, Avg_Amount
FROM CTE
WHERE Row_Num = 1
  AND Amount > Avg_Amount;


-- Q7
-- Show customers with strictly increasing order amounts

WITH CTE AS (
    SELECT Customer_Name, Amount,
           LAG(Amount) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Prev_Amount
    FROM Sales_Records
)
SELECT Customer_Name
FROM CTE
GROUP BY Customer_Name
HAVING COUNT(*) = COUNT(
    CASE 
        WHEN Prev_Amount IS NULL OR Amount > Prev_Amount THEN 1
    END
);


-- Q8
-- Find the longest gap (in days) between two orders 
-- per customer

WITH CTE AS (
    SELECT Customer_Name, Order_Date,
           LAG(Order_Date) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Prev_Date
    FROM Sales_Records
)
SELECT Customer_Name,
       MAX(DATEDIFF(Order_Date, Prev_Date)) AS Max_Gap
FROM CTE
WHERE Prev_Date IS NOT NULL
GROUP BY Customer_Name;


-- Q9 (tricky 🔥)
-- Show customers whose running total crosses 50000 
-- for the first time

WITH CTE AS (
    SELECT Customer_Name, Order_Date, Amount,
           SUM(Amount) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Running_Total
    FROM Sales_Records
),
Flagged AS (
    SELECT *,
           LAG(Running_Total) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Prev_Total
    FROM CTE
)
SELECT Customer_Name, Order_Date, Running_Total
FROM Flagged
WHERE Running_Total >= 50000
AND (Prev_Total < 50000 OR Prev_Total IS NULL);


-- Q10 (boss 😏)
-- Find customers who had at least 3 consecutive purchase days

WITH CTE AS (
    SELECT Customer_Name, Order_Date,
           LAG(Order_Date, 1) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Prev1,
           LAG(Order_Date, 2) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Prev2
    FROM Sales_Records
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Prev1 IS NOT NULL
AND Prev2 IS NOT NULL
AND DATEDIFF(Order_Date, Prev1) = 1
AND DATEDIFF(Prev1, Prev2) = 1;