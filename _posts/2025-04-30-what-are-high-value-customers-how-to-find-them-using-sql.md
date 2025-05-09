---
title: What are High-Value Customers? How to Find Them Using SQL
author: Murat Süzen
date: 2025-04-30 09:00:00
categories: [SQL, Data Analysis]
tags: [sql, high-value customers, data queries, aggregate functions, business insights]
math: false
mermaid: false
---


In today’s data-driven businesses, identifying **high-value customers** is critical for marketing, sales, and retention strategies. But how can we systematically identify these customers from raw transaction data? In this article, we will explore how to use SQL queries to identify top-tier customers who generate the most revenue.

## Why High-Value Customers Matter

High-value customers often:
- Generate the majority of a company's revenue
- Show consistent repeat purchases
- Are more receptive to upsell and loyalty programs

Knowing who they are allows businesses to:
- Offer targeted promotions
- Provide personalized support
- Allocate marketing resources efficiently

## SQL Scenario: Northwind Database

We will use the Northwind sample database, focusing on orders from 2016. Our goal: **find customers who placed orders totaling $15,000 or more in 2016.**

## Step 1: Understand the Tables

We need three main tables:
- **Customers** → customer details
- **Orders** → order details, including date
- **OrderDetails** → individual product prices and quantities per order

## Step 2: Write the Base Query

First, pull all relevant order data:

```sql
SELECT
    Customers.CustomerID,
    Customers.CompanyName,
    Orders.OrderID,
    SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrderAmount
FROM Customers
JOIN Orders ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
WHERE OrderDate >= '2016-01-01' AND OrderDate < '2017-01-01'
GROUP BY Customers.CustomerID, Customers.CompanyName, Orders.OrderID
HAVING SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) >= 10000
ORDER BY TotalOrderAmount DESC;
```

This query finds **individual orders** over $10,000.

## Step 3: Aggregate Per Customer

Instead of per order, sum all orders per customer:

```sql
SELECT
    Customers.CustomerID,
    Customers.CompanyName,
    SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) AS TotalOrderAmount
FROM Customers
JOIN Orders ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
WHERE OrderDate >= '2016-01-01' AND OrderDate < '2017-01-01'
GROUP BY Customers.CustomerID, Customers.CompanyName
HAVING SUM(OrderDetails.Quantity * OrderDetails.UnitPrice) >= 15000
ORDER BY TotalOrderAmount DESC;
```

This identifies **top customers by total 2016 spend**.

## Step 4: Including Discounts

To account for discounts, adjust the calculation:

```sql
SELECT
    Customers.CustomerID,
    Customers.CompanyName,
    SUM(OrderDetails.Quantity * OrderDetails.UnitPrice * (1 - OrderDetails.Discount)) AS TotalOrderAmountWithDiscount
FROM Customers
JOIN Orders ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
WHERE OrderDate >= '2016-01-01' AND OrderDate < '2017-01-01'
GROUP BY Customers.CustomerID, Customers.CompanyName
HAVING SUM(OrderDetails.Quantity * OrderDetails.UnitPrice * (1 - OrderDetails.Discount)) >= 15000
ORDER BY TotalOrderAmountWithDiscount DESC;
```

Now you are factoring in **realized revenue** after discounts.

## Best Practices

- Use indexes on date and customer fields for performance
- Consider excluding canceled or returned orders
- Combine with customer metadata for deeper segmentation (e.g., region, industry)
- Automate reporting for monthly or quarterly updates

## Final Thoughts

Identifying high-value customers is a powerful way to focus business efforts where they matter most. With well-constructed SQL queries, you can extract these insights directly from your database and make data-driven decisions.