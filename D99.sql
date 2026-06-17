USE Daily_SQL;

-- DATASET

CREATE TABLE Library_Borrowing (
    Borrow_ID INT,
    Member_ID INT,
    Member_Name VARCHAR(50),
    Borrow_Date DATE,
    Book_Category VARCHAR(50),
    Books_Borrowed INT,
    Membership_Type VARCHAR(20)
);

INSERT INTO Library_Borrowing 
VALUES	(1,101,'Alice','2024-01-01','Technology',2,'Premium'),
		(2,101,'Alice','2024-01-02','Technology',1,'Premium'),
		(3,101,'Alice','2024-01-03','Fiction',3,'Premium'),
		(4,101,'Alice','2024-01-07','History',1,'Premium'),

		(5,102,'Bob','2024-01-01','Fiction',2,'Standard'),
		(6,102,'Bob','2024-01-05','Technology',1,'Standard'),
		(7,102,'Bob','2024-01-06','Science',2,'Standard'),

		(8,103,'Charlie','2024-01-02','Science',4,'Premium'),
		(9,103,'Charlie','2024-01-03','Science',2,'Premium'),
		(10,103,'Charlie','2024-01-04','Technology',3,'Premium'),
		(11,103,'Charlie','2024-01-05','History',2,'Premium'),

		(12,104,'David','2024-01-01','History',1,'Basic'),
		(13,104,'David','2024-01-08','History',2,'Basic'),

		(14,105,'Emma','2024-01-03','Technology',5,'Premium'),
		(15,105,'Emma','2024-01-04','Technology',2,'Premium'),
		(16,105,'Emma','2024-01-05','Science',3,'Premium');
        
SELECT *
FROM Library_Borrowing;


-- Q1
-- Show each member's total borrowing records,
-- total books borrowed, and average books borrowed.
--
-- Return:
-- Member_ID
-- Member_Name
-- Total_Borrowing_Records
-- Total_Books_Borrowed
-- Average_Books_Borrowed

SELECT Member_ID, Member_Name,
	   COUNT(Borrow_ID) AS Total_Borrowing_Records,
       SUM(Books_Borrowed) AS Total_Books_Borrowed,
       ROUND(AVG(Books_Borrowed), 2) AS Average_Books_Borrowed
FROM Library_Borrowing
GROUP BY Member_ID, Member_Name;


-- Q2
-- Show each book category's total borrowing records
-- and total books borrowed.
--
-- Return:
-- Book_Category
-- Total_Borrowing_Records
-- Total_Books_Borrowed

SELECT Book_Category,
	   COUNT(Borrow_ID) AS Total_Borrowing_Records,
       SUM(Books_Borrowed) AS Total_Books_Borrowed
FROM Library_Borrowing
GROUP BY Book_Category;


-- Q3
-- Find the top 3 members by total books borrowed.
--
-- Return:
-- Member_ID
-- Member_Name
-- Total_Books_Borrowed

WITH CTE AS (
	SELECT Member_ID, Member_Name,
		   SUM(Books_Borrowed) AS Total_Books_Borrowed
	FROM Library_Borrowing
	GROUP BY Member_ID, Member_Name
),
CTE2 AS (
	SELECT *,
		   DENSE_RANK() OVER(ORDER BY Total_Books_Borrowed DESC) AS D_Rank
	FROM CTE
)
SELECT Member_ID, Member_Name, Total_Books_Borrowed
FROM CTE2
WHERE D_Rank <= 3;


-- Q4
-- Find members who borrowed books within 2 days
-- of their previous borrowing activity.
--
-- Return:
-- Member_ID
-- Member_Name

WITH CTE AS (
	SELECT Member_ID, Member_Name, Borrow_Date,
		   LAG(Borrow_Date) OVER(PARTITION BY Member_ID
           ORDER BY Borrow_Date, Borrow_ID) AS Previous
	FROM Library_Borrowing
)
SELECT DISTINCT Member_ID, Member_Name
FROM CTE
WHERE Previous IS NOT NULL
AND DATEDIFF(Borrow_Date, Previous) <= 2;


-- Q5
-- Find members whose total books borrowed is greater
-- than the average total books borrowed of all members.
--
-- Return:
-- Member_ID
-- Member_Name
-- Total_Books_Borrowed

WITH CTE AS (
	SELECT Member_ID, Member_Name,
		   SUM(Books_Borrowed) AS Total_Books_Borrowed
	FROM Library_Borrowing
	GROUP BY Member_ID, Member_Name
)
SELECT *
FROM CTE
WHERE Total_Books_Borrowed > (
	SELECT AVG(Total_Books_Borrowed)
    FROM CTE
);


-- BONUS
-- Find members whose longest borrowing streak
-- is exactly 3 days.
--
-- Return:
-- Member_ID
-- Member_Name
-- Longest_Streak
--
-- Note:
-- Ignore duplicate borrow dates if a member
-- has multiple borrowings on the same day.

WITH CTE AS (
	SELECT DISTINCT Member_ID, Member_Name, Borrow_Date
    FROM Library_Borrowing
),
CTE2 AS (
	SELECT *,
		   ROW_NUMBER() OVER(PARTITION BY Member_ID
           ORDER BY Borrow_Date) AS RN
	FROM CTE
),
CTE3 AS (
	SELECT *,
		   DATE_SUB(Borrow_Date, INTERVAL RN DAY) AS GK
	FROM CTE2
),
CTE4 AS (
	SELECT Member_ID, Member_Name,
		   COUNT(*) AS Longest_Streak
	FROM CTE3
    GROUP BY Member_ID, Member_Name, GK
)
SELECT Member_ID, Member_Name,
	   MAX(Longest_Streak) AS Longest_Streak
FROM CTE4
GROUP BY Member_ID, Member_Name
HAVING MAX(Longest_Streak) = 3;