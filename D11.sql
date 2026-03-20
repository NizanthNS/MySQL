SELECT *
FROM Customers;

SELECT *
FROM Orders;

SELECT *
FROM Products;


-- 1. Show the lowest priced product in each city (based on orders).

SELECT *
FROM (
	SELECT Customers.City,
		   Orders.Order_ID,
           Products.Product_Name,
           Products.Price,
           RANK() OVER(PARTITION BY Customers.City
           ORDER BY Products.Price ASC) AS RanK_
	FROM Customers
    INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Products
		ON Orders.Product_ID = Products.Product_ID
	) T
WHERE Rank_ = 1;


-- 2. Show the top 3 customers by total spending.

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Spent DESC) AS Rank_
	FROM (
		 SELECT Customers.Customer_ID,
				Customers.Customer_Name,
                SUM(Orders.Quantity * Products.Price) AS Total_Spent
		 FROM Customers
         INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		 INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
		 GROUP BY Customers.Customer_ID, Customers.Customer_Name
		) T
	) R
WHERE Rank_ <= 3;


-- 3. Show the first order (smallest order_id) per customer.

SELECT *
FROM (
	 SELECT Customers.Customer_ID,
			Customers.Customer_Name,
            Orders.Order_ID,
            ROW_NUMBER() OVER(PARTITION BY Customers.Customer_ID
            ORDER BY Orders.Order_ID ASC) AS Row_Num
	 FROM Customers
     INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	) R
WHERE Row_Num = 1;


-- 4. Show the least frequently ordered product per customer.

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Customer_ID
           ORDER BY Total ASC) AS Rank_
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Customer_Name,
               Products.Product_Name,
               COUNT(Orders.Order_ID) AS Total
		FROM Customers
        INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
		GROUP BY Customers.Customer_ID, Customers.Customer_Name, Products.Product_Name
		)T
	)R
WHERE Rank_ = 1;


-- 5. Show the customer with the lowest total spending overall.

SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(ORDER BY Total_Spent ASC) AS Row_Num
	FROM (
		SELECT Customers.Customer_ID,
			   Customers.Customer_Name,
               SUM(Orders.Quantity * Products.Price) AS Total_Spent
		FROM Customers
        INNER JOIN Orders
			ON Customers.Customer_ID = Orders.Customer_ID
		INNER JOIN Products
			ON Orders.Product_ID = Products.Product_ID
		GROUP BY Customers.Customer_ID, Customers.Customer_Name
		)T
	)R
WHERE Row_Num = 1;

