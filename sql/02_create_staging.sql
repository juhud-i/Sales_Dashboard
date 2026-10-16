

CREATE TABLE sales_data.staging_sales (
    order_id                TEXT,
    order_date              TEXT,
    ship_date               TEXT,
    ship_mode               TEXT,
    customer_id             TEXT,
    customer_name           TEXT,
    segment                 TEXT,
    country                 TEXT,
    city                    TEXT,
    state                   TEXT,
    postal_code             TEXT,
    region                  TEXT,
    product_id              TEXT,
    category                TEXT,
    sub_category            TEXT,
    product_name            TEXT,
    sales                   TEXT

);

/*
    - Why use TEXT at this stage?
    - Blank postal codes can be imported without failing.
    - Dates can be examined before conversion.
    - Sales values can be checked before converting them to numeric values.
    - Postal codes remain text, which is appropriate because they are identifiers rather than quantities.
*/


COPY sales_data.staging_sales(
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales
)

FROM '/mnt/d/DS_Course/11.Career_prep/To_Job/Projects/Data_Analyst/Sales_Dashboard/data/raw/sales_data.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    NULL '',
    QUOTE '"',
    ENCODING 'UTF8'
);

/*
If above fails use psql command line to copy the data into the staging table.
psql -h 127.0.0.1 -U data_analyst -d sales_data -W
Password: 
psql (16.15 (Ubuntu 16.15-0ubuntu0.24.04.1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
Type "help" for help.

sales_data=> SELECT current_user, current_database();
 current_user | current_database 
--------------+------------------
 data_analyst | sales_data
(1 row)

sales_data-> \copy sales_data.staging_sales (
order_id, order_date, ship_date, ship_mode, c
ustomer_id, customer_name, segment, country, 
city, state, postal_code, region, product_id,
 category, sub_category, product_name, sales)
 FROM '/mnt/d/DS_Course/11.Career_prep/To_Job
/Projects/Data_Analyst/Sales_Dashboard/data/r
aw/sales_data.csv' WITH (FORMAT CSV, HEADER T
RUE, NULL '', ENCODING 'UTF8');
COPY 9800
sales_data-> 
*/ 

SELECT *
FROM sales_data.staging_sales
LIMIT 50; 