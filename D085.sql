USE Daily_SQL;

CREATE TABLE Students (
    Student_ID INT PRIMARY KEY,
    Student_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Students
VALUES  (1, 'Arun',   'IT'),
        (2, 'Meena',  'HR'),
        (3, 'Ravi',   'Finance'),
        (4, 'Priya',  'IT'),
        (5, 'Divya',  'Finance');


CREATE TABLE Course_Enrollments (
    Enrollment_ID INT PRIMARY KEY,
    Student_ID INT,
    Course_Name VARCHAR(50),
    Fee_Amount INT,
    Enrollment_Date DATE
);

INSERT INTO Course_Enrollments
VALUES  (101, 1, 'SQL',        5000, '2024-01-05'),
        (102, 1, 'Python',     7000, '2024-01-20'),
        (103, 2, 'Excel',      4000, '2024-01-10'),
        (104, 3, 'SQL',        5000, '2024-01-15'),
        (105, 1, 'Power BI',   6000, '2024-02-05'),
        (106, 4, 'Python',     7000, '2024-01-25'),
        (107, 5, 'SQL',        5000, '2024-01-28'),
        (108, 3, 'Python',     7000, '2024-02-12'),
        (109, 2, 'SQL',        5000, '2024-02-18'),
        (110, 4, 'Power BI',   6000, '2024-03-01'),
        (111, 5, 'Python',     7000, '2024-03-08'),
        (112, 1, 'Excel',      4000, '2024-03-15');
        
        
SELECT *
FROM Students;

SELECT *
FROM Course_Enrollments;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each student along with:
-- 1. Total Enrollments
-- 2. Total Fee Paid
-- 3. Average Fee Amount
-- ordered by Total Fee Paid descending.

SELECT S.Student_ID, S.Student_Name,
	   COUNT(E.Enrollment_ID) AS Total_Enrollments,
       SUM(E.Fee_Amount) AS Total_Fee_Paid,
       ROUND(AVG(E.Fee_Amount), 2) AS Average_Fee_Amount
FROM Students S
INNER JOIN Course_Enrollments E
	ON S.Student_ID = E.Student_ID
GROUP BY S.Student_ID, S.Student_Name
ORDER BY Total_Fee_Paid DESC;


-- Q2
-- Find students whose total fee paid
-- is greater than the average total fee paid
-- of all students.

WITH CTE AS (
	SELECT S.Student_ID, S.Student_Name,
		   SUM(E.Fee_Amount) AS Total_Fee_Paid
	FROM Students S
	INNER JOIN Course_Enrollments E
		ON S.Student_ID = E.Student_ID
	GROUP BY S.Student_ID, S.Student_Name
)
SELECT *
FROM CTE
WHERE Total_Fee_Paid > (
	SELECT AVG(Total_Fee_Paid)
    FROM CTE
);


-- Q3
-- Show the highest spending student
-- in each Department.

WITH CTE AS (
	SELECT S.Student_ID, S.Student_Name, S.Department,
		   SUM(E.Fee_Amount) AS Total_Fee_Paid
	FROM Students S
	INNER JOIN Course_Enrollments E
		ON S.Student_ID = E.Student_ID
	GROUP BY S.Student_ID, S.Student_Name, S.Department
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY Department
           ORDER BY Total_Fee_Paid DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank = 1;


-- Q4
-- Show courses that were enrolled in
-- more than once within the same month.

SELECT Course_Name,
	   COUNT(Enrollment_ID) AS Total_Enrollments,
       YEAR(Enrollment_Date) AS Year_,
       MONTH(Enrollment_Date) AS Month_
FROM Course_Enrollments
GROUP BY Course_Name, YEAR(Enrollment_Date), MONTH(Enrollment_Date)
HAVING COUNT(Enrollment_ID) > 1;


-- Q5
-- Show each enrollment record along with:
-- 1. Previous Fee_Amount of that student
-- 2. Difference from previous Fee_Amount
-- 3. Running total Fee_Amount of that student

WITH CTE AS (
	SELECT Enrollment_ID, Fee_Amount, Enrollment_Date,
		   COALESCE(LAG(Fee_Amount) OVER(PARTITION BY Student_ID
           ORDER BY Enrollment_Date), 0) AS Previous_Fee,
           SUM(Fee_Amount) OVER(PARTITION BY Student_ID
           ORDER BY Enrollment_Date) AS Running_Total
	FROM Course_Enrollments
)
SELECT *,
	   Fee_Amount - Previous_Fee AS Difference
FROM CTE;