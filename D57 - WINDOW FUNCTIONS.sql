USE Daily_SQL;


SELECT *
FROM Sales_Records;


-- Q1
-- Assign row number to each order per customer (by date)

SELECT Customer_Name,Order_ID, Product, Order_Date,
	   ROW_NUMBER() OVER(PARTITION BY Customer_Name
       ORDER BY Order_Date) AS Row_Num
FROM Sales_Records;


-- Q2
-- Find the first order per customer

SELECT *
FROM (
	SELECT Customer_Name,Order_ID, Product, Order_Date,
		   ROW_NUMBER() OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS RN
	FROM Sales_Records
	)R
WHERE RN = 1;


-- Q3
-- Find the last order per customer

SELECT *
FROM (
	SELECT Customer_Name, Order_ID, Product, Order_Date,
		   ROW_NUMBER() OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date DESC) AS RN
	FROM Sales_Records
	)R
WHERE RN = 1;


-- Q4
-- Rank customers based on total spending

SELECT *,
	   RANK() OVER(ORDER BY Total_Spending DESC) AS Rnk
FROM (
	SELECT Customer_Name,
		   SUM(Amount) AS Total_Spending
	FROM Sales_Records
    GROUP BY Customer_Name
)R;


-- Q5
-- Show top 3 customers (handle ties properly)

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY 
           Total_Spending DESC) AS D_Rank	
	FROM (
		SELECT Customer_Name,
			   SUM(Amount) AS Total_Spending
		FROM Sales_Records
		GROUP BY Customer_Name
		)R
	)D
WHERE D_Rank <= 3;


-- Q6
-- Show each order with previous order amount

SELECT Order_ID, Customer_Name, Amount, Order_Date,
	   LAG(Amount) OVER(PARTITION BY Customer_Name
	   ORDER BY Order_Date) AS Previous_Order_Amount
FROM Sales_Records;


-- Q7
-- Show difference between current and previous order

WITH CTE AS (
	SELECT Order_ID, Customer_Name, Amount, Order_Date,
		   LAG(Amount) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous_Order_Amount
	FROM Sales_Records
	)
SELECT *,
	   COALESCE(Amount - Previous_Order_Amount, 0) AS Difference
FROM CTE;


-- Q8
-- Show running total per customer

SELECT Customer_Name, Order_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Order_Date) AS Running_Total
FROM Sales_Records;

-- OR

SELECT Customer_Name, Order_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Order_Date
       ROWS BETWEEN UNBOUNDED 
       PRECEDING AND CURRENT ROW) AS Running_Total
FROM Sales_Records;


-- Q9 (tricky 🔥)
-- Show customers whose spending increased compared to previous order

SELECT DISTINCT Customer_Name
FROM (
	SELECT Order_ID, Customer_Name, Amount, Order_Date,
		   LAG(Amount) OVER(PARTITION BY Customer_Name
		   ORDER BY Order_Date) AS Previous_Order_Amount
	FROM Sales_Records
	)D
WHERE Amount > Previous_Order_Amount;


-- Q10 (boss level 😏)
-- Show customers with consecutive purchase days

WITH CTE AS (
	SELECT Customer_Name, Order_Date,
		   LAG(Order_Date) OVER(PARTITION BY Customer_Name
           ORDER BY Order_Date) AS Previous
	FROM Sales_Records
    )
SELECT DISTINCT Customer_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Order_Date, Previous) = 1;