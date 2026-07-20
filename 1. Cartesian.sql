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
