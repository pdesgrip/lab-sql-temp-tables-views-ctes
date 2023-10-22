USE saklia;


-- rental info
CREATE VIEW rental_info AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS 'rental_count'
FROM
    customer AS c
JOIN
    rental AS r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email;

--  temporary table for pay summary
CREATE TEMPORARY TABLE temp_payment_summary AS
SELECT
    r.customer_id,
    SUM(p.amount) AS total_paid
FROM
    rental_info AS r
LEFT JOIN
    payment AS p ON r.customer_id = p.customer_id
GROUP BY
    r.customer_id;

-- generate the report
WITH customer_summary_cte AS 
    (SELECT
        CONCAT(ri.first_name, ' ', ri.last_name) AS customer_name, 
        ri.email,
        ri.rental_count,
        tp.total_paid,
        tp.total_paid / ri.rental_count AS average_payment_per_rental
    FROM
        rental_info AS ri
    LEFT JOIN
        temp_payment_summary AS tp ON ri.customer_id = tp.customer_id)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM
    customer_summary_cte
ORDER BY
    customer_name;

