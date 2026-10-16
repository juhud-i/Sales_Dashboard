-- Active: 1792065438178@@127.0.0.1@5432@sales_data
SELECT version(); -- Check the version of PostgreSQL

SELECT datname
FROM pg_database; -- List all databases

SELECT current_database(); --verify the name of the current database

SELECT current_database(), current_user; -- Verify the current database and user

CREATE SCHEMA IF NOT EXISTS sales_data;  -- Create a new schema named 'sales_data' if it doesn't already exist
                                        -- A schema groups related tables inside the database.

