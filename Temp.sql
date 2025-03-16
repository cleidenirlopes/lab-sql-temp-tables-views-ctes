-- Step 1: Create a View summarizing rental information for each customer
CREATE VIEW rental_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Step 2: Create a Temporary Table to calculate the total amount paid by each customer
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    rs.customer_id,
    SUM(p.amount) AS total_paid
FROM rental_summary rs
LEFT JOIN payment p ON rs.customer_id = p.customer_id
GROUP BY rs.customer_id;

-- Step 3: Create a CTE and the Final Customer Summary Report
WITH customer_summary AS (
    SELECT 
        rs.first_name,
        rs.last_name,
        rs.email,
        rs.rental_count,
        cps.total_paid,
        (cps.total_paid / NULLIF(rs.rental_count, 0)) AS average_payment_per_rental
    FROM rental_summary rs
    LEFT JOIN customer_payment_summary cps ON rs.customer_id = cps.customer_id
)
-- Generate the final report
SELECT * FROM customer_summary;
