USE Daily_SQL;

-- DATASET

CREATE TABLE Employee_Attendance (
    Attendance_ID INT,
    Employee_ID INT,
    Employee_Name VARCHAR(50),
    Attendance_Date DATE,
    Department VARCHAR(30),
    Hours_Worked INT,
    Work_Mode VARCHAR(20)
);

INSERT INTO Employee_Attendance 
VALUES	(1,101,'Alice','2024-01-01','IT',8,'Office'),
		(2,101,'Alice','2024-01-02','IT',8,'Office'),
		(3,101,'Alice','2024-01-03','IT',7,'WFH'),
		(4,101,'Alice','2024-01-07','IT',8,'Office'),

		(5,102,'Bob','2024-01-01','HR',8,'Office'),
		(6,102,'Bob','2024-01-05','HR',7,'WFH'),
		(7,102,'Bob','2024-01-06','HR',8,'Office'),

		(8,103,'Charlie','2024-01-02','Finance',9,'Office'),
		(9,103,'Charlie','2024-01-03','Finance',8,'Office'),
		(10,103,'Charlie','2024-01-04','Finance',8,'WFH'),
		(11,103,'Charlie','2024-01-05','Finance',7,'WFH'),

		(12,104,'David','2024-01-01','IT',6,'WFH'),
		(13,104,'David','2024-01-08','IT',8,'Office'),

		(14,105,'Emma','2024-01-03','Sales',8,'Office'),
		(15,105,'Emma','2024-01-04','Sales',9,'Office'),
		(16,105,'Emma','2024-01-05','Sales',8,'WFH');
        

SELECT *
FROM Employee_Attendance;

-- Q1
-- Show each employee's total attendance records,
-- total hours worked, and average hours worked.

SELECT Employee_ID, Employee_Name,
	   COUNT(Attendance_ID) AS Total_Attendance_Records,
       SUM(Hours_Worked) AS Total_Hours_Worked,
       ROUND(AVG(Hours_Worked), 2) AS Average_Hours_Worked
FROM Employee_Attendance
GROUP BY Employee_ID, Employee_Name;


-- Q2
-- Show each department's total attendance records
-- and total hours worked.

SELECT Department,
	   COUNT(Attendance_ID) AS Total_Attendance_Records,
       SUM(Hours_Worked) AS Total_Hours_Worked
FROM Employee_Attendance
GROUP BY Department;


-- Q3
-- Find the top 3 employees by total hours worked.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Hours_Worked DESC) AS D_Rank
	FROM (
		SELECT Employee_ID, Employee_Name,
			   SUM(Hours_Worked) AS Total_Hours_Worked
		FROM Employee_Attendance
		GROUP BY Employee_ID, Employee_Name
	)T
)D
WHERE D_Rank <= 3;


-- Q4
-- Find employees who have an attendance record
-- within 2 days of their previous attendance.

WITH CTE AS (
	SELECT Employee_ID, Employee_Name, Attendance_Date,
		   LAG(Attendance_Date) OVER(PARTITION BY Employee_ID
           ORDER BY Attendance_Date, Attendance_ID) AS Previous
	FROM Employee_Attendance
)
SELECT DISTINCT Employee_ID, Employee_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Attendance_Date, Previous) <= 2;


-- Q5
-- Find employees whose total hours worked is greater
-- than the average total hours worked of all employees.

WITH CTE AS (
	SELECT Employee_ID, Employee_Name,
		   SUM(Hours_Worked) AS Total_Hours_Worked
	FROM Employee_Attendance
	GROUP BY Employee_ID, Employee_Name
)
SELECT *
FROM CTE
WHERE Total_Hours_Worked > (
	SELECT AVG(Total_Hours_Worked)
    FROM CTE
);


-- BONUS
-- Find each employee's longest consecutive attendance streak.
--
-- Return:
-- Employee_ID
-- Employee_Name
-- Longest_Streak

WITH CTE AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Employee_ID
           ORDER BY Attendance_Date) AS RN
	FROM Employee_Attendance
),
CTE2 AS (
	SELECT *,
		   DATE_SUB(Attendance_Date, INTERVAL RN DAY) AS Group_Key
	FROM CTE
),
CTE3 AS (
	SELECT Employee_ID, Employee_Name,
		   COUNT(*) AS Streak
	FROM CTE2
    GROUP BY Employee_ID, Employee_Name, Group_Key
)
SELECT Employee_ID, Employee_Name,
	   MAX(Streak) AS Longest_Streak
FROM CTE3
GROUP BY Employee_ID, Employee_Name;