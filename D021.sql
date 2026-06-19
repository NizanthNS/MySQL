CREATE TABLE Departments (
    Dept_ID   INT PRIMARY KEY,
    Dept_Name VARCHAR(50),
    Location  VARCHAR(50)
);


CREATE TABLE Employees (
    Emp_ID     INT PRIMARY KEY,
    Name       VARCHAR(50),
    Dept_ID    INT,
    Salary     INT,
    Hire_Date  DATE,
    Manager_ID INT,
    FOREIGN KEY (Dept_ID) REFERENCES Departments(Dept_ID)
);


CREATE TABLE Orders (
    Order_ID   INT PRIMARY KEY,
    Emp_ID     INT,
    Product    VARCHAR(50),
    Amount     INT,
    Order_Date DATE,
    FOREIGN KEY (Emp_ID) REFERENCES Employees(Emp_ID)
);


INSERT INTO Departments 
VALUES	(10, 'Engineering', 'Bangalore'),
		(20, 'Marketing',   'Mumbai'),
		(30, 'HR',          'Chennai'),
		(40, 'Finance',     'Delhi');


INSERT INTO Employees 
VALUES	(1, 'Alice', 10, 85000, '2019-03-15', NULL),
		(2, 'Bob',   10, 72000, '2020-07-01', 1),
		(3, 'Carol', 20, 95000, '2018-01-10', NULL),
		(4, 'David', 20, 60000, '2021-11-22', 3),
		(5, 'Eve',   30, 78000, '2020-05-30', NULL),
		(6, 'Frank', 10, 91000, '2017-09-04', 1),
		(7, 'Grace', 30, 67000, '2022-02-14', 5),
		(8, 'Hank',  20, 83000, '2019-08-20', 3);


INSERT INTO Orders 
VALUES	(101, 2, 'Laptop',     1200, '2023-01-10'),
		(102, 4, 'Monitor',     400, '2023-02-18'),
		(103, 2, 'Keyboard',     80, '2023-03-05'),
		(104, 6, 'Laptop',     1200, '2023-03-20'),
		(105, 7, 'Mouse',        40, '2023-04-11'),
		(106, 4, 'Monitor',     400, '2023-05-02'),
		(107, 8, 'Headphones',  150, '2023-06-15');
        

SELECT *
FROM Departments;


SELECT *
FROM Employees;


SELECT *
FROM Orders;


-- 1. List all employees in the Engineering department with their salary.

SELECT Employees.Emp_ID,
	   Employees.Name,
       Employees.Salary,
       Departments.Dept_Name
FROM Employees
INNER JOIN Departments
	ON Employees.Dept_ID = Departments.Dept_ID
WHERE Departments.Dept_Name = 'Engineering';


-- 2. Find the total number of employees in each department.

SELECT Departments.Dept_Name,
	   COUNT(Employees.Emp_ID) AS Total_Employees
FROM Departments
LEFT JOIN Employees
	ON Employees.Dept_ID = Departments.Dept_ID
GROUP BY Departments.Dept_Name;


-- 3. Show the names of employees who were hired after January 1, 2020.
	   
SELECT Emp_ID,
	   Name,
       Salary,
       Hire_Date
FROM Employees
WHERE Hire_Date > '2020-01-01';


-- 4. Find the average salary per department, and show only departments where the average is above 75,000.

SELECT Departments.Dept_ID,
	   Departments.Dept_Name,
	   AVG(Employees.Salary) AS Average_Salary
FROM Departments
INNER JOIN Employees
	ON Employees.Dept_ID = Departments.Dept_ID
GROUP BY Departments.Dept_ID, Departments.Dept_Name
HAVING AVG(Employees.Salary) > 75000;

-- OR

WITH CTE AS (
	SELECT Departments.Dept_ID,
		   Departments.Dept_Name,
		   AVG(Employees.Salary) AS Average_Salary
	From Departments
	INNER JOIN Employees
		ON Employees.Dept_ID = Departments.Dept_ID
	GROUP BY Departments.Dept_ID, Departments.Dept_Name
)
SELECT *
FROM CTE
WHERE Average_Salary > 75000;
        

-- 5. List all departments that have no employees.

SELECT Departments.Dept_Name,
	   Employees.Emp_ID
FROM Departments
LEFT JOIN Employees
	ON Employees.Dept_ID = Departments.Dept_ID
WHERE Employees.Emp_ID IS NULL;


-- 6. For each employee, show their name and the name of their manager.

SELECT A.Name, B.Name AS Manager
FROM Employees A
LEFT JOIN Employees B
	ON A.Manager_ID = B.Emp_ID;
    

-- 7. Find the employee(s) who placed the highest total order amount.

SELECT Employees.Emp_ID,
	   Employees.Name,
       SUM(Orders.Amount) AS Total_Amount
FROM Employees
INNER JOIN Orders
	ON Employees.Emp_ID = Orders.Emp_ID
GROUP BY Employees.Emp_ID, Employees.Name
ORDER BY Total_Amount DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER() OVER(ORDER BY Total_Amount DESC) AS Row_Num
	FROM (
		SELECT Employees.Emp_ID,
			   Employees.Name,
			   SUM(Orders.Amount) AS Total_Amount
		FROM Employees
		INNER JOIN Orders
			ON Employees.Emp_ID = Orders.Emp_ID
		GROUP BY Employees.Emp_ID, Employees.Name
            )T
		)R
WHERE Row_Num = 1;


-- 8. Rank employees within each department by salary (highest first) using a window function.

SELECT *
FROM (
	SELECT Departments.Dept_ID,
		   Departments.Dept_Name,
           Employees.Emp_ID,
           Employees.Name,
           Employees.Salary,
           RANK() OVER(PARTITION BY Departments.Dept_ID
           ORDER BY Employees.Salary DESC) AS Rank_
	FROM Employees
	INNER JOIN Departments
		ON Employees.Dept_ID = Departments.Dept_ID
	)T
WHERE Rank_ <= 1;

-- 9. Find employees whose salary is above their department's average salary.

SELECT *
FROM (
	SELECT Departments.Dept_ID,
		   Departments.Dept_Name,
           Employees.Emp_ID,
           Employees.Name,
           Employees.Salary,
		   AVG(Employees.Salary) OVER(PARTITION BY Employees.Dept_ID) AS Average
	FROM Employees
	INNER JOIN Departments
		ON Employees.Dept_ID = Departments.Dept_ID
	)T
WHERE Salary > Average;


-- 10. For each month in 2023, calculate the running total of order amounts.

SELECT 
    Month_,
    Monthly_Total,
    SUM(Monthly_Total) OVER (ORDER BY Month_
    ) AS Running_Total
FROM (
    SELECT 
        MONTH(Order_Date) AS Month_,
        SUM(Amount) AS Monthly_Total
    FROM Orders
    WHERE YEAR(Order_Date) = 2023
    GROUP BY MONTH(Order_Date)
) T;

-- OR

WITH CTE AS (
	SELECT MONTH(Order_Date) AS Month_,
		   SUM(Amount) AS Monthly_Total
	FROM Orders
	WHERE YEAR(Order_Date) = 2023
	GROUP BY MONTH(Order_Date)
	)
SELECT Month_,
	   Monthly_Total,
	   SUM(Monthly_Total) OVER (ORDER BY Month_) AS Running_Total
FROM CTE;






