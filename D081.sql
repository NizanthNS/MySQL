USE Daily_SQL;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees
VALUES  (1, 'Arun',   'IT'),
        (2, 'Meena',  'HR'),
        (3, 'Ravi',   'Finance'),
        (4, 'Priya',  'IT'),
        (5, 'Divya',  'Finance');
        

CREATE TABLE Salary_History (
    Salary_ID INT PRIMARY KEY,
    Emp_ID INT,
    Salary_Amount INT,
    Effective_Date DATE
);

INSERT INTO Salary_History
VALUES  (101, 1, 50000, '2024-01-01'),
        (102, 1, 55000, '2024-02-01'),
        (103, 2, 45000, '2024-01-10'),
        (104, 3, 60000, '2024-01-15'),
        (105, 1, 58000, '2024-03-01'),
        (106, 4, 52000, '2024-01-20'),
        (107, 5, 61000, '2024-01-25'),
        (108, 3, 65000, '2024-02-15'),
        (109, 2, 47000, '2024-02-20'),
        (110, 4, 56000, '2024-03-05'),
        (111, 5, 67000, '2024-03-10'),
        (112, 1, 62000, '2024-04-01');
        

SELECT *
FROM Employees;

SELECT *
FROM Salary_History;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each employee along with:
-- 1. Number of salary records
-- 2. Total Salary Amount
-- 3. Average Salary Amount
-- ordered by Total Salary Amount descending.

SELECT E.Emp_ID, E.Employee_Name,
	   COUNT(S.Salary_ID) AS Salary_Records,
       SUM(S.Salary_Amount) AS Total_Salary,
       ROUND(AVG(S.Salary_Amount), 2) AS Average_Salary
FROM Employees E
INNER JOIN Salary_History S
	ON E.Emp_ID = S.Emp_ID
GROUP BY E.Emp_ID, E.Employee_Name
ORDER BY Total_Salary DESC;


-- Q2
-- Find employees whose total salary amount
-- is greater than the average total salary amount
-- of all employees.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name,
		   SUM(S.Salary_Amount) AS Total_Salary
	FROM Employees E
	INNER JOIN Salary_History S
		ON E.Emp_ID = S.Emp_ID
	GROUP BY E.Emp_ID, E.Employee_Name
)
SELECT *
FROM CTE
WHERE Total_Salary > (
	SELECT AVG(Total_Salary)
    FROM CTE
);


-- Q3
-- Show the employee with the highest total salary amount
-- in each Department.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, E.Department,
		   SUM(S.Salary_Amount) AS Total_Salary
	FROM Employees E
	INNER JOIN Salary_History S
		ON E.Emp_ID = S.Emp_ID
	GROUP BY E.Emp_ID, E.Employee_Name, E.Department
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Total_Salary DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank = 1;


-- Q4
-- Show employees who received
-- more than one salary update within the same month.

SELECT E.Emp_ID, E.Employee_Name,
	   COUNT(S.Salary_ID) AS Total_Salary_ID,
       YEAR(S.Effective_Date) AS Year_,
       MONTH(S.Effective_Date) AS Month_
FROM Employees E
INNER JOIN Salary_History S
	ON E.Emp_ID = S.Emp_ID
GROUP BY E.Emp_ID, E.Employee_Name, 
		 YEAR(S.Effective_Date), MONTH(S.Effective_Date)
HAVING COUNT(S.Salary_ID) > 1;


-- Q5
-- Show each salary record along with:
-- 1. Previous Salary_Amount of that employee
-- 2. Difference from previous Salary_Amount
-- 3. Running total Salary_Amount of that employee

WITH CTE AS (
	SELECT Salary_ID, Emp_ID, Salary_Amount, Effective_Date,
		   LAG(Salary_Amount) OVER(PARTITION BY Emp_ID
           ORDER BY Effective_Date) AS Previous_Amount,
           SUM(Salary_Amount) OVER(PARTITION BY Emp_ID
           ORDER BY Effective_Date) AS Running_Total
	FROM Salary_History
),
CTE2 AS (
	SELECT *,
		   Salary_Amount - Previous_Amount AS Difference
	FROM CTE
    WHERE Previous_Amount IS NOT NULL
)
SELECT Salary_ID, Emp_ID, Salary_Amount, 
	   Previous_Amount, Running_total, Difference
FROM CTE2;


-- Q6 (Date Logic)
-- Find employees who received another salary update
-- within 35 days of their previous update.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, S.Effective_Date,
		   LAG(S.Effective_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY S.Effective_Date, S.Salary_ID) AS Previous_Date
	FROM Employees E
	INNER JOIN Salary_History S
		ON E.Emp_ID = S.Emp_ID
)
SELECT DISTINCT Emp_ID, Employee_Name
FROM CTE 
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Effective_Date, Previous_Date) <= 35;


-- Bonus Challenge
-- Show:
-- 1. Employee_Name
-- 2. First Effective_Date
-- 3. Latest Effective_Date
-- 4. Total Salary Records
-- 5. Total Salary Amount
-- 6. Average Days Between Salary Updates

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, S.Effective_Date, 
		   S.Salary_ID, S.Salary_Amount,
           LAG(S.Effective_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY S.Effective_Date, S.Salary_ID) AS Previous_Date
	FROM Employees E
	INNER JOIN Salary_History S
		ON E.Emp_ID = S.Emp_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Effective_Date, Previous_Date) AS Days_Gap
	FROM CTE
),
CTE3 AS (
	SELECT Emp_ID, Employee_Name,
		   MIN(Effective_Date) AS First_Effective_Date,
           MAX(Effective_Date) AS Last_Effective_Date,
           COUNT(Salary_ID) AS Total_Salary_Records,
           SUM(Salary_Amount) AS Total_Salary_Amount,
           ROUND(AVG(Days_Gap), 2) AS Average_Salary_Updates
	FROM CTE2
    GROUP BY Emp_ID, Employee_Name
)
SELECT Employee_Name, First_Effective_Date, Last_Effective_Date,
	   Total_Salary_Records, Total_Salary_Amount, Average_Salary_Updates
FROM CTE3;