# Olist E-Commerce Analysis

## Project Overview

This project analyzes the Brazilian Olist e-commerce dataset to identify trends in revenue, customer behavior, delivery performance, product categories, sellers, and payment methods.

The goal was to clean and validate the raw data, analyze it using SQL in BigQuery, and build an interactive dashboard in Looker Studio that summarizes the most important business insights.

## Tools Used

- Microsoft Excel
- Google BigQuery
- SQL
- Looker Studio
- GitHub

## Dataset

The dataset contains multiple related tables covering:

- Customers
- Orders
- Order items
- Payments
- Reviews
- Products
- Sellers
- Geolocation
- Product category translations

The tables were connected using keys such as:

- `order_id`
- `customer_id`
- `customer_unique_id`
- `product_id`
- `seller_id`

## Data Cleaning

Before analysis, I validated each dataset by checking:

- Missing values
- Exact duplicate rows
- Data types
- Date and timestamp fields
- Categorical values
- Numeric ranges
- Repeated IDs and whether they represented valid business records

Some important cleaning decisions included:

- Removing more than 260,000 exact duplicate rows from the geolocation dataset
- Preserving valid missing review comments
- Preserving repeated customer IDs when they represented multiple purchases
- Correcting table and column naming conventions for SQL
- Fixing CSV parsing issues caused by quoted review text
- Converting monthly date fields into proper date types for dashboard reporting

## Business Questions

The analysis focused on questions such as:

- How many orders were placed?
- How has revenue changed over time?
- Which product categories generate the most revenue?
- Which states generate the most revenue?
- Which sellers generate the most revenue?
- What is the average order value?
- What percentage of customers make repeat purchases?
- What percentage of deliveries arrive late?
- Which states have the highest late-delivery rates?
- Which payment methods are used most often?
- Which product categories receive the highest review scores?

## Key Findings

- Total Orders: **99,441**
- Total Revenue: **$16.01M**
- Average Order Value: **$160.99**
- Average Delivery Time: **12.5 days**
- Late Delivery Rate: **6.77%**
- Repeat Customer Rate: **3.12%**

Additional findings:

- São Paulo generated the highest total revenue
- Health & Beauty was the highest-revenue product category
- Books: General Interest had the highest average review score among categories with at least 100 reviews
- Credit cards represented approximately 73.9% of payment records
- The highest-revenue seller generated approximately $229K in item revenue
- November 2017 recorded the highest order volume
- April 2018 recorded the highest monthly payment revenue

## SQL Skills Demonstrated

This project includes examples of:

- `SELECT`
- `WHERE`
- `GROUP BY`
- `ORDER BY`
- `COUNT`
- `COUNT DISTINCT`
- `SUM`
- `AVG`
- `JOIN`
- Multiple-table joins
- `CASE WHEN`
- `DATE_DIFF`
- Date formatting
- Common Table Expressions (CTEs)
- Window functions
- `LAG`
- `HAVING`
- Views
- Aggregation and KPI calculations

## Dashboard

![Olist E-Commerce Dashboard](olist_dashboard.png)

The dashboard was built in Looker Studio and includes:

- Total Revenue
- Total Orders
- Average Order Value
- Late Delivery Rate
- Average Delivery Time
- Repeat Customer Rate
- Monthly Revenue Trend
- Top Product Categories by Revenue
- Top States by Revenue
- Payment Method Share

## Repository Files

- `olist_analysis_queries.sql` — SQL used for analysis
- `olist_dashboard.png` — final Looker Studio dashboard
- `README.md` — project documentation

## What I Learned

This project helped me practice working with a relational dataset containing multiple connected tables. I learned how to validate raw data, troubleshoot CSV and schema issues, create SQL joins, calculate business KPIs, build reusable BigQuery views, and turn SQL results into a dashboard designed for business users.
