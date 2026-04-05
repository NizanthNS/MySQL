CREATE DATABASE Employee;


USE Employee;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Emp_Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    Manager_ID INT
);


CREATE TABLE Projects (
    Project_ID INT PRIMARY KEY,
    Emp_ID INT,
    Project_Name VARCHAR(50),
    Hours_Worked INT
);


INSERT INTO Employees
VALUES		(1, 'Arjun', 'IT', 60000, NULL),
			(2, 'Meera', 'HR', 45000, 1),
			(3, 'Karan', 'IT', 70000, 1),
			(4, 'Divya', 'Finance', 50000, 1),
			(5, 'Rohit', 'IT', 55000, 3),
			(6, 'Sneha', 'HR', 48000, 2),
			(7, 'Vikram', 'Finance', 52000, 4),
			(8, 'Anita', 'IT', 62000, 3);


INSERT INTO Projects 
VALUES	(101, 1, 'Website', 120),
		(102, 3, 'Mobile App', 150),
		(103, 5, 'API Development', 90),
		(104, 2, 'Recruitment System', 60),
		(105, 4, 'Budget Analysis', 80),
		(106, 3, 'Cloud Migration', 110),
		(107, 8, 'Security Upgrade', 95),
		(108, 6, 'Training Portal', 70),
		(109, 7, 'Audit Tool', 85),
		(110, 5, 'Automation Script', 75);
 

SELECT *
FROM Employees;

SELECT *
FROM Projects;


-- 1. Show all employees in the IT department

SELECT *
FROM Employees
WHERE Department = 'IT';

-- OR

SELECT Emp_ID, Emp_Name
FROM Employees
WHERE Department = 'IT';


-- 2. Show employees with salary greater than 60,000

SELECT *
FROM Employees
WHERE Salary > 60000;

-- OR

SELECT Emp_ID, Emp_Name, Salary
FROM Employees
WHERE Salary > 60000;


-- 3. Show employee names and project names they are working on

SELECT Employees.Emp_Name, Projects.Project_Name
FROM Employees
INNER JOIN Projects
	ON Employees.Emp_ID = Projects.Emp_ID;


-- 4. Find the total hours worked by each employee

SELECT Employees.Emp_ID,
	   Employees.Emp_Name, 
	   SUM(Projects.Hours_Worked) AS Total_Hours_Worked
FROM Employees
INNER JOIN Projects
	ON Employees.Emp_ID = Projects.Emp_ID
GROUP BY Employees.Emp_ID, Employees.Emp_Name;


-- 5. Find the highest salary in the company

SELECT *
FROM Employees
WHERE Salary = (
		Select MAX(Salary) 
		From Employees);

-- OR

SELECT *
FROM Employees
ORDER BY Salary DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT Emp_ID, Emp_Name, Salary,
		   RANK() OVER(ORDER BY Salary DESC) AS Rnk
	FROM Employees
    )R
WHERE Rnk = 1;


-- 6. Show employees who do not have a manager

SELECT *
FROM Employees
WHERE Manager_ID IS NULL;

-- OR

SELECT Emp_ID, Emp_Name
FROM Employees
WHERE Manager_ID IS NULL;


-- 7. Count number of employees in each department

SELECT Department, COUNT(Emp_Id) AS No_of_Emp_By_Department
FROM Employees
GROUP BY Department;


-- 8. Find the employee who worked the most hours on projects

SELECT Employees.Emp_Name, SUM(Projects.Hours_Worked) AS Total_Hours_Worked
FROM Employees
INNER JOIN Projects
	ON Employees.Emp_ID = Projects.Emp_ID
GROUP BY Employees.Emp_Name, Employees.Emp_ID
ORDER BY Total_Hours_Worked DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Hours_Worked DESC) AS Rnk
	FROM
		(
		SELECT Employees.Emp_ID,
			   Employees.Emp_Name, 
			   SUM(Projects.Hours_Worked) AS Total_Hours_Worked
		FROM Employees
		INNER JOIN Projects
			ON Employees.Emp_ID = Projects.Emp_ID
		GROUP BY Employees.Emp_Name, Employees.Emp_ID
	)R
)T
WHERE Rnk = 1;

-- OR

WITH CTE AS (
	SELECT Employees.Emp_ID,
		   Employees.Emp_Name, 
		   SUM(Projects.Hours_Worked) AS Total_Hours_Worked
	FROM Employees
	INNER JOIN Projects
		ON Employees.Emp_ID = Projects.Emp_ID
	GROUP BY Employees.Emp_ID, Employees.Emp_Name
)
SELECT *
FROM CTE
WHERE Total_Hours_Worked = (
	SELECT MAX(Total_Hours_Worked)
    FROM CTE
    );
    
-- OR

SELECT Employees.Emp_ID,
	   Employees.Emp_Name, 
	   SUM(Projects.Hours_Worked) AS Total_Hours_Worked
FROM Employees
INNER JOIN Projects
	ON Employees.Emp_ID = Projects.Emp_ID
GROUP BY Employees.Emp_ID, Employees.Emp_Name
HAVING Total_Hours_Worked = (
	SELECT MAX(Total_Hours_Worked)
    FROM (
		SELECT Employees.Emp_ID,
			   Employees.Emp_Name, 
			   SUM(Projects.Hours_Worked) AS Total_Hours_Worked
		FROM Employees
		INNER JOIN Projects
			ON Employees.Emp_ID = Projects.Emp_ID
		GROUP BY Employees.Emp_ID, Employees.Emp_Name
        )T
	);
    
-- OR

SELECT Emp_ID, Emp_Name, Total_Hours_Worked
FROM (
	SELECT Employees.Emp_ID,
		   Employees.Emp_Name, 
		   SUM(Projects.Hours_Worked) AS Total_Hours_Worked,
		   RANK() OVER(ORDER BY SUM(Projects.Hours_Worked) DESC) AS Rnk
	FROM Employees
	INNER JOIN Projects
		ON Employees.Emp_ID = Projects.Emp_ID
	GROUP BY Employees.Emp_ID, Employees.Emp_Name
) T
WHERE Rnk = 1;
		

-- 9. Show employees whose salary is above the average salary

SELECT *
FROM Employees
WHERE Salary > (
	Select AVG(Salary) 
    FROM Employees
    );

-- OR

SELECT *
FROM (
	SELECT Emp_ID, 
		   Emp_Name, 
		   Salary,
		   AVG(Salary) OVER() AS Avg_Salary
	FROM Employees
) T
WHERE Salary > Avg_Salary;
    

-- 10. Find the department with the highest average salary

SELECT Department, AVG(Salary) AS Average_Salary
FROM Employees
GROUP BY Department
ORDER BY Average_Salary DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Average_Salary DESC) AS Rnk
	FROM (
		SELECT Department,
			   AVG(Salary) AS Average_Salary
		FROM Employees
        GROUP BY Department
        )R
	)T
WHERE Rnk = 1;


-- Find employees earning above their department average

WITH CTE AS (
	SELECT Emp_ID,
		   Emp_Name,
		   Department,
		   Salary,
		   AVG(Salary) OVER (PARTITION BY Department) AS Dept_Avg_Salary
	FROM Employees
)
SELECT *
FROM CTE
WHERE Salary > Dept_Avg_Salary;