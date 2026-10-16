/*
    The main cleaning tasks are:
- Remove unnecessary leading and trailing spaces.
- Convert date strings to PostgreSQL DATE.
- Convert sales values to NUMERIC.
- Convert empty postal codes to SQL NULL.
- Standardize empty text fields as NULL.
- Preserve valid identifiers and avoid deleting legitimate repeated order IDs.
*/

DROP TABLE IF EXISTS sales_data.clean_sales;

CREATE TABLE sales_data.clean_sales AS
SELECT NULLIF(TRIM(order_id), '') AS order_id,
-- Assumes dates are formatted as DD/MM/YYYY or D/MM/YY, with or without leading zeros.
TO_DATE(
    NULLIF(TRIM(order_date), ''),
    'DD/MM/YYYY'
) AS order_date,
TO_DATE(
    NULLIF(TRIM(ship_date), ''),
    'DD/MM/YYYY'
) AS ship_date,
NULLIF(TRIM(ship_mode), '') AS ship_mode,
NULLIF(TRIM(customer_id), '') AS customer_id,
NULLIF(TRIM(customer_name), '') AS customer_name,
NULLIF(TRIM(segment), '') AS segment,
NULLIF(TRIM(country), '') AS country,
NULLIF(TRIM(city), '') AS city,
NULLIF(TRIM(state), '') AS state,
-- Keep postal codes as text, but convert empty strings to NULL.
NULLIF(TRIM(postal_code), '') AS postal_code,
NULLIF(TRIM(region), '') AS region,
NULLIF(TRIM(product_id), '') AS product_id,
NULLIF(TRIM(category), '') AS category,
NULLIF(TRIM(sub_category), '') AS sub_category,
NULLIF(TRIM(product_name), '') AS product_name,
NULLIF(TRIM(sales), '')::NUMERIC(12, 2) AS sales
FROM sales_data.staging_sales;

SELECT
    COUNT(*) AS total_rows,
    COUNT(postal_code) AS rows_with_postal_code,
    COUNT(*) - COUNT(postal_code) AS missing_postal_codes
FROM sales_data.clean_sales;

-- Check the row count
SELECT COUNT(*) AS clean_rows
FROM sales_data.clean_sales;

-- Check for missing essential identifiers
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL)
        AS missing_order_ids,
    COUNT(*) FILTER (WHERE customer_id IS NULL)
        AS missing_customer_ids,
    COUNT(*) FILTER (WHERE product_id IS NULL)
        AS missing_product_ids,
    COUNT(*) FILTER (WHERE order_date IS NULL)
        AS missing_order_dates,
    COUNT(*) FILTER (WHERE sales IS NULL)
        AS missing_sales_values
FROM sales_data.clean_sales;

-- Check date inconsistencies
SELECT COUNT(*) AS inconsistent_dates
FROM sales_data.clean_sales
WHERE ship_date < order_date;

-- Inspect negative or zero sales values
SELECT COUNT(*) AS negative_or_zero_sales
FROM sales_data.clean_sales
WHERE sales <= 0;

-- Check duplicate-looking records
SELECT
    order_id,
    customer_id,
    product_id,
    sales,
    COUNT(*) AS duplicate_occurrences
FROM sales_data.clean_sales
GROUP BY order_id, customer_id, product_id, sales
HAVING COUNT(*) > 1
ORDER BY duplicate_occurrences DESC;