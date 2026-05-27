USE Daily_SQL;


CREATE TABLE Students (
    Student_ID INT PRIMARY KEY,
    Student_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Students
VALUES  (1, 'Arun',   'Computer Science'),
        (2, 'Meena',  'Electronics'),
        (3, 'Ravi',   'Mechanical'),
        (4, 'Priya',  'Computer Science'),
        (5, 'Divya',  'Electronics');
        

CREATE TABLE Exam_Data (
    Exam_ID INT PRIMARY KEY,
    Student_ID INT,
    Subject_Name VARCHAR(50),
    Marks INT,
    Exam_Date DATE
);

INSERT INTO Exam_Data
VALUES  (101, 1, 'SQL',        85, '2024-01-05'),
        (102, 1, 'Python',     90, '2024-01-12'),
        (103, 2, 'Circuits',   78, '2024-01-10'),
        (104, 3, 'Thermodynamics', 88, '2024-01-15'),
        (105, 1, 'DBMS',       92, '2024-01-20'),
        (106, 4, 'SQL',        80, '2024-01-22'),
        (107, 5, 'Signals',    84, '2024-01-25'),
        (108, 3, 'Machines',   91, '2024-02-01'),
        (109, 2, 'Networks',   86, '2024-02-05'),
        (110, 4, 'Python',     89, '2024-02-08'),
        (111, 5, 'Circuits',   90, '2024-02-10'),
        (112, 1, 'SQL',        95, '2024-02-15');


SELECT *
FROM Students;
        
SELECT *
FROM Exam_Data;
        

-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each student along with:
-- 1. Total Exams Attempted
-- 2. Total Marks Scored
-- 3. Average Marks
-- ordered by Total Marks Scored descending.

WITH CTE AS (
	SELECT S.Student_ID, S.Student_Name,
		   COUNT(E.Exam_ID) AS Total_Exams_Attempted,
           SUM(E.Marks) AS Total_Marks_Scored,
           ROUND(AVG(E.Marks), 2) AS Average_Marks
	FROM Students S
    INNER JOIN Exam_Data E
		ON S.Student_ID = E.Student_ID
	GROUP BY S.Student_ID, S.Student_Name
)
SELECT *
FROM CTE
ORDER BY Total_Marks_Scored DESC;


-- Q2
-- Find students whose total marks
-- are greater than the average total marks
-- of all students.

WITH CTE AS (
	SELECT S.Student_ID, S.Student_Name,
           SUM(E.Marks) AS Total_Marks_Scored
	FROM Students S
    INNER JOIN Exam_Data E
		ON S.Student_ID = E.Student_ID
	GROUP BY S.Student_ID, S.Student_Name
)
SELECT *
FROM CTE
WHERE Total_Marks_Scored > (
	SELECT AVG(Total_Marks_Scored)
    FROM CTE
);


-- Q3
-- Show the highest scoring student
-- in each Department.

SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Total_Marks_Scored DESC) AS D_Rank
	FROM (
		SELECT S.Student_ID, S.Student_Name, S.Department,
			   SUM(E.Marks) AS Total_Marks_Scored
		FROM Students S
		INNER JOIN Exam_Data E
			ON S.Student_ID = E.Student_ID
		GROUP BY S.Student_ID, S.Student_Name, S.Department
	)M
)D
WHERE D_Rank = 1;


-- Q4
-- Show subjects that were attempted
-- more than once within the same month.

SELECT Subject_Name,
	   COUNT(Exam_ID) AS Total_Exams_Attempted,
       YEAR(Exam_Date) AS Year_,
       MONTH(Exam_Date) AS Month_
FROM Exam_Data
GROUP BY Subject_Name, YEAR(Exam_Date), MONTH(Exam_Date)
HAVING COUNT(Exam_ID) > 1;


-- Q5
-- Show each exam entry along with:
-- 1. Previous Marks scored by that student
-- 2. Difference from previous Marks
-- 3. Running total Marks of that student

WITH CTE AS (
	SELECT E.Exam_ID, S.Student_ID, S.Student_Name,  
		   E.Marks, E.Exam_Date,
           LAG(E.Marks) OVER(PARTITION BY S.Student_ID
           ORDER BY E.Exam_Date) AS Previous_Marks,
           SUM(E.Marks) OVER(PARTITION BY S.Student_ID
           ORDER BY E.Exam_Date) AS Running_Total
	FROM Students S
	INNER JOIN Exam_Data E
		ON S.Student_ID = E.Student_ID
)
SELECT *,
	   Marks - Previous_Marks AS Difference
FROM CTE
WHERE Previous_Marks IS NOT NULL;


-- Q6 (Date Logic)
-- Find students who attempted another exam
-- within 10 days of their previous exam.

WITH CTE AS (
	SELECT S.Student_ID, S.Student_Name, E.Exam_Date,
           LAG(E.Exam_Date) OVER(PARTITION BY S.Student_ID
           ORDER BY E.Exam_Date) AS Previous
	FROM Students S
	INNER JOIN Exam_Data E
		ON S.Student_ID = E.Student_ID
)
SELECT DISTINCT Student_ID, Student_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Exam_Date, Previous) <= 10;


-- Bonus Challenge
-- Show:
-- 1. Student_Name
-- 2. First Exam_Date
-- 3. Latest Exam_Date
-- 4. Total Exams Attempted
-- 5. Total Marks Scored
-- 6. Average Days Between Exams

WITH CTE AS (
	SELECT S.Student_ID, S.Student_Name, E.Marks, E.Exam_Date, E.Exam_ID,
		   LAG(E.Exam_Date) OVER(PARTITION BY S.Student_ID
           ORDER BY E.Exam_Date) AS Previous
	FROM Students S
	INNER JOIN Exam_Data E
		ON S.Student_ID = E.Student_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Exam_Date, Previous) AS Days_Gap
	FROM CTE
)
SELECT Student_ID, Student_Name,
	   MIN(Exam_Date) AS First_Exam_Date,
	   MAX(Exam_Date) AS Latest_Exam_Date,
       COUNT(Exam_ID) AS Total_Exams_Attempted,
       SUM(Marks) AS Total_Marks_Scored,
       ROUND(AVG(Days_Gap), 2) AS Average_Days_Between_Exams
FROM CTE2
GROUP BY Student_ID, Student_Name;