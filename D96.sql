USE Daily_SQL;


-- DATASET

CREATE TABLE Movie_Watch_History (
    Watch_ID INT,
    User_ID INT,
    User_Name VARCHAR(50),
    Watch_Date DATE,
    Movie_Genre VARCHAR(30),
    Watch_Minutes INT,
    Device_Type VARCHAR(20)
);

INSERT INTO Movie_Watch_History 
VALUES	(1,101,'Alice','2024-01-01','Action',120,'Mobile'),
		(2,101,'Alice','2024-01-02','Action',90,'TV'),
		(3,101,'Alice','2024-01-03','Comedy',100,'TV'),
		(4,101,'Alice','2024-01-07','Drama',80,'Mobile'),

		(5,102,'Bob','2024-01-01','Comedy',70,'Laptop'),
		(6,102,'Bob','2024-01-05','Action',110,'TV'),
		(7,102,'Bob','2024-01-06','Action',95,'TV'),

		(8,103,'Charlie','2024-01-02','Drama',140,'Mobile'),
		(9,103,'Charlie','2024-01-03','Drama',120,'TV'),
		(10,103,'Charlie','2024-01-04','Action',130,'Laptop'),
		(11,103,'Charlie','2024-01-05','Comedy',90,'TV'),

		(12,104,'David','2024-01-01','Comedy',60,'Mobile'),
		(13,104,'David','2024-01-08','Action',100,'TV'),

		(14,105,'Emma','2024-01-03','Drama',150,'TV'),
		(15,105,'Emma','2024-01-04','Drama',160,'TV'),
		(16,105,'Emma','2024-01-05','Action',140,'Laptop');

SELECT *
FROM Movie_Watch_History;
        

-- Q1
-- Show each user's total movies watched,
-- total watch minutes, and average watch minutes.

SELECT User_ID, User_Name,
	   COUNT(Watch_ID) AS Total_Movies_Watched,
       SUM(Watch_Minutes) AS Total_Watch_Minutes,
       AVG(Watch_Minutes) AS Average_Watch_Minutes
FROM Movie_Watch_History
GROUP BY User_ID, User_Name;


-- Q2
-- Show each movie genre's total watches
-- and total watch minutes.

SELECT Movie_Genre,
	   COUNT(Watch_ID) AS Total_Movies_Watched,
       SUM(Watch_Minutes) AS Total_Watch_Minutes
FROM Movie_Watch_History
GROUP BY Movie_Genre;


-- Q3
-- Find the top 3 users by total watch minutes.

WITH CTE AS (
	SELECT User_ID, User_Name,
		   SUM(Watch_Minutes) AS Total_Watch_Minutes
	FROM Movie_Watch_History
	GROUP BY User_ID, User_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Watch_Minutes DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 3;


-- Q4
-- Find users who watched movies within 2 days
-- of their previous watch activity.

WITH CTE AS (
	SELECT User_ID, User_Name, Watch_Date,
		   LAG(Watch_Date) OVER(PARTITION BY User_ID
           ORDER BY Watch_Date, Watch_ID) AS Previous
	FROM Movie_Watch_History
)
SELECT DISTINCT User_ID, User_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Watch_Date, Previous) <= 2;


-- Q5
-- Find users whose total watch minutes are greater
-- than the average total watch minutes of all users.

WITH CTE AS (
	SELECT User_ID, User_Name,
		   SUM(Watch_Minutes) AS Total_Watch_Minutes
	FROM Movie_Watch_History
	GROUP BY User_ID, User_Name
)
SELECT *
FROM CTE
WHERE Total_Watch_Minutes > (
	SELECT AVG(Total_Watch_Minutes)
    FROM CTE
);


-- BONUS
-- Find each user's current streak.
--
-- Return:
-- User_ID
-- User_Name
-- Current_Streak
--
-- Definition:
-- A current streak is the streak that contains
-- the user's most recent watch date.
--
-- Note:
-- Ignore duplicate watch dates if a user
-- has multiple watches on the same day.

WITH CTE AS (
	SELECT DISTINCT User_ID, User_Name, Watch_Date
    FROM Movie_Watch_History
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY User_ID
           ORDER BY Watch_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Watch_Date, INTERVAL RN DAY) AS GK
	FROM CTE2
),
CTE4 AS (
	SELECT User_ID, User_Name,
		   COUNT(*) AS Streak,
		   MAX(Watch_Date) AS End_Date
	FROM CTE3
	GROUP BY User_ID, User_Name, GK
),
CTE5 AS (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY User_ID
		   ORDER BY End_Date DESC) AS D_Rank
	FROM CTE4
)
SELECT User_ID, User_Name, Streak AS Current_Streak
FROM CTE5
WHERE D_Rank = 1;