USE Daily_SQL;

-- DATASET

CREATE TABLE Online_Learning_Activity (
    Activity_ID INT,
    Student_ID INT,
    Student_Name VARCHAR(50),
    Activity_Date DATE,
    Course_Name VARCHAR(50),
    Minutes_Spent INT,
    Activity_Type VARCHAR(20)
);

INSERT INTO Online_Learning_Activity 
VALUES	(1,101,'Alice','2024-01-01','SQL Basics',45,'Video'),
		(2,101,'Alice','2024-01-02','SQL Basics',60,'Quiz'),
		(3,101,'Alice','2024-01-03','SQL Basics',50,'Video'),
		(4,101,'Alice','2024-01-07','Python Basics',40,'Video'),

		(5,102,'Bob','2024-01-01','Excel',30,'Video'),
		(6,102,'Bob','2024-01-05','Excel',45,'Quiz'),
		(7,102,'Bob','2024-01-06','SQL Basics',55,'Video'),

		(8,103,'Charlie','2024-01-02','Power BI',70,'Video'),
		(9,103,'Charlie','2024-01-03','Power BI',65,'Quiz'),
		(10,103,'Charlie','2024-01-04','SQL Basics',80,'Video'),
		(11,103,'Charlie','2024-01-05','SQL Basics',60,'Quiz'),

		(12,104,'David','2024-01-01','Excel',25,'Video'),
		(13,104,'David','2024-01-08','Power BI',35,'Video'),

		(14,105,'Emma','2024-01-03','Python Basics',90,'Video'),
		(15,105,'Emma','2024-01-04','Python Basics',85,'Quiz'),
		(16,105,'Emma','2024-01-05','SQL Basics',95,'Video');
        
SELECT *
FROM Online_Learning_Activity;


-- Q1
-- Show each student's total activities,
-- total minutes spent, and average minutes spent.

SELECT Student_ID, Student_Name,
	   COUNT(Activity_ID) AS Total_Activities,
       SUM(Minutes_Spent) AS Total_Minutes_Spent,
       ROUND(AVG(Minutes_Spent), 2) AS Average_Minutes_Spent
FROM Online_Learning_Activity
GROUP BY Student_ID, Student_Name;


-- Q2
-- Show each course's total activities
-- and total minutes spent.

SELECT Course_Name,
	   COUNT(Activity_ID) AS Total_Activities,
       SUM(Minutes_Spent) AS Total_Minutes_Spent
FROM Online_Learning_Activity
GROUP BY Course_Name;


-- Q3
-- Find the top 3 students by total minutes spent.

WITH CTE AS (
	SELECT Student_ID, Student_Name,
		   SUM(Minutes_Spent) AS Total_Minutes_Spent
	FROM Online_Learning_Activity
	GROUP BY Student_ID, Student_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Minutes_Spent DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 3;


-- Q4
-- Find students who had activity within 2 days
-- of their previous activity.

WITH CTE AS (
	SELECT Student_ID, Student_Name, Activity_Date,
		   LAG(Activity_Date) OVER(PARTITION BY Student_ID
           ORDER BY Activity_Date, Activity_ID) AS Previous
	FROM Online_Learning_Activity
)
SELECT DISTINCT Student_ID, Student_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Activity_Date, Previous) <= 2;


-- Q5
-- Find students whose total minutes spent is greater
-- than the average total minutes spent of all students.

WITH CTE AS (
	SELECT Student_ID, Student_Name,
		   SUM(Minutes_Spent) AS Total_Minutes_Spent
	FROM Online_Learning_Activity
	GROUP BY Student_ID, Student_Name
)
SELECT *
FROM CTE
WHERE Total_Minutes_Spent > (
	SELECT AVG(Total_Minutes_Spent)
    FROM CTE
);


-- BONUS
-- Find the total number of activity streaks for each student.
--
-- Return:
-- Student_ID
-- Student_Name
-- Total_Streaks
--
-- Note:
-- Ignore duplicate activity dates if a student
-- has multiple activities on the same day.

WITH CTE AS (
	SELECT DISTINCT Student_ID, Student_Name, Activity_Date
    FROM Online_Learning_Activity
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Student_ID
           ORDER BY Activity_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Activity_Date, INTERVAL RN DAY) AS GP
	FROM CTE2
),
CTE4 AS (
	SELECT Student_ID, Student_Name,
		   COUNT(*) AS Streak
	FROM CTE3
    GROUP BY Student_ID, Student_Name, GP
)
SELECT Student_ID, Student_Name,
	   COUNT(Streak) AS Total_Streaks
FROM CTE4
GROUP BY Student_ID, Student_Name;