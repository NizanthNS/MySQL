USE Daily_SQL;


CREATE TABLE Employee_Salary (
    Emp_ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    Join_Year INT
);

INSERT INTO Employee_Salary
VALUES  (1, 'Arun',    'HR',        40000, 2021),
        (2, 'Meena',   'IT',        70000, 2019),
        (3, 'Ravi',    'Finance',   65000, 2020),
        (4, 'Priya',   'IT',        72000, 2018),
        (5, 'Karthik', 'HR',        45000, 2022),
        (6, 'Divya',   'Finance',   80000, 2017),
        (7, 'Sanjay',  'IT',        55000, 2023),
        (8, 'Nisha',   'Marketing', 50000, 2024),
        (9, 'Vikram',  'Marketing', 62000, 2020),
        (10,'Aarthi',  'IT',        68000, 2021);
        

SELECT *
FROM Employee_Salary;


-- Day 8 : Window Functions


-- Q1
-- Assign a row number to all employees
-- ordered by Salary descending.

SELECT Emp_ID, Name, Salary,
	   ROW_NUMBER() OVER(ORDER BY Salary DESC) AS Row_Num
FROM Employee_Salary;


-- Q2
-- Rank employees based on Salary
-- using RANK().

SELECT Emp_ID, Name, Salary,
	   RANK() OVER(ORDER BY Salary DESC) AS Rank_
FROM Employee_Salary;


-- Q3
-- Rank employees based on Salary
-- using DENSE_RANK().

SELECT Emp_ID, Name, Salary,
	   DENSE_RANK() OVER(ORDER BY Salary DESC) AS D_Rank
FROM Employee_Salary;


-- Q4
-- Show the highest paid employee
-- in each Department.

SELECT *
FROM (
	SELECT Emp_ID, Name, Salary, Department,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Salary DESC) AS D_Rank
	FROM Employee_Salary
    )D
WHERE D_Rank = 1;


-- Q5
-- Show each employee along with:
-- 1. Their Salary
-- 2. Previous employee's Salary
-- ordered by Salary ascending.

SELECT Emp_ID, Name, Salary,
	   LAG(Salary) OVER(ORDER BY Salary) AS Previous_Employee_Salary
FROM Employee_Salary;


-- Q6
-- Show each employee along with:
-- 1. Their Salary
-- 2. Next employee's Salary
-- ordered by Salary ascending.

SELECT Emp_ID, Name, Salary,
	   LEAD(Salary) OVER(ORDER BY Salary) AS Next_Employee_Salary
FROM Employee_Salary;


-- Bonus Debugging Question

SELECT Name,
       Salary,
       ROW_NUMBER()
FROM Employee_Salary;

-- What is wrong with this query?
-- Rewrite it correctly.

-- ANSWER

SELECT Name,
       Salary,
       ROW_NUMBER() OVER(ORDER BY Salary) AS Row_Num
FROM Employee_Salary;