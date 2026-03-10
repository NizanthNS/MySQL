CREATE TABLE Students (
	student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    class VARCHAR(50),
    age INT
);


CREATE TABLE Exams (
    exam_id INT PRIMARY KEY,
    student_id INT,
    subject VARCHAR(50),
    marks INT
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


Select *
From Students;

Select *
From Exams;


-- 1. Show all students from class 10A

Select *
From Students
WHERE class = '10A';


-- 2. Show students who scored more than 80 in Math

Select *
From Students
INNER JOIN Exams
	ON Students.student_id = Exams.student_id
    WHERE Exams.subject = 'Math' 
    AND  Exams.marks > 80;


-- 3. Show student name and subject they took exams in

Select Students.student_name, Exams.subject
From Students
INNER JOIN Exams
	ON Students.student_id = Exams.student_id;


-- 4.Find the average marks per subject

Select subject, AVG(marks) AS Average_Marks
From Exams
GROUP BY subject;


-- 5. Find the highest mark in the Math subject

Select MAX(marks) AS Highest_mark_in_Math
From Exams
WHERE subject = 'Math';


-- 6. Show students who never took a Science exam

Select *
From Students
LEFT JOIN Exams
	ON Students.student_id = Exams.student_id
    AND Exams.subject = 'Science'
    WHERE Exams.exam_id IS NULL;


-- 7. Count number of students in each class

Select class, COUNT(student_id) AS Total_Students
From Students
GROUP BY class;

-- OR

Select class, COUNT(*) AS Total_Students
From Students
GROUP BY class;


-- 8. Find the student who scored the highest marks overall

Select Students.student_name, Exams.subject, Exams.marks
From Students
INNER JOIN Exams
	ON Students.student_id = Exams.student_id
    WHERE Exams.marks = (Select MAX(marks) From Exams);


-- 9. Show students whose marks are above the average marks

Select Students.student_name, Exams.marks
From Students
INNER JOIN Exams
	ON Students.student_id = Exams.student_id
    WHERE marks > (Select AVG(marks) From Exams);


-- 10. Find the class with the highest average marks

Select Students.class, AVG(Exams.marks) AS Highest_average_marks
From Exams
INNER JOIN Students
	ON Students.student_id = Exams.student_id
    GROUP BY Students.class
    ORDER BY Highest_average_marks DESC
    LIMIT 1;








