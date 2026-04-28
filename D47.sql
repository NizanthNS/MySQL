CREATE TABLE Orders_Data (
    Order_ID INT,
    Customer_Name VARCHAR(50),
    Order_Date DATE,
    Amount INT
);

INSERT INTO Orders_Data 
VALUES
(1, 'Arun',  '2024-01-01', 20000),
(2, 'Arun',  '2024-01-10', 15000),
(3, 'Arun',  '2024-02-05', 20000),
(4, 'Meena', '2024-01-03', 30000),
(5, 'Meena', '2024-01-20', 25000),
(6, 'Meena', '2024-03-01', 10000),
(7, 'Ravi',  '2024-01-02', 40000),
(8, 'Ravi',  '2024-02-15', 10000),
(9, 'Priya', '2024-01-05', 25000),
(10,'Priya', '2024-01-25', 30000);

SELECT *
FROM Orders_Data ;


-- Find total amount spent by each customer

SELECT Customer_Name, SUM(Amount) AS Total_Spent
FROM Orders_Data
GROUP BY Customer_Name;


-- Find the number of orders for each customer

SELECT Customer_Name, COUNT(*) AS Order_Count
FROM Orders_Data
GROUP BY Customer_Name;


-- Find the highest order amount

SELECT MAX(Amount) AS Highest_Amount
FROM Orders_Data;


-- Find all orders placed in January 2024

SELECT *
FROM Orders_Data
WHERE Order_Date BETWEEN '2024-01-01' AND '2024-01-31';


-- Find the latest order date for each customer

SELECT Customer_Name, MAX(Order_Date) AS Latest_Order
FROM Orders_Data
GROUP BY Customer_Name;