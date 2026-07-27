
-- A CTE (Common Table Expression) is a temporary named result set that exists only for the execution of a single SQL statement.

-- It helps you break a complex query into smaller, easier-to-read steps.

-- A CTE is a temporary named query used to simplify complex SQL statements.

-- Example

WITH CTE AS (
    SELECT ...
)
SELECT *
FROM CTE;

-- Without CTE:

SELECT *
FROM (
    SELECT Customer_ID,
           SUM(Order_Amount) AS Total_Order
    FROM Orders
    GROUP BY Customer_ID
) A
WHERE Total_Order > 1000;

-- With CTE:

WITH CTE AS (
    SELECT Customer_ID,
           SUM(Order_Amount) AS Total_Order
    FROM Orders
    GROUP BY Customer_ID
)
SELECT *
FROM CTE
WHERE Total_Order > 1000;

-- Why do we use CTEs?
-- Improve readability
-- Break complex queries into steps
-- Reuse intermediate results
-- Make debugging easier
-- Build multi-step analytical queries
