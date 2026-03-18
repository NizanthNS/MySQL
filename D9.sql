SELECT *
FROM Customers;


SELECT *
FROM Orders;


SELECT *
FROM Products;


-- Show each order with a row number (ordered by order_id).

SELECT *,
ROW_NUMBER() OVER(ORDER BY Order_ID) AS Row_Num
FROM Orders;


-- Assign a rank to products based on price (highest price = rank 1).

SELECT *,
RANK() OVER(ORDER BY Price DESC) AS Price_Rank
FROM Products;


-- Show each customer’s orders with row numbers per customer.

SELECT Customers.Customer_ID,
	   Customers.Customer_Name,
	   ROW_NUMBER() OVER(PARTITION BY Orders.Customer_ID 
       ORDER BY Orders.Order_ID) AS Orders
FROM Customers
INNER JOIN Orders
	ON Customers.Customer_ID = Orders.Customer_ID;


-- Find the most expensive product using RANK().

SELECT *
	FROM (
		SELECT *,
		RANK() OVER(ORDER BY Price DESC) AS RANK_By_Price
		FROM Products
		) R
    WHERE RANK_By_Price = 1;

-- Show top 2 most expensive products.

SELECT *
	FROM (
		SELECT *,
		ROW_NUMBER() OVER(ORDER BY Price DESC) AS RANK_By_Price
		FROM Products
		) R
    WHERE RANK_By_Price <= 2;
    

-- Show the highest quantity order for each customer.

SELECT Customer_ID,
       Customer_Name,
       Order_ID,
       Quantity
FROM (
    SELECT Customers.Customer_ID,
           Customers.Customer_Name,
           Orders.Order_ID,
           Orders.Quantity,
           ROW_NUMBER() OVER(PARTITION BY Orders.Customer_ID
		   ORDER BY Orders.Quantity DESC
           ) AS Row_Num
    FROM Customers
    INNER JOIN Orders
        ON Customers.Customer_ID = Orders.Customer_ID
) T
WHERE Row_Num = 1;

-- OR

SELECT *
FROM
	(
	SELECT *,
    RANK() OVER(PARTITION BY Customer_ID
    ORDER BY Quantity DESC) AS Highest_Quantity
    FROM Orders
    ) H
WHERE Highest_Quantity = 1;

-- Show each product with its price and the average product price.

SELECT *,
	AVG(Price) OVER() AS Average_Price
	FROM Products;


-- Show products where price is above average using window function.

SELECT *
	FROM
    (
		SELECT *,
		AVG(Price) OVER() AS Average_Price
		FROM Products
	) A
    WHERE Price > Average_Price;

-- Rank customers based on total spending.

SELECT *,
	RANK() OVER(ORDER BY Total_Spent DESC) AS Rank_
FROM (
	SELECT Customers.Customer_ID,
		   Customers.Customer_Name,
           SUM(Orders.Quantity * Products.Price) AS Total_spent
	FROM Customers
    INNER JOIN Orders
		ON Customers.Customer_ID = Orders.Customer_ID
	INNER JOIN Products
		ON Orders.Product_ID = Products.Product_ID
	GROUP BY Customers.Customer_ID, Customers.Customer_Name
	) T;


-- Show the top spending customer per city.

SELECT *
FROM (
    SELECT Customers.City,
           Customers.Customer_Name,
           Customers.Customer_ID,
           SUM(Orders.Quantity * Products.Price) AS Total_Spent,
           RANK() OVER (PARTITION BY Customers.City
		   ORDER BY SUM(Orders.Quantity * Products.Price) DESC) AS Rank_
    FROM Customers
    INNER JOIN Orders
        ON Customers.Customer_ID = Orders.Customer_ID
    INNER JOIN Products
        ON Orders.Product_ID = Products.Product_ID
    GROUP BY Customers.City, Customers.Customer_Name, Customers.Customer_ID
) T
WHERE Rank_ = 1;






