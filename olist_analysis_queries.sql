-- =========================================================
-- OLIST E-COMMERCE ANALYSIS
-- Google BigQuery
-- =========================================================


-- =========================================================
-- 1. TOTAL ORDERS
-- =========================================================

SELECT
  COUNT(*) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`;


-- =========================================================
-- 2. ORDERS BY STATUS
-- =========================================================

SELECT
  order_status,
  COUNT(*) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`
GROUP BY order_status
ORDER BY total_orders DESC;


-- =========================================================
-- 3. MONTHLY ORDER VOLUME
-- =========================================================

SELECT
  FORMAT_DATE('%Y-%m', DATE(order_purchase_timestamp)) AS order_month,
  COUNT(*) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`
GROUP BY order_month
ORDER BY order_month;


-- =========================================================
-- 4. MONTHLY REVENUE
-- =========================================================

SELECT
  FORMAT_DATE('%Y-%m', DATE(o.order_purchase_timestamp)) AS order_month,
  ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.order_payments` AS p
  ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month;


-- =========================================================
-- 5. REVENUE BY PRODUCT CATEGORY
-- =========================================================

SELECT
  pct.product_category_name_english AS product_category,
  ROUND(SUM(oi.price), 2) AS total_revenue
FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_items` AS oi
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.products` AS p
  ON oi.product_id = p.product_id
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.product_category_translation` AS pct
  ON p.product_category_name = pct.product_category_name
GROUP BY product_category
ORDER BY total_revenue DESC;


-- =========================================================
-- 6. ORDERS BY CUSTOMER STATE
-- =========================================================

SELECT
  c.customer_state,
  COUNT(*) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.customers` AS c
  ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- =========================================================
-- 7. AVERAGE REVIEW SCORE BY PRODUCT CATEGORY
-- =========================================================

SELECT
  pct.product_category_name_english AS product_category,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(*) AS review_count
FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_reviews` AS r
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.order_items` AS oi
  ON r.order_id = oi.order_id
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.products` AS p
  ON oi.product_id = p.product_id
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.product_category_translation` AS pct
  ON p.product_category_name = pct.product_category_name
GROUP BY product_category
HAVING COUNT(*) >= 100
ORDER BY avg_review_score DESC;


-- =========================================================
-- 8. DELIVERY PERFORMANCE
-- Average delivery time + late delivery rate
-- =========================================================

SELECT
  ROUND(
    AVG(
      DATE_DIFF(
        DATE(order_delivered_customer_date),
        DATE(order_purchase_timestamp),
        DAY
      )
    ),
    2
  ) AS avg_delivery_days,

  ROUND(
    100 * AVG(
      CASE
        WHEN DATE(order_delivered_customer_date) >
             DATE(order_estimated_delivery_date)
        THEN 1
        ELSE 0
      END
    ),
    2
  ) AS late_delivery_rate_pct

FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- =========================================================
-- 9. LATE DELIVERY RATE BY STATE
-- =========================================================

SELECT
  c.customer_state,

  ROUND(
    100 * AVG(
      CASE
        WHEN DATE(o.order_delivered_customer_date) >
             DATE(o.order_estimated_delivery_date)
        THEN 1
        ELSE 0
      END
    ),
    2
  ) AS late_delivery_rate_pct,

  COUNT(*) AS delivered_orders

FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o

JOIN `project-2246b9ea-0836-444d-a5f.olist_project.customers` AS c
  ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY late_delivery_rate_pct DESC;


-- =========================================================
-- 10. REPEAT CUSTOMER RATE
-- =========================================================

WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    COUNT(*) AS order_count
  FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
  JOIN `project-2246b9ea-0836-444d-a5f.olist_project.customers` AS c
    ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)

SELECT
  COUNT(*) AS total_customers,
  COUNTIF(order_count > 1) AS repeat_customers,
  ROUND(
    100 * COUNTIF(order_count > 1) / COUNT(*),
    2
  ) AS repeat_customer_rate_pct
FROM customer_orders;


-- =========================================================
-- 11. TOP SELLERS BY REVENUE
-- =========================================================

SELECT
  oi.seller_id,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  COUNT(DISTINCT oi.order_id) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_items` AS oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;


-- =========================================================
-- 12. AVERAGE ORDER VALUE
-- =========================================================

WITH order_totals AS (
  SELECT
    order_id,
    SUM(payment_value) AS order_value
  FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_payments`
  GROUP BY order_id
)

SELECT
  ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;


-- =========================================================
-- 13. PAYMENT METHOD SHARE
-- =========================================================

SELECT
  payment_type,
  COUNT(*) AS payment_records,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER (),
    2
  ) AS payment_share_pct
FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_payments`
GROUP BY payment_type
ORDER BY payment_records DESC;


-- =========================================================
-- 14. MONTHLY REVENUE GROWTH
-- =========================================================

WITH monthly_revenue AS (
  SELECT
    FORMAT_DATE('%Y-%m', DATE(o.order_purchase_timestamp)) AS order_month,
    SUM(p.payment_value) AS revenue
  FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
  JOIN `project-2246b9ea-0836-444d-a5f.olist_project.order_payments` AS p
    ON o.order_id = p.order_id
  GROUP BY order_month
),

revenue_with_previous AS (
  SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue
  FROM monthly_revenue
)

SELECT
  order_month,
  ROUND(revenue, 2) AS revenue,
  ROUND(previous_month_revenue, 2) AS previous_month_revenue,
  ROUND(
    100 * (revenue - previous_month_revenue) / previous_month_revenue,
    2
  ) AS monthly_growth_pct
FROM revenue_with_previous
ORDER BY order_month;


-- =========================================================
-- 15. REVENUE BY CUSTOMER STATE
-- =========================================================

SELECT
  c.customer_state,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.customers` AS c
  ON o.customer_id = c.customer_id
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.order_payments` AS p
  ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- =========================================================
-- 16. DASHBOARD VIEW: MONTHLY REVENUE
-- =========================================================

CREATE OR REPLACE VIEW
`project-2246b9ea-0836-444d-a5f.olist_project.v_monthly_revenue`
AS

SELECT
  DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.order_payments` AS p
  ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month;


-- =========================================================
-- 17. DASHBOARD VIEW: CATEGORY REVENUE
-- =========================================================

CREATE OR REPLACE VIEW
`project-2246b9ea-0836-444d-a5f.olist_project.v_category_revenue`
AS

SELECT
  pct.product_category_name_english AS product_category,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  COUNT(DISTINCT oi.order_id) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_items` AS oi
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.products` AS p
  ON oi.product_id = p.product_id
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.product_category_translation` AS pct
  ON p.product_category_name = pct.product_category_name
GROUP BY product_category;


-- =========================================================
-- 18. DASHBOARD VIEW: STATE REVENUE
-- =========================================================

CREATE OR REPLACE VIEW
`project-2246b9ea-0836-444d-a5f.olist_project.v_state_revenue`
AS

SELECT
  c.customer_state,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.customers` AS c
  ON o.customer_id = c.customer_id
JOIN `project-2246b9ea-0836-444d-a5f.olist_project.order_payments` AS p
  ON o.order_id = p.order_id
GROUP BY c.customer_state;


-- =========================================================
-- 19. DASHBOARD VIEW: KPI SUMMARY
-- =========================================================

CREATE OR REPLACE VIEW
`project-2246b9ea-0836-444d-a5f.olist_project.v_kpis`
AS

WITH order_totals AS (
  SELECT
    order_id,
    SUM(payment_value) AS order_value
  FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_payments`
  GROUP BY order_id
),

repeat_customers AS (
  SELECT
    c.customer_unique_id,
    COUNT(*) AS order_count
  FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders` AS o
  JOIN `project-2246b9ea-0836-444d-a5f.olist_project.customers` AS c
    ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)

SELECT
  (
    SELECT COUNT(*)
    FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`
  ) AS total_orders,

  ROUND(
    (
      SELECT SUM(payment_value)
      FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_payments`
    ),
    2
  ) AS total_revenue,

  ROUND(
    (
      SELECT AVG(order_value)
      FROM order_totals
    ),
    2
  ) AS average_order_value,

  ROUND(
    (
      SELECT AVG(
        CASE
          WHEN DATE(order_delivered_customer_date) >
               DATE(order_estimated_delivery_date)
          THEN 1
          ELSE 0
        END
      ) * 100
      FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`
      WHERE order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
        AND order_estimated_delivery_date IS NOT NULL
    ),
    2
  ) AS late_delivery_rate_pct,

  ROUND(
    (
      SELECT AVG(
        DATE_DIFF(
          DATE(order_delivered_customer_date),
          DATE(order_purchase_timestamp),
          DAY
        )
      )
      FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`
      WHERE order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
    ),
    2
  ) AS avg_delivery_days,

  ROUND(
    (
      SELECT
        100 * COUNTIF(order_count > 1) / COUNT(*)
      FROM repeat_customers
    ),
    2
  ) AS repeat_customer_rate_pct;
