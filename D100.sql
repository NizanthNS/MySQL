USE Daily_SQL;

-- DATASET

CREATE TABLE Hospital_Visits (
    Visit_ID INT,
    Patient_ID INT,
    Patient_Name VARCHAR(50),
    Visit_Date DATE,
    Department VARCHAR(50),
    Bill_Amount INT,
    Visit_Type VARCHAR(20)
);

INSERT INTO Hospital_Visits 
VALUES	(1,101,'Alice','2024-01-01','Cardiology',5000,'Consultation'),
		(2,101,'Alice','2024-01-02','Cardiology',3000,'Follow-up'),
		(3,101,'Alice','2024-01-03','Neurology',7000,'Consultation'),
		(4,101,'Alice','2024-01-08','Cardiology',2000,'Follow-up'),

		(5,102,'Bob','2024-01-01','Orthopedics',4000,'Consultation'),
		(6,102,'Bob','2024-01-05','Orthopedics',3500,'Follow-up'),
		(7,102,'Bob','2024-01-06','Dermatology',2500,'Consultation'),

		(8,103,'Charlie','2024-01-02','Neurology',8000,'Consultation'),
		(9,103,'Charlie','2024-01-03','Neurology',6000,'Follow-up'),
		(10,103,'Charlie','2024-01-04','Cardiology',5000,'Consultation'),
		(11,103,'Charlie','2024-01-05','Cardiology',4000,'Follow-up'),

		(12,104,'David','2024-01-01','Dermatology',1500,'Consultation'),
		(13,104,'David','2024-01-08','Dermatology',2500,'Follow-up'),

		(14,105,'Emma','2024-01-03','Cardiology',9000,'Consultation'),
		(15,105,'Emma','2024-01-04','Cardiology',4000,'Follow-up'),
		(16,105,'Emma','2024-01-05','Neurology',6000,'Consultation');
        

SELECT *
FROM Hospital_Visits;

-- Q1
-- Show each patient's total visit records,
-- total bill amount, and average bill amount.
--
-- Return:
-- Patient_ID
-- Patient_Name
-- Total_Visit_Records
-- Total_Bill_Amount
-- Average_Bill_Amount

SELECT Patient_ID, Patient_Name,
	   COUNT(Visit_ID) AS Total_Visit_Records,
       SUM(Bill_Amount) AS Total_Bill_Amount,
       ROUND(AVG(Bill_Amount), 2) AS Average_Bill_Amount
FROM Hospital_Visits
GROUP BY Patient_ID, Patient_Name;


-- Q2
-- Show each department's total visit records
-- and total bill amount.
--
-- Return:
-- Department
-- Total_Visit_Records
-- Total_Bill_Amount

SELECT Department,
	   COUNT(Visit_ID) AS Total_Visit_Records,
       SUM(Bill_Amount) AS Total_Bill_Amount
FROM Hospital_Visits
GROUP BY Department;


-- Q3
-- Find the top 3 patients by total bill amount.
--
-- Return:
-- Patient_ID
-- Patient_Name
-- Total_Bill_Amount

WITH CTE AS (
	SELECT Patient_ID, Patient_Name,
		   SUM(Bill_Amount) AS Total_Bill_Amount
	FROM Hospital_Visits
	GROUP BY Patient_ID, Patient_Name
),
CTE2 AS (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Bill_Amount DESC) AS D_Rank
	FROM CTE
)
SELECT Patient_ID, Patient_Name, Total_Bill_Amount
FROM CTE2
WHERE D_Rank <= 3;


-- Q4
-- Find patients who visited within 2 days
-- of their previous visit.
--
-- Return:
-- Patient_ID
-- Patient_Name

WITH CTE AS (
	SELECT Patient_ID, Patient_Name, Visit_Date,
		   LAG(Visit_Date) OVER(PARTITION BY Patient_ID
           ORDER BY Visit_Date, Visit_ID) AS Previous
	FROM Hospital_Visits
)
SELECT DISTINCT Patient_ID, Patient_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Visit_Date, Previous) <= 2;


-- Q5
-- Find patients whose total bill amount is greater
-- than the average total bill amount of all patients.
--
-- Return:
-- Patient_ID
-- Patient_Name
-- Total_Bill_Amount

WITH CTE AS (
	SELECT Patient_ID, Patient_Name,
		   SUM(Bill_Amount) AS Total_Bill_Amount
	FROM Hospital_Visits
	GROUP BY Patient_ID, Patient_Name
)
SELECT *
FROM CTE
WHERE Total_Bill_Amount > (
	SELECT AVG(Total_Bill_Amount)
    FROM CTE
);


-- BONUS
-- Find the start date and end date of each patient's
-- current visit streak.
--
-- Return:
-- Patient_ID
-- Patient_Name
-- Current_Streak
-- Start_Date
-- End_Date
--
-- Definition:
-- A current streak is the streak that contains
-- the patient's most recent visit date.
--
-- Note:
-- Ignore duplicate visit dates if a patient
-- has multiple visits on the same day.

WITH CTE AS (
	SELECT DISTINCT Patient_ID, Patient_Name, Visit_Date
    FROM Hospital_Visits
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Patient_ID
           ORDER BY Visit_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Visit_Date, INTERVAL RN DAY) AS GK
	FROM CTE2
),
CTE4 AS (
	SELECT Patient_ID, Patient_Name,
		   COUNT(*) AS Streak,
           MIN(Visit_Date) AS Start_Date,
		   MAX(Visit_Date) AS End_Date
	FROM CTE3
	GROUP BY Patient_ID, Patient_Name, GK
),
CTE5 AS (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Patient_ID
		   ORDER BY End_Date DESC) AS D_Rank
	FROM CTE4
)
SELECT Patient_ID, Patient_Name, Streak AS Current_Streak, Start_Date, End_Date
FROM CTE5
WHERE D_Rank = 1;