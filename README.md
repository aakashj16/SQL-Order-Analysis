# SQL-Order-Analysis
SQL queries and analysis focused on order management, including sales trends and customer purchasing behavior.

## Overview
This repository contains a set of SQL scripts designed for analyzing customer and order data for an e-commerce platform. The data is for the year 2024 and includes a variety of tables that track customer orders, products, shippers, and payments. Additionally, there are queries to help generate business insights, such as customer lifetime value, churn analysis, order trends, and product sales analytics.

## Database Schema
The SQL schema defines several key tables and their relationships. Here's a brief overview of the tables:
- **address:** Stores customer shipping addresses.
- **online_customers:** Contains customer details, including contact information and address relationships.
- **shipper:** Stores details about the shipping companies handling the deliveries.
- **order_header:** Contains the main details for each order, including the status and payment mode.
- **product_class:** Defines categories of products.
- **products:** Stores details about individual products, including price and availability.
- **order_items:** Contains the products included in each order along with their quantities.

## Date Assumptions
The data is available for the year 2024. Date values have been hardcoded in multiple queries for this purpose.
For example, queries like year("2024-12-31") and quarter("2024-12-31") reflect data for the year 2024. The system uses these hardcoded dates to compute various insights, like quarterly spending, churn analysis, or trends.

**CSV Files**
CSV files representing the data for each of the tables (address, online_customers, shipper, order_header, products, etc.) will be available in this GitHub repository. These files can be imported into a database for testing or analysis. Ensure that you import the data in the correct order to maintain referential integrity between tables.

**Queries**
The queries provided in this repository allow for the extraction of key business insights, such as:
- **Customer Lifetime Value (CLV):** Calculate the total amount spent by each customer over their lifetime.
- **Top Spending Customers:** Find the highest spending customers in a given quarter.
- **Customer Retention and Churn Analysis:** Identify retained and churned customers based on their order activity.
- **Top Products by Sales Volume and Revenue:** Find the most sold and highest revenue-generating products in the current quarter.
- **Order Cancellation Rate:** Calculate the percentage of canceled orders over time.
- **Potential Stockout Risk:** Identify products that may face stockouts based on previous demand.
- **Price Increase Impact:** Simulate revenue changes based on a hypothetical price increase for top-selling products.
- **Sales Trends:** View weekly sales trends and moving averages for both order count and total sales.

## Views and Procedures
- **current_month_dashboard View:** Provides a summary of orders placed in the current month, including customer names, cart sizes, and order status.
- **weekly_sales_trend View:** Provides weekly sales data, including the number of orders, total sales, and percentage change from the previous week.
- **customer_revenue Procedure:** A stored procedure that allows you to calculate the total revenue for a specific customer within a given date range.

**Example Usage**
To use the customer_revenue procedure, you can call it with a customer ID and a date range:

`call customer_revenue(76, "2024-12-01", "2024-12-31");`

This will return the total revenue for customer 76 between December 1st and December 31st, 2024.

## Instructions for Setup
- Clone the repository or download the CSV files.
- Import the CSV files into your MySQL (or compatible) database. Make sure to create the schema and tables first.
- Run the SQL scripts provided to analyze the data. Use the queries to extract key metrics like customer lifetime value, product sales, churn, and more.

## License
This project is licensed under the MIT License.

