---
title: LINQ Queries in C# What Is LINQ and How to Use It
author: Murat Süzen
date: 2025-05-06 09:00:00
categories: [ASP.NET Core, LINQ]
tags: [csharp, linq, data querying, collections, dotnet]
math: false
mermaid: false
---

Language Integrated Query (LINQ) is one of the most powerful features in C#. It allows you to **query, transform, and filter data** directly in your C# code using a consistent, expressive syntax.

In this guide, we’ll cover **what LINQ is**, **why it’s useful**, **how to use it**, and provide plenty of practical examples for working with collections, databases, and beyond.

---

## What Is LINQ?

LINQ stands for **Language Integrated Query**. It brings SQL-like querying capabilities into C# and .NET languages, allowing you to work with in-memory collections, databases, XML, and more.

Example:

```csharp
var numbers = new[] { 1, 2, 3, 4, 5 };
var evenNumbers = numbers.Where(n => n % 2 == 0);
```

You can write concise, readable queries over data — no matter where that data comes from.

---

## Why Use LINQ?

✅ **Unified querying**: Whether you work with arrays, lists, databases, or XML, the syntax stays the same.  
✅ **Type safety**: Compile-time checking helps avoid mistakes.  
✅ **Readable code**: More expressive and concise compared to loops or manual filtering.  
✅ **Composable**: You can chain multiple queries together smoothly.

---

## LINQ Syntax Forms

There are two ways to write LINQ queries:

### Query Syntax (SQL-like)

```csharp
var result = from n in numbers
             where n % 2 == 0
             select n;
```

### Method Syntax (Fluent)

```csharp
var result = numbers.Where(n => n % 2 == 0);
```

Both are valid and can be mixed.

---

## Common LINQ Operations

### Filtering with `Where`

```csharp
var adults = people.Where(p => p.Age >= 18);
```

### Projection with `Select`

```csharp
var names = people.Select(p => p.Name);
```

### Ordering with `OrderBy`

```csharp
var sorted = people.OrderBy(p => p.LastName);
```

### Aggregation

```csharp
var totalAge = people.Sum(p => p.Age);
var averageAge = people.Average(p => p.Age);
var count = people.Count();
```

### Grouping

```csharp
var grouped = people.GroupBy(p => p.City);
foreach (var group in grouped)
{
    Console.WriteLine($"City: {group.Key}, Count: {group.Count()}");
}
```

---

## LINQ with Collections

```csharp
List<int> numbers = new() { 1, 2, 3, 4, 5, 6 };

var squaredEvens = numbers
    .Where(n => n % 2 == 0)
    .Select(n => n * n);

foreach (var num in squaredEvens)
{
    Console.WriteLine(num);
}
```

---

## LINQ with Entity Framework Core

```csharp
var expensiveProducts = dbContext.Products
    .Where(p => p.Price > 1000)
    .OrderBy(p => p.Name)
    .ToList();
```

### Important

- LINQ-to-Entities queries are translated to SQL and run on the database.
- Always test performance and understand generated queries.

---

## LINQ with Anonymous Types

```csharp
var projected = people.Select(p => new { p.Name, p.Age });
```

You can project only the fields you need, which is efficient and reduces memory usage.

---

## Combining Multiple Queries

```csharp
var query = products
    .Where(p => p.InStock)
    .OrderByDescending(p => p.Rating)
    .Take(10);
```

You can chain multiple operations for complex querying.

---

## Best Practices

✅ Use method syntax for flexibility.  
✅ Avoid materializing queries too early (use `ToList()` only when needed).  
✅ Be aware of deferred execution: queries don’t run until you enumerate them.  
✅ Watch out for performance when querying large datasets.

---

## Summary

LINQ is a cornerstone of modern C# development, providing a consistent, expressive way to work with data. By mastering LINQ, you gain the ability to write cleaner, more maintainable, and efficient code for a wide range of data sources.
