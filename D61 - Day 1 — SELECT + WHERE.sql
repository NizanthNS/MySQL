USE Daily_SQL;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    City VARCHAR(50),
    Experience INT,
    Join_Date DATE
);

INSERT INTO Employees 
VALUES	(1, 'Arun',    'HR',        40000, 'Chennai',   2, '2023-01-10'), 
		(2, 'Meena',   'IT',        70000, 'Bangalore', 5, '2022-03-15'),
		(3, 'Ravi',    'Finance',   65000, 'Chennai',   4, '2021-07-01'),
		(4, 'Priya',   'IT',        72000, 'Hyderabad', 6, '2024-02-20'),
		(5, 'Karthik', 'HR',        45000, 'Bangalore', 3, '2020-11-11'),
		(6, 'Divya',   'Finance',   80000, 'Chennai',   7, '2023-06-05'),
		(7, 'Sanjay',  'IT',        55000, 'Pune',      2, '2022-09-18'),
		(8, 'Nisha',   'Marketing', 50000, 'Chennai',   1, '2024-01-12'),
		(9, 'Vikram',  'Marketing', 62000, 'Hyderabad', 4, '2021-04-25'),
		(10,'Aarthi',  'IT',        68000, 'Bangalore', 5, '2023-08-30');
        

-- Day 1 : SELECT + WHERE


-- Q1
-- Display all columns from the Employees table.

SELECT *
FROM Employees;


-- Q2
-- Show only:
-- Name
-- Department
-- Salary
-- from the Employees table.

SELECT Name, Department, Salary
FROM Employees;


-- Q3
-- Show employees who work in the IT department.

SELECT Emp_ID, Name
FROM Employees
WHERE Department = 'IT';


-- Q4
-- Show employees:
-- 1. From Chennai
-- 2. Salary greater than 60000

SELECT Emp_ID, Name, City, Salary
FROM Employees
WHERE City = 'Chennai'
AND Salary > 60000;


-- Q5
-- Show employees whose department is either:
-- HR
-- Finance

SELECT Emp_ID, Name, Department
FROM Employees
WHERE Department IN ('HR', 'Finance');


-- Q6
-- Show employees whose name starts with:
-- A
-- OR
-- P

SELECT Emp_ID, Name
FROM Employees
WHERE Name LIKE 'A%'
OR Name LIKE 'P%';


-- Bonus Debugging Question

SELECT *
FROM Employees
WHERE City = 'Chennai'
OR Salary > 60000
AND Department = 'IT';

-- Requirement:
-- Employees from Chennai
-- OR employees in IT department
-- with salary greater than 60000

-- Rewrite the query correctly.

-- ANSWER

SELECT *
FROM Employees
WHERE City = 'Chennai'
OR (
    Department = 'IT'
    AND Salary > 60000
);