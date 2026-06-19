USE Daily_SQL;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    Join_Date DATE
);

INSERT INTO Employees
VALUES  (1, 'Arun',    'IT',        70000, '2021-01-10'),
        (2, 'Meena',   'HR',        50000, '2020-03-15'),
        (3, 'Ravi',    'Finance',   65000, '2019-07-01'),
        (4, 'Priya',   'IT',        72000, '2022-02-20'),
        (5, 'Karthik', 'HR',        48000, '2021-11-11'),
        (6, 'Divya',   'Finance',   80000, '2018-06-05'),
        (7, 'Sanjay',  'IT',        55000, '2023-09-18'),
        (8, 'Nisha',   'Marketing', 52000, '2024-01-12'),
        (9, 'Vikram',  'Marketing', 62000, '2020-04-25'),
        (10,'Aarthi',  'IT',        68000, '2022-08-30');
        

CREATE TABLE Employee_Attendance (
    Attendance_ID INT PRIMARY KEY,
    Emp_ID INT,
    Attendance_Date DATE,
    Status VARCHAR(20)
);

INSERT INTO Employee_Attendance
VALUES  (101, 1, '2024-01-01', 'Present'),
        (102, 1, '2024-01-02', 'Present'),
        (103, 1, '2024-01-10', 'Absent'),
        (104, 2, '2024-01-01', 'Present'),
        (105, 2, '2024-01-20', 'Present'),
        (106, 3, '2024-01-03', 'Absent'),
        (107, 3, '2024-01-15', 'Present'),
        (108, 4, '2024-01-05', 'Present'),
        (109, 4, '2024-01-06', 'Present'),
        (110, 4, '2024-01-25', 'Absent'),
        (111, 5, '2024-01-02', 'Present'),
        (112, 5, '2024-01-18', 'Present');
        

SELECT *
FROM Employees;

SELECT *
FROM Employee_Attendance;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each Department along with:
-- 1. Total employees
-- 2. Average Salary
-- ordered by Average Salary descending.

SELECT Department,
	   COUNT(Emp_ID) AS Total_Employees,
	   ROUND(AVG(Salary), 2) AS Average_Salary
FROM Employees
GROUP BY Department
ORDER BY AVG(Salary) DESC;


-- Q2
-- Find employees whose Salary
-- is greater than the average Salary
-- of their own Department.

WITH CTE AS (
	SELECT Employee_Name, Salary, Department,
		   AVG(Salary) OVER(PARTITION BY 
		   Department) AS Average_Salary
	FROM Employees
)
SELECT *
FROM CTE
WHERE Salary > Average_Salary;


-- Q3
-- Show the highest paid employee
-- in each Department.

SELECT *
FROM (
	SELECT Employee_Name, Department, Salary,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Salary DESC) AS D_Rank
	FROM Employees
)D
WHERE D_Rank = 1;


-- Q4
-- Show employees who have more than 1 attendance record
-- within the same month.

SELECT E.Employee_Name,
       YEAR(A.Attendance_Date) AS Year_,
       MONTH(A.Attendance_Date) AS Month_,
       COUNT(A.Attendance_Date) AS Total_Attendance
FROM Employees E
INNER JOIN Employee_Attendance A
    ON E.Emp_ID = A.Emp_ID
GROUP BY E.Employee_Name, YEAR(A.Attendance_Date),
       MONTH(A.Attendance_Date)
HAVING COUNT(A.Attendance_Date) > 1;


-- Q5
-- Show each attendance record along with:
-- 1. Previous attendance date of that employee
-- 2. Difference in days from previous attendance

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, 
		   A.Status, A.Attendance_Date,
           LAG(A.Attendance_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY A.Attendance_Date) AS Previous_Date
	FROM Employees E
	INNER JOIN Employee_Attendance A
		ON E.Emp_ID = A.Emp_ID
)
SELECT *,
	   DATEDIFF(Attendance_Date, Previous_Date) AS Days_Diff
FROM CTE
WHERE Previous_Date IS NOT NULL;


-- Q6 (Date Logic)
-- Find employees who returned to attendance
-- within 7 days of their previous attendance.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, A.Attendance_Date,
           LAG(A.Attendance_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY A.Attendance_Date) AS Previous_Date
	FROM Employees E
	INNER JOIN Employee_Attendance A
		ON E.Emp_ID = A.Emp_ID
)
SELECT DISTINCT Emp_ID, Employee_Name
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Attendance_Date, Previous_Date) <= 7;


-- Bonus Challenge
-- Show:
-- 1. Employee_Name
-- 2. First Attendance Date
-- 3. Latest Attendance Date
-- 4. Total Attendance Records
-- 5. Total Days Between First and Latest Attendance

SELECT E.Emp_ID, E.Employee_Name,
	   COUNT(A.Attendance_ID) AS Total_Attendance_Records,
       MIN(A.Attendance_Date) AS First_Attendance_Date,
       MAX(A.Attendance_Date) AS Latest_Attendance_Date,
       DATEDIFF(MAX(A.Attendance_Date), 
       MIN(A.Attendance_Date)) AS Total_Days_Diff
FROM Employees E
INNER JOIN Employee_Attendance A
	ON E.Emp_ID = A.Emp_ID
GROUP BY E.Emp_ID, E.Employee_Name;
