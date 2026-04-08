CREATE DATABASE Employees;


USE Employees;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT
);

INSERT INTO Employees 
VALUES	(1, 'Arun', 'IT', 50000),
		(2, 'Meena', 'IT', 70000),
		(3, 'Ravi', 'HR', 40000),
		(4, 'Priya', 'HR', 60000),
		(5, 'Kiran', 'IT', 60000),
		(6, 'Sneha', 'HR', 45000);

SELECT *
FROM Employees;


-- Get total salary per department

SELECT Department,
	   SUM(Salary) AS Total_Salary
FROM Employees
GROUP BY Department;


-- Show each employee + total salary of their department

SELECT Name,
       Department,
       SUM(Salary) OVER(PARTITION BY Department) AS Total_Salary
FROM Employees;


-- Highest salary per department (per employee row)

SELECT Name,
       Department,
       Salary,
       MAX(Salary) OVER(PARTITION BY Department) AS Highest_Salary
FROM Employees;


-- Running total per department

SELECT *,
	   SUM(Salary) OVER(PARTITION BY Department 
       ORDER BY Emp_ID) AS Running_total
FROM Employees;


-- Show employees who have the 2nd highest salary in each department

SELECT *
FROM (
	SELECT Emp_ID, Name, Department, Salary,
		   RANK() OVER(PARTITION BY Department
           ORDER BY Salary DESC) AS Rnk
	FROM Employees
    )R
WHERE Rnk = 2;

-- OR

SELECT *
FROM (
	SELECT Emp_ID, Name, Department, Salary,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Salary DESC) AS Rnk
	FROM Employees
    )R
WHERE Rnk = 2;


-- Compare with Department Average

SELECT Name, Salary,
	   AVG(Salary) OVER(PARTITION BY Department) AS Average_Salary,
       Salary - AVG(Salary) OVER(PARTITION BY Department) AS Difference
FROM Employees;

-- OR

WITH CTE AS (
    SELECT Name,
           Salary,
           Department,
           AVG(Salary) OVER(PARTITION BY Department) AS Avg_Salary
    FROM Employees
)
SELECT *,
       Salary - Avg_Salary AS difference
FROM CTE;


-- Flag Highest Earners

SELECT Name,
	   Department,
       Salary,
       CASE
			WHEN Salary = MAX(Salary) OVER(PARTITION BY Department)
            THEN 'YES'
            ELSE 'NO'
	   END AS Highest_Earner
FROM Employees;


-- Cumulative % Contribution

SELECT Name,
       Salary,
       ROUND(Salary * 100.0 / SUM(Salary) 
       OVER(PARTITION BY Department), 2) AS Percentage
FROM Employees;


-- Previous Employee Salary

SELECT Name, Salary,
	   LAG(Salary) OVER(ORDER BY Emp_ID) AS Previous_Salary
FROM Employees;

-- OR

SELECT Name, Salary, Department,
	   LAG(Salary) OVER(PARTITION BY Department
       ORDER BY Emp_ID) AS Previous_Salary
FROM Employees;










        
        