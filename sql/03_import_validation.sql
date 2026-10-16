
-- Total number of imported rows
SELECT COUNT(*) AS total_rows
FROM sales_data.staging_sales; --9800

-- 2. Inspect the first 50 rows
SELECT *
FROM sales_data.staging_sales
LIMIT 50;

-- 3. Check for missing values in KEY column
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(order_id), '') IS NULL
    ) AS missing_order_ids,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(customer_id), '') IS NULL
    ) AS missing_customer_ids,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(product_id), '') IS NULL
    ) AS missing_product_ids,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(order_date), '') IS NULL
    ) AS missing_order_dates
    FROM sales_data.staging_sales;

-- 4. Inspect date formats
SELECT order_date, ship_date
FROM sales_data.staging_sales
LIMIT 20;

--5. Inspect sales values that may need cleaning
SELECT sales
FROM sales_data.staging_sales
WHERE NULLIF(TRIM(sales), '') IS NULL
    OR TRIM(sales) !~ '^[0-9]+(\.[0-9]{1,2})?$'
LIMIT 20;