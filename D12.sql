CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department_id INT,
    salary INT
);

INSERT INTO Employees
VALUES	(1, 'Arun', 10, 60000),
		(2, 'Meena', 20, 75000),
		(3, 'Ravi', 10, 50000),
		(4, 'Divya', 30, 90000),
		(5, 'Karan', 20, 80000),
		(6, 'Sneha', 10, 65000);


CREATE TABLE Departments (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(50)
);

INSERT INTO Departments 
VALUES	(10, 'IT'),
		(20, 'HR'),
		(30, 'Finance');


CREATE TABLE Projects (
    Project_ID INT,
    Employee_ID INT,
    Hours_Worked INT
);

INSERT INTO Projects 
VALUES	(101, 1, 5),
		(101, 3, 7),
		(102, 2, 6),
		(102, 5, 4),
		(103, 4, 8),
		(103, 6, 3),
		(101, 6, 6),
		(102, 1, 2);


SELECT *
FROM Employees;


SELECT *
FROM Departments;


SELECT *
FROM Projects;


-- 1. Show the highest paid employee in each department

SELECT *
FROM (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           Employees.Salary,
           Employees.Department_ID,
           Departments.Department_Name,
           RANK() OVER(PARTITION BY Employees.Department_ID
           ORDER BY Employees.Salary DESC) AS Rank_
	FROM Employees
    INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
	) R
WHERE Rank_ = 1;

-- 2. Show the top 2 employees by total hours worked

SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(ORDER BY Total_Hours DESC) AS Row_Num
	FROM (
		  SELECT Employees.Employee_ID,
				 Employees.Employee_Name,
                 SUM(Projects.Hours_Worked) AS Total_Hours
		  FROM Employees
          INNER JOIN Projects
			ON Employees.Employee_ID = Projects.Employee_ID
		  GROUP BY Employees.Employee_ID, Employees.Employee_Name
          )R
	)T
WHERE Row_Num <= 2;

-- 3. Show the employee who worked the least hours in each department

SELECT *
FROM (
		SELECT Employees.Employee_ID,
			   Employees.Employee_Name,
               Employees.Department_ID,
			   Departments.Department_Name,
               SUM(Projects.Hours_Worked) AS Total_Hours,
               ROW_NUMBER() OVER(PARTITION BY Employees.Department_ID
               ORDER BY SUM(Projects.Hours_Worked) ASC) AS Row_Num
		FROM Employees
        INNER JOIN Departments
			ON Employees.Department_ID = Departments.Department_ID
		INNER JOIN Projects
			ON Employees.Employee_ID = Projects.Employee_ID
		GROUP BY Employees.Employee_ID, Employees.Employee_Name, 
				 Employees.Department_ID, Departments.Department_Name
		)R
WHERE Row_Num = 1;

-- OR

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY Department_ID
		   ORDER BY Total_Hours ASC) AS Row_Num
    FROM (
        SELECT Employees.Employee_ID,
               Employees.Employee_Name,
               Employees.Department_ID,
               Departments.Department_Name,
               SUM(Projects.Hours_Worked) AS Total_Hours
        FROM Employees
        INNER JOIN Projects
            ON Employees.Employee_ID = Projects.Employee_ID
		INNER JOIN Departments
			ON Employees.Department_ID = Departments.Department_ID
        GROUP BY Employees.Employee_ID,
                 Employees.Employee_Name,
                 Employees.Department_ID,
                 Departments.Department_Name
    ) T
) R
WHERE Row_Num = 1;


-- 4. Show the most hardworking employee per project (highest hours)

SELECT *
FROM (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           Projects.Project_ID,
           Projects.Hours_Worked,
           RANK() OVER(PARTITION BY Projects.Project_ID
           ORDER BY Projects.Hours_Worked DESC) AS Rank_
	FROM Employees
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	) T
WHERE Rank_ = 1;


-- 5. Show the employee with the lowest salary overall

SELECT *
FROM (
	SELECT Employee_ID, Employee_Name, Salary,
	ROW_NUMBER () OVER (ORDER BY Salary ASC) AS Row_Num
	FROM Employees
 )R
WHERE Row_Num = 1;





