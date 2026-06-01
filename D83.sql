USE Daily_SQL;

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    City VARCHAR(50)
);

INSERT INTO Customers
VALUES  (1, 'Arun', 'Chennai'),
        (2, 'Meena', 'Bangalore'),
        (3, 'Ravi', 'Mumbai'),
        (4, 'Priya', 'Chennai'),
        (5, 'Karan', 'Bangalore');


CREATE TABLE Gym_Visits (
    Visit_ID INT PRIMARY KEY,
    Customer_ID INT,
    Visit_Date DATE,
    Workout_Type VARCHAR(50),
    Calories_Burned INT
);

INSERT INTO Gym_Visits
VALUES  (101, 1, '2025-01-02', 'Cardio', 300),
        (102, 1, '2025-01-10', 'Strength', 450),
        (103, 2, '2025-01-05', 'Cardio', 280),
        (104, 3, '2025-01-08', 'Yoga', 200),
        (105, 1, '2025-01-20', 'Cardio', 350),
        (106, 4, '2025-01-15', 'Strength', 500),
        (107, 5, '2025-01-18', 'Cardio', 320),
        (108, 3, '2025-02-01', 'Yoga', 250),
        (109, 2, '2025-02-10', 'Strength', 400),
        (110, 4, '2025-02-20', 'Cardio', 380),
        (111, 5, '2025-02-25', 'Strength', 420),
        (112, 1, '2025-03-01', 'Yoga', 270);


SELECT *
FROM Customers;

SELECT *
FROM Gym_Visits;


-- Mixed SQL Practice + Date Logic


-- Q1
-- Show each customer along with:
-- 1. Total Gym Visits
-- 2. Total Calories Burned
-- 3. Average Calories Burned
-- ordered by Total Calories Burned descending.

SELECT C.Customer_ID, C.Customer_Name,
	   COUNT(G.Visit_ID) AS Total_Gym_Visits,
       SUM(G.Calories_Burned) AS Total_Calories_Burned,
       ROUND(AVG(G.Calories_Burned), 2) AS Average_Calories_Burned
FROM Customers C
INNER JOIN Gym_Visits G
	ON C.Customer_ID = G.Customer_ID
GROUP BY C.Customer_ID, C.Customer_Name
ORDER BY Total_Calories_Burned DESC;


-- Q2
-- Find customers whose total calories burned
-- is greater than the average total calories burned
-- of all customers.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name,
		   SUM(G.Calories_Burned) AS Total_Calories_Burned
	FROM Customers C
	INNER JOIN Gym_Visits G
		ON C.Customer_ID = G.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name
)
SELECT *
FROM CTE
WHERE Total_Calories_Burned > (
	SELECT AVG(Total_Calories_Burned)
    FROM CTE
);


-- Q3
-- Show the customer with the highest total calories burned
-- in each City.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, C.City,
		   SUM(G.Calories_Burned) AS Total_Calories_Burned
	FROM Customers C
	INNER JOIN Gym_Visits G
		ON C.Customer_ID = G.Customer_ID
	GROUP BY C.Customer_ID, C.Customer_Name, C.City
)
SELECT *
FROM (
	SELECT *,
		   DENSE_RANK() OVER(PARTITION BY City
           ORDER BY Total_Calories_Burned DESC) AS D_Rank
	FROM CTE
)D
WHERE D_Rank = 1;


-- Q4
-- Show workout types that were performed
-- more than once within the same month.

SELECT Workout_Type,
	   COUNT(Visit_ID) AS Total_Visits,
       YEAR(Visit_Date) AS Year_,
       MONTH(Visit_Date) AS Month_
FROM Gym_Visits
GROUP BY Workout_Type, YEAR(Visit_Date), MONTH(Visit_Date)
HAVING COUNT(Visit_ID) > 1;


-- Q5
-- Show each gym visit along with:
-- 1. Previous Calories_Burned of that customer
-- 2. Difference from previous Calories_Burned
-- 3. Running total Calories_Burned of that customer

WITH CTE AS (
	SELECT Visit_ID, Customer_ID, Visit_Date, Calories_Burned,
		   LAG(Calories_Burned) OVER(PARTITION BY Customer_ID
		   ORDER BY Visit_Date) AS Previous_Calories,
		   Calories_Burned - LAG(Calories_Burned) OVER(PARTITION BY 
		   Customer_ID ORDER BY Visit_Date) AS Difference,
		   SUM(Calories_Burned) OVER(PARTITION BY Customer_ID
		   ORDER BY Visit_Date) AS Running_Total
	FROM Gym_Visits
)
SELECT *
FROM CTE
WHERE Previous_Calories IS NOT NULL;


-- Q6 (Date Logic)
-- Find customers who visited the gym again
-- within 12 days of their previous visit.

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, G.Visit_Date,
		   LAG(G.Visit_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY G.Visit_Date, G.Visit_ID) AS Previous_Date
	FROM Customers C
	INNER JOIN Gym_Visits G
		ON C.Customer_ID = G.Customer_ID
)
SELECT DISTINCT Customer_ID, Customer_Name
FROM CTE
WHERE Previous_Date IS NOT NULL
AND DATEDIFF(Visit_Date, Previous_Date) <= 12;


-- Bonus Challenge
-- Show:
-- 1. Customer_Name
-- 2. First Visit_Date
-- 3. Latest Visit_Date
-- 4. Total Gym Visits
-- 5. Total Calories Burned
-- 6. Average Days Between Visits

WITH CTE AS (
	SELECT C.Customer_ID, C.Customer_Name, G.Visit_Date, G.Visit_ID, G.Calories_Burned,
		   LAG(G.Visit_Date) OVER(PARTITION BY C.Customer_ID
           ORDER BY G.Visit_Date, G.Visit_ID) AS Previous_Date
	FROM Customers C
	INNER JOIN Gym_Visits G
		ON C.Customer_ID = G.Customer_ID
),
CTE2 AS (
	SELECT *,
		   DATEDIFF(Visit_Date, Previous_Date) AS Days_Gap
	FROM CTE
)
SELECT Customer_ID, Customer_Name,
	   MIN(Visit_Date) AS First_Visit_Date,
       MAX(Visit_Date) AS Last_Visit_Date,
       COUNT(Visit_ID) AS Total_Gym_Visits,
       SUM(Calories_Burned) AS Total_Calories_Burned,
       ROUND(AVG(Days_Gap), 2) AS Average_Days
FROM CTE2
GROUP BY Customer_ID, Customer_Name;