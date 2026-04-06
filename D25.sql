CREATE TABLE Students (
	Student_ID INT PRIMARY KEY,
    Student_Name VARCHAR(50),
    Class VARCHAR(50),
    Age INT
);


CREATE TABLE Exams (
    Exam_ID INT PRIMARY KEY,
    Student_ID INT,
    Subjects VARCHAR(50),
    Marks INT
);


INSERT INTO Students
VALUES	(1, 'Arun', '10A', 15),
		(2, 'Meena', '10A', 16),
		(3, 'Ravi', '10B', 15),
		(4, 'Divya', '10B', 16),
		(5, 'Karan', '10A', 15),
		(6, 'Sneha', '10C', 17),
		(7, 'Vikram', '10C', 16),
		(8, 'Anita', '10B', 15);


INSERT INTO Exams 
VALUES	(101, 1, 'Math', 85),
		(102, 1, 'Science', 78),
		(103, 2, 'Math', 92),
		(104, 2, 'Science', 88),
		(105, 3, 'Math', 67),
		(106, 4, 'Science', 75),
		(107, 5, 'Math', 85),
		(108, 6, 'Science', 91),
		(109, 7, 'Math', 73),
		(110, 8, 'Science', 84),
		(111, 3, 'Science', 72),
		(112, 5, 'Science', 80);


SELECT *
FROM Students;

Select *
FROM Exams;


-- 1. Show all students from class 10A

SELECT *
FROM Students
WHERE Class = '10A';

-- OR

SELECT Student_ID, Student_Name
FROM Students
WHERE Class = '10A';


-- 2. Show students who scored more than 80 in Math

SELECT *
FROM Students
INNER JOIN Exams
	ON Students.Student_ID = Exams.Student_ID
    WHERE Exams.Subjects = 'Math' 
    AND  Exams.marks > 80;

-- OR

SELECT Students.Student_ID,
	   Students.Student_Name,
       Students.Class,
       Exams.Marks
FROM Students
INNER JOIN Exams
	ON Students.Student_ID = Exams.Student_ID
WHERE Exams.Subjects = 'Math'
AND  Exams.marks > 80;


-- 3. Show student name and subject they took exams in

SELECT Students.Student_Name, Exams.Subjects
FROM Students
LEFT JOIN Exams
	ON Students.Student_ID = Exams.Student_ID;


-- 4.Find the average marks per subject

SELECT Subjects, AVG(Marks) AS Average_Marks
FROM Exams
GROUP BY Subjects;

-- OR Per Class

SELECT Students.Class,
       AVG(Exams.Marks) AS Average_Marks
FROM Students
INNER JOIN Exams
	ON Students.Student_ID = Exams.Student_ID
GROUP BY Students.Class;


-- 5. Find the highest mark in the Math subject

SELECT MAX(Marks) AS Highest_mark_in_Math
FROM Exams
WHERE Subjects = 'Math';


-- 6. Show students who never took a Science exam

SELECT Students.Student_ID,
	   Students.Student_Name,
       Students.Class
FROM Students
LEFT JOIN Exams
	ON Students.Student_ID = Exams.Student_ID
    AND Exams.Subjects = 'Science'
    WHERE Exams.Exam_ID IS NULL;


-- 7. Count number of students in each class

SELECT Class, COUNT(*) AS Total_Students
FROM Students
GROUP BY Class;


-- 8. Find the student who scored the highest marks overall

SELECT Students.Student_Name, 
	   Exams.Subjects, 
	   Exams.marks
From Students
INNER JOIN Exams
	ON Students.Student_ID = Exams.Student_ID
    WHERE Exams.Marks = (
		SELECT MAX(Marks) 
        FROM Exams);


-- 9. Show students whose marks are above the average marks

SELECT Students.Student_Name, 
	   Exams.Marks
FROM Students
INNER JOIN Exams
	ON Students.Student_ID = Exams.Student_ID
    WHERE Marks > (
		SELECT AVG(Marks) 
        FROM Exams
        );


-- 10. Find the class with the highest average marks

Select Students.Class, 
	   AVG(Exams.Marks) AS Highest_average_marks
From Exams
INNER JOIN Students
	ON Students.Student_ID = Exams.Student_ID
    GROUP BY Students.Class
    ORDER BY Highest_average_marks DESC
    LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Highest_average_marks DESC) AS Rnk
	FROM (
		Select Students.Class, 
			   AVG(Exams.Marks) AS Highest_average_marks
		From Exams
		INNER JOIN Students
			ON Students.Student_ID = Exams.Student_ID
		GROUP BY Students.Class
        )T
	)R
WHERE Rnk = 1;

-- OR

WITH CTE AS (
	Select Students.Class, 
		   AVG(Exams.Marks) AS Highest_average_marks
	From Exams
	INNER JOIN Students
		ON Students.Student_ID = Exams.Student_ID
    GROUP BY Students.Class
    ORDER BY Highest_average_marks DESC
)
SELECT *
FROM CTE
WHERE Highest_average_marks = (
	SELECT MAX(Highest_average_marks)
    FROM CTE
);

-- OR PER CLASS

SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Class ORDER BY Avg_Marks DESC) AS rnk
    FROM (
        SELECT Students.Student_ID,
               Students.Student_Name,
               Students.Class,
               AVG(Exams.Marks) AS Avg_Marks
        FROM Students
        INNER JOIN Exams
            ON Students.Student_ID = Exams.Student_ID
        GROUP BY Students.Student_ID, Students.Student_Name, Students.Class
    ) T
) T
WHERE rnk = 1;

-- OR Marks Per Class

SELECT *
FROM (
	SELECT Students.Student_ID,
		   Students.Student_Name,
		   Students.Class,
		   Exams.Marks,
           Exams.Subjects,
           RANK() OVER(PARTITION BY Students.Class
           ORDER BY Exams.Marks) AS Rnk
	FROM Students
	INNER JOIN Exams
		ON Students.Student_ID = Exams.Student_ID
    ) T
WHERE rnk <=2 ;
