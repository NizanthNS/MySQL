USE Daily_SQL;


-- DATASET

CREATE TABLE Delivery_Records (
    Delivery_ID INT,
    Driver_ID INT,
    Driver_Name VARCHAR(50),
    Delivery_Date DATE,
    City VARCHAR(30),
    Delivery_Count INT,
    Delivery_Status VARCHAR(20)
);

INSERT INTO Delivery_Records 
VALUES	(1,101,'Alice','2024-01-01','Chennai',12,'Completed'),
		(2,101,'Alice','2024-01-02','Chennai',10,'Completed'),
		(3,101,'Alice','2024-01-03','Chennai',15,'Completed'),
		(4,101,'Alice','2024-01-07','Madurai',8,'Completed'),

		(5,102,'Bob','2024-01-01','Coimbatore',9,'Completed'),
		(6,102,'Bob','2024-01-05','Coimbatore',11,'Completed'),
		(7,102,'Bob','2024-01-06','Coimbatore',13,'Completed'),

		(8,103,'Charlie','2024-01-02','Chennai',14,'Completed'),
		(9,103,'Charlie','2024-01-03','Chennai',12,'Completed'),
		(10,103,'Charlie','2024-01-04','Madurai',16,'Completed'),
		(11,103,'Charlie','2024-01-05','Madurai',10,'Completed'),

		(12,104,'David','2024-01-01','Trichy',7,'Completed'),
		(13,104,'David','2024-01-08','Trichy',9,'Completed'),

		(14,105,'Emma','2024-01-03','Chennai',18,'Completed'),
		(15,105,'Emma','2024-01-04','Chennai',20,'Completed'),
		(16,105,'Emma','2024-01-05','Chennai',17,'Completed');
        

SELECT *
FROM Delivery_Records;


-- Q1
-- Show each driver's total delivery records,
-- total deliveries completed, and average deliveries per record.

SELECT Driver_ID, Driver_Name,
	   COUNT(Delivery_ID) AS Total_Delivery,
       SUM(Delivery_Count) AS Total_Deliveries_Completed,
       ROUND(AVG(Delivery_Count), 2) AS Average_Deliveries
FROM Delivery_Records
GROUP BY Driver_ID, Driver_Name;


-- Q2
-- Show each city's total delivery records
-- and total deliveries completed.

SELECT City,
	   COUNT(Delivery_ID) AS Total_Delivery,
       SUM(Delivery_Count) AS Total_Deliveries_Completed
FROM Delivery_Records
GROUP BY City;


-- Q3
-- Find the top 3 drivers by total deliveries completed.

WITH CTE AS (
	SELECT Driver_ID, Driver_Name,
		   SUM(Delivery_Count) AS Total_Deliveries_Completed
	FROM Delivery_Records
	GROUP BY Driver_ID, Driver_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY 
           Total_Deliveries_Completed DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 3;


-- Q4
-- Find drivers who have a delivery record
-- within 2 days of their previous delivery.

WITH CTE AS (
	SELECT Driver_ID, Driver_Name, Delivery_Date,
		   LAG(Delivery_Date) OVER(PARTITION BY Driver_ID
           ORDER BY Delivery_Date, Delivery_ID) AS Previous
	FROM Delivery_Records
)
SELECT DISTINCT Driver_ID, Driver_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Delivery_Date, Previous) <= 2;


-- Q5
-- Find drivers whose total deliveries completed is greater
-- than the average total deliveries completed of all drivers.

WITH CTE AS (
	SELECT Driver_ID, Driver_Name,
		   SUM(Delivery_Count) AS Total_Deliveries_Completed
	FROM Delivery_Records
	GROUP BY Driver_ID, Driver_Name
)
SELECT *
FROM CTE
WHERE Total_Deliveries_Completed > (
	SELECT AVG(Total_Deliveries_Completed)
    FROM CTE
);


-- BONUS
-- Find every delivery streak for each driver.
--
-- Return:
-- Driver_ID
-- Driver_Name
-- Start_Date
-- End_Date
-- Streak_Length
--
-- Note:
-- Do NOT return only the longest streak.
-- Return all streaks.

WITH CTE AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Driver_ID
           ORDER BY Delivery_Date) AS RN
	FROM Delivery_Records
),
CTE2 AS (
	SELECT *,
		   DATE_SUB(Delivery_Date, INTERVAL RN DAY) AS Group_Key
	FROM CTE
),
CTE3 AS (
	SELECT Driver_ID, Driver_Name,
		   COUNT(*) AS Streak_Length,
           MIN(Delivery_Date) AS Start_Date,
		   MAX(Delivery_Date) AS End_Date
	FROM CTE2
    GROUP BY Driver_ID, Driver_Name, Group_Key
)
SELECT *
FROM CTE3;