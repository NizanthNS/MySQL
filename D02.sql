CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    manager_id INT
);


CREATE TABLE Projects (
    project_id INT PRIMARY KEY,
    emp_id INT,
    project_name VARCHAR(50),
    hours_worked INT
);


INSERT INTO Employees
VALUES		(1, 'Arjun', 'IT', 60000, NULL),
			(2, 'Meera', 'HR', 45000, 1),
			(3, 'Karan', 'IT', 70000, 1),
			(4, 'Divya', 'Finance', 50000, 1),
			(5, 'Rohit', 'IT', 55000, 3),
			(6, 'Sneha', 'HR', 48000, 2),
			(7, 'Vikram', 'Finance', 52000, 4),
			(8, 'Anita', 'IT', 62000, 3);
            
Select *
From Employees;


INSERT INTO Projects 
VALUES	(101, 1, 'Website', 120),
		(102, 3, 'Mobile App', 150),
		(103, 5, 'API Development', 90),
		(104, 2, 'Recruitment System', 60),
		(105, 4, 'Budget Analysis', 80),
		(106, 3, 'Cloud Migration', 110),
		(107, 8, 'Security Upgrade', 95),
		(108, 6, 'Training Portal', 70),
		(109, 7, 'Audit Tool', 85),
		(110, 5, 'Automation Script', 75);
        
Select *
From Projects;


-- 1. Show all employees in the IT department

Select *
From Employees
WHERE department = 'IT';


-- 2. Show employees with salary greater than 60,000

Select *
From Employees
WHERE salary > 60000;


-- 3. Show employee names and project names they are working on

Select Employees.emp_name, Projects.project_name
From Employees
INNER JOIN Projects
	ON Employees.emp_id = Projects.emp_id;


-- 4. Find the total hours worked by each employee

Select Employees.emp_name, SUM(Projects.hours_worked) AS Total_Hours_Worked
From Employees
INNER JOIN Projects
	ON Employees.emp_id = Projects.emp_id
GROUP BY Employees.emp_name;


-- 5. Find the highest salary in the company

Select *
From Employees
WHERE salary = (Select MAX(salary) From Employees);

-- OR

Select *
From Employees
ORDER BY salary DESC
LIMIT 1;


-- 6. Show employees who do not have a manager

Select *
From Employees
WHERE manager_id IS NULL;


-- 7. Count number of employees in each department

Select department, COUNT(emp_id) AS No_of_Emp_By_Department
From Employees
GROUP BY department;


-- 8. Find the employee who worked the most hours on projects

Select Employees.emp_name, SUM(Projects.hours_worked) AS Total_Hours_Worked
From Employees
INNER JOIN Projects
	ON Employees.emp_id = Projects.emp_id
GROUP BY Employees.emp_name, Employees.emp_id
ORDER BY Total_Hours_Worked DESC
LIMIT 1;


-- 9. Show employees whose salary is above the average salary

Select *
From Employees
WHERE salary > (Select AVG(salary) From Employees);
    

-- 10. Find the department with the highest average salary

Select department, AVG(salary) AS Average_Salary
From Employees
GROUP BY department
ORDER BY Average_Salary DESC
LIMIT 1;