USE Daily_SQL;


SELECT *
FROM Employees;


-- Q1
-- Show employees with Salary > 60000

SELECT Emp_ID, Name, Salary
FROM Employees
WHERE Salary > 60000;


-- Q2
-- Show departments where total salary > 150000

SELECT Department,
	   SUM(Salary) AS Total_Salary
FROM Employees
GROUP BY Department
HAVING SUM(Salary) > 150000;


-- Q3
-- Show cities where average salary > 60000

SELECT City,
	   AVG(Salary) AS Average
FROM Employees
GROUP BY City
HAVING AVG(Salary) > 60000;


-- Q4
-- Show departments having more than 2 employees

SELECT Department,
	   COUNT(Emp_ID) AS Total_Emp
FROM Employees
GROUP BY Department
HAVING COUNT(Emp_ID) > 2;


-- Q5
-- Show employees from IT department with salary > 50000

SELECT Emp_ID, Name, Department, Salary
FROM Employees
WHERE Department = 'IT'
AND	Salary > 50000;


-- Q6 (mix 🔥)
-- Show departments where total salary > 150000 
-- AND average salary > 60000

SELECT Department,
	   SUM(Salary) AS Total_Salary,
	   AVG(Salary) AS Average
FROM Employees
GROUP BY Department
HAVING SUM(Salary) > 150000
AND AVG(Salary) > 60000;


-- Q7 (tricky 🚨)
-- Show cities where MIN salary > 40000

SELECT City,
	   MIN(Salary) AS Minimum_Salary
FROM Employees
GROUP BY City
HAVING MIN(Salary) > 40000;


-- Q8 (debug 🔧)
-- What is wrong? Fix it

SELECT Department,
       SUM(Salary)
FROM Employees
GROUP BY Department
HAVING SUM(Salary) > 150000;


-- Q9 (combo 🔥)
-- Show departments with more than 2 employees 
-- AND total salary > 150000

SELECT Department,
	   COUNT(Emp_ID) AS Total_Emp,
       SUM(Salary) AS Total_Salary
FROM Employees
GROUP BY Department
HAVING COUNT(Emp_ID) > 2
AND SUM(Salary) > 150000;


-- Q10 (thinking 🚀)
-- Show employees whose salary is above the 
-- average salary of their department

SELECT *
FROM (
	SELECT Emp_ID, Name, Salary, Department,
		   AVG(Salary) OVER(PARTITION BY Department) AS Average
	FROM Employees
)R
WHERE Salary > Average;

-- OR

SELECT Emp_ID, Name, Salary, Department
FROM Employees E
WHERE Salary > (
	SELECT AVG(Salary)
    FROM Employees
    WHERE Department = E.Department
);