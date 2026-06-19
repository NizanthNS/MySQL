USE Daily_SQL;

CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Patients
VALUES  (1, 'Arun',   'Chennai'),
        (2, 'Meena',  'Bangalore'),
        (3, 'Ravi',   'Hyderabad'),
        (4, 'Priya',  'Chennai'),
        (5, 'Divya',  'Bangalore');
        

CREATE TABLE Hospital_Visits (
    Visit_ID INT PRIMARY KEY,
    Patient_ID INT,
    Doctor_Name VARCHAR(50),
    Visit_Cost INT,
    Visit_Date DATE
);

INSERT INTO Hospital_Visits
VALUES  (101, 1, 'Dr. Kumar',  500, '2024-01-02'),
        (102, 1, 'Dr. Kumar',  700, '2024-01-08'),
        (103, 2, 'Dr. Mehta',  600, '2024-01-10'),
        (104, 3, 'Dr. Rao',    900, '2024-01-15'),
        (105, 1, 'Dr. Kumar',  800, '2024-01-20'),
        (106, 4, 'Dr. Kumar',  750, '2024-01-25'),
        (107, 5, 'Dr. Mehta',  650, '2024-02-01'),
        (108, 3, 'Dr. Rao',   1000, '2024-02-05'),
        (109, 2, 'Dr. Mehta',  700, '2024-02-08'),
        (110, 4, 'Dr. Kumar',  850, '2024-02-12'),
        (111, 5, 'Dr. Mehta',  750, '2024-02-15'),
        (112, 1, 'Dr. Kumar',  900, '2024-02-18');
        

SELECT *
FROM Patients;

SELECT *
FROM Hospital_Visits;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each patient along with:
-- 1. Total Visits
-- 2. Total Visit Cost
-- 3. Average Visit Cost
-- ordered by Total Visit Cost descending.

WITH CTE AS (
	SELECT P.Patient_ID, P.Patient_Name,
		   COUNT(H.Visit_ID) AS Total_Visits,
           SUM(H.Visit_Cost) AS Total_Visit_Cost,
           ROUND(AVG(H.Visit_Cost), 2) AS Average_Visit_Cost
	FROM Patients P
    INNER JOIN Hospital_Visits H
		ON P.Patient_ID = H.Patient_ID
	GROUP BY P.Patient_ID, P.Patient_Name
)
SELECT *
FROM CTE
ORDER BY Total_Visit_Cost DESC;


-- Q2
-- Find patients whose total visit cost
-- is greater than the average total visit cost
-- of all patients.

WITH CTE AS (
	SELECT P.Patient_ID, P.Patient_Name,
           SUM(H.Visit_Cost) AS Total_Visit_Cost
	FROM Patients P
    INNER JOIN Hospital_Visits H
		ON P.Patient_ID = H.Patient_ID
	GROUP BY P.Patient_ID, P.Patient_Name
)
SELECT *
FROM CTE
WHERE Total_Visit_Cost > (
	SELECT AVG(Total_Visit_Cost)
    FROM CTE
);


-- Q3
-- Show the highest spending patient
-- in each City.

WITH CTE AS (
	SELECT P.Patient_ID, P.Patient_Name, P.City,
           SUM(H.Visit_Cost) AS Total_Visit_Cost
	FROM Patients P
    INNER JOIN Hospital_Visits H
		ON P.Patient_ID = H.Patient_ID
	GROUP BY P.Patient_ID, P.Patient_Name, P.City
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY City
           ORDER BY Total_Visit_Cost DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank = 1;


-- Q4
-- Show doctors who handled visits
-- more than once within the same month.

SELECT Doctor_Name,
	   COUNT(Visit_ID) AS Total_Visits,
	   YEAR(Visit_Date) AS Year_,
       MONTH(Visit_Date) AS Month_
FROM Hospital_Visits
GROUP BY Doctor_Name, YEAR(Visit_Date), MONTH(Visit_Date)
HAVING COUNT(Visit_ID) > 1;


-- Q5
-- Show each visit entry along with:
-- 1. Previous Visit_Cost of that patient
-- 2. Difference from previous Visit_Cost
-- 3. Running total Visit_Cost of that patient

WITH CTE AS (
	SELECT Patient_ID, Visit_ID, Visit_Cost, Visit_Date,
		   LAG(Visit_Cost) OVER(PARTITION BY Patient_ID
           ORDER BY Visit_Date) AS Previous_Cost,
           SUM(Visit_Cost) OVER(PARTITION BY Patient_ID
           ORDER BY Visit_Date) AS Running_Total
	FROM Hospital_Visits
),
CTE2 AS (
	SELECT *,
		   Visit_Cost - Previous_Cost AS Difference
	FROM CTE
)
SELECT Patient_ID, Visit_ID, Previous_Cost, Visit_Cost, 
	   Running_Total, Difference, Visit_Date
FROM CTE2
WHERE Previous_Cost IS NOT NULL;


-- Q6 (Date Logic)
-- Find patients who visited again
-- within 10 days of their previous visit.

WITH CTE AS (
	SELECT P.Patient_ID, P.Patient_Name, H.Visit_Date,
		   LAG(H.Visit_Date) OVER(PARTITION BY P.Patient_ID
           ORDER BY H.Visit_Date, H.Visit_ID) AS Previous_Date
	FROM Patients P
    INNER JOIN Hospital_Visits H
		ON P.Patient_ID = H.Patient_ID
)
SELECT DISTINCT Patient_ID, Patient_Name
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Visit_Date, Previous_Date) <= 10;


-- Bonus Challenge
-- Show:
-- 1. Patient_Name
-- 2. First Visit_Date
-- 3. Latest Visit_Date
-- 4. Total Visits
-- 5. Total Visit Cost
-- 6. Average Days Between Visits

WITH CTE AS (
	SELECT P.Patient_ID, P.Patient_Name, H.Visit_Date, 
		   H.Visit_ID, Visit_Cost,
		   LAG(H.Visit_Date) OVER(PARTITION BY P.Patient_ID
           ORDER BY H.Visit_Date, H.Visit_ID) AS Previous_Date
	FROM Patients P
    INNER JOIN Hospital_Visits H
		ON P.Patient_ID = H.Patient_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Visit_Date, Previous_Date) AS Days_Gap
	FROM CTE
),
CTE3 AS (
	SELECT Patient_ID, Patient_Name,
		   MIN(Visit_Date) AS First_Visit_Date,
           MAX(Visit_Date) AS Latest_Visit_Date,
           COUNT(Visit_ID) AS Total_Visits,
           SUM(Visit_Cost) AS Total_Visit_Cost,
           ROUND(AVG(Days_Gap), 2) AS Average_Days_Between_Visits
	FROM CTE2
    GROUP BY Patient_ID, Patient_Name
)
SELECT Patient_Name, First_Visit_Date, Latest_Visit_Date,
	   Total_Visits, Total_Visit_Cost, Average_Days_Between_Visits
FROM CTE3;