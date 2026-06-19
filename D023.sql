CREATE TABLE Students (
    Student_ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO Students 
VALUES	(1, 'Arun'),
		(2, 'Meena'),
		(3, 'Ravi'),
		(4, 'Priya'),
		(5, 'Kiran');


CREATE TABLE Courses (
    Course_ID INT PRIMARY KEY,
    Course_Name VARCHAR(50)
);

INSERT INTO Courses 
VALUES	(101, 'SQL'),
		(102, 'Python'),
		(103, 'Java');


CREATE TABLE Enrollments (
    Enroll_ID INT PRIMARY KEY,
    Student_ID INT,
    Course_ID INT
);

INSERT INTO Enrollments 
VALUES	(1, 1, 101),
		(2, 2, 101),
		(3, 1, 102),
		(4, 3, 103);
        

SELECT *
FROM Students;


SELECT *
FROM Courses;


SELECT *
FROM Enrollments;
        

-- Get all students and the courses they are enrolled in.

SELECT Students.Student_ID,
	   Students.Name,
       Enrollments.Enroll_ID,
       Courses.Course_Name
FROM Students
LEFT JOIN Enrollments
	ON Students.Student_ID = Enrollments.Student_ID
LEFT JOIN Courses
	ON Enrollments.Course_ID = Courses.Course_ID;
    

-- Find students who are not enrolled in any course.

SELECT Students.Student_ID,
	   Students.Name,
       Enrollments.Enroll_ID,
       Courses.Course_Name
FROM Students
LEFT JOIN Enrollments
	ON Students.Student_ID = Enrollments.Student_ID
LEFT JOIN Courses
	ON Enrollments.Course_ID = Courses.Course_ID
WHERE Enrollments.Enroll_ID IS NULL;


-- Find courses that have no students enrolled.

SELECT Students.Student_ID,
	   Students.Name,
       Enrollments.Enroll_ID,
       Courses.Course_Name
FROM Courses
LEFT JOIN Enrollments
	ON Enrollments.Course_ID = Courses.Course_ID
LEFT JOIN Students
	ON Students.Student_ID = Enrollments.Student_ID
WHERE Students.Student_ID IS NULL;

-- OR

SELECT Courses.Course_ID,
       Courses.Course_Name
FROM Courses
LEFT JOIN Enrollments
    ON Courses.Course_ID = Enrollments.Course_ID
WHERE Enrollments.Enroll_ID IS NULL;


-- Find the number of courses each student is enrolled in.

SELECT Students.Student_ID,
       Students.Name,
       COUNT(Enrollments.Course_ID) AS Total_No_of_Course
FROM Students
LEFT JOIN Enrollments
    ON Students.Student_ID = Enrollments.Student_ID
GROUP BY Students.Student_ID, Students.Name;


-- Find the student who enrolled in the maximum number of courses.

WITH CTE AS (
	SELECT Students.Student_ID,
		   Students.Name,
		   COUNT(Enrollments.Course_ID) AS Total_No_of_Course
	FROM Students
	LEFT JOIN Enrollments
		ON Students.Student_ID = Enrollments.Student_ID
	GROUP BY Students.Student_ID, Students.Name
)
SELECT *
FROM CTE
ORDER BY Total_No_Of_Course DESC
LIMIT 1;

-- OR

SELECT *
FROM (
	SELECT *,
		   RANK() OVER(ORDER BY Total_No_Of_Course DESC) AS Rnk
	FROM (
			SELECT Students.Student_ID,
				   Students.Name,
				   COUNT(Enrollments.Course_ID) AS Total_No_of_Course
			FROM Students
			LEFT JOIN Enrollments
				ON Students.Student_ID = Enrollments.Student_ID
			GROUP BY Students.Student_ID, Students.Name
		)R
	)T
WHERE Rnk = 1;







