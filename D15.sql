SELECT *
FROM Employees;

SELECT *
FROM Departments;

SELECT *
FROM Projects;


-- 1. Show the employee who has the 2nd highest total hours worked overall

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Hours DESC) AS Rank_
	FROM (
		SELECT Employees.Employee_ID,
			   Employees.Employee_Name,
               SUM(Projects.Hours_Worked) AS Total_Hours
		FROM Employees
        INNER JOIN Projects
			ON Employees.Employee_ID = Projects.Employee_ID
		GROUP BY Employees.Employee_ID,
			     Employees.Employee_Name
		)R
	)T
WHERE Rank_ = 2;


-- 2. Show the department with the highest average salary


SELECT *
FROM (
	SELECT Departments.Department_ID,
		   Departments.Department_Name,
           AVG(Employees.Salary) AS Average,
           RANK() OVER(ORDER BY AVG(Employees.Salary) DESC) AS Rank_
	FROM Employees
    INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
	GROUP BY Departments.Department_ID,
			 Departments.Department_Name
        ) T
WHERE Rank_ = 1;

-- OR

SELECT Departments.Department_ID,
       Departments.Department_Name,
       AVG(Employees.Salary) AS Average
FROM Employees
JOIN Departments
    ON Employees.Department_ID = Departments.Department_ID
GROUP BY Departments.Department_ID,
         Departments.Department_Name
HAVING AVG(Employees.Salary) = (
    SELECT MAX(avg_salary)
    FROM (
        SELECT AVG(Salary) AS avg_salary
        FROM Employees
        GROUP BY Department_ID
    ) T
);


-- 3. Show employees whose total hours worked is greater than the average total hours worked of all employees

SELECT *
FROM (
    SELECT Employee_ID,
           SUM(Hours_Worked) AS Total_Hours
    FROM Projects
    GROUP BY Employee_ID
) T
WHERE Total_Hours > (
    SELECT AVG(Total_Hours)
    FROM (
        SELECT Employee_ID,
               SUM(Hours_Worked) AS Total_Hours
        FROM Projects
        GROUP BY Employee_ID
    ) R
);


-- 4. Show the employee who worked on the most number of projects (handle ties)

SELECT *
FROM (
    SELECT *,
           RANK() OVER(ORDER BY Total DESC) AS Rank_
    FROM (
        SELECT Employees.Employee_ID,
               Employees.Employee_Name,
               COUNT(Projects.Project_ID) AS Total
        FROM Employees
        INNER JOIN Projects
            ON Employees.Employee_ID = Projects.Employee_ID
        GROUP BY Employees.Employee_ID,
                 Employees.Employee_Name
    ) T
) R
WHERE Rank_ = 1;


-- 5. Show employees who have worked on every project

SELECT Employees.Employee_ID,
       Employees.Employee_Name
FROM Employees
INNER JOIN Projects
    ON Employees.Employee_ID = Projects.Employee_ID
GROUP BY Employees.Employee_ID,
         Employees.Employee_Name
HAVING COUNT(DISTINCT Projects.Project_ID) = (
    SELECT COUNT(DISTINCT Project_ID)
    FROM Projects
);



