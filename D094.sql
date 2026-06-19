USE Daily_SQL;

-- DATASET

CREATE TABLE Gym_Checkins (
    Checkin_ID INT,
    Member_ID INT,
    Member_Name VARCHAR(50),
    Checkin_Date DATE,
    Gym_Branch VARCHAR(30),
    Workout_Minutes INT,
    Membership_Type VARCHAR(20)
);

INSERT INTO Gym_Checkins 
VALUES	(1,101,'Alice','2024-01-01','Chennai',60,'Gold'),
		(2,101,'Alice','2024-01-02','Chennai',45,'Gold'),
		(3,101,'Alice','2024-01-03','Chennai',50,'Gold'),
		(4,101,'Alice','2024-01-07','Madurai',40,'Gold'),

		(5,102,'Bob','2024-01-01','Coimbatore',55,'Silver'),
		(6,102,'Bob','2024-01-05','Coimbatore',65,'Silver'),
		(7,102,'Bob','2024-01-06','Coimbatore',50,'Silver'),

		(8,103,'Charlie','2024-01-02','Chennai',70,'Platinum'),
		(9,103,'Charlie','2024-01-03','Chennai',60,'Platinum'),
		(10,103,'Charlie','2024-01-04','Madurai',75,'Platinum'),
		(11,103,'Charlie','2024-01-05','Madurai',55,'Platinum'),

		(12,104,'David','2024-01-01','Trichy',30,'Silver'),
		(13,104,'David','2024-01-08','Trichy',45,'Silver'),

		(14,105,'Emma','2024-01-03','Chennai',80,'Gold'),
		(15,105,'Emma','2024-01-04','Chennai',75,'Gold'),
		(16,105,'Emma','2024-01-05','Chennai',85,'Gold');
        
SELECT *
FROM Gym_Checkins;

-- Q1
-- Show each member's total check-ins,
-- total workout minutes, and average workout minutes.

SELECT Member_ID, Member_Name,
	   COUNT(Checkin_ID) AS Total_Check_ins,
       SUM(Workout_Minutes) AS Total_Workout_Minutes,
       ROUND(AVG(Workout_Minutes), 2) AS Average_Workout_Minutes
FROM Gym_Checkins
GROUP BY Member_ID, Member_Name;


-- Q2
-- Show each gym branch's total check-ins
-- and total workout minutes.

SELECT Gym_Branch,
	   COUNT(Checkin_ID) AS Total_Check_ins,
       SUM(Workout_Minutes) AS Total_Workout_Minutes
FROM Gym_Checkins
GROUP BY Gym_Branch;


-- Q3
-- Find the top 3 members by total workout minutes.

WITH CTE AS (
	SELECT Member_ID, Member_Name,
		   SUM(Workout_Minutes) AS Total_Workout_Minutes
	FROM Gym_Checkins
	GROUP BY Member_ID, Member_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY 
           Total_Workout_Minutes DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 3;


-- Q4
-- Find members who checked in within 2 days
-- of their previous check-in.

WITH CTE AS (
	SELECT Member_ID, Member_Name, Checkin_Date,
		   LAG(Checkin_Date) OVER(PARTITION BY Member_ID 
           ORDER BY Checkin_Date, Checkin_ID) AS Previous
	FROM Gym_Checkins
)
SELECT DISTINCT Member_ID, Member_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Checkin_Date, Previous) <= 2;


-- Q5
-- Find members whose total workout minutes are greater
-- than the average total workout minutes of all members.

WITH CTE AS (
	SELECT Member_ID, Member_Name,
		   SUM(Workout_Minutes) AS Total_Workout_Minutes
	FROM Gym_Checkins
	GROUP BY Member_ID, Member_Name
)
SELECT *
FROM CTE
WHERE Total_Workout_Minutes > (
	SELECT AVG(Total_Workout_Minutes)
    FROM CTE
);


-- BONUS
-- Find members whose longest consecutive check-in streak
-- is at least 3 days.
--
-- Return:
-- Member_ID
-- Member_Name
-- Longest_Streak
--
-- Note:
-- Assume a member can have multiple check-ins
-- on the same day. Ignore duplicate dates when
-- calculating streaks.

WITH CTE AS (
	SELECT DISTINCT Member_ID, Member_Name, Checkin_Date
	FROM Gym_Checkins
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Member_ID
		   ORDER BY Checkin_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Checkin_Date, INTERVAL RN DAY) AS GP
	FROM CTE2
),
CTE4 AS (
	SELECT Member_ID, Member_Name,
		   COUNT(*) AS Streak
	FROM CTE3
	GROUP BY Member_ID, Member_Name, GP
)
SELECT Member_ID, Member_Name,
       MAX(Streak) AS Longest_Streak
FROM CTE4
GROUP BY Member_ID, Member_Name
HAVING MAX(Streak) >= 3;