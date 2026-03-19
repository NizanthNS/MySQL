SELECT *
FROM Customers;


SELECT *
FROM Orders;


SELECT *
FROM Products;


-- 1. Show the highest priced product in each city based on orders.

SELECT *
FROM (
	SELECT Customers.City,
           Customers.Customer_Name,
		   Products.Product_Name,
		   Products.Price,
           RANK() OVER(PARTITION BY Customers.City 
           ORDER BY Products.Price DESC) AS Rank_
	FROM Customers
    INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Products
		ON Orders.Product_ID = Products.Product_ID
        ) R
WHERE Rank_ = 1;

-- 2. Show the top 2 customers by total quantity ordered.

SELECT *
FROM (
	SELECT Customers.Customer_ID,
		   Customers.Customer_Name,
           SUM(Orders.Quantity) AS Total_Quantity,
           RANK() OVER(ORDER BY SUM(Orders.Quantity) DESC) AS Top
	FROM Customers
    INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	GROUP BY Customers.Customer_ID, Customers.Customer_Name
    ) T
WHERE Top <=2;

-- OR

SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY Total_Quantity DESC) AS Top
    FROM (
        SELECT Customers.Customer_ID,
               Customers.Customer_Name,
               SUM(Orders.Quantity) AS Total_Quantity
        FROM Customers
        INNER JOIN Orders
            ON Customers.Customer_ID = Orders.Customer_ID
        GROUP BY Customers.Customer_ID, Customers.Customer_Name
    ) T
) R
WHERE Top <= 2;


-- 3. Show the latest order per customer.


SELECT *
FROM (
	SELECT Customers.Customer_ID,
		   Customers.Customer_Name,
           Orders.Order_ID,
           ROW_NUMBER() OVER(PARTITION BY Orders.Customer_ID 
		   ORDER BY Orders.Order_ID DESC) AS Row_Num
	FROM Customers
	INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	) R
WHERE Row_Num = 1;


-- 4. Show the most frequently ordered product per customer.

SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Customer_ID
           ORDER BY Total_Orders DESC) AS Rank_
    FROM (
        SELECT Customers.Customer_ID,
               Customers.Customer_Name,
               Products.Product_Name,
               COUNT(Orders.Order_ID) AS Total_Orders
        FROM Customers
        INNER JOIN Orders
            ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
        GROUP BY Customers.Customer_ID, Customers.Customer_Name, Products.Product_Name
    ) T
) R
WHERE Rank_ = 1;


-- 5. Show the top spending customer overall using ROW_NUMBER().

SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(ORDER BY Total_Price DESC) AS Row_Num
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Customer_Name,
               SUM(Orders.Quantity * Products.Price) AS Total_Price
		FROM Customers
        INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
		GROUP BY Customers.Customer_ID, Customers.Customer_Name
        ) T
	) R
WHERE Row_Num = 1;


