USE Daily_SQL;

-- DATASET

CREATE TABLE Food_Orders (
    Order_ID INT,
    Customer_ID INT,
    Customer_Name VARCHAR(50),
    Order_Date DATE,
    Restaurant_Name VARCHAR(50),
    Order_Amount INT,
    Order_Status VARCHAR(20)
);

INSERT INTO Food_Orders 
VALUES	(1,101,'Alice','2024-01-01','Burger Hub',450,'Delivered'),
		(2,101,'Alice','2024-01-02','Burger Hub',300,'Delivered'),
		(3,101,'Alice','2024-01-03','Pizza Point',600,'Delivered'),
		(4,101,'Alice','2024-01-07','Pizza Point',500,'Cancelled'),

		(5,102,'Bob','2024-01-01','Burger Hub',350,'Delivered'),
		(6,102,'Bob','2024-01-05','Taco Town',400,'Delivered'),
		(7,102,'Bob','2024-01-06','Taco Town',450,'Delivered'),

		(8,103,'Charlie','2024-01-02','Pizza Point',700,'Delivered'),
		(9,103,'Charlie','2024-01-03','Pizza Point',650,'Delivered'),
		(10,103,'Charlie','2024-01-04','Pizza Point',500,'Delivered'),
		(11,103,'Charlie','2024-01-10','Burger Hub',300,'Delivered'),

		(12,104,'David','2024-01-01','Taco Town',250,'Delivered'),
		(13,104,'David','2024-01-08','Burger Hub',450,'Delivered'),

		(14,105,'Emma','2024-01-03','Pizza Point',800,'Delivered'),
		(15,105,'Emma','2024-01-04','Pizza Point',750,'Delivered'),
		(16,105,'Emma','2024-01-05','Pizza Point',900,'Delivered');
        

SELECT *
FROM Food_Orders;

-- Q1
-- Show each customer's total orders, total amount spent,
-- and average order amount.

SELECT Customer_ID, Customer_Name,
	   COUNT(Order_ID) AS Total_Orders,
       SUM(Order_Amount) AS Total_Amount,
       ROUND(AVG(Order_Amount), 2) AS Average_Amount
FROM Food_Orders
GROUP BY Customer_ID, Customer_Name;


-- Q2
-- Show each restaurant's total orders and total revenue.

SELECT Restaurant_Name,
	   COUNT(Order_ID) AS Total_Orders,
       SUM(Order_Amount) AS Total_Amount
FROM Food_Orders
GROUP BY Restaurant_Name;


-- Q3
-- Find the top 3 customers by total amount spent.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name,
		   SUM(Order_Amount) AS Total_Amount_Spent
	FROM Food_Orders
	GROUP BY Customer_ID, Customer_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Amount_Spent DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 3;


-- Q4
-- Find customers who placed an order within 2 days
-- of their previous order.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name, Order_Date,
		   LAG(Order_Date) OVER(PARTITION BY Customer_ID
		   ORDER BY Order_Date, Order_ID) AS Previous
	FROM Food_Orders
)
SELECT DISTINCT Customer_ID, Customer_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Order_Date, Previous) <= 2;


-- Q5
-- Find customers whose total spending is greater than
-- the average spending of all customers.

WITH CTE AS (
	SELECT Customer_ID, Customer_Name,
		   SUM(Order_Amount) AS Total_Amount_Spent
	FROM Food_Orders
	GROUP BY Customer_ID, Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Amount_Spent > (
	SELECT AVG(Total_Amount_Spent)
    FROM CTE
);


-- BONUS
-- Find each customer's longest consecutive ordering streak.
--
-- Example:
-- Orders on Jan 1, Jan 2, Jan 3 = streak of 3 days.
-- Orders on Jan 5, Jan 6 = streak of 2 days.
--
-- Return:
-- Customer_ID
-- Customer_Name
-- Longest_Streak

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY Customer_ID
		   ORDER BY Order_Date) AS RN
    FROM Food_Orders
),
CTE2 AS (
	SELECT *,
		   DATE_SUB(Order_Date, INTERVAL RN DAY) AS Group_Key
	FROM CTE
),
CTE3 AS (
	SELECT Customer_ID, Customer_Name,
		   COUNT(*) AS Streak
	FROM CTE2
    GROUP BY Customer_ID, Customer_Name, Group_Key
)
SELECT DISTINCT Customer_ID, Customer_Name,
	   MAX(Streak) AS Longest_Streak
FROM CTE3
GROUP BY Customer_ID, Customer_Name;