USE Daily_SQL;

CREATE TABLE Employees (
    Emp_ID INT,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    Hire_Date DATE,
    City VARCHAR(50)
);

INSERT INTO Employees 
VALUES	(1, 'Arun',  'IT',      60000, '2023-01-10', 'Chennai'),
		(2, 'Meena', 'HR',      50000, '2022-05-20', 'Mumbai'),
		(3, 'Ravi',  'IT',      70000, '2021-03-15', 'Chennai'),
		(4, 'Priya', 'Finance', 65000, '2023-07-01', 'Delhi'),
		(5, 'Karan', 'IT',      40000, '2020-11-11', 'Mumbai'),
		(6, 'Sneha', 'HR',      55000, '2022-08-08', 'Chennai'),
		(8, 'Anu',   'IT',      30000, '2024-01-01', 'Bangalore'),
		(9, 'Raj',   'HR',      45000, '2023-03-03', 'Mumbai'),
		(10,'Divya', 'Finance', 75000, '2022-09-09', 'Chennai');
        
SELECT *
FROM Employees;


-- Q1
-- Show all employees

SELECT *
FROM Employees;

-- Q2
-- Show only Name and Salary

SELECT Name, Salary
FROM Employees;


-- Q3
-- Employees with Salary > 60000

SELECT Emp_ID, Name, Salary
FROM Employees
WHERE Salary > 60000;


-- Q4
-- Employees from Chennai

SELECT Emp_ID, Name, City
FROM Employees
WHERE City = 'Chennai';


-- Q5
-- Employees from IT department AND salary > 50000

SELECT Emp_ID, Name, Department, Salary
FROM Employees
WHERE Department = 'IT'
AND Salary > 50000;


-- Q6
-- Employees from HR OR Finance

SELECT Emp_ID, Name, Department
FROM Employees
WHERE Department = 'HR' 
   OR Department = 'Finance';


-- Q7
-- Employees whose salary is BETWEEN 40000 AND 70000

SELECT Emp_ID, Name, Salary
FROM Employees
WHERE Salary BETWEEN 40000 AND 70000;

-- OR

SELECT Emp_ID, Name, Salary
FROM Employees
WHERE Salary >= 40000 AND Salary <= 70000;


-- Q8
-- Employees whose city is IN ('Chennai', 'Mumbai')

SELECT Emp_ID, Name, City
FROM Employees
WHERE City IN ('Chennai', 'Mumbai');


-- Q9
-- Employees whose name starts with 'A'

SELECT Emp_ID, Name
FROM Employees
WHERE Name LIKE 'A%';


-- Q10 (tiny tricky 🔥)
-- Employees whose salary is NOT between 50000 and 70000

SELECT Emp_ID, Name, Salary
FROM Employees
WHERE Salary NOT BETWEEN 50000 AND 70000;