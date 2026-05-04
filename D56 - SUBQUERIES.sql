USE Daily_SQL;

SELECT *
FROM Customer_Info;

SELECT *
FROM Sales_Records;


-- Q1
-- Show customers whose total spending is greater than 
-- average total spending of all customers

SELECT C.Customer_Name,
	   SUM(S.Amount) AS Total_Amount
FROM Customer_Info C
INNER JOIN Sales_Records S
	ON C.Customer_Name = S.Customer_Name
GROUP BY C.Customer_Name
HAVING SUM(S.Amount) > (
	SELECT AVG(Total_Amount)
    FROM (
		SELECT C.Customer_Name,
			   SUM(S.Amount) AS Total_Amount
		FROM Customer_Info C
		INNER JOIN Sales_Records S
			ON C.Customer_Name = S.Customer_Name
		GROUP BY C.Customer_Name
	)A
);
	

-- Q2
-- Show customers who have made more orders than the 
-- average number of orders

SELECT C.Customer_Name,
	   COUNT(S.Order_ID) AS Total_Orders
FROM Customer_Info C
INNER JOIN Sales_Records S
	ON C.Customer_Name = S.Customer_Name
GROUP BY C.Customer_Name
HAVING COUNT(S.Order_ID) > (
	SELECT AVG(Total_Orders)
    FROM (
		SELECT C.Customer_Name,
			   COUNT(S.Order_ID) AS Total_Orders
		FROM Customer_Info C
		INNER JOIN Sales_Records S
			ON C.Customer_Name = S.Customer_Name
		GROUP BY C.Customer_Name
	)A
);


-- Q3
-- Show products whose total sales amount is greater than 
-- average product sales

SELECT Product,
	   SUM(Amount) AS Total_Sales
FROM Sales_Records
GROUP BY Product
HAVING SUM(Amount) > (
	SELECT AVG(Total_Sales)
    FROM (
		SELECT Product,
			   SUM(Amount) AS Total_Sales
		FROM Sales_Records
		GROUP BY Product
	)A
);


-- Q4
-- Show customers who have spent more than the highest spending 
-- customer from Chennai

SELECT C.Customer_Name,
	   SUM(S.Amount) AS Total_Amount
FROM Customer_Info C
INNER JOIN Sales_Records S
	ON C.Customer_Name = S.Customer_Name
GROUP BY C.Customer_Name
HAVING SUM(S.Amount) > (
	SELECT MAX(Total_Amount)
    FROM (
		SELECT C.Customer_Name,
			   SUM(S.Amount) AS Total_Amount
		FROM Customer_Info C
		INNER JOIN Sales_Records S
			ON C.Customer_Name = S.Customer_Name
		WHERE C.City = 'Chennai'
		GROUP BY C.Customer_Name
	)A
);  
	


-- Q5
-- Show customers whose total spending is less than 
-- the minimum spending of any Mumbai customer

SELECT C.Customer_Name,
	   SUM(S.Amount) AS Total_Amount
FROM Customer_Info C
INNER JOIN Sales_Records S
	ON C.Customer_Name = S.Customer_Name
GROUP BY C.Customer_Name
HAVING SUM(S.Amount) < (
	SELECT MIN(Total_Amount)
    FROM (
		SELECT C.Customer_Name,
			   SUM(S.Amount) AS Total_Amount
		FROM Customer_Info C
		INNER JOIN Sales_Records S
			ON C.Customer_Name = S.Customer_Name
		WHERE C.City = 'Mumbai'
		GROUP BY C.Customer_Name
	)M
); 


-- Q6 (correlated 🔥)
-- Show customers who have at least one order greater 
-- than their own average order amount

SELECT DISTINCT Customer_Name
FROM Sales_Records S
WHERE S.Amount > (
	SELECT AVG(Amount)
    FROM Sales_records
    WHERE Customer_Name = S.Customer_Name
);


-- Q7 (EXISTS concept 🚀)
-- Show customers who have made at least one purchase

SELECT C.Customer_Name
FROM Customer_Info C
WHERE EXISTS (
    SELECT 1
    FROM Sales_Records S
    WHERE S.Customer_Name = C.Customer_Name
);


-- Q8 (NOT EXISTS 🔥)
-- Show customers who have never made a purchase

SELECT C.Customer_Name
FROM Customer_Info C
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales_Records S
    WHERE S.Customer_Name = C.Customer_Name
);


-- Q9 (nested 🔥)
-- Show customers whose total spending is in 
-- top 3 among all customers

SELECT Customer_Name, Total_Spent
FROM (
    SELECT Customer_Name,
           SUM(Amount) AS Total_Spent
    FROM Sales_Records
    GROUP BY Customer_Name
) T1
WHERE (
    SELECT COUNT(DISTINCT T2.Total_Spent)
    FROM (
        SELECT Customer_Name,
               SUM(Amount) AS Total_Spent
        FROM Sales_Records
        GROUP BY Customer_Name
    ) T2
    WHERE T2.Total_Spent > T1.Total_Spent
) < 3;


-- Q10 (boss level 😏)
-- Show customers whose average order amount is greater 
-- than the overall average order amount

SELECT DISTINCT Customer_Name
FROM (
    SELECT Customer_Name,
           AVG(Amount) OVER(PARTITION BY Customer_Name) AS Average
    FROM Sales_Records
) A
WHERE Average > (
    SELECT AVG(Amount)
    FROM Sales_Records
);