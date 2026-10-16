CREATE SCHEMA IF NOT EXISTS star_schema; -- Create a schema for the star schema tables

CREATE TABLE IF NOT EXISTS star_schema.fact_sales (
    sales_key               SERIAL PRIMARY KEY,
    order_id                TEXT,
    order_date_key          INTEGER,
    customer_key            INTEGER,
    product_key             INTEGER,
    ship_date_key           INTEGER,
    sales                   NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS star_schema.dim_customers (
    customer_key            SERIAL PRIMARY KEY,
    customer_id             TEXT UNIQUE,
    customer_name           TEXT,
    segment                 TEXT
);

CREATE TABLE IF NOT EXISTS star_schema.dim_products (
    product_key             SERIAL PRIMARY KEY,
    product_id              TEXT,
    product_name            TEXT,
    category                TEXT,
    sub_category            TEXT
);

CREATE TABLE IF NOT EXISTS star_schema.dim_dates (
    date_key                SERIAL PRIMARY KEY,
    full_date              DATE,
    year                    INTEGER,
    quarter                 INTEGER,
    month                   INTEGER,
    week                    INTEGER,   
    day                     INTEGER
);

CREATE TABLE IF NOT EXISTS star_schema.dim_locations (
    location_key            SERIAL PRIMARY KEY,
    region                  TEXT,
    country                 TEXT,
    city                    TEXT,
    state                   TEXT,
    postal_code             TEXT,
);

DROP SCHEMA IF EXISTS star_schema CASCADE; -- Drop the schema if it already exists to avoid conflicts


-- Create the schema if it does not exist.
CREATE SCHEMA IF NOT EXISTS sales;

-- 1. Customer dimension
CREATE TABLE sales.dim_customer (
    customer_key   BIGINT GENERATED ALWAYS AS IDENTITY
                   PRIMARY KEY,
    customer_id    TEXT NOT NULL UNIQUE,
    customer_name  TEXT,
    segment        TEXT
);

-- 2. Product dimension
CREATE TABLE sales.dim_product (
    product_key   BIGINT GENERATED ALWAYS AS IDENTITY
                  PRIMARY KEY,
    product_id    TEXT NOT NULL UNIQUE,
    product_name  TEXT,
    category      TEXT,
    sub_category  TEXT
);

-- 3. Date dimension
CREATE TABLE sales.dim_date (
    date_key     INTEGER PRIMARY KEY,
    full_date    DATE NOT NULL UNIQUE,
    year         INTEGER NOT NULL,
    quarter      INTEGER NOT NULL,
    month        INTEGER NOT NULL,
    month_name   TEXT NOT NULL,
    day_of_month INTEGER NOT NULL,
    day_of_week  INTEGER NOT NULL
);

-- 4. Location dimension
CREATE TABLE sales.dim_location (
    location_key BIGINT GENERATED ALWAYS AS IDENTITY
                 PRIMARY KEY,
    country      TEXT,
    city         TEXT,
    state        TEXT,
    postal_code  TEXT,
    region       TEXT
);

-- 5. Sales fact table
CREATE TABLE sales.fact_sales (
    sales_line_key BIGINT GENERATED ALWAYS AS IDENTITY
                   PRIMARY KEY,

    order_id       TEXT NOT NULL,
    order_date_key INTEGER REFERENCES sales.dim_date(date_key),
    ship_date_key  INTEGER REFERENCES sales.dim_date(date_key),

    customer_key   BIGINT NOT NULL
                   REFERENCES sales.dim_customer(customer_key),

    product_key    BIGINT NOT NULL
                   REFERENCES sales.dim_product(product_key),

    location_key   BIGINT NOT NULL
                   REFERENCES sales.dim_location(location_key),

    ship_mode      TEXT,
    sales          NUMERIC(12, 2) NOT NULL
);



