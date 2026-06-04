USE Daily_SQL;

-- DATASET

CREATE TABLE Course_Enrollments (
    Enrollment_ID INT,
    Student_ID INT,
    Student_Name VARCHAR(50),
    Course_Name VARCHAR(50),
    Enrollment_Date DATE,
    Fee_Amount INT,
    Completion_Status VARCHAR(20)
);

INSERT INTO Course_Enrollments 
VALUES	(1,101,'Alice','SQL Basics','2024-01-05',5000,'Completed'),
		(2,101,'Alice','Python Basics','2024-01-20',6000,'Completed'),
		(3,101,'Alice','Power BI','2024-02-01',7000,'In Progress'),

		(4,102,'Bob','SQL Basics','2024-01-10',5000,'Completed'),
		(5,102,'Bob','Excel','2024-02-15',3000,'Completed'),

		(6,103,'Charlie','SQL Basics','2024-01-08',5000,'Completed'),
		(7,103,'Charlie','Python Basics','2024-01-18',6000,'Completed'),
		(8,103,'Charlie','Power BI','2024-01-28',7000,'Completed'),

		(9,104,'David','Excel','2024-01-12',3000,'Completed'),
		(10,104,'David','SQL Basics','2024-03-01',5000,'In Progress'),

		(11,105,'Emma','Python Basics','2024-01-25',6000,'Completed'),
		(12,105,'Emma','Power BI','2024-02-10',7000,'Completed'),

		(13,106,'Frank','Excel','2024-01-30',3000,'Completed'),
		(14,106,'Frank','SQL Basics','2024-02-05',5000,'Completed'),
		(15,106,'Frank','Python Basics','2024-02-20',6000,'In Progress');
        
SELECT *
FROM Course_Enrollments;

-- Q1
-- Show each student's total enrollments, total fee paid, and average fee amount.

SELECT Student_ID, Student_Name,
	   COUNT(Enrollment_ID) AS Total_Enrollments,
       SUM(Fee_Amount) AS Total_Fee_Paid,
       ROUND(AVG(Fee_Amount), 2) AS Average_Fee
FROM Course_Enrollments
GROUP BY Student_ID, Student_Name;


-- Q2
-- Show each course's total students enrolled and total revenue.

SELECT Course_Name,
	   COUNT(Student_ID) AS Total_Students,
       SUM(Fee_Amount) AS Total_Revenue
FROM Course_Enrollments
GROUP BY Course_Name;


-- Q3
-- Find the top 2 students by total fee paid.

WITH CTE AS (
	SELECT Student_ID, Student_Name,
		   SUM(Fee_Amount) AS Total_Fee_Paid
	FROM Course_Enrollments
	GROUP BY Student_ID, Student_Name
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Fee_Paid DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank <= 2;

-- OR

SELECT Student_ID, Student_Name,
	   SUM(Fee_Amount) AS Total_Fee_Paid
FROM Course_Enrollments
GROUP BY Student_ID, Student_Name
ORDER BY Total_Fee_Paid DESC
LIMIT 2;


-- Q4
-- Find students who enrolled in another course within 20 days of their previous enrollment.

WITH CTE AS (
	SELECT Student_ID, Student_Name, Enrollment_Date,
		   LAG(Enrollment_Date) OVER(PARTITION BY Student_ID
           ORDER BY Enrollment_Date, Enrollment_ID) AS Previous
	FROM Course_Enrollments
)
SELECT DISTINCT Student_ID, Student_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Enrollment_Date, Previous) <= 20;


-- Q5
-- Find students whose total fee paid is greater than the average total fee paid across all students.

WITH CTE AS (
	SELECT Student_ID, Student_Name,
		   SUM(Fee_Amount) AS Total_Fee_Paid
	FROM Course_Enrollments
	GROUP BY Student_ID, Student_Name
)
SELECT *
FROM CTE
WHERE Total_Fee_Paid > (
	SELECT AVG(Total_Fee_Paid)
    FROM CTE
);


-- BONUS
-- For each student, find the longest gap
-- between two consecutive enrollments.
--
-- Expected Columns:
-- Student_ID
-- Student_Name
-- Longest_Gap_Days

WITH CTE AS (
    SELECT Student_ID,
           Student_Name,
           DATEDIFF(Enrollment_Date, LAG(Enrollment_Date) OVER(
		   PARTITION BY Student_ID ORDER BY Enrollment_Date)) AS Gap_Days
    FROM Course_Enrollments
)
SELECT Student_ID,
       Student_Name,
       MAX(Gap_Days) AS Longest_Gap_Days
FROM CTE
GROUP BY Student_ID, Student_Name;