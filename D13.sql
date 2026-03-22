USE Demo2;

SELECT *
FROM Employees;

SELECT *
FROM Departments;

SELECT *
FROM Projects;


-- 1. Show the second highest salary employee in each department.

SELECT *
FROM (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           Employees.Salary,
           Employees.Department_ID,
           Departments.Department_Name,
           RANK() OVER(PARTITION BY Employees.Department_ID
           ORDER BY Employees.Salary DESC) AS Rank_
	FROM Employees
    INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
	) R
WHERE Rank_ = 2;


-- 2. Show employees whose salary is above the average salary of their department.

SELECT *
FROM (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           Employees.Salary,
           Employees.Department_ID,
           Departments.Department_Name,
           AVG(Employees.Salary) OVER(PARTITION BY 
           Employees.Department_ID) AS Average
	FROM Employees
    INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
	)A
WHERE Salary > Average;


-- 3. Show the project where total hours worked is highest.

SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(ORDER BY Total_Hours DESC) AS Row_Num
	FROM (
		SELECT Project_ID,
               SUM(Hours_Worked) AS Total_Hours
		FROM Projects
        GROUP BY Project_ID
        )P
	)T
WHERE Row_Num = 1;


-- 4. Show employees who worked on more than 1 project.

SELECT Employees.Employee_ID,
	   Employees.Employee_Name,
       COUNT(DISTINCT Projects.Project_ID) AS Project
FROM Employees
INNER JOIN Projects
	ON Employees.Employee_ID = Projects.Employee_ID
GROUP BY Employees.Employee_ID, Employees.Employee_Name
HAVING Project > 1;
       


-- 5. Show the employee who worked the most total hours, but only among employees from IT department.

SELECT *
FROM (
		SELECT Employees.Employee_ID,
			   Employees.Employee_Name,
               Employees.Department_ID,
               Departments.Department_Name,
               SUM(Projects.Hours_Worked) AS Total_Hours,
               ROW_NUMBER() OVER(PARTITION BY Employees.Department_ID
			   ORDER BY SUM(Projects.Hours_Worked) DESC) AS Row_Num
		FROM Employees
        INNER JOIN Departments
			ON Employees.Department_ID = Departments.Department_ID
		INNER JOIN Projects
			ON Employees.Employee_ID = Projects.Employee_ID
		GROUP BY Employees.Employee_ID,
			     Employees.Employee_Name,
                 Employees.Department_ID,
                 Departments.Department_Name
		HAVING Departments.Department_Name = 'IT'
	)T
WHERE Row_Num = 1;

-- OR

SELECT *
FROM (
    SELECT Employees.Employee_ID,
           Employees.Employee_Name,
           Employees.Department_ID,
           Departments.Department_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours,
           ROW_NUMBER() OVER(PARTITION BY Employees.Department_ID
		   ORDER BY SUM(Projects.Hours_Worked) DESC) AS Row_Num
    FROM Employees
    INNER JOIN Departments
        ON Employees.Department_ID = Departments.Department_ID
    INNER JOIN Projects
        ON Employees.Employee_ID = Projects.Employee_ID
    WHERE Departments.Department_Name = 'IT'
    GROUP BY Employees.Employee_ID,
             Employees.Employee_Name,
             Employees.Department_ID,
             Departments.Department_Name
) T
WHERE Row_Num = 1;


-- 1. Show each project entry with the previous hours worked (for same employee)

SELECT *,
	   LAG(Hours_Worked, 1,0) OVER(PARTITION BY Employee_ID
       ORDER BY Project_ID) AS Previous_Hours
FROM Projects;


-- 2. Show each project entry with the next hours worked

SELECT *,
	   LEAD(Hours_Worked, 1,0) OVER(PARTITION BY Employee_ID
       ORDER BY Project_ID) AS Next_Hours
FROM Projects;


-- 3. Show cumulative hours worked per employee

SELECT *,
	   SUM(Hours_Worked) OVER(PARTITION BY Employee_ID
       ORDER BY Project_ID) AS Cumulative_Hours
FROM Projects;


-- 4. Show average of current + previous row (per employee)

SELECT *,
	   AVG(Hours_Worked) OVER(PARTITION BY Employee_ID
	   ORDER BY Project_ID ROWS BETWEEN 1 
       PRECEDING AND CURRENT ROW) AS Moving_Average
FROM Projects;



