USE Daily_SQL;

-- DATASET

CREATE TABLE Website_Activity (
    Activity_ID INT,
    User_ID INT,
    User_Name VARCHAR(50),
    Activity_Date DATE,
    Page_Name VARCHAR(50),
    Session_Minutes INT,
    Device VARCHAR(20)
);

INSERT INTO Website_Activity 
VALUES	(1,101,'Alice','2024-01-01','Home',20,'Mobile'),
		(2,101,'Alice','2024-01-02','Products',35,'Mobile'),
		(3,101,'Alice','2024-01-03','Checkout',25,'Desktop'),
		(4,101,'Alice','2024-01-07','Home',15,'Mobile'),

		(5,102,'Bob','2024-01-01','Home',30,'Desktop'),
		(6,102,'Bob','2024-01-05','Products',40,'Desktop'),
		(7,102,'Bob','2024-01-06','Checkout',20,'Mobile'),

		(8,103,'Charlie','2024-01-02','Home',45,'Mobile'),
		(9,103,'Charlie','2024-01-03','Products',30,'Mobile'),
		(10,103,'Charlie','2024-01-04','Checkout',50,'Desktop'),
		(11,103,'Charlie','2024-01-05','Home',35,'Desktop'),

		(12,104,'David','2024-01-01','Home',10,'Mobile'),
		(13,104,'David','2024-01-08','Products',25,'Mobile'),

		(14,105,'Emma','2024-01-03','Home',60,'Desktop'),
		(15,105,'Emma','2024-01-04','Products',45,'Desktop'),
		(16,105,'Emma','2024-01-05','Checkout',55,'Mobile');
 
SELECT *
FROM Website_Activity;
 

-- Q1
-- Show each user's total activities, total session minutes,
-- and average session minutes.

SELECT User_ID, User_Name,
	   COUNT(Activity_ID) AS Total_Activities,
       SUM(Session_Minutes) AS Total_Session_Minutes,
       ROUND(AVG(Session_Minutes), 2) AS Average_Session_Minutes
FROM Website_Activity
GROUP BY User_ID, User_Name;


-- Q2
-- Show each page's total activities and total session minutes.

SELECT Page_Name,
	   COUNT(Activity_ID) AS Total_Activities,
       SUM(Session_Minutes) AS Total_Session_Minutes
FROM Website_Activity
GROUP BY Page_Name;


-- Q3
-- Find the top 3 users by total session minutes.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY 
           Total_Session_Minutes DESC) AS D_Rank
	FROM (
		SELECT User_ID, User_Name,
			   SUM(Session_Minutes) AS Total_Session_Minutes
		FROM Website_Activity
		GROUP BY User_ID, User_Name
	)T
)D
WHERE D_Rank <= 3;


-- Q4
-- Find users who had activity within 2 days
-- of their previous activity.

WITH CTE AS (
	SELECT User_ID, User_Name, Activity_Date,
		   LAG(Activity_Date) OVER(PARTITION BY User_ID
           ORDER BY Activity_Date, Activity_ID) AS Previous
	FROM Website_Activity
)
SELECT DISTINCT User_ID, User_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Activity_Date, Previous) <= 2;


-- Q5
-- Find users whose total session minutes are greater
-- than the average total session minutes of all users.

SELECT User_ID, User_Name,
       SUM(Session_Minutes) AS Total_Session_Minutes
FROM Website_Activity
GROUP BY User_ID, User_Name
HAVING SUM(Session_Minutes) > (
	SELECT AVG(Total_Session_Minutes)
    FROM (
SELECT User_ID, User_Name,
       SUM(Session_Minutes) AS Total_Session_Minutes
FROM Website_Activity
GROUP BY User_ID, User_Name
	)A
);


-- BONUS
-- Find all continuous activity streaks for each user.
--
-- Return:
-- User_ID
-- User_Name
-- Start_Date
-- End_Date
-- Streak_Length
--
-- Extra condition:
-- Ignore duplicate activity dates if a user has multiple activities
-- on the same day.

WITH CTE AS (
	SELECT DISTINCT User_ID, User_Name, Activity_Date
	FROM Website_Activity
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY User_ID
		   ORDER BY Activity_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Activity_Date, INTERVAL RN DAY) AS GK
	FROM CTE2
)
SELECT User_ID, User_Name,
       MIN(Activity_Date) AS Start_Date,
       MAX(Activity_Date) AS End_Date,
       COUNT(*) AS Streak_Length
FROM CTE3
GROUP BY User_ID, User_Name, GK;