CREATE TABLE Students (
	student_id INT PRIMARY KEY,
	student_name VARCHAR(50),
	class VARCHAR(10),
	age INT
);


CREATE TABLE Marks (
	exam_id INT PRIMARY KEY,
	student_id INT,
	subject VARCHAR(50),
	marks INT
);


INSERT INTO Students 
VALUES	(1,'Arun','10A',15),
		(2,'Meena','10A',16),
		(3,'Ravi','10B',15),
		(4,'Divya','10B',16),
		(5,'Karan','10A',15),
		(6,'Sneha','10C',17),
		(7,'Vikram','10C',16);
        

INSERT INTO Marks 
VALUES	(101,1,'Math',85),
		(102,1,'Science',78),
		(103,2,'Math',92),
		(104,3,'Math',88),
		(105,4,'Science',81),
		(106,5,'Math',76),
		(107,6,'Math',95),
		(108,7,'Science',84),
		(109,3,'Science',79);


SELECT *
FROM Students;

SELECT *
FROM Marks;


-- 1. Show all students in class '10A'

SELECT *
FROM Students
WHERE class = '10A';


-- 2. Show students whose age is greater than 15

SELECT *
FROM Students
WHERE age > 15;


-- 3. Show student names and their subjects

SELECT student_name, subject
FROM Students
INNER JOIN Marks
	ON Students.student_id = Marks.student_id;


-- 4. Find the average marks for each subject

SELECT subject, AVG(marks) AS Average_Marks
FROM Marks
GROUP BY subject;


-- 5. Find the highest mark in Math

SELECT MAX(marks) AS Highest_Mark_In_Math
FROM Marks
WHERE subject = 'Math';

-- OR

SELECT *
FROM Marks
WHERE subject = 'Math'
ORDER BY marks DESC
LIMIT 1;

-- OR

SELECT *
FROM Marks
WHERE marks = (
	SELECT MAX(marks) 
    FROM Marks
    WHERE subject = 'Math');

-- AND

SELECT *
FROM Marks
WHERE marks = (
	SELECT MAX(marks) 
    FROM Marks);

-- OR

SELECT *
FROM Marks
ORDER BY marks DESC
LIMIT 1;


-- 6. Show students who did not take the Science exam

SELECT *
FROM Students
LEFT JOIN Marks
	ON Students.student_id = Marks.student_id
    AND subject = 'Science'
    WHERE exam_id IS NULL;


-- 7. Count number of students in each class

SELECT class, COUNT(*) AS Total_Students
FROM Students
GROUP BY class;


-- 8. Find the student who scored the highest mark

SELECT *
FROM Students
INNER JOIN Marks
	ON Students.student_id = Marks.student_id
    WHERE marks = (
		SELECT MAX(marks)
        FROM Marks);
        
-- OR

SELECT *
FROM Students
INNER JOIN Marks
	ON Students.student_id = Marks.student_id
    ORDER BY marks DESC
    LIMIT 1;


-- 9. Show students whose marks are above the average marks

SELECT *
FROM Students
INNER JOIN Marks
	ON Students.student_id = Marks.student_id
    WHERE marks > (
		SELECT AVG(marks)
        FROM Marks);


-- 10. Find the class with the highest average marks

SELECT Students.class, AVG(Marks.marks) AS Average_Marks
FROM Students
INNER JOIN Marks
	ON Students.student_id = Marks.student_id
    GROUP BY Students.class
    ORDER BY Average_Marks DESC
    LIMIT 1;

-- OR

SELECT Students.class, AVG(Marks.marks) AS Average_Marks
FROM Students
INNER JOIN Marks
	ON Students.student_id = Marks.student_id
    GROUP BY Students.class
    HAVING AVG(Marks.marks) = (
		SELECT MAX(Average_Marks)
        FROM (
			SELECT Students.class, AVG(Marks.marks) AS Average_Marks
			FROM Students
            INNER JOIN Marks
				ON Students.student_id = Marks.student_id
				GROUP BY Students.class) M
);
    

SELECT 
    Students.class,
    Students.student_name,
    Marks.subject,
    Marks.marks,
    AVG(Marks.marks) OVER (PARTITION BY Students.class) AS Class_Average
	FROM Students
	INNER JOIN Marks
		ON Students.student_id = Marks.student_id;
        

SELECT *
FROM (
    SELECT
        s.class,
        s.student_name,
        m.subject,
        m.marks,
        AVG(m.marks) OVER (PARTITION BY s.class) AS class_avg
		FROM Students s
		INNER JOIN Marks m
			ON s.student_id = m.student_id
) t
WHERE marks > class_avg;


SELECT 
	S.class,
    S.student_name,
    M.subject,
    M.marks,
    AVG(M.marks) OVER (PARTITION BY S.class ORDER BY M.marks DESC) AS Class_Average
    FROM Students S
    INNER JOIN Marks M
		ON S.student_id = M.student_id;
    
    
SELECT
    S.student_name,
    M.subject,
    M.marks,
    AVG(M.marks) OVER () AS Overall_Average
	FROM Students S
	INNER JOIN Marks M
		ON S.student_id = M.student_id;
    