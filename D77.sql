USE Daily_SQL;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees
VALUES  (1, 'Arun',   'IT'),
        (2, 'Meena',  'HR'),
        (3, 'Ravi',   'Finance'),
        (4, 'Priya',  'IT'),
        (5, 'Divya',  'Finance');
        

CREATE TABLE Task_Data (
    Task_ID INT PRIMARY KEY,
    Emp_ID INT,
    Task_Name VARCHAR(50),
    Hours_Spent INT,
    Task_Date DATE
);

INSERT INTO Task_Data
VALUES  (101, 1, 'Bug Fixing',      5, '2024-01-01'),
        (102, 1, 'Development',     8, '2024-01-05'),
        (103, 2, 'Recruitment',     4, '2024-01-06'),
        (104, 3, 'Audit',           7, '2024-01-10'),
        (105, 1, 'Testing',         6, '2024-01-12'),
        (106, 4, 'Development',     9, '2024-01-15'),
        (107, 5, 'Audit',           5, '2024-01-18'),
        (108, 3, 'Budget Planning', 8, '2024-01-22'),
        (109, 2, 'Interviews',      3, '2024-02-01'),
        (110, 4, 'Bug Fixing',      4, '2024-02-05'),
        (111, 5, 'Audit',           6, '2024-02-08'),
        (112, 1, 'Development',     7, '2024-02-12');
        

SELECT *
FROM Employees;

SELECT *
FROM Task_Data;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each employee along with:
-- 1. Total Tasks Completed
-- 2. Total Hours Spent
-- 3. Average Hours per Task
-- ordered by Total Hours Spent descending.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name,
		   COUNT(T.Task_ID) AS Total_Tasks_Completed,
           SUM(T.Hours_Spent) AS Total_Hours_Spent,
           AVG(T.Hours_Spent) AS Average_Hours
	FROM Employees E
    INNER JOIN Task_Data T
		ON E.Emp_ID = T.Emp_ID
	GROUP BY E.Emp_ID, E.Employee_Name
)
SELECT *
FROM CTE
ORDER BY Total_Hours_Spent DESC;


-- Q2
-- Find employees whose total hours spent
-- is greater than the average total hours
-- spent by all employees.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name,
           SUM(T.Hours_Spent) AS Total_Hours_Spent
	FROM Employees E
    INNER JOIN Task_Data T
		ON E.Emp_ID = T.Emp_ID
	GROUP BY E.Emp_ID, E.Employee_Name
)
SELECT *
FROM CTE
WHERE Total_Hours_Spent > (
	SELECT AVG(Total_Hours_Spent)
    FROM CTE
);


-- Q3
-- Show the employee with the highest total hours
-- spent in each Department.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Total_Hours_Spent DESC) AS D_Rank
	FROM (
			SELECT E.Emp_ID, E.Employee_Name, E.Department,
				   SUM(T.Hours_Spent) AS Total_Hours_Spent
			FROM Employees E
			INNER JOIN Task_Data T
				ON E.Emp_ID = T.Emp_ID
			GROUP BY E.Emp_ID, E.Employee_Name, E.Department
	)D
)H
WHERE D_Rank = 1;


-- Q4
-- Show tasks that were performed
-- more than once within the same month.

SELECT Task_Name,
	   COUNT(Task_ID) AS Total_Tasks,
       YEAR(Task_Date) AS Year_,
       MONTH(Task_Date) AS Month_
FROM Task_Data
GROUP BY Task_Name, YEAR(Task_Date), MONTH(Task_Date)
HAVING COUNT(Task_ID) > 1;


-- Q5
-- Show each task entry along with:
-- 1. Previous Hours_Spent of that employee
-- 2. Difference from previous Hours_Spent
-- 3. Running total Hours_Spent of that employee

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, T.Task_Date, T.Hours_Spent, T.Task_name,
		   LAG(T.Hours_Spent) OVER(PARTITION BY E.Emp_ID
           ORDER BY T.Task_Date) AS Previous_Hours,
           SUM(T.Hours_Spent) OVER(PARTITION BY E.Emp_ID
           ORDER BY T.Task_Date) AS Running_total
	FROM Employees E
    INNER JOIN Task_Data T
		ON E.Emp_ID = T.Emp_ID
)
SELECT *,
	   Hours_Spent - Previous_Hours AS Difference
FROM CTE
WHERE Previous_Hours IS NOT NULL;


-- Q6 (Date Logic)
-- Find employees who worked again
-- within 7 days of their previous task entry.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, T.Task_Date,
		   LAG(T.Task_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY T.Task_Date) AS Previous_Hours
	FROM Employees E
    INNER JOIN Task_Data T
		ON E.Emp_ID = T.Emp_ID
)
SELECT DISTINCT Emp_ID, Employee_Name
FROM CTE
WHERE Previous_Hours IS NOT NULL
AND DATEDIFF(Task_Date, Previous_Hours) <= 7;


-- Bonus Challenge
-- Show:
-- 1. Employee_Name
-- 2. First Task_Date
-- 3. Latest Task_Date
-- 4. Total Tasks Completed
-- 5. Total Hours Spent
-- 6. Average Days Between Task Entries

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, T.Task_Date, T.Task_ID, T.Hours_Spent,
		   LAG(T.Task_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY T.Task_Date) AS Previous_Hours
	FROM Employees E
    INNER JOIN Task_Data T
		ON E.Emp_ID = T.Emp_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Task_Date, Previous_Hours) AS Days_Gap
	FROM CTE
)
SELECT Emp_ID, Employee_Name,
	   MIN(Task_Date) AS First_Task_Date,
	   MAX(Task_Date) AS Last_Task_Date,
       COUNT(Task_ID) AS Total_Tasks_Completed,
       SUM(Hours_Spent) AS Total_Hours_Spent,
       ROUND(AVG(Days_Gap), 2) AS Average_Days
FROM CTE2
GROUP BY Emp_ID, Employee_Name;