# Sales Dashboard Data Analysis Project

## 1. Overview

This project explores retail sales data using **Python, PostgreSQL, and Power BI**.

- **Python in VS Code** is used for data inspection, cleaning, exploratory data analysis (EDA), and visualizations.
- **PostgreSQL running in WSL** is used to store the dataset and perform SQL-based analysis.
- **VS Code** is the development environment for Python notebooks and SQL scripts.
- **Power BI Desktop on Windows** is used to build the interactive sales dashboard.

The goal is to turn raw sales records into useful insights about sales trends, product categories, customers, and geographical performance.

## 2. Business Objectives

The project aims to:

- Summarize overall sales performance.
- Identify categories, sub-categories, and products with the highest sales.
- Compare sales across regions, states, and cities.
- Examine sales by customer segment and shipping method.
- Explore monthly and annual sales patterns.
- Validate the data and document limitations.
- Present the results in an interactive Power BI report.

## 3. Technology Stack

| Technology | Role |
|---|---|
| Python | Data inspection, cleaning, EDA, and charting |
| Pandas | Tabular data manipulation and aggregation |
| NumPy | Numerical operations |
| Matplotlib and Seaborn | Data visualization |
| Jupyter Notebook | Organize code, charts, and findings |
| PostgreSQL | Store data and run SQL analysis |
| WSL | Linux environment hosting PostgreSQL |
| Visual Studio Code | Python and SQL development client |
| Power BI Desktop | Interactive dashboard and reporting |
| CSV | Source data format |

## 4. Project Files and Structure

A suggested project structure is:

```text
sales-dashboard-project/
├── data/
│   └── sales_data.csv
├── notebooks/
│   └── sales_analysis.ipynb
├── outputs/
│   ├── charts/
│   ├── category_sales_summary.csv
│   └── monthly_sales_summary.csv
├── sql/
│   ├── create_tables.sql
│   ├── data_validation.sql
│   └── sales_analysis.sql
├── sales_dashboard.pbix
├── requirements.txt
└── README.md
```

The `notebooks/`, `outputs/`, `sql/`, and `requirements.txt` items are recommended project artifacts; add them as they are created. Keep the source CSV and Power BI report in the locations configured in your project.

## 5. Dataset

The source file is `sales_data.csv`.

The dataset contains 9,800 rows and 18 columns, including an extra unnamed index-like column. After reviewing the file, the unnamed column can be removed if it is not needed.

| Field | Description |
|---|---|
| Order ID | Identifier for an order; an order can contain multiple product rows |
| Order Date | Date the order was placed |
| Ship Date | Date the order was shipped |
| Ship Mode | Shipping method |
| Customer ID | Customer identifier |
| Customer Name | Customer name |
| Segment | Customer segment |
| Country | Country associated with the sale |
| City | City associated with the sale |
| State | State associated with the sale |
| Postal Code | Postal code |
| Region | Sales region |
| Product ID | Product identifier |
| Category | Product category |
| Sub-Category | Product sub-category |
| Product Name | Product description |
| Sales | Sales amount for the order line |

### Dataset profile

- **Rows:** 9,800
- **Distinct order IDs:** 4,922
- **Distinct customer IDs:** 793
- **Total sales:** 2,261,536.78 in the dataset's currency units
- **Categories:** Furniture, Office Supplies, Technology
- **Regions:** Central, East, South, West
- **Exact duplicate rows detected in the raw CSV:** 0
- **Missing postal codes:** 11

These are reference values from the source CSV. Recalculate them during analysis and validate them after importing the data into PostgreSQL.

### Data limitations

The provided CSV contains a `Sales` field but does not contain explicit `Profit`, `Cost`, `Quantity`, or `Discount` fields. As a result, profit margin, units sold, and discount impact cannot be calculated from this file alone. Additional source data would be required for those analyses.

## 6. End-to-End Workflow

### Step 1: Inspect the source data with Python

Load `sales_data.csv` into Pandas. Review the row and column counts, data types, sample records, missing values, duplicate rows, and summary statistics.

### Step 2: Clean and validate the data

- Remove the unnamed index-like column if it is not required.
- Parse `Order Date` and `Ship Date` using the correct date format.
- Confirm that `Sales` is numeric.
- Investigate missing postal codes and invalid values.
- Check for duplicate records and unexpected values before changing or deleting rows.
- Record any cleaning decisions in the notebook.

### Step 3: Perform exploratory data analysis

Use Python to summarize sales and explore patterns by category, sub-category, product, region, customer segment, shipping method, and time period. Create charts to support the analysis and document evidence-based observations.

### Step 4: Load and analyze data in PostgreSQL

Create a PostgreSQL database in WSL, import the validated data, and use SQL to calculate business summaries. Use VS Code to edit and execute SQL scripts.

### Step 5: Connect Power BI to PostgreSQL

Use Power BI Desktop on Windows to connect to the PostgreSQL database. Load the required tables or query results and validate key totals against Python and SQL outputs.

### Step 6: Build the dashboard

Create KPI cards, sales trend charts, product/category comparisons, regional visuals, and relevant slicers.

### Step 7: Communicate findings

Summarize the main observations, explain their business relevance, and propose recommendations that are supported by the data.

## 7. Python Environment Setup

Use a virtual environment to keep project dependencies separate from other Python projects.

From the project root in a VS Code PowerShell terminal:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install pandas numpy matplotlib seaborn jupyter ipykernel
```

If PowerShell prevents activation, use the virtual environment's Python executable directly:

```powershell
.\.venv\Scripts\python.exe -m pip install pandas numpy matplotlib seaborn jupyter ipykernel
```

Install the **Python** and **Jupyter** extensions in VS Code. Create `notebooks/sales_analysis.ipynb` and select the `.venv` environment as the notebook kernel.

Example imports:

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
```

If the CSV is stored in the `data/` directory and the notebook is stored in `notebooks/`, load it with:

```python
DATA_PATH = Path("../data/sales_data.csv")
df = pd.read_csv(DATA_PATH)
```

## 8. Python EDA Plan

Organize the notebook into these sections:

1. **Introduction and business questions**
2. **Data loading and inspection**
3. **Data cleaning and validation**
4. **Descriptive statistics**
5. **Sales by category and sub-category**
6. **Top-selling products**
7. **Monthly and annual sales trends**
8. **Sales by region, state, and city**
9. **Sales by customer segment and shipping method**
10. **Findings, limitations, and recommendations**

Example: calculate sales by category:

```python
category_sales = (
    df.groupby("category", as_index=False)
      .agg(total_sales=("sales", "sum"))
      .sort_values("total_sales", ascending=False)
)
```

Example: calculate monthly sales after converting `order_date` to a valid datetime type:

```python
df["order_date"] = pd.to_datetime(
    df["order_date"],
    dayfirst=True,
    errors="coerce"
)

monthly_sales = (
    df.dropna(subset=["order_date"])
      .set_index("order_date")["sales"]
      .resample("MS")
      .sum()
      .reset_index()
)
```

Confirm the date format in the source data before choosing `dayfirst=True`. Investigate any dates converted to missing values instead of silently dropping them.

## 9. PostgreSQL and SQL Analysis

PostgreSQL runs in WSL. VS Code is used as the SQL client to create tables, execute queries, validate imported data, and save reusable SQL scripts.

Suggested SQL analyses include:

- Total sales.
- Distinct orders and customers.
- Sales by category and sub-category.
- Sales by region and state.
- Sales by customer segment.
- Monthly sales trends.
- Data quality and record-count checks.

Example PostgreSQL query for sales by category:

```sql
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales
GROUP BY category
ORDER BY total_sales DESC;
```

Example query for monthly sales:

```sql
SELECT
    DATE_TRUNC('month', order_date)::DATE AS sales_month,
    ROUND(SUM(sales), 2) AS monthly_sales
FROM sales
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY sales_month;
```

Use distinct order counts because an order can contain multiple product rows:

```sql
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales), 2) AS total_sales
FROM sales;
```

## 10. Power BI Dashboard

The Power BI report file is `sales_dashboard.pbix`.

Recommended dashboard elements include:

- **KPI cards:** Total Sales, Total Orders, and Total Customers.
- **Line chart:** Monthly sales trend.
- **Bar charts:** Sales by category, sub-category, and top products.
- **Regional visuals:** Sales by region, state, or city.
- **Segment analysis:** Sales by customer segment and shipping method.
- **Slicers:** Order Date, Region, Category, and Segment.

These are recommendations; verify which visuals and measures are implemented in the actual `.pbix` report.

### Connect Power BI to PostgreSQL in WSL

1. Start PostgreSQL in WSL and confirm that the database is accessible.
2. Open Power BI Desktop on Windows.
3. Select **Get Data → PostgreSQL database**.
4. Enter the server and port. `localhost:5432` may work when Windows-to-WSL localhost forwarding is available.
5. Enter the database name and PostgreSQL credentials.
6. Select the required tables or provide a suitable query.
7. Load the data and validate totals against PostgreSQL and Python.

Connection details depend on WSL networking, PostgreSQL listening settings, and authentication configuration. Do not commit passwords or other credentials to source control.

## 11. Key Metrics

| Metric | Definition |
|---|---|
| Total Sales | Sum of the `Sales` field |
| Total Orders | Distinct count of `Order ID` |
| Total Customers | Distinct count of `Customer ID` |
| Sales by Category | Sales grouped by category |
| Sales by Region | Sales grouped by region |
| Monthly Sales | Sales grouped by month of order date |

The available source fields support sales-based metrics. Profitability, units sold, and discount-related measures require additional data.

## 12. Findings and Recommendations

For each important result, document:

- **Business question:** What are you investigating?
- **Method:** Which query, calculation, or visualization did you use?
- **Observation:** What does the result show?
- **Interpretation:** What might explain the pattern?
- **Recommendation:** What action should the business investigate?

Do not record a conclusion until it is supported by the actual analysis results. Distinguish observed patterns from possible explanations.

## 13. Limitations

- The dataset does not include explicit profit, cost, quantity, or discount fields.
- Eleven rows have missing postal codes.
- Date formats must be verified before time-based analysis.
- An order can have multiple product rows, so order counts should use distinct order IDs.
- Results describe the supplied dataset and should not automatically be generalized to other businesses or time periods.
- Dashboard accuracy depends on correct data types, relationships, aggregations, and refresh settings.

## 14. Future Improvements

- Add profit, cost, quantity, and discount data if a suitable source becomes available.
- Create a dedicated date dimension for time-intelligence calculations.
- Add month-over-month and year-over-year comparisons.
- Automate data validation between Python, PostgreSQL, and Power BI.
- Add indexes where query performance testing shows they are useful.
- Document final findings and recommendations after reviewing the completed dashboard.

## 15. Conclusion

This project demonstrates a practical sales analysis workflow combining Python-based EDA, PostgreSQL SQL analysis in WSL, development in VS Code, and interactive reporting in Power BI Desktop on Windows.

The project focuses on validating the data, discovering sales patterns, and communicating evidence-based findings through a reproducible analysis workflow.

## Author

Dan Oling'a
Github: juhud-i <juhudi.data@gmail.com>

Portfolio:

## License

Confirm the original dataset's license and usage terms before redistributing the source data or project files.
