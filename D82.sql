USE Daily_SQL;

CREATE TABLE Employees (
    Emp_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees
VALUES  (1, 'Arjun', 'IT'),
        (2, 'Meena', 'HR'),
        (3, 'Ravi', 'IT'),
        (4, 'Priya', 'Finance'),
        (5, 'Karan', 'HR');
        

CREATE TABLE Training_Data (
    Training_ID INT PRIMARY KEY,
    Emp_ID INT,
    Training_Name VARCHAR(50),
    Training_Date DATE,
    Score INT
);

INSERT INTO Training_Data
VALUES  (101, 1, 'SQL',           '2025-01-05', 85),
        (102, 1, 'Python',        '2025-01-20', 90),
        (103, 2, 'Communication', '2025-01-10', 75),
        (104, 3, 'SQL',           '2025-02-01', 88),
        (105, 3, 'Power BI',      '2025-02-12', 92),
        (106, 4, 'Excel',         '2025-01-15', 80),
        (107, 4, 'Finance Tools', '2025-01-25', 85),
        (108, 5, 'Communication', '2025-02-05', 78),
        (109, 5, 'Recruitment',   '2025-02-18', 82),
        (110, 1, 'Power BI',      '2025-02-10', 95);
        

SELECT *
FROM Employees;

SELECT *
FROM Training_Data;
        

-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each employee along with:
-- 1. Total Trainings Attended
-- 2. Total Score
-- 3. Average Score
-- ordered by Total Score descending.

SELECT E.Emp_ID, E.Employee_Name,
	   COUNT(T.Training_ID) AS Total_Trainings_Attended,
       SUM(T.Score) AS Total_Score,
       AVG(T.Score) AS Average_Score
FROM Employees E
INNER JOIN Training_Data T
	ON E.Emp_ID = T.Emp_ID
GROUP BY E.Emp_ID, E.Employee_Name
ORDER BY Total_Score DESC;


-- Q2
-- Find employees whose total score
-- is greater than the average total score
-- of all employees.

SELECT E.Emp_ID, E.Employee_Name,
       SUM(T.Score) AS Total_Score
FROM Employees E
INNER JOIN Training_Data T
	ON E.Emp_ID = T.Emp_ID
GROUP BY E.Emp_ID, E.Employee_Name
HAVING SUM(T.Score) > (
	SELECT AVG(Total_Score)
    FROM (
		SELECT E.Emp_ID, E.Employee_Name,
			   SUM(T.Score) AS Total_Score
		FROM Employees E
		INNER JOIN Training_Data T
			ON E.Emp_ID = T.Emp_ID
		GROUP BY E.Emp_ID, E.Employee_Name
	)A
);


-- Q3
-- Show the highest scoring employee
-- (based on total score)
-- in each Department.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Total_Score DESC) AS D_Rank
	FROM (
		SELECT E.Emp_ID, E.Employee_Name, E.Department,
			   SUM(T.Score) AS Total_Score
		FROM Employees E
		INNER JOIN Training_Data T
			ON E.Emp_ID = T.Emp_ID
		GROUP BY E.Emp_ID, E.Employee_Name, E.Department
	)H
)D
WHERE D_Rank = 1;


-- Q4
-- Show training programs that were attended
-- more than once within the same month.

SELECT Training_Name,
	   COUNT(Training_ID) AS Total_Trainings_Attended,
	   YEAR(Training_Date) AS Year_,
       MONTH(Training_Date) AS Month_
FROM Training_Data
GROUP BY Training_Name, YEAR(Training_Date), MONTH(Training_Date)
HAVING COUNT(Training_ID) > 1;


-- Q5
-- Show each training record along with:
-- 1. Previous Score of that employee
-- 2. Difference from previous Score
-- 3. Running total Score of that employee

WITH CTE AS (
	SELECT Training_ID, Training_Date, Score,
		   LAG(Score) OVER(PARTITION BY Emp_ID
           ORDER BY Training_Date) AS Previous_Score,
           SUM(Score) OVER(PARTITION BY Emp_ID
           ORDER BY Training_Date) AS Running_Total
	FROM Training_Data
),
CTE2 AS (
	SELECT *,
		   Score - Previous_Score AS Difference
	FROM CTE
    WHERE Previous_Score IS NOT NULL
)
SELECT Training_ID, Training_Date, Score,
	   Previous_Score, Running_Total,  Difference
FROM CTE2;


-- Q6 (Date Logic)
-- Find employees who attended another training
-- within 15 days of their previous training.

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, T.Training_Date,
		   LAG(T.Training_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY T.Training_Date, Training_ID) AS Previous_Date
	FROM Employees E
	INNER JOIN Training_Data T
		ON E.Emp_ID = T.Emp_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Training_Date, Previous_Date) AS Days_Gap
	FROM CTE
)
SELECT DISTINCT Emp_ID, Employee_Name
FROM CTE2
WHERE Days_Gap <= 15;


-- Bonus Challenge
-- Show:
-- 1. Employee_Name
-- 2. First Training_Date
-- 3. Latest Training_Date
-- 4. Total Trainings Attended
-- 5. Total Score
-- 6. Average Days Between Trainings

WITH CTE AS (
	SELECT E.Emp_ID, E.Employee_Name, T.Training_Date, T.Training_ID, T.Score,
		   LAG(T.Training_Date) OVER(PARTITION BY E.Emp_ID
           ORDER BY T.Training_Date, T.Training_ID) AS Previous_Date
	FROM Employees E
	INNER JOIN Training_Data T
		ON E.Emp_ID = T.Emp_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Training_Date, Previous_Date) AS Days_Gap
	FROM CTE
    WHERE Previous_Date IS NOT NULL
)
SELECT Emp_ID, Employee_Name,
	   MIN(Training_Date) AS First_Training_Date,
       MAX(Training_Date) AS Last_Training_Date,
       COUNT(Training_ID) AS Total_Trainings_Attended,
       SUM(Score) AS Total_Score,
       ROUND(AVG(Days_Gap), 2) AS Average_Days
FROM CTE2
GROUP BY Emp_ID, Employee_Name;