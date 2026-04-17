CREATE TABLE Orders_Data (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Product VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Orders_Data 
VALUES  
    (1, 'Arun', 'Laptop',   '2024-01-01', 50000),
    (2, 'Arun', 'Mouse',    '2024-01-02', 2000),
    (3, 'Arun', 'Keyboard', '2024-01-03', 3000),
    (4, 'Meena','Laptop',   '2024-01-01', 55000),
    (5, 'Meena','Mouse',    '2024-01-04', 2500),
    (6, 'Ravi', 'Keyboard', '2024-01-02', 4000),
    (7, 'Ravi', 'Mouse',    '2024-01-05', 1500),
    (8, 'Priya','Laptop',   '2024-01-06', 60000);
    
SELECT *
FROM Orders_Data;


-- Q1
-- Show customer_name, order_date, amount,
-- and running total per customer

SELECT Customer_Name, Order_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
       ORDER BY Order_Date) AS Running_Total
FROM Orders_Data;

-- OR

SELECT Customer_Name, Order_Date, Amount,
	   SUM(Amount) OVER(PARTITION BY Customer_Name
	   ORDER BY Order_Date ROWS BETWEEN UNBOUNDED 
       PRECEDING AND CURRENT ROW) AS Running_Total
FROM Orders_Data;


-- Q2
-- Show product and total sales

SELECT Product,
	   SUM(Amount) AS Total_Sales
FROM Orders_Data
GROUP BY Product
ORDER BY Total_Sales DESC;


-- Q3 (Debug 🚨)
-- What is wrong? Fix it.

SELECT customer_name,
       product,
       SUM(amount) AS total
FROM orders_data
GROUP BY customer_name;

-- Answer

SELECT Customer_Name,
       Product,
       SUM(Amount) AS Total
FROM Orders_Data
GROUP BY Customer_Name, Product;


-- Q4 (Trap)
-- Show each order and rank orders per product (highest first)

SELECT Order_ID, Product, Amount,
	   RANK() OVER(PARTITION BY Product
       ORDER BY Amount DESC) AS Rank_
FROM Orders_Data;


-- Q5 (Both + Debug 🚨)
-- What is wrong? Fix it.

SELECT customer_name,
       SUM(amount) AS total_sales,
       RANK() OVER(PARTITION BY product ORDER BY total_sales DESC) AS rank_
FROM orders_data
GROUP BY customer_name;

-- Answer

SELECT *,
	   RANK() OVER(PARTITION BY Product
       ORDER BY Total_Sales DESC) AS Rank_
FROM (
	SELECT Customer_Name,
		   Product,
		   SUM(Amount) AS Total_Sales
	FROM Orders_Data
    GROUP BY Customer_Name, Product
)T;

-- OR

WITH CTE AS (
	SELECT Customer_Name,
		   Product,
		   SUM(Amount) AS Total_Sales
	FROM Orders_Data
    GROUP BY Customer_Name, Product
)
SELECT *,
	   RANK() OVER(PARTITION BY Product
       ORDER BY Total_Sales DESC) AS Rank_
FROM CTE;

-- Q6 (Final)
-- Show orders where amount is greater than average amount of that product

WITH CTE AS (
	SELECT Order_ID, Product, Amount,
		   AVG(Amount) OVER(PARTITION BY Product) AS Average
	FROM Orders_Data
)
SELECT *
FROM CTE
WHERE Amount > Average;

-- OR

SELECT Order_ID,
       Product,
       Amount
FROM Orders_Data O1
WHERE Amount > (
    SELECT AVG(Amount)
    FROM Orders_Data O2
    WHERE O1.Product = O2.Product
);
		