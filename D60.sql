USE Daily_SQL;

SELECT *
FROM Customer_Info;

SELECT *
FROM Sales_Records;


-- Q1
-- Find customers whose latest order amount
-- is greater than their average order amount

WITH CTE AS (
	SELECT Customer_Name, Amount, Order_Date,
		   AVG(Amount) OVER(PARTITION BY Customer_Name) AS Average,
		   ROW_NUMBER() OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date DESC) AS Row_Num
	FROM Sales_Records
)
SELECT Customer_Name, Amount, Average
FROM CTE
WHERE RoW_Num = 1 
AND	Amount > Average;


-- Q2
-- Show top 2 products per city based on total sales

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY City
           ORDER BY Total_Amount DESC) AS D_Rank
	FROM (
		SELECT S.Product, C.City,
			   SUM(S.Amount) AS Total_Amount
		FROM Customer_Info C
        INNER JOIN Sales_Records S
			ON C.Customer_Name = S.Customer_Name
        GROUP BY S.Product, C.City
	)T
)D
WHERE D_Rank <= 2;


-- Q3
-- Find customers whose spending increased for
-- 2 consecutive orders

WITH CTE AS (
	SELECT Customer_Name, Amount, Order_Date,
		   LAG(Amount, 1) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous1,
           LAG(Amount, 2) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous2
	FROM Sales_Records
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous1 IS NOT NULL
AND Previous2 IS NOT NULL
AND Amount > Previous1
AND Previous1 > Previous2;


-- Q4
-- Find customers who purchased on 3 consecutive days
-- and whose running total crossed 50000

WITH CTE AS (
	SELECT Customer_Name, Amount, Order_Date,
		   SUM(Amount) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Running_Total,
		   LAG(Order_Date, 1) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous1,
           LAG(Order_Date, 2) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous2
	FROM Sales_Records
)
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous1 IS NOT NULL
AND   Previous2 IS NOT NULL
AND DATEDIFF(Order_Date, Previous1) = 1
AND DATEDIFF(Previous1, Previous2) = 1
AND Running_Total > 50000;


-- Q5
-- Show products whose latest sale amount is the
-- highest sale amount for that product

WITH CTE AS (
	SELECT Product, Amount, Order_Date,
		   ROW_NUMBER() OVER(PARTITION BY Product
           ORDER BY Order_Date DESC) AS Row_Num
	FROM Sales_Records
),
CTE2 AS (
	SELECT Product,
		   MAX(Amount) AS Highest_Amount
	FROM CTE
    GROUP BY Product
)
SELECT L.Product, L.Amount, M.Highest_Amount
FROM CTE L
INNER JOIN CTE2 M
	ON L.Product = M.Product
WHERE L.Row_Num = 1
AND L.Amount = M.Highest_Amount;


-- Q6 (boss 😏)
-- Find customers whose every next order amount
-- is greater than previous order amount
-- AND total spending is above city average

WITH CTE AS (
    SELECT C.Customer_Name, C.City, S.Amount, S.Order_Date,
           LAG(S.Amount) OVER(PARTITION BY C.Customer_Name
		   ORDER BY S.Order_Date) AS Previous_Amount
    FROM Customer_Info C
    INNER JOIN Sales_Records S
        ON C.Customer_Name = S.Customer_Name
),
CTE2 AS (
    SELECT Customer_Name, City
    FROM CTE
    GROUP BY Customer_Name, City
    HAVING COUNT(*) = COUNT(
        CASE
            WHEN Previous_Amount IS NULL
                 OR Amount > Previous_Amount
            THEN 1
        END
    )
),
CTE3 AS (
    SELECT C.Customer_Name, C.City,
           SUM(S.Amount) AS Total_Spent
    FROM Customer_Info C
    INNER JOIN Sales_Records S
        ON C.Customer_Name = S.Customer_Name
    GROUP BY C.Customer_Name, C.City
),
CTE4 AS (
    SELECT City,
           AVG(Total_Spent) AS Avg_City_Spent
    FROM CTE3
    GROUP BY City
)
SELECT C3.Customer_Name,
       C3.City,
       C3.Total_Spent,
       C4.Avg_City_Spent
FROM CTE3 C3
INNER JOIN CTE4 C4
    ON C3.City = C4.City
INNER JOIN CTE2 C2
    ON C3.Customer_Name = C2.Customer_Name
WHERE C3.Total_Spent > C4.Avg_City_Spent;