USE Daily_SQL;

-- DATASET: Employee Attendance

CREATE TABLE Employees (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(100),
    Department VARCHAR(50),
    City VARCHAR(50),
    Join_Date DATE
);

INSERT INTO Employees
VALUES	(1,'Arun','IT','Chennai','2024-01-10'),
		(2,'Divya','HR','Bangalore','2024-02-15'),
		(3,'Karthik','IT','Chennai','2024-03-20'),
		(4,'Sneha','Finance','Hyderabad','2024-01-25'),
		(5,'Rahul','HR','Bangalore','2024-04-12'),
		(6,'Priya','Finance','Hyderabad','2024-02-28'),
		(7,'Vijay','IT','Chennai','2024-05-05'),
		(8,'Anitha','HR','Bangalore','2024-03-18');

CREATE TABLE Attendance (
    Attendance_ID INT PRIMARY KEY,
    Employee_ID INT,
    Attendance_Date DATE,
    Status VARCHAR(20),
    Work_Hours DECIMAL(5,2),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

INSERT INTO Attendance
VALUES	(101,1,'2024-06-01','Present',8.5),
		(102,1,'2024-06-02','Present',9.0),
		(103,1,'2024-06-03','Present',8.0),
		(104,1,'2024-06-05','Present',9.5),
		(105,1,'2024-06-06','Absent',0),

		(106,2,'2024-06-01','Present',8.0),
		(107,2,'2024-06-03','Present',8.5),
		(108,2,'2024-06-04','Present',9.0),
		(109,2,'2024-06-10','Present',8.0),

		(110,3,'2024-06-02','Present',9.0),
		(111,3,'2024-06-03','Present',9.5),
		(112,3,'2024-06-04','Present',9.0),
		(113,3,'2024-06-05','Present',8.5),
		(114,3,'2024-06-12','Present',10.0),

		(115,4,'2024-06-01','Present',7.5),
		(116,4,'2024-06-02','Absent',0),
		(117,4,'2024-06-03','Present',8.0),
		(118,4,'2024-06-04','Present',8.5),

		(119,5,'2024-06-05','Present',8.0),
		(120,5,'2024-06-06','Present',8.5),
		(121,5,'2024-06-07','Present',9.0),

		(122,6,'2024-06-01','Present',8.5),
		(123,6,'2024-06-02','Present',9.0),
		(124,6,'2024-06-03','Present',8.0),
		(125,6,'2024-06-08','Present',9.5),

		(126,7,'2024-06-10','Present',9.0),
		(127,7,'2024-06-11','Present',9.5),
		(128,7,'2024-06-12','Present',10.0),

		(129,8,'2024-06-02','Present',8.0),
		(130,8,'2024-06-03','Present',8.5),
		(131,8,'2024-06-04','Absent',0),
		(132,8,'2024-06-05','Present',9.0);
        

SELECT *
FROM Employees;

SELECT *
FROM Attendance;

-- Q1
-- Show each employee's:
-- total attendance records,
-- total work hours,
-- average work hours.
--
-- Use both tables.
--
-- Return:
-- Employee_ID
-- Employee_Name
-- Total_Attendance_Records
-- Total_Work_Hours
-- Average_Work_Hours

SELECT E.Employee_ID, E.Employee_Name,
	   COUNT(A.Attendance_ID) AS Total_Attendance_Records,
       SUM(A.Work_Hours) AS Total_Work_Hours,
       ROUND(AVG(A.Work_Hours), 2) AS Average_Work_Hours
FROM Employees E
INNER JOIN Attendance A
	ON E.Employee_ID = A.Employee_ID
GROUP BY E.Employee_ID, E.Employee_Name;


-- Q2
-- Show each department's:
-- total attendance records,
-- total work hours,
-- average work hours.
--
-- Return:
-- Department
-- Total_Attendance_Records
-- Total_Work_Hours
-- Average_Work_Hours

SELECT E.Department,
	   COUNT(A.Attendance_ID) AS Total_Attendance_Records,
       SUM(A.Work_Hours) AS Total_Work_Hours,
       ROUND(AVG(A.Work_Hours), 2) AS Average_Work_Hours
FROM Employees E
INNER JOIN Attendance A
	ON E.Employee_ID = A.Employee_ID
GROUP BY E.Department;


-- Q3
-- Find the top 3 employees by total work hours.
--
-- Use DENSE_RANK().
--
-- Return:
-- Employee_ID
-- Employee_Name
-- Department
-- Total_Work_Hours

WITH CTE AS (
	SELECT E.Employee_ID, E.Employee_Name, E.Department,
		   SUM(A.Work_Hours) AS Total_Work_Hours
	FROM Employees E
	INNER JOIN Attendance A
		ON E.Employee_ID = A.Employee_ID
	GROUP BY E.Employee_ID, E.Employee_Name, E.Department
),
CTE2 AS (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Work_Hours DESC) AS D_Rank
	FROM CTE
)
SELECT Employee_ID, Employee_Name, Department, Total_Work_Hours
FROM CTE2
WHERE D_Rank <= 3;


-- Q4
-- Find employees who had a present attendance
-- within 2 days of their previous present attendance.
--
-- Use JOIN + LAG().
--
-- Only compare dates where Status = 'Present'.
--
-- Return:
-- Employee_ID
-- Employee_Name

WITH CTE AS (
	SELECT E.Employee_ID, Employee_Name, A.Attendance_Date,
		   LAG(A.Attendance_Date) OVER(PARTITION BY E.Employee_ID
           ORDER BY A.Attendance_Date, A.Attendance_ID) AS Previous
	FROM Employees E
	INNER JOIN Attendance A
		ON E.Employee_ID = A.Employee_ID
	WHERE Status = 'Present'
)
SELECT DISTINCT Employee_ID, Employee_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Attendance_Date, Previous) <= 2;


-- Q5 (COHORT ANALYSIS)
-- For each cohort month, find:
-- total employees
-- total work hours
-- average work hours.
--
-- Definition:
-- Cohort Month = Month in which the employee joined.
--
-- Return:
-- Cohort_Month
-- Total_Employees
-- Total_Work_Hours
-- Average_Work_Hours

WITH CTE AS (
	SELECT Employee_ID,
		   DATE_FORMAT(Join_Date, '%Y-%m') AS Cohort_Month
	FROM Employees
)
SELECT Cohort_Month,
	   COUNT(DISTINCT C.Employee_ID) AS Total_Employees,
	   SUM(A.Work_Hours) AS Total_Work_Hours,
	   ROUND(AVG(A.Work_Hours), 2) AS Average_Work_Hours
FROM CTE C
INNER JOIN Attendance A
	ON C.Employee_ID = A.Employee_ID
GROUP BY Cohort_Month;


-- BONUS (GAP & ISLAND)
-- Find each employee's longest consecutive
-- PRESENT attendance streak.
--
-- Ignore Absent records.
--
-- Return:
-- Employee_ID
-- Employee_Name
-- Longest_Streak
-- Start_Date
-- End_Date
--
-- If multiple streaks have the same length,
-- return the most recent streak.

WITH CTE AS (
	SELECT DISTINCT E.Employee_ID, E.Employee_Name, A.Attendance_Date
	FROM Employees E
	INNER JOIN Attendance A
		ON E.Employee_ID = A.Employee_ID
	WHERE Status = 'Present'
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Employee_ID
           ORDER BY Attendance_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Attendance_Date, INTERVAL RN DAY) AS GK
	FROM CTE2
),
CTE4 AS (
	SELECT Employee_ID, Employee_Name,
		   COUNT(*) AS Streak,
		   MIN(Attendance_Date) AS Start_Date,
           MAX(Attendance_Date) AS End_Date
	FROM CTE3
    GROUP BY Employee_ID, Employee_Name, GK
),
CTE5 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Employee_ID
           ORDER BY Streak DESC, End_Date DESC) AS  Row_Num
	FROM CTE4
)
SELECT Employee_ID, Employee_Name, Streak AS Longest_Streak,
	   Start_Date, End_Date
FROM CTE5
WHERE Row_Num = 1;
           

-- BONUS+
-- Find employees whose total work hours
-- are greater than the average total work hours
-- of employees in the same department.
--
-- Return:
-- Employee_ID
-- Employee_Name
-- Department
-- Total_Work_Hours

SELECT Employee_ID, Employee_Name, Department, Total_Work_Hours
FROM (
	SELECT *,
		   AVG(Total_Work_Hours) OVER(PARTITION BY Department) AS Avg_Dep
	FROM (
		SELECT E.Employee_ID, E.Employee_Name, Department,
			   SUM(A.Work_Hours) AS Total_Work_Hours
		FROM Employees E
		INNER JOIN Attendance A
			ON E.Employee_ID = A.Employee_ID
		GROUP BY E.Employee_ID, E.Employee_Name, Department
	)A
)D
WHERE Total_Work_Hours > Avg_Dep;


-- INTERVIEW CHALLENGE
-- For each department, find the employee who has
-- the highest average work hours among employees
-- who have at least 3 attendance records.
--
-- Return:
-- Department
-- Employee_ID
-- Employee_Name
-- Average_Work_Hours
-- Total_Attendance_Records

SELECT Department, Employee_ID, Employee_Name, Average_Work_Hours, Total_Attendance_Records
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Department
           ORDER BY Average_Work_Hours DESC) AS RN
	FROM (
		SELECT E.Employee_ID, E.Employee_Name, Department,
			   ROUND(AVG(A.Work_Hours), 2) AS Average_Work_Hours,
			   COUNT(A.Attendance_ID) AS Total_Attendance_Records
		FROM Employees E
		INNER JOIN Attendance A
			ON E.Employee_ID = A.Employee_ID
		GROUP BY E.Employee_ID, E.Employee_Name, Department
        HAVING COUNT(A.Attendance_ID) >= 3
	)A
)H
WHERE RN = 1;