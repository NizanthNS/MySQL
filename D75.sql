USE Daily_SQL;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT
);

INSERT INTO Employees
VALUES  (1, 'Arun',    'IT',        70000),
        (2, 'Meena',   'HR',        50000),
        (3, 'Ravi',    'Finance',   65000),
        (4, 'Priya',   'IT',        80000),
        (5, 'Divya',   'Finance',   72000),
        (6, 'Sanjay',  'HR',        48000);
        

CREATE TABLE Project_Data (
    Project_ID INT PRIMARY KEY,
    Emp_ID INT,
    Project_Name VARCHAR(50),
    Hours_Worked INT,
    Work_Date DATE
);

INSERT INTO Project_Data
VALUES  (101, 1, 'Alpha',   5, '2024-01-01'),
        (102, 1, 'Alpha',   6, '2024-01-03'),
        (103, 2, 'Beta',    4, '2024-01-05'),
        (104, 3, 'Gamma',   7, '2024-01-07'),
        (105, 1, 'Delta',   8, '2024-01-10'),
        (106, 4, 'Alpha',   9, '2024-01-12'),
        (107, 5, 'Gamma',   6, '2024-01-15'),
        (108, 3, 'Gamma',   5, '2024-01-18'),
        (109, 6, 'Beta',    3, '2024-01-20'),
        (110, 4, 'Delta',   7, '2024-01-22'),
        (111, 5, 'Gamma',   8, '2024-02-01'),
        (112, 1, 'Alpha',   4, '2024-02-05');
        
        
SELECT *
FROM Employees;

SELECT *
FROM Project_Data;

-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each employee along with:
-- 1. Total Projects Worked
-- 2. Total Hours Worked
-- 3. Average Hours per Entry
-- ordered by Total Hours Worked descending.

WITH CTE AS (
    SELECT E.Emp_ID, E.Employee_Name,
           COUNT(P.Project_ID) AS Total_Projects_Worked,
           SUM(P.Hours_Worked) AS Total_Hours_Worked,
           ROUND(AVG(P.Hours_Worked), 2) AS Average_Hours
    FROM Employees E
    INNER JOIN Project_Data P
        ON E.Emp_ID = P.Emp_ID
    GROUP BY E.Emp_ID, E.Employee_Name
)
SELECT *
FROM CTE
ORDER BY Total_Hours_Worked DESC;


-- Q2
-- Find employees whose total hours worked
-- is greater than the average total hours
-- worked by all employees.

WITH CTE AS (
    SELECT E.Emp_ID, E.Employee_Name,
           SUM(P.Hours_Worked) AS Total_Hours_Worked
    FROM Employees E
    INNER JOIN Project_Data P
        ON E.Emp_ID = P.Emp_ID
    GROUP BY E.Emp_ID, E.Employee_Name
)
SELECT *
FROM CTE
WHERE Total_Hours_Worked > (
	SELECT AVG(Total_Hours_Worked)
    FROM CTE
);


-- Q3
-- Show the employee with the highest total hours
-- worked in each Department.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Total_Hours_Worked DESC) AS D_Rank
	FROM (
		    SELECT E.Emp_ID, E.Employee_Name, Department,
				   SUM(P.Hours_Worked) AS Total_Hours_Worked
			FROM Employees E
			INNER JOIN Project_Data P
				ON E.Emp_ID = P.Emp_ID
			GROUP BY E.Emp_ID, E.Employee_Name, Department
	)D
)M
WHERE D_Rank = 1;


-- Q4
-- Show projects that were worked on
-- more than once within the same month.

SELECT Project_Name,
       COUNT(Project_ID) AS Total_Projects,
       YEAR(Work_Date) AS Year_,
       MONTH(Work_Date) AS Month_
FROM Project_Data
GROUP BY Project_Name, YEAR(Work_Date), MONTH(Work_Date)
HAVING COUNT(Project_ID) > 1;


-- Q5
-- Show each project entry along with:
-- 1. Previous Hours_Worked of that employee
-- 2. Difference from previous Hours_Worked
-- 3. Running total Hours_Worked of that employee

WITH CTE AS (
	SELECT Project_ID, Work_Date, Hours_Worked,
		   LAG(Hours_Worked) OVER(PARTITION BY Emp_ID
           ORDER BY Work_Date) AS Previous_Hours_Worked,
           SUM(Hours_Worked) OVER(PARTITION BY Emp_ID
           ORDER BY Work_Date) AS Running_Total
	FROM Project_Data
)
SELECT *,
	   Hours_Worked - Previous_Hours_Worked AS Difference
FROM CTE
WHERE Previous_Hours_Worked IS NOT NULL;


-- Q6 (Date Logic)
-- Find employees who worked again
-- within 7 days of their previous work entry.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, P.Work_Date,
		   LAG(P.Work_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY P.Work_Date) AS Previous
	FROM Employees E
    INNER JOIN Project_Data P
		ON E.Emp_ID = P.Emp_ID
)
SELECT DISTINCT Employee_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Work_Date, Previous) <= 7;


-- Bonus Challenge
-- Show:
-- 1. Employee_Name
-- 2. First Work_Date
-- 3. Latest Work_Date
-- 4. Total Project Entries
-- 5. Total Hours Worked
-- 6. Average Days Between Work Entries

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, P.Work_Date, P.Hours_Worked,
		   LAG(P.Work_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY P.Work_Date) AS Previous
	FROM Employees E
    INNER JOIN Project_Data P
		ON E.Emp_ID = P.Emp_ID
),
CTE2 AS (
	SELECT Emp_ID, Employee_Name, Work_Date, Hours_Worked, Previous,
		   DATEDIFF(Work_Date, Previous) AS Days_Gap
	FROM CTE
)
SELECT Emp_ID, Employee_Name,
	   MIN(Work_Date) AS First_Work_Date,
       MAX(Work_Date) AS Last_Work_Date,
       COUNT(*) AS Total_Project_Entries,
       SUM(Hours_Worked) AS Total_Hours_Worked,
       AVG(Days_Gap) AS Average_Days
FROM CTE2
GROUP BY Emp_ID, Employee_Name;

       