USE Demo4;

SELECT *
FROM Customers;

SELECT *
FROM Orders;

SELECT *
FROM Products;


-- 1. Categorize each order as:
-- High → Amount ≥ 50000
-- Medium → Amount between 20000 and 49999
-- Low → Amount < 20000

SELECT Orders.Order_ID,
	   (Orders.Quantity * Products.Price) AS Amount,
CASE
	WHEN (Orders.Quantity * Products.Price) >= 50000 THEN 'High'
    WHEN (Orders.Quantity * Products.Price) >= 20000 THEN 'Medium'
    ELSE 'Low'
    END AS Category
FROM Orders
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID;
    

-- 2. Show total sales for each category (High / Medium / Low)

SELECT
	SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 50000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS High_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 20000 
        AND (Orders.Quantity * Products.Price) < 50000
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Medium_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) < 20000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Low_Sales
FROM Orders
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID;


-- 3. Show each customer’s High, Medium, Low spending

SELECT	Customers.Customer_ID,
		Customers.Customer_Name,
		SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 50000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS High_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 20000 
        AND (Orders.Quantity * Products.Price) < 50000
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Medium_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) < 20000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Low_Sales
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Customers.Customer_ID,
		 Customers.Customer_Name;
         

-- 4. Show customers who have spent in ALL 3 categories (High, Medium, Low)

WITH CTE AS (
SELECT	Customers.Customer_ID,
		Customers.Customer_Name,
		SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 50000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS High_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 20000 
        AND (Orders.Quantity * Products.Price) < 50000
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Medium_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) < 20000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Low_Sales
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Customers.Customer_ID,
		 Customers.Customer_Name
)
SELECT *
FROM CTE
WHERE High_Sales > 0 AND
	  Medium_Sales > 0 AND
      Low_Sales > 0;


-- 5. Show % of High, Medium, Low spending per customer

WITH CTE AS (
SELECT	Customers.Customer_ID,
		Customers.Customer_Name,
		SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 50000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS High_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) >= 20000 
        AND (Orders.Quantity * Products.Price) < 50000
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Medium_Sales,
    SUM(
		CASE WHEN (Orders.Quantity * Products.Price) < 20000 
        THEN	(Orders.Quantity * Products.Price)
        ELSE	0
	END ) AS Low_Sales
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID
INNER JOIN Products
	ON Orders.Product_ID = Products.Product_ID
GROUP BY Customers.Customer_ID,
		 Customers.Customer_Name
)
SELECT Customer_ID,
	   Customer_Name,
	   (High_Sales * 100.0) / 
	   (High_Sales + Medium_Sales + Low_Sales) AS High_Percentage,
	   (Medium_Sales * 100.0) / 
	   (High_Sales + Medium_Sales + Low_Sales) AS Medium_Percentage,
	   (Low_Sales * 100.0) / 
       (High_Sales + Medium_Sales + Low_Sales) AS Low_Percentage
FROM CTE;






                  
	
       






