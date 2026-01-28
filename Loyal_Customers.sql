CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    signup_date DATE
);

INSERT INTO customers (customer_id, customer_name, email, signup_date) VALUES
(1, 'Alice Johnson', 'alice@example.com', '2023-01-10'),
(2, 'Bob Smith', 'bob@example.com', '2023-02-15'),
(3, 'Charlie Lee', 'charlie@example.com', '2023-03-20'),
(4, 'Diana Ross', 'diana@example.com', '2023-04-01');


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


INSERT INTO orders (order_id, customer_id, order_date, order_amount) VALUES
(101, 1, CURRENT_DATE - INTERVAL '10' DAY, 120.50),
(102, 1, CURRENT_DATE - INTERVAL '40' DAY, 75.00),
(103, 2, CURRENT_DATE - INTERVAL '20' DAY, 200.00),
(104, 3, CURRENT_DATE - INTERVAL '60' DAY, 50.00),
(105, 4, CURRENT_DATE - INTERVAL '5' DAY, 300.00);

Select * From customers;

Select * From orders;

SELECT DISTINCT c.customer_id, c.customer_name As loyal_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '30' DAY;