USE Daily_SQL;


CREATE TABLE Activity_Log (
    Log_ID INT,
    Customer_Name VARCHAR(50),
    Login_Date DATE
);

INSERT INTO Activity_Log 
VALUES  
    (1, 'Arun',  '2024-01-01'),
    (2, 'Arun',  '2024-01-02'),
    (3, 'Arun',  '2024-01-04'),
    (4, 'Arun',  '2024-01-05'),
    (5, 'Meena', '2024-01-01'),
    (6, 'Meena', '2024-01-03'),
    (7, 'Meena', '2024-01-04'),
    (8, 'Ravi',  '2024-01-02'),
    (9, 'Ravi',  '2024-01-03'),
    (10,'Ravi',  '2024-01-04');
    

SELECT *
FROM Activity_Log;


-- Q1
-- Assign row number per customer by date

SELECT Customer_Name,
	   Login_Date,
	   ROW_NUMBER() OVER(PARTITION BY Customer_Name 
       ORDER BY Login_Date) AS Row_Num
FROM Activity_Log;


-- Q2
-- Assign rank per customer by date (check difference)

SELECT Customer_Name,
	   Login_Date,
	   RANK() OVER(PARTITION BY Customer_Name 
       ORDER BY Login_Date) AS Rank_
FROM Activity_Log;


-- Q3 (Important 🔥)
-- Find customers who logged in for 2+ consecutive days

WITH CTE AS (
    SELECT Customer_Name,
           Login_Date,
           ROW_NUMBER() OVER(PARTITION BY Customer_Name
		   ORDER BY Login_Date) AS Row_Num
    FROM Activity_Log
),
CTE2 AS (
    SELECT Customer_Name,
           (Login_Date - Row_Num) AS Group_
    FROM CTE
),
CTE3 AS (
    SELECT Customer_Name,
           Group_,
           COUNT(*) AS Streak_Length
    FROM CTE2
    GROUP BY Customer_Name, Group_
    HAVING COUNT(*) >= 2
)
SELECT DISTINCT Customer_Name
FROM CTE3;


-- Q4 (Debug 🚨)
-- What is wrong? Fix it.

SELECT Customer_Name,
       ROW_NUMBER() OVER(PARTITION BY
       Customer_Name ORDER BY Login_Date) AS Row_Num
FROM Activity_Log;


-- Q5 (Advanced 🔥)
-- Find longest consecutive streak per customer

WITH CTE AS (
    SELECT Customer_Name,
           Login_Date,
           ROW_NUMBER() OVER(PARTITION BY Customer_Name
		   ORDER BY Login_Date) AS Row_Num
    FROM Activity_Log
),
CTE2 AS (
    SELECT Customer_Name,
           (Login_Date - Row_Num) AS Group_
    FROM CTE
),
CTE3 AS (
    SELECT Customer_Name,
           Group_,
           COUNT(*) AS Streak_Length
    FROM CTE2
    GROUP BY Customer_Name, Group_
)
SELECT Customer_Name,
	   MAX(Streak_Length) AS Max_Streak
FROM CTE3
GROUP BY Customer_Name;