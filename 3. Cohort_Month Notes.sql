-- Definition:
-- A customer's cohort month is the month of
-- their first booking date.

-- Example

WITH CTE AS (
	SELECT C.Customer_ID,
		   MIN(M.Booking_Date) AS First_Booking_Date
	FROM Customers C
	INNER JOIN Movie_Bookings M
		ON C.Customer_ID = M.Customer_ID
	GROUP BY C.Customer_ID
),
CTE2 AS (
	SELECT *,
		   DATE_FORMAT(First_Booking_Date, '%Y-%m') AS Cohort_Month
	FROM CTE
)
SELECT Cohort_Month,
	   COUNT(DISTINCT CT.Customer_ID) AS Total_Customers,
       SUM(B.Ticket_Amount) AS Total_Ticket_Revenue
FROM CTE2 CT
INNER JOIN Movie_Bookings B
	ON CT.Customer_ID = B.Customer_ID
GROUP BY Cohort_Month;
