USE Daily_SQL;


CREATE TABLE Activity_Log (
    User_ID INT,
    Activity_Date DATE
);

INSERT INTO Activity_Log 
VALUES	(1, '2024-01-01'),
		(1, '2024-01-02'),
		(1, '2024-01-05'),
		(1, '2024-01-06'),
		(2, '2024-01-01'),
		(2, '2024-01-10'),
		(3, '2024-01-03'),
		(3, '2024-01-04'),
		(3, '2024-01-05');
        
SELECT *
FROM Activity_Log;


-- Q1 (Warm-up)
-- Find each user’s first activity date

SELECT *
FROM (
	SELECT User_ID, Activity_Date,
		   ROW_NUMBER() OVER(PARTITION BY User_ID
           ORDER BY Activity_Date) AS Row_Num
	FROM Activity_Log
    )T
WHERE Row_Num = 1;

-- OR

SELECT User_ID, 
	   MIN(Activity_Date) AS First_Activity
FROM Activity_Log
GROUP BY User_ID;


-- Q2 (Date gap 🔥)
-- Find users who were active on consecutive days

WITH CTE AS (
	SELECT User_ID, Activity_Date,
		   LAG(Activity_Date) OVER(PARTITION BY User_ID
           ORDER BY Activity_Date) AS Previous_Date
	FROM Activity_Log
)
SELECT DISTINCT User_ID
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Activity_Date, Previous_Date) = 1;


-- Q3 (Self JOIN 🔥)
-- Find users who were active again within 7 days (use self join)

WITH CTE AS (
	SELECT A.USER_ID, A.Activity_Date
	FROM Activity_Log A
	JOIN Activity_Log B
		ON A.User_ID = B.User_ID AND
	A.Activity_Date > B.Activity_Date AND
    DATEDIFF(A.Activity_Date, B.Activity_Date) <= 7
)
SELECT DISTINCT User_ID
FROM CTE;


-- Q4 (LAG version 🔁)
-- Same as Q3, but using LAG()

WITH CTE AS (
	SELECT User_ID, Activity_Date,
		   LAG(Activity_Date) OVER(PARTITION BY User_ID
           ORDER BY Activity_Date) AS Previous_Date
	FROM Activity_Log
)
SELECT DISTINCT User_ID
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Activity_Date, Previous_Date) BETWEEN 1 AND 7;


-- Q5 (Streak 🧠)
-- Find users with at least 3 consecutive days of activity

WITH CTE AS (
	SELECT User_ID, Activity_Date,
		   ROW_NUMBER() OVER(PARTITION BY User_ID
           ORDER BY Activity_Date) AS Row_Num
	FROM Activity_Log
),
CTE2 AS (
	SELECT *,
		   Activity_Date - Row_Num AS Group_Key
	FROM CTE
)
SELECT DISTINCT User_ID
FROM CTE2
GROUP BY User_ID, Group_Key
HAVING COUNT(*) >= 3;



-- Q6 (Final 🚀)
-- For each user, find the maximum gap (in days) between their activities

WITH CTE AS (
    SELECT User_ID, Activity_Date,
           LAG(Activity_Date) OVER(PARTITION BY User_ID
		   ORDER BY Activity_Date) AS Previous_Date
    FROM Activity_Log
),
CTE2 AS (
    SELECT User_ID, Activity_Date,
           DATEDIFF(Activity_Date, Previous_Date) AS Difference
    FROM CTE
    WHERE Previous_Date IS NOT NULL
)
SELECT User_ID,
       MAX(Difference) AS Max_
FROM CTE2
GROUP BY User_ID;
