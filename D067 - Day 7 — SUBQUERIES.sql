USE Daily_SQL;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    Experience INT
);

INSERT INTO Employees
VALUES  (1, 'Arun',    'HR',        40000, 2),
        (2, 'Meena',   'IT',        70000, 5),
        (3, 'Ravi',    'Finance',   65000, 4),
        (4, 'Priya',   'IT',        72000, 6),
        (5, 'Karthik', 'HR',        45000, 3),
        (6, 'Divya',   'Finance',   80000, 7),
        (7, 'Sanjay',  'IT',        55000, 2),
        (8, 'Nisha',   'Marketing', 50000, 1),
        (9, 'Vikram',  'Marketing', 62000, 4),
        (10,'Aarthi',  'IT',        68000, 5);
        

SELECT *
FROM Employees;


-- Day 7 : Subqueries


-- Q1
-- Show employees whose Salary is greater than
-- the average Salary of all employees.

SELECT Emp_ID, Name, Salary
FROM Employees
WHERE Salary > (
	SELECT AVG(Salary)
    FROM Employees
);


-- Q2
-- Show employees who work in the same Department
-- as 'Meena'.

SELECT Emp_ID, Name
FROM Employees
WHERE Department = (
	SELECT Department
    FROM Employees
    WHERE Name = 'Meena'
);


-- Q3
-- Find employees whose Salary is equal to
-- the highest Salary in the company.

SELECT Emp_ID, Name, Salary
FROM Employees
WHERE Salary = (
	SELECT MAX(Salary)
    FROM Employees
);


-- Q4
-- Show employees whose Experience is greater than
-- the minimum Experience in the IT department.

SELECT Emp_ID, Name, Department, Experience
FROM Employees
WHERE Department = 'IT'
AND Experience > (
	SELECT MIN(Experience)
    FROM Employees
    WHERE Department = 'IT'
);


-- Q5
-- Find employees who earn more than
-- the average Salary of their own Department.

SELECT Emp_ID, Name, Salary, Department
FROM Employees E1
WHERE Salary > (
	SELECT AVG(Salary)
    FROM Employees E2
    WHERE E1.Department = E2.Department
);


-- Q6
-- Show the second highest Salary in the Employees table.

SELECT MAX(Salary) AS Second_Highest_Salary
FROM Employees
WHERE Salary < (
	SELECT MAX(Salary)
	FROM Employees
);


-- Bonus Debugging Question

SELECT Name, Salary
FROM Employees
WHERE Salary > AVG(Salary);

-- What is wrong with this query?
-- Rewrite it correctly.

-- ANSWER

SELECT Name, Salary
FROM Employees
WHERE Salary > (
	SELECT AVG(Salary)
    FROM Employees
);