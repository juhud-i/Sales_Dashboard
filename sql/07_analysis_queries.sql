-- A. Overall Sales Analysis
SELECT
    COUNT(*) AS sales_lines,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_id) AS total_products,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(AVG(sales), 2) AS avg_line_sales
FROM sales_data.clean_sales;

-- B. Sales by Product Category
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        100.0 * SUM(sales)
        / NULLIF(SUM(SUM(sales)) OVER(), 0),
        2
    ) AS percentage_of_total_sales
FROM sales_data.clean_sales
GROUP BY category
ORDER BY total_sales DESC;

-- C. Monthly Sales Trend
SELECT
    DATE_TRUNC('month', order_date)::DATE AS sales_month,
    ROUND(SUM(sales), 2) AS total_monthly_sales
FROM sales_data.clean_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)::DATE
ORDER BY sales_month;

--D. Top 10 products by sales
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales_data.clean_sales
GROUP BY product_id, product_name, category, sub_category
ORDER BY total_sales DESC
LIMIT 10;

--E. Sales by Region
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        100.0 * SUM(sales)
        / NULLIF(SUM(SUM(sales)) OVER(), 0),
        2
    ) AS percentage_of_total_sales
FROM sales_data.clean_sales
GROUP BY region
ORDER BY total_sales DESC;

--F. Sales by Customer Segment
SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        100.0 * SUM(sales)
        / NULLIF(SUM(SUM(sales)) OVER(), 0),
        2
    ) AS percentage_of_total_sales
FROM sales_data.clean_sales
GROUP BY segment
ORDER BY total_sales DESC;

--G. Shipping duration
SELECT
    ship_mode,
    COUNT(*) AS sales_lines,
    ROUND(
        AVG(ship_date - order_date),
        2
    ) AS avg_shipping_duration_days
FROM sales_data.clean_sales
WHERE order_date IS NOT NULL
    AND ship_date IS NOT NULL
    AND ship_date >= order_date
GROUP BY ship_mode
ORDER BY avg_shipping_duration_days ASC;

--H. Customers with the highest sales
SELECT
    customer_id,
    customer_name,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        100.0 * SUM(sales)
        / NULLIF(SUM(SUM(sales)) OVER(), 0),
        2
    ) AS percentage_of_total_sales
FROM sales_data.clean_sales
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC
LIMIT 10;
