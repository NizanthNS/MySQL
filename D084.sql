USE Daily_SQL;


CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees
VALUES  (1, 'Arun', 'IT'),
        (2, 'Meena', 'HR'),
        (3, 'Ravi', 'Finance'),
        (4, 'Priya', 'IT'),
        (5, 'Karan', 'HR');
        

CREATE TABLE Leave_Data (
    Leave_ID INT PRIMARY KEY,
    Emp_ID INT,
    Leave_Date DATE,
    Leave_Type VARCHAR(50),
    Leave_Days INT
);

INSERT INTO Leave_Data
VALUES  (101, 1, '2025-01-05', 'Sick Leave', 2),
        (102, 1, '2025-01-20', 'Casual Leave', 1),
        (103, 2, '2025-01-08', 'Sick Leave', 3),
        (104, 3, '2025-01-15', 'Casual Leave', 2),
        (105, 1, '2025-02-02', 'Sick Leave', 1),
        (106, 4, '2025-01-18', 'Casual Leave', 4),
        (107, 5, '2025-01-25', 'Sick Leave', 2),
        (108, 3, '2025-02-10', 'Sick Leave', 3),
        (109, 2, '2025-02-20', 'Casual Leave', 1),
        (110, 4, '2025-03-01', 'Sick Leave', 2),
        (111, 5, '2025-03-05', 'Casual Leave', 3),
        (112, 1, '2025-03-15', 'Casual Leave', 2);
 
 
 SELECT *
 FROM Employees;
 
 SELECT *
 FROM Leave_Data;
 

-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each employee along with:
-- 1. Total Leave Records
-- 2. Total Leave Days
-- 3. Average Leave Days
-- ordered by Total Leave Days descending.

SELECT E.Emp_ID, E.Employee_Name,
	   COUNT(L.Leave_ID) AS Total_Leave_Records,
       SUM(L.Leave_Days) AS Total_Leave_Days,
       ROUND(AVG(L.Leave_Days), 2) AS Average_Leave_Days
FROM Employees E
INNER JOIN Leave_Data L
	ON E.Emp_ID = L.Emp_ID
GROUP BY E.Emp_ID, E.Employee_Name
ORDER BY Total_Leave_Days DESC;


-- Q2
-- Find employees whose total leave days
-- is greater than the average total leave days
-- of all employees.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name,
		   SUM(L.Leave_Days) AS Total_Leave_Days
	FROM Employees E
	INNER JOIN Leave_Data L
		ON E.Emp_ID = L.Emp_ID
	GROUP BY E.Emp_ID, E.Employee_Name
)
SELECT *
FROM CTE
WHERE Total_Leave_Days > (
	SELECT AVG(Total_Leave_Days)
    FROM CTE
);


-- Q3
-- Show the employee with the highest total leave days
-- in each Department.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, E.Department,
		   SUM(L.Leave_Days) AS Total_Leave_Days
	FROM Employees E
	INNER JOIN Leave_Data L
		ON E.Emp_ID = L.Emp_ID
	GROUP BY E.Emp_ID, E.Employee_Name, E.Department
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Total_Leave_Days DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank = 1;


-- Q4
-- Show leave types that were taken
-- more than once within the same month.

SELECT Leave_Type,
	   COUNT(Leave_ID) AS Total_Leave_Records,
       YEAR(Leave_Date) AS Year_,
       MONTH(Leave_Date) AS Month_
FROM Leave_Data
GROUP BY Leave_Type, YEAR(Leave_Date), MONTH(Leave_Date)
HAVING COUNT(Leave_ID) > 1;


-- Q5
-- Show each leave record along with:
-- 1. Previous Leave_Days of that employee
-- 2. Difference from previous Leave_Days
-- 3. Running total Leave_Days of that employee

WITH CTE AS (
	SELECT Leave_ID, Leave_Date, Leave_Days,
		   LAG(Leave_Days) OVER(PARTITION BY Emp_ID
		   ORDER BY Leave_Date) AS Previous_Leave_Days,
           SUM(Leave_Days) OVER(PARTITION BY Emp_ID
           ORDER BY Leave_Date) AS Running_Total
	FROM Leave_Data
)
SELECT *,
	   Leave_Days - Previous_Leave_Days AS Difference
FROM CTE
WHERE Previous_Leave_Days IS NOT NULL;
       


-- Q6 (Date Logic)
-- Find employees who took another leave
-- within 20 days of their previous leave.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, L.Leave_Date,
		   LAG(L.Leave_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY L.Leave_Date) AS Previous_Date
	FROM Employees E
	INNER JOIN Leave_Data L
		ON E.Emp_ID = L.Emp_ID
)
SELECT DISTINCT Emp_ID, Employee_Name
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Leave_Date, Previous_Date) <= 20;


-- Bonus Challenge
-- Show:
-- 1. Employee_Name
-- 2. First Leave_Date
-- 3. Latest Leave_Date
-- 4. Total Leave Records
-- 5. Total Leave Days
-- 6. Average Days Between Leaves

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, L.Leave_ID, 
		   L.Leave_Date, L.Leave_Days,
		   LAG(L.Leave_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY L.Leave_Date) AS Previous_Date
	FROM Employees E
	INNER JOIN Leave_Data L
		ON E.Emp_ID = L.Emp_ID
),
CTE2 AS ( 
	SELECT *,
		   DATEDIFF(Leave_Date, Previous_Date) AS Days_Gap
	FROM CTE
)
SELECT Emp_ID, Employee_Name,
	   MIN(Leave_Date) First_Leave_Date,
       MAX(Leave_Date) Last_Leave_Date,
       COUNT(Leave_ID) Total_Leave_Records,
       SUM(Leave_Days) Total_Leave_Days,
       ROUND(AVG(Days_Gap), 2) Average_Days
FROM CTE2
GROUP BY Emp_ID, Employee_Name;