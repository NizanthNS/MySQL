USE Daily_SQL;

SELECT *
FROM Employees;


-- Q1
-- Show all employees ordered by Salary (ascending)

SELECT Emp_ID, Name, Salary
FROM Employees
ORDER BY Salary;


-- Q2
-- Show all employees ordered by Salary (descending)

SELECT Emp_ID, Name, Salary
FROM Employees
ORDER BY Salary DESC;


-- Q3
-- Show top 3 highest paid employees

SELECT Emp_ID, Name, Salary
FROM Employees
ORDER BY Salary DESC
LIMIT 3;


-- Q4
-- Show lowest 2 salaries

SELECT Emp_ID, Name, Salary
FROM Employees
ORDER BY Salary
LIMIT 2;


-- Q5
-- Show employees ordered by Department, then Salary (descending)

SELECT Emp_ID, Name, Department, Salary
FROM Employees
ORDER BY Department, Salary DESC;


-- Q6
-- Show top 2 highest paid employees from IT department

SELECT Emp_ID, Name, Department, Salary
FROM Employees
WHERE Department = 'IT'
ORDER BY Salary DESC
LIMIT 2;

-- OR

SELECT *
FROM (
	SELECT Emp_ID, Name, Department, Salary,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Salary DESC) AS D_Rank
	FROM Employees
	WHERE Department = 'IT'
)R
WHERE D_Rank <= 2;


-- Q7
-- Show the 2nd highest salary

SELECT Emp_ID, Name, Salary
FROM Employees
ORDER BY Salary DESC
LIMIT 1 OFFSET 1;

-- OR

SELECT MAX(Salary) AS Second_Highest_Salary
FROM Employees
WHERE Salary < (
	SELECT MAX(Salary) AS Second_Highest_Salary
    FROM Employees
);


-- Q8 (slightly tricky 🔥)
-- Show top 3 salaries (handle ties properly)

SELECT *
FROM (
	SELECT Emp_ID, Name, Salary,
		   DENSE_RANK() OVER(ORDER BY Salary DESC) AS D_Rank
	FROM Employees
)R
WHERE D_Rank <= 3;


-- Q9 (important 🚨)
-- Show employees ordered by Name alphabetically, but Salary descending within same name

SELECT Emp_ID, Name, Salary
FROM Employees
ORDER BY Name ASC, Salary DESC;


-- Q10 (offset concept 🔥)
-- Show 3rd and 4th highest paid employees

SELECT Emp_ID, Name, Salary
FROM Employees
ORDER BY Salary DESC
LIMIT 2 OFFSET 2;

-- OR

SELECT *
FROM (
	SELECT Emp_ID, Name, Salary,
		   DENSE_RANK() OVER(ORDER BY Salary DESC) AS D_Rank
	FROM Employees
)R
WHERE D_Rank IN (3, 4);