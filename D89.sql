USE Daily_SQL;

-- DATASET

CREATE TABLE User_Logins (
    Login_ID INT,
    User_ID INT,
    User_Name VARCHAR(50),
    Login_Date DATE,
    Device_Type VARCHAR(20),
    Session_Minutes INT,
    Country VARCHAR(30)
);

INSERT INTO User_Logins 
VALUES	(1,101,'Alice','2024-01-01','Mobile',45,'India'),
		(2,101,'Alice','2024-01-02','Mobile',30,'India'),
		(3,101,'Alice','2024-01-03','Desktop',60,'India'),
		(4,101,'Alice','2024-01-06','Mobile',20,'India'),

		(5,102,'Bob','2024-01-01','Desktop',50,'USA'),
		(6,102,'Bob','2024-01-04','Desktop',40,'USA'),
		(7,102,'Bob','2024-01-05','Mobile',35,'USA'),

		(8,103,'Charlie','2024-01-02','Mobile',25,'UK'),
		(9,103,'Charlie','2024-01-03','Mobile',30,'UK'),
		(10,103,'Charlie','2024-01-04','Desktop',55,'UK'),
		(11,103,'Charlie','2024-01-05','Desktop',45,'UK'),

		(12,104,'David','2024-01-01','Mobile',15,'India'),
		(13,104,'David','2024-01-07','Mobile',20,'India'),

		(14,105,'Emma','2024-01-03','Desktop',80,'Canada'),
		(15,105,'Emma','2024-01-04','Desktop',70,'Canada'),
		(16,105,'Emma','2024-01-05','Mobile',50,'Canada');
        

SELECT *
FROM User_Logins;
        

-- Q1
-- Show each user's total logins, total session minutes,
-- and average session minutes.

SELECT User_ID, User_Name,
	   COUNT(Login_ID) AS Total_Logins,
       SUM(Session_Minutes) AS Total_Session_Minutes,
       ROUND(AVG(Session_Minutes), 2) AS Average_Session_Minutes
FROM User_Logins
GROUP BY User_ID, User_Name;


-- Q2
-- Show each country's total logins and total session minutes.

SELECT Country, 
	   COUNT(Login_ID) AS Total_Logins,
       SUM(Session_Minutes) AS Total_Session_Minutes
FROM User_Logins
GROUP BY Country;
	   

-- Q3
-- Find the top 3 users by total session minutes.

WITH CTE AS (
	SELECT User_ID, User_Name,
		   SUM(Session_Minutes) AS Total_Session_Minutes
	FROM User_Logins
	GROUP BY User_ID, User_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY 
           Total_Session_Minutes DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 3;


-- Q4
-- Find users who logged in within 2 days of their previous login.

WITH CTE AS (
	SELECT User_ID, User_Name, Login_Date,
		   LAG(Login_Date) OVER(PARTITION BY User_ID
           ORDER BY Login_Date, Login_ID) AS Previous
	FROM User_Logins
)
SELECT DISTINCT User_ID, User_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Login_Date, Previous) <= 2;


-- Q5
-- Find users whose total session minutes are greater than
-- the average total session minutes of all users.

WITH CTE AS (
	SELECT User_ID, User_Name,
		   SUM(Session_Minutes) AS Total_Session_Minutes
	FROM User_Logins
	GROUP BY User_ID, User_Name
)
SELECT *
FROM CTE
WHERE Total_Session_Minutes > (
	SELECT AVG(Total_Session_Minutes)
    FROM CTE
);


-- BONUS
-- Find each user's longest consecutive login streak.
--
-- Return:
-- User_ID
-- User_Name
-- Longest_Streak

WITH CTE AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY User_ID
           ORDER BY Login_Date) AS RN
	FROM User_Logins
),
CTE2 AS (
	SELECT *,
		   DATE_SUB(Login_Date, INTERVAL RN DAY) AS G_Key
	FROM CTE
),
CTE3 AS (
	SELECT User_ID, User_Name,
		   COUNT(*) AS Streak
	FROM CTE2
    GROUP BY User_ID, User_Name, G_Key
)
SELECT DISTINCT User_ID, User_Name,
	   MAX(Streak) AS Longest_Streak
FROM CTE3
GROUP BY User_ID, User_Name;