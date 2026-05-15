USE Daily_SQL;


CREATE TABLE Online_Customers (
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Online_Customers
VALUES  (1, 'Arun',    'Chennai'),
        (2, 'Meena',   'Bangalore'),
        (3, 'Ravi',    'Hyderabad'),
        (4, 'Priya',   'Pune'),
        (5, 'Divya',   'Chennai');
        

CREATE TABLE Store_Customers (
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Store_Customers
VALUES  (4, 'Priya',   'Pune'),
        (5, 'Divya',   'Chennai'),
        (6, 'Sanjay',  'Mumbai'),
        (7, 'Nisha',   'Delhi'),
        (8, 'Vikram',  'Hyderabad');
        

SELECT *
FROM Online_Customers;

SELECT *
FROM Store_Customers;


-- Day 6 : UNION + UNION ALL


-- Q1
-- Show all customers from both tables
-- without duplicates.

SELECT Customer_ID, Customer_Name
FROM Online_Customers

UNION

SELECT Customer_ID, Customer_Name
FROM Store_Customers;


-- Q2
-- Show all customers from both tables
-- including duplicates.

SELECT Customer_ID, Customer_Name
FROM Online_Customers

UNION ALL

SELECT Customer_ID, Customer_Name
FROM Store_Customers;


-- Q3
-- Show only Customer_Name and City
-- from both tables without duplicates.

SELECT Customer_Name, City
FROM Online_Customers

UNION

SELECT Customer_Name, City
FROM Store_Customers;


-- Q4
-- Find all unique cities from both tables.

SELECT City
FROM Online_Customers

UNION

SELECT City
FROM Store_Customers;


-- Q5
-- Show all customer records from both tables
-- ordered by Customer_Name ascending.

SELECT *
FROM Online_Customers

UNION ALL

SELECT *
FROM Store_Customers
ORDER BY Customer_Name;


-- Q6
-- Find how many total customer rows exist
-- when combining both tables including duplicates.

SELECT COUNT(*) AS Total_Rows
FROM (
	SELECT *
	FROM Online_Customers

	UNION ALL

	SELECT *
	FROM Store_Customers
)U;


-- Bonus Debugging Question

SELECT Customer_ID, Customer_Name
FROM Online_Customers

UNION

SELECT Customer_ID
FROM Store_Customers;

-- What is wrong with this query?
-- Rewrite it correctly.

-- ANSWER

SELECT Customer_ID, Customer_Name
FROM Online_Customers

UNION

SELECT Customer_ID, Customer_Name
FROM Store_Customers;