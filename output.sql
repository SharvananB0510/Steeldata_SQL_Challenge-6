
/*1. How many transactions were completed during each marketing campaign? */

SELECT 
    M.campaign_name, COUNT(T.transaction_id) AS transactions
FROM
    transactions T
        JOIN
    marketing_campaigns M USING (product_id)
GROUP BY campaign_name;

/*2. Which product had the highest sales quantity? */

SELECT 
    S.Product_name, COUNT(T.quantity) AS qty
FROM
    transactions T
        JOIN
    sustainable_clothing S USING (product_id)
GROUP BY product_name
ORDER BY qty DESC
LIMIT 1;

/*3. What is the total revenue generated from each marketing campaign? */

SELECT 
    M.campaign_name,
    ROUND(SUM(T.quantity * S.price), 2) AS total_revenue
FROM
    transactions T
        JOIN
    marketing_campaigns M USING (product_id)
        JOIN
    sustainable_clothing S USING (product_id)
GROUP BY campaign_name;

/*4. What is the top-selling product category based on the total revenue generated? */

SELECT 
    S.category,
    ROUND(SUM(T.quantity * S.price), 2) AS total_revenue
FROM
    transactions T
        JOIN
    sustainable_clothing S USING (product_id)
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;

/*5. Which products had a higher quantity sold compared to the average quantity sold?*/

SELECT 
    S.product_name, SUM(T.quantity) AS qty
FROM
    transactions T
        JOIN
    sustainable_clothing S USING (product_id)
GROUP BY product_name
HAVING SUM(T.quantity) > (SELECT 
        AVG(quantity)
    FROM
        transactions)
ORDER BY qty DESC;

/* 6. What is the average revenue generated per day during the marketing campaigns? */

SELECT 
    M.campaign_name,
    ROUND(Sum(T.quantity * S.price) / (DATEDIFF(M.end_date, M.start_date)),
            2) AS avg_revenue_per_day
FROM
    transactions T
        JOIN
    marketing_campaigns M USING (product_id)
        JOIN
    sustainable_clothing S USING (product_id)
GROUP BY campaign_name , M.start_date , M.end_date;

/* 7. What is the percentage contribution of each product to the total revenue? */

with CTE_total as (SELECT 
    SUM(S.price * T.quantity) AS total
FROM
    transactions T
        JOIN
    sustainable_clothing S USING (product_id) )
,CTE_percent as (
SELECT 
    S.product_name,
    ROUND(SUM(S.price * T.quantity), 2) AS contribution
FROM
    transactions T
        JOIN
    sustainable_clothing S USING (product_id)
GROUP BY product_name)
SELECT 
    P.product_name,
    P.contribution,
    ROUND((P.contribution / T.total) * 100, 2) AS percentage
FROM
    CTE_percent P
        CROSS JOIN
    CTE_total T
GROUP BY product_name , total
ORDER BY contribution DESC;
---

/*8. Compare the average quantity sold during marketing campaigns to outside the marketing campaigns */

WITH CTE_during AS (
    SELECT
        ROUND(AVG(T.quantity), 2) AS during_campaigns
    FROM
        transactions T
    INNER JOIN
        marketing_campaigns M USING (product_id)
),
CTE_outside AS (
    SELECT
        ROUND(AVG(T.quantity), 2) AS outside_campaigns
    FROM
        transactions T
    LEFT JOIN
        marketing_campaigns M USING (product_id)
    WHERE
        M.product_id IS NULL
)
SELECT
    D.during_campaigns,
    O.outside_campaigns
FROM
    CTE_during D
JOIN
    CTE_outside O ON 1 = 1;

/*9. Compare the revenue generated by products inside the marketing campaigns to outside the campaigns */

with inside as (
SELECT 
    ROUND(SUM(S.price * T.quantity), 2) AS revenue_inside_campaigns
FROM
    transactions T
        JOIN
    sustainable_clothing S USING (product_id)
        JOIN
    marketing_campaigns M USING (product_id))
,outside as (
SELECT 
    ROUND(SUM(S.price * T.quantity), 2) AS revenue_outside_campaigns
FROM
    transactions T
        JOIN
    sustainable_clothing S USING (product_id)
        LEFT JOIN
    marketing_campaigns M USING (product_id)
WHERE
    M.product_id IS NULL)
SELECT 
    I.revenue_inside_campaigns, O.revenue_outside_campaigns
FROM
    inside I
        JOIN
    outside O ON 1 = 1;

/*10. Rank the products by their average daily quantity sold */

SELECT
    S.Product_name,
    SUM(T.quantity) AS total_quantity,
    DENSE_RANK() OVER (ORDER BY SUM(T.quantity) DESC) AS products_rank
FROM
    transactions T
JOIN
    sustainable_clothing S USING (product_id)
GROUP BY
    S.Product_name;
