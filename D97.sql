USE Daily_SQL;


-- DATASET

CREATE TABLE App_Usage (
    Usage_ID INT,
    User_ID INT,
    User_Name VARCHAR(50),
    Usage_Date DATE,
    Feature_Name VARCHAR(50),
    Minutes_Used INT,
    Device_Type VARCHAR(20)
);

INSERT INTO App_Usage 
VALUES	(1,101,'Alice','2024-01-01','Chat',45,'Mobile'),
		(2,101,'Alice','2024-01-02','Chat',30,'Mobile'),
		(3,101,'Alice','2024-01-03','Video Call',60,'Desktop'),
		(4,101,'Alice','2024-01-07','Chat',20,'Mobile'),

		(5,102,'Bob','2024-01-01','Video Call',40,'Desktop'),
		(6,102,'Bob','2024-01-05','Chat',35,'Mobile'),
		(7,102,'Bob','2024-01-06','File Share',50,'Desktop'),

		(8,103,'Charlie','2024-01-02','Chat',70,'Mobile'),
		(9,103,'Charlie','2024-01-03','Video Call',55,'Desktop'),
		(10,103,'Charlie','2024-01-04','File Share',65,'Desktop'),
		(11,103,'Charlie','2024-01-05','Chat',45,'Mobile'),

		(12,104,'David','2024-01-01','Chat',25,'Mobile'),
		(13,104,'David','2024-01-08','Video Call',30,'Desktop'),

		(14,105,'Emma','2024-01-03','File Share',80,'Desktop'),
		(15,105,'Emma','2024-01-04','Chat',75,'Mobile'),
		(16,105,'Emma','2024-01-05','Video Call',90,'Desktop');
        

SELECT *
FROM App_Usage;


-- Q1
-- Show each user's total usage records,
-- total minutes used, and average minutes used.
--
-- Return:
-- User_ID
-- User_Name
-- Total_Usage_Records
-- Total_Minutes_Used
-- Average_Minutes_Used

SELECT User_ID, User_Name,
	   COUNT(Usage_ID) AS Total_Usage_Records,
       SUM(Minutes_Used) Total_Minutes_Used,
       ROUND(AVG(Minutes_Used), 2) Average_Minutes_Used
FROM App_Usage
GROUP BY User_ID, User_Name;


-- Q2
-- Show each feature's total usage records
-- and total minutes used.
--
-- Return:
-- Feature_Name
-- Total_Usage_Records
-- Total_Minutes_Used

SELECT Feature_Name,
	   COUNT(Usage_ID) AS Total_Usage_Records,
       SUM(Minutes_Used) Total_Minutes_Used
FROM App_Usage
GROUP BY Feature_Name;


-- Q3
-- Find the top 3 users by total minutes used.
--
-- Return:
-- User_ID
-- User_Name
-- Total_Minutes_Used

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Minutes_Used DESC) AS D_Rank
	FROM (
		SELECT User_ID, User_Name,
			   SUM(Minutes_Used) Total_Minutes_Used
		FROM App_Usage
		GROUP BY User_ID, User_Name
	)D
)T
WHERE D_Rank <= 3;


-- Q4
-- Find users who used the app within 2 days
-- of their previous usage.
--
-- Return:
-- User_ID
-- User_Name

WITH CTE AS (
	SELECT User_ID, User_Name, Usage_Date,
		   LAG(Usage_Date) OVER(PARTITION BY User_ID
           ORDER BY Usage_Date, Usage_ID) AS  Previous
	FROM App_Usage
)
SELECT DISTINCT User_ID, User_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Usage_Date, Previous) <= 2;


-- Q5
-- Find users whose total minutes used is greater
-- than the average total minutes used of all users.
--
-- Return:
-- User_ID
-- User_Name
-- Total_Minutes_Used

SELECT User_ID, User_Name,
       SUM(Minutes_Used) Total_Minutes_Used
FROM App_Usage
GROUP BY User_ID, User_Name
HAVING SUM(Minutes_Used) > (
	SELECT AVG(Total_Minutes_Used)
    FROM (
		SELECT User_ID, User_Name,
			   SUM(Minutes_Used) Total_Minutes_Used
		FROM App_Usage
		GROUP BY User_ID, User_Name
	)A
);


-- BONUS
-- Find the start date and end date of each user's
-- longest streak.
--
-- Return:
-- User_ID
-- User_Name
-- Longest_Streak
-- Start_Date
-- End_Date

WITH CTE AS (
	SELECT DISTINCT User_ID, User_Name, Usage_Date
    FROM App_Usage
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY User_ID
           ORDER BY Usage_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Usage_Date, INTERVAL RN DAY) AS GP
	FROM CTE2
),
CTE4 AS (
	SELECT User_ID, User_Name,
		   COUNT(*) AS Streak,
		   MIN(Usage_Date) AS Start_Date,
           MAX(Usage_Date) AS End_Date
	FROM CTE3
    GROUP BY User_ID, User_Name, GP
)
SELECT *
FROM (
	SELECT User_ID, User_Name, Start_Date,
		   End_Date, Streak AS Longest_Streak,
		   ROW_NUMBER() OVER(PARTITION BY  User_ID
           ORDER BY Streak DESC, End_Date DESC) AS RN
	FROM CTE4
)R
WHERE RN = 1;