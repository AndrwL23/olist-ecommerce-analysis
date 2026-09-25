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
  (SELECT COUNT(*) FROM `project-2246b9ea-0836-444d-a5f.olist_project.orders`) AS total_orders,

  ROUND(
    (SELECT SUM(payment_value)
     FROM `project-2246b9ea-0836-444d-a5f.olist_project.order_payments`),
    2
  ) AS total_revenue,

  ROUND(
    (SELECT AVG(order_value) FROM order_totals),
    2
  ) AS average_order_value,

  ROUND(
    (
      SELECT AVG(
        CASE
          WHEN DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)
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
      SELECT 100 * COUNTIF(order_count > 1) / COUNT(*)
      FROM repeat_customers
    ),
    2
  ) AS repeat_customer_rate_pct;