USE Daily_SQL;

SELECT *
FROM Employees;


-- Q1
-- Find total salary of all employees

SELECT SUM(Salary) AS Total_Salary
FROM Employees;


-- Q2
-- Find average salary

SELECT AVG(Salary) AS Average_Salary
FROM Employees;


-- Q3
-- Find total salary per department

SELECT Department,
	   SUM(Salary) AS Total_Salary
FROM Employees
GROUP BY Department;


-- Q4
-- Find average salary per city

SELECT City,
	   AVG(Salary) AS Average
FROM Employees
GROUP BY City;


-- Q5
-- Find number of employees per department

SELECT Department,
	   COUNT(Emp_ID) AS Total_Emp
FROM Employees
GROUP BY Department;


-- Q6
-- Find maximum salary in each department

SELECT Department,
	   MAX(Salary) AS Highest_Salary
FROM Employees
GROUP BY Department;


-- Q7
-- Find minimum salary in each city

SELECT City,
	   MIN(Salary) AS Minimum_Salary
FROM Employees
GROUP BY City;


-- Q8
-- Find total salary per department and city

SELECT Department, City,
	   SUM(Salary) AS Total_Salary
FROM Employees
GROUP BY Department, City;


-- Q9 (slightly tricky 🔥)
-- Find departments where total salary > 150000

SELECT Department,
	   SUM(Salary) AS Total_Salary
FROM Employees
GROUP BY Department
HAVING SUM(Salary) > 150000;


-- Q10 (important concept 🚨)
-- What is wrong? Fix it

SELECT Department,
       SUM(Salary) AS Total
FROM Employees
GROUP BY Department
HAVING SUM(Salary) > 150000;

-- Find city with highest average salary

SELECT City,
	   AVG(Salary) AS Average_Salary
FROM Employees
GROUP BY City
ORDER BY Average_Salary DESC
LIMIT 1;

-- OR

SELECT City,
	   AVG(Salary) AS Average_Salary
FROM Employees
GROUP BY City
HAVING Average_Salary = (
	SELECT MAX(Average_Salary)
	FROM (
		SELECT City,
			   AVG(Salary) AS Average_Salary
		FROM Employees
		GROUP BY City
        )R
);