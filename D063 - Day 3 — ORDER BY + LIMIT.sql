USE Daily_SQL;


CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(50),
    Category VARCHAR(50),
    Price INT,
    Stock INT,
    Rating DECIMAL(2,1)
);

INSERT INTO Products
VALUES  (1, 'Laptop',      'Electronics', 75000, 15, 4.5),
        (2, 'Mobile',      'Electronics', 45000, 30, 4.7),
        (3, 'Chair',       'Furniture',   7000,  20, 4.1),
        (4, 'Table',       'Furniture',   12000, 10, 4.3),
        (5, 'T-Shirt',     'Clothing',    1500,  50, 4.0),
        (6, 'Jeans',       'Clothing',    2500,  40, 4.4),
        (7, 'Headphones',  'Electronics', 3000,  25, 4.6),
        (8, 'Sofa',        'Furniture',   35000, 5,  4.8),
        (9, 'Jacket',      'Clothing',    4000,  18, 4.2),
        (10,'Watch',       'Accessories', 8000,  12, 4.5);
        
	
SELECT *
FROM Products;


-- Day 3 : ORDER BY + LIMIT


-- Q1
-- Display all products ordered by Price in ascending order.

SELECT Product_ID, Product_Name, Price
FROM Products
ORDER BY Price ASC;


-- Q2
-- Display all products ordered by Rating in descending order.

SELECT Product_ID, Product_Name, Rating
FROM Products
ORDER BY Rating DESC;


-- Q3
-- Show the top 3 most expensive products.

SELECT Product_ID, Product_Name, Price
FROM Products
ORDER BY Price DESC
LIMIT 3;


-- Q4
-- Show the 2 products with the lowest Stock.

SELECT Product_ID, Product_Name, Stock
FROM Products
ORDER BY Stock ASC
LIMIT 2;


-- Q5
-- Display products ordered by:
-- 1. Category in ascending order
-- 2. Price in descending order

SELECT Product_Name, Category, Price
FROM Products
ORDER BY Category ASC, Price DESC;


-- Q6
-- Show the second highest priced product.

SELECT Product_Name, Price
FROM Products
ORDER BY Price DESC
LIMIT 1 OFFSET 1;


-- Bonus Debugging Question

SELECT *
FROM Products
LIMIT 3
ORDER BY Price DESC;

-- What is wrong with this query?
-- Rewrite it correctly.

-- ANSWER

SELECT *
FROM Products
ORDER BY Price DESC
LIMIT 3;