SELECT *
FROM Departments;

SELECT *
FROM Employees;

SELECT *
FROM Projects;


-- 1. Show all employees from IT department

SELECT *
FROM Employees
INNER JOIN Departments
	ON Employees.Department_ID = Departments.Department_ID
WHERE Departments.Department_Name = 'IT';


-- 2. Show employees with salary > 70000

SELECT *
FROM Employees
WHERE Salary > 70000;


-- 3. Show all employees along with their department names

SELECT Employees.Employee_ID, 
	   Employees.Employee_Name, 
       Departments.Department_Name
FROM Employees
LEFT JOIN Departments
	ON Employees.Department_ID = Departments.Department_ID;


-- 4. Show total salary per department

SELECT Departments.Department_ID,
	   Departments.Department_Name,
       SUM(Employees.Salary) AS Total_Salary
FROM Employees
INNER JOIN Departments
	ON Employees.Department_ID = Departments.Department_ID
GROUP BY Departments.Department_Name, Departments.Department_ID;


-- 5. Show departments where total salary > 120000

SELECT Departments.Department_ID,
	   Departments.Department_Name,
       SUM(Employees.Salary) AS Total_Salary
FROM Employees
INNER JOIN Departments
	ON Employees.Department_ID = Departments.Department_ID
GROUP BY Departments.Department_Name, Departments.Department_ID
HAVING Total_Salary > 120000;


-- 6. Show employees whose salary is greater than overall average salary

SELECT Employee_ID, Employee_Name, Salary
FROM Employees
WHERE Salary > (
				SELECT AVG(Salary)
                FROM Employees
                );


-- 7. Show the highest paid employee overall

SELECT Employee_ID, Employee_Name, Salary
FROM Employees
WHERE Salary = (
			SELECT MAX(Salary)
            FROM
            Employees
				);

-- OR

SELECT Employee_ID, Employee_Name, Salary
FROM Employees
ORDER BY Salary DESC
LIMIT 1;


-- 8. Show each employee with a salary rank (highest to lowest)

SELECT Employee_ID, Employee_Name, Salary,
	   RANK() OVER(ORDER BY Salary DESC) AS Rank_
FROM Employees;


-- 9. Show the top 2 highest paid employees per department

SELECT *
FROM (
	SELECT Employees.Employee_ID, 
		Employees.Employee_Name,
		Employees.Salary,
		Departments.Department_ID,
		Departments.Department_Name,
		RANK() OVER(PARTITION BY Departments.Department_ID
		ORDER BY Employees.Salary DESC) AS Rank_
	FROM Employees
	INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
        ) R
WHERE Rank_ <= 2;


-- 10. Show each employee with row number within department (by salary DESC)

SELECT Employees.Employee_ID, 
	   Employees.Employee_Name,
	   Employees.Salary,
	   Departments.Department_ID,
	   Departments.Department_Name,
	   ROW_NUMBER() OVER(PARTITION BY Departments.Department_ID
	   ORDER BY Employees.Salary DESC) AS Row_Num
FROM Employees
INNER JOIN Departments
	ON Employees.Department_ID = Departments.Department_ID;


