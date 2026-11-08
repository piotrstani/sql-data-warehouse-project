{% docs __overview__ %}

# SQL Data Warehouse

## Architecture

This project implements an analytical Data Warehouse
using PostgreSQL, dbt Core and Apache Airflow.

### Bronze Layer

Raw CRM and ERP source data loaded from CSV files
using Python and PostgreSQL COPY.

### Silver Layer

Standardized, cleaned and validated data.

- Data type standardization
- Data cleansing
- Deduplication
- Data quality testing
- Historical snapshots (SCD Type 2)

### Gold Layer

Business-ready analytical models:

- Customer dimensions
- Product dimensions
- Sales fact tables

## Data Quality

The project uses dbt generic and singular tests:

- Primary key validation
- Referential integrity
- Business rule validation
- Source freshness

## Orchestration

Apache Airflow coordinates data ingestion,
dbt transformations and data quality checks.

## Repository

[SQL Data Warehouse Project](https://github.com/piotrstani/sql-data-warehouse-project)


---
- ## _Data Flow_  
![input schema](assets/Data_Flow.drawio.png) 


---
- ## _Data Mart_  
![input schema](assets/Data_Mart.drawio.png) 


---
- ## _Silver Diagram_ 
![input schema](assets/Silver_Diagram.drawio.png) 

{% enddocs %}