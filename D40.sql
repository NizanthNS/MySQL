USE Daily_SQL;

CREATE TABLE User_Activity (
    User_ID INT,
    Activity_Time DATETIME
);

INSERT INTO User_Activity
VALUES
    (1, '2024-01-01 10:00:00'),
    (1, '2024-01-01 10:10:00'),
    (1, '2024-01-01 11:00:00'),
    (1, '2024-01-01 11:20:00'),
    (2, '2024-01-01 09:00:00'),
    (2, '2024-01-01 09:25:00'),
    (2, '2024-01-01 10:00:00');
    

SELECT *
FROM User_Activity;


-- Q1
-- For each row, show previous activity time + time difference (minutes)

WITH CTE AS (
	SELECT User_ID, Activity_Time,
		   LAG(Activity_Time) OVER(PARTITION BY User_ID
		   ORDER BY Activity_Time) AS Previous_Activity_Time
	FROM User_Activity
)
SELECT *,
	   TIMESTAMPDIFF(MINUTE, Previous_Activity_Time, Activity_Time) AS Difference
FROM CTE;


-- Q2 (Important 🔥)
-- Mark session start:
-- If gap > 30 mins → new session (1)
-- Else → same session (0)

WITH CTE AS (
	SELECT User_ID, Activity_Time,
		   LAG(Activity_Time) OVER(PARTITION BY User_ID
		   ORDER BY Activity_Time) AS Previous_Activity_Time
	FROM User_Activity
),
CTE2 AS (
	SELECT *,
	TIMESTAMPDIFF(MINUTE, Previous_Activity_Time, Activity_Time) AS Difference
FROM CTE
)
SELECT *,
	   CASE
			WHEN Previous_Activity_Time IS NULL THEN 1
			WHEN TIMESTAMPDIFF(MINUTE, Previous_Activity_Time, Activity_Time) > 30 THEN 1
	   ELSE 0
	   END AS Session_Start
FROM CTE2;


-- Q3 (Core 🔥🔥)
-- Assign session IDs (1,2,3...) per user

WITH CTE AS (
	SELECT User_ID, Activity_Time,
		   LAG(Activity_Time) OVER(PARTITION BY User_ID
		   ORDER BY Activity_Time) AS Previous_Activity_Time
	FROM User_Activity
),
CTE2 AS (
	SELECT *,
	TIMESTAMPDIFF(MINUTE, Previous_Activity_Time, Activity_Time) AS Difference
FROM CTE
),
CTE3 AS (
	SELECT *,
		   CASE
				WHEN Previous_Activity_Time IS NULL THEN 1
				WHEN Difference > 30 THEN 1
		   ELSE 0
		   END AS Session_Start
FROM CTE2
)
SELECT *,
	   SUM(Session_Start) OVER(PARTITION BY USER_ID
       ORDER BY Activity_Time) AS Session_ID
FROM CTE3;

-- Q4
-- Count number of sessions per user

WITH CTE AS (
	SELECT User_ID, Activity_Time,
		   LAG(Activity_Time) OVER(PARTITION BY User_ID
		   ORDER BY Activity_Time) AS Previous_Activity_Time
	FROM User_Activity
),
CTE2 AS (
	SELECT *,
	TIMESTAMPDIFF(MINUTE, Previous_Activity_Time, Activity_Time) AS Difference
FROM CTE
),
CTE3 AS (
	SELECT *,
		   CASE
				WHEN Previous_Activity_Time IS NULL THEN 1
				WHEN Difference > 30 THEN 1
		   ELSE 0
		   END AS Session_Start
FROM CTE2
),
CTE4 AS (
	SELECT *,
		 SUM(Session_Start) OVER(PARTITION BY USER_ID
		 ORDER BY Activity_Time) AS Session_ID
	FROM CTE3
)
SELECT User_ID,
	   MAX(Session_ID) AS Session_Count
FROM CTE4
GROUP BY User_ID;


-- Q5 (Advanced 🔥)
-- Find session duration (start time, end time, duration)

WITH CTE AS (
	SELECT User_ID, Activity_Time,
		   LAG(Activity_Time) OVER(PARTITION BY User_ID
		   ORDER BY Activity_Time) AS Previous_Activity_Time
	FROM User_Activity
),
CTE2 AS (
	SELECT *,
	TIMESTAMPDIFF(MINUTE, Previous_Activity_Time, Activity_Time) AS Difference
FROM CTE
),
CTE3 AS (
	SELECT *,
		   CASE
				WHEN Previous_Activity_Time IS NULL THEN 1
				WHEN Difference > 30 THEN 1
		   ELSE 0
		   END AS Session_Start
FROM CTE2
),
CTE4 AS (
	SELECT *,
		 SUM(Session_Start) OVER(PARTITION BY USER_ID
		 ORDER BY Activity_Time) AS Session_ID
	FROM CTE3
)
SELECT User_ID,
       Session_ID,
       MIN(Activity_Time),
       MAX(Activity_Time),
       TIMESTAMPDIFF(MINUTE,  MIN(Activity_Time), MAX(Activity_Time)) AS Duration
FROM CTE4
GROUP BY User_ID, Session_ID;