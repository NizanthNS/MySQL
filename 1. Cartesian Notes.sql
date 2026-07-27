CARTESIAN PRODUCT / CROSS JOIN

Definition:
A CROSS JOIN is a SQL join operation that combines every row from one table with every row from another table. 
The result produced by a CROSS JOIN is called the Cartesian Product.

Formula:
If Table A has m rows and Table B has n rows,

Total Rows = m × n

Example:

Customers

+-------------+-------+
| Customer_ID | Name  |
+-------------+-------+
| 1           | Alice |
| 2           | Bob   |
+-------------+-------+

Products

+------------+----------+
| Product_ID | Product  |
+------------+----------+
| 101        | Laptop   |
| 102        | Mouse    |
| 103        | Keyboard |
+------------+----------+

Query:

SELECT *
FROM Customers
CROSS JOIN Products;

Result:

Alice  Laptop
Alice  Mouse
Alice  Keyboard
Bob    Laptop
Bob    Mouse
Bob    Keyboard

Total Rows:
2 Customers × 3 Products = 6 Rows

Key Points:
• CROSS JOIN returns every possible combination of rows.
• CROSS JOIN is the SQL operation.
• Cartesian Product is the result of that operation.
• No ON condition is required.
• Can also occur accidentally if tables are combined without a proper join condition.

Real-world Uses:
• Every Employee × Every Shift
• Every Product × Every Color
• Every Student × Every Subject
• Calendar Dates × Stores
• Sizes × Colors for Inventory

Interview Definition:
"A CROSS JOIN is the SQL operation that combines every row from one table with every row from another table. 
The result produced by a CROSS JOIN is called the Cartesian Product."

Easy to Remember:
CROSS JOIN (Operation) → CARTESIAN PRODUCT (Result)

CREATE TABLE C (
	Num_ID INT
    );

INSERT INTO C
VALUES (1),
	   (2),
       (3);    

    
CREATE TABLE B (
	Num_ID INT
	);

INSERT INTO B
VALUES (1),
	   (2),
       (3),
       (1),
       (2),
       (3);
       
    
SELECT *
FROM B;

SELECT *
FROM C;

SELECT *
FROM B
LEFT JOIN C
	ON C.Num_ID = B.Num_ID;

ALTER TABLE C
RENAME COLUMN Num_ID TO Number_ID;

SELECT *
FROM B
CROSS JOIN C
	ON C.Number_ID = B.Num_ID;
    
    
CREATE TABLE D (
	Num_ID INT
    );

INSERT INTO D
VALUES (1),
	     (2),
       (3);    

    
CREATE TABLE E (
	Number_ID INT
	);

INSERT INTO E
VALUES (1),
	     (2),
       (3),
       (4),
       (5),
       (6);

SELECT *
FROM D;

SELECT *
FROM E;
    
SELECT *
FROM D
CROSS JOIN E
	ON D.Num_ID = E.Number_ID; -- CROSS JOIN IS Not Valid if values are different
