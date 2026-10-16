
-- Full refresh: remove old fact and dimension records.
TRUNCATE TABLE
    sales.fact_sales,
    sales.dim_customer,
    sales.dim_product,
    sales.dim_location,
    sales.dim_date
RESTART IDENTITY;

-- -----------------------------------------
-- A. Load customers
-- -----------------------------------------
INSERT INTO sales.dim_customer (
    customer_id,
    customer_name,
    segment
)
SELECT DISTINCT ON (customer_id)
    customer_id,
    customer_name,
    segment
FROM sales_data.clean_sales
WHERE customer_id IS NOT NULL
ORDER BY
    customer_id,
    customer_name NULLS LAST,
    segment NULLS LAST;

-- -----------------------------------------
-- B. Load products
-- -----------------------------------------
INSERT INTO sales.dim_product (
    product_id,
    product_name,
    category,
    sub_category
)
SELECT DISTINCT ON (product_id)
    product_id,
    product_name,
    category,
    sub_category
FROM sales_data.clean_sales
WHERE product_id IS NOT NULL
ORDER BY
    product_id,
    product_name NULLS LAST,
    category NULLS LAST,
    sub_category NULLS LAST;

-- -----------------------------------------
-- C. Load locations
-- -----------------------------------------
INSERT INTO sales.dim_location (
    country,
    city,
    state,
    postal_code,
    region
)
SELECT DISTINCT
    country,
    city,
    state,
    postal_code,
    region
FROM sales_data.clean_sales;

-- -----------------------------------------
-- D. Load dates
-- Include both order dates and ship dates.
-- -----------------------------------------
WITH all_dates AS (
    SELECT order_date AS d
    FROM sales_data.clean_sales
    WHERE order_date IS NOT NULL

    UNION

    SELECT ship_date AS d
    FROM sales_data.clean_sales
    WHERE ship_date IS NOT NULL
),
date_bounds AS (
    SELECT MIN(d) AS min_date, MAX(d) AS max_date
    FROM all_dates
),
calendar AS (
    SELECT gs::DATE AS d
    FROM date_bounds b
    CROSS JOIN LATERAL generate_series(
        b.min_date::TIMESTAMP,
        b.max_date::TIMESTAMP,
        INTERVAL '1 day'
    ) AS gs
    WHERE b.min_date IS NOT NULL
)
INSERT INTO sales.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day_of_month,
    day_of_week
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER,
    d,
    EXTRACT(YEAR FROM d)::INTEGER,
    EXTRACT(QUARTER FROM d)::INTEGER,
    EXTRACT(MONTH FROM d)::INTEGER,
    TO_CHAR(d, 'FMMonth'),
    EXTRACT(DAY FROM d)::INTEGER,
    EXTRACT(ISODOW FROM d)::INTEGER
FROM calendar;


SELECT COUNT(*) AS total_entries
FROM sales.fact_sales;

SELECT 'dim_customer' AS table_name, COUNT(*) AS rows
FROM sales.dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*)
FROM sales.dim_product
UNION ALL
SELECT 'dim_location', COUNT(*)
FROM sales.dim_location
UNION ALL
SELECT 'dim_date', COUNT(*)
FROM sales.dim_date;

INSERT INTO sales.fact_sales (
    order_id,
    order_date_key,
    ship_date_key,
    customer_key,
    product_key,
    location_key,
    ship_mode,
    sales
)
SELECT
    s.order_id,
    TO_CHAR(s.order_date, 'YYYYMMDD')::INTEGER,
    TO_CHAR(s.ship_date, 'YYYYMMDD')::INTEGER,
    c.customer_key,
    p.product_key,
    l.location_key,
    s.ship_mode,
    s.sales
FROM sales_data.clean_sales s
JOIN sales.dim_customer c
    ON c.customer_id = s.customer_id
JOIN sales.dim_product p
    ON p.product_id = s.product_id
JOIN sales.dim_location l
    ON l.country IS NOT DISTINCT FROM s.country
   AND l.city IS NOT DISTINCT FROM s.city
   AND l.state IS NOT DISTINCT FROM s.state
   AND l.postal_code IS NOT DISTINCT FROM s.postal_code
   AND l.region IS NOT DISTINCT FROM s.region
WHERE s.order_id IS NOT NULL
  AND s.customer_id IS NOT NULL
  AND s.product_id IS NOT NULL
  AND s.sales IS NOT NULL;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;