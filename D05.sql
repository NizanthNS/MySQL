CREATE TABLE Employees (
	emp_id INT PRIMARY KEY,
	emp_name VARCHAR(50),
	department VARCHAR(50),
	salary INT
);


CREATE TABLE Projects (
	project_id INT PRIMARY KEY,
	emp_id INT,
	project_name VARCHAR(50),
	hours_worked INT
);


INSERT INTO Employees 
VALUES	(1,'Arun','IT',70000),
		(2,'Meena','HR',50000),
		(3,'Ravi','IT',80000),
		(4,'Divya','Finance',60000),
		(5,'Karan','IT',75000),
		(6,'Sneha','HR',55000);


INSERT INTO Projects 
VALUES	(101,1,'Website',120),
		(102,1,'Database',80),
		(103,3,'Mobile App',150),
		(104,4,'Audit System',90),
		(105,5,'AI Tool',200),
		(106,2,'Recruitment',60),
		(107,6,'Training',70);


SELECT *
FROM Employees;

SELECT *
FROM Projects;


-- 1. Show all employees in the IT department

SELECT *
FROM Employees
WHERE department = 'IT';


-- 2. Show employees with salary greater than 65000

SELECT *
FROM Employees
WHERE salary > 65000;


-- 3. Show employee names and their project names

SELECT Employees.emp_name, Projects.project_name
FROM Employees
INNER JOIN Projects
	ON Employees.emp_id = Projects.emp_id;


-- 4. Find total hours worked by each employee

SELECT Employees.emp_id, Employees.emp_name, SUM(hours_worked) AS Total_Hours_Worked
FROM Employees
INNER JOIN Projects
	ON Employees.emp_id = Projects.emp_id
    GROUP BY Employees.emp_id, Employees.emp_name;


-- 5. Find the highest salary

SELECT *
FROM Employees
WHERE salary = (SELECT MAX(salary) FROM Employees);

-- OR

SELECT *
FROM Employees
ORDER BY salary DESC
LIMIT 1;


-- 6. Show employees who are not assigned to any project

SELECT *
FROM Employees
LEFT JOIN Projects
	ON Employees.emp_id = Projects.emp_id
	WHERE project_id IS NULL;


-- 7. Count employees in each department

SELECT department, COUNT(*) AS Employees_by_Department
FROM Employees
GROUP BY department;


-- 8. Find the employee who worked the most hours

SELECT Employees.emp_name, Employees.emp_id, SUM(Projects.hours_worked) AS Hours
FROM Employees
INNER JOIN Projects
	ON Employees.emp_id = Projects.emp_id
    GROUP BY Employees.emp_name, Employees.emp_id
    ORDER BY Hours DESC
    LIMIT 1;
    
-- OR

SELECT Employees.emp_name, Employees.emp_id, SUM(Projects.hours_worked) AS Hours
FROM Employees
INNER JOIN Projects
	ON Employees.emp_id = Projects.emp_id
    GROUP BY Employees.emp_id, Employees.emp_name
    HAVING Hours = (
		SELECT MAX(Hours)
        FROM (
			SELECT SUM(hours_worked) AS Hours
			FROM Projects
			GROUP BY emp_id
			) T
);


-- 9. Show employees whose salary is above the average salary

SELECT *
FROM Employees
WHERE salary > (
		SELECT AVG(salary)
		FROM Employees);


-- 10. Find the department with the highest total salary

SELECT department, SUM(salary) AS Highest_Salary
FROM Employees
GROUP BY department
ORDER BY Highest_Salary DESC
LIMIT 1;

-- OR

SELECT department, SUM(salary) AS Total_Salary
FROM Employees
GROUP BY department
HAVING SUM(salary) = (
	SELECT MAX(Total_Salary)
    FROM (
		SELECT SUM(salary) AS Total_Salary
        FROM Employees
        GROUP BY department
        ) H
);


CREATE TABLE Sales (
	sale_id INT,
	product VARCHAR(50),
	amount INT
);


INSERT INTO Sales 
VALUES	(1,'Laptop',60000),
		(2,'Mobile',20000),
		(3,'Laptop',65000),
		(4,'Mouse',1000),
		(5,'Mobile',22000),
		(6,'Keyboard',2000),
		(7,'Laptop',62000),
		(8,'Mouse',1200);

SELECT *
FROM Sales;


-- 1. Find Duplicate Products

SELECT  product, COUNT(*)
FROM Sales
GROUP BY product
HAVING COUNT(*) > 1;


-- 2. Second Highest Sale Amount

SELECT MAX(amount) AS Second_Highest_Sale_Amount
FROM Sales
WHERE amount < (
	SELECT MAX(amount) 
    FROM Sales);
    
-- OR

SELECT amount AS Second_Highest_Sale_Amount
FROM Sales
ORDER BY amount DESC
LIMIT 1 OFFSET 1;


-- 3. Product With Highest Total Sales

SELECT product, SUM(amount) AS Highest_Total_Sales
FROM Sales
GROUP BY product
ORDER BY SUM(amount) DESC
LIMIT 1;

 -- OR 
 
 SELECT product, SUM(amount) AS Highest_Total_Sales
 FROM Sales
 GROUP BY product
 HAVING Highest_Total_Sales = (
	SELECT MAX(Highest_Total_Sales)
    FROM (
		SELECT SUM(amount) AS Highest_Total_Sales
        FROM Sales
        GROUP BY product
        ) H
);

