SELECT *
FROM Employees;

SELECT *
FROM Departments;

SELECT *
FROM Projects;


-- 1. Show total hours worked per employee using CTE

WITH Total_Hours AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           SUM(Projects.Hours_Worked) AS Hours
	FROM Employees
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID, Employees.Employee_Name
    )
SELECT *
FROM Total_Hours;


-- 2. Using CTE, show employees whose total hours > average total hours

WITH CTE AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours
	FROM Employees
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID,
			 Employees.Employee_Name
)
SELECT *
FROM CTE
WHERE Total_Hours > (
	SELECT AVG(Total_Hours)
    FROM CTE
    );
    

-- 3. Using CTE, show the employee with the highest total hours worked

WITH CTE AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours
	FROM Employees
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID,
			 Employees.Employee_Name
)
SELECT *
FROM CTE
WHERE Total_Hours = (
	SELECT MAX(Total_Hours)
    FROM CTE
    );
    
-- OR

WITH CTE AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours
	FROM Employees
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID,
			 Employees.Employee_Name
)
SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Hours DESC) AS Rank_
	FROM CTE
    ) T
WHERE Rank_ = 1;


-- 4. Using CTE, show top 2 employees based on total hours worked

WITH CTE AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours
	FROM Employees
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID,
			 Employees.Employee_Name
)
SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_Hours DESC) AS Rank_
	FROM CTE
    ) T
WHERE Rank_ <= 2;


-- 5. Using CTE, show employees whose total hours is below department average hours

WITH CTE AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           Departments.Department_ID,
           Departments.Department_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours
	FROM Employees
    INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID,
			 Employees.Employee_Name,
             Departments.Department_ID,
             Departments.Department_Name
)
SELECT *
FROM (
	SELECT *,
		   AVG(Total_Hours) OVER(
           PARTITION BY Department_ID) AS Department_Average
	FROM CTE
    )T
WHERE Total_Hours < Department_Average;


-- 6. 2nd highest total hours per department

WITH CTE AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           Departments.Department_ID,
           Departments.Department_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours
	FROM Employees
    INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID,
			 Employees.Employee_Name,
             Departments.Department_ID,
             Departments.Department_Name
)
SELECT *
FROM (
	SELECT *,
		   RANK() OVER(PARTITION BY Department_ID
           ORDER BY Total_Hours DESC) AS Rank_
	FROM CTE
    )T
WHERE Rank_ = 2;


-- 7. Using CTE, show employees whose total hours are higher than the previous employee in the same department

WITH CTE AS (
	SELECT Employees.Employee_ID,
		   Employees.Employee_Name,
           Departments.Department_ID,
           Departments.Department_Name,
           SUM(Projects.Hours_Worked) AS Total_Hours
	FROM Employees
    INNER JOIN Departments
		ON Employees.Department_ID = Departments.Department_ID
    INNER JOIN Projects
		ON Employees.Employee_ID = Projects.Employee_ID
	GROUP BY Employees.Employee_ID,
			 Employees.Employee_Name,
             Departments.Department_ID,
             Departments.Department_Name
)
SELECT *
FROM (
	SELECT *,
		   LAG(Total_Hours) OVER(PARTITION BY Department_ID
           ORDER BY Total_Hours) AS Previous_Hours
	FROM CTE
    )T
WHERE Total_Hours > Previous_Hours;








