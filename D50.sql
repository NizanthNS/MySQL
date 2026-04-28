CREATE TABLE Employee_Data (
    Emp_ID INT,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT
);

INSERT INTO Employee_Data 
VALUES	(1, 'Arun', 'IT', 50000),
		(2, 'Meena', 'HR', 40000),
		(3, 'Ravi', 'IT', 60000),
		(4, 'Priya', 'Finance', 55000),
		(5, 'Kumar', 'HR', 45000),
		(6, 'Anita', 'Finance', 70000);


SELECT *
FROM Employee_Data;


-- Find employees who earn more than average salary

SELECT Name, Salary
FROM Employee_Data
WHERE Salary > (
	SELECT AVG(Salary) 
    FROM Employee_Data
);


-- Find employees with highest salary in the table

SELECT Name, Salary
FROM Employee_Data
WHERE Salary = (
	SELECT MAX(Salary) 
    FROM Employee_Data
);


-- Find employees who earn more than the average salary of their department

SELECT Name, Department, Salary
FROM Employee_Data E
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Employee_Data
    WHERE Department = E.Department
);


-- Find departments where average salary is greater than 50000

SELECT Department
FROM Employee_Data
GROUP BY Department
HAVING AVG(Salary) > 50000;


-- Find the second highest salary

SELECT MAX(Salary) AS Second_Highest
FROM Employee_Data
WHERE Salary < (
	SELECT MAX(Salary) 
    FROM Employee_Data
);