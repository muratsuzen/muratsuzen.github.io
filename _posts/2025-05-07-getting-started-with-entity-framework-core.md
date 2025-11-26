---
title: Getting Started with Entity Framework Core
author: Murat Süzen
date: 2025-05-07 09:00:00
categories: [ASP.NET Core, Entity Framework Core]
tags: [entity framework core, ef core, csharp, orm, database access]
math: false
mermaid: false
---

Entity Framework Core (EF Core) is Microsoft’s modern object-relational mapper (ORM) for .NET. It enables developers to interact with databases using C# objects, reducing the need to write raw SQL and making data access more maintainable, testable, and scalable.

In this guide, we’ll explore **what EF Core is**, **how to set it up**, **basic CRUD operations**, and **best practices**. You’ll get hands-on examples to kickstart your database projects confidently.

---

## What Is Entity Framework Core?

Entity Framework Core is a lightweight, extensible, open-source, and cross-platform ORM. It maps .NET classes (entities) to database tables, allowing you to work with data using LINQ queries and C# code instead of SQL.

### Why Use EF Core?

✅ Reduce boilerplate code  
✅ Automatically generate database schemas (migrations)  
✅ Use strong typing and compile-time checks  
✅ Easily switch between different database providers (SQL Server, PostgreSQL, SQLite, etc.)  
✅ Improve maintainability and testability

---

## Setting Up EF Core

Let’s create a basic project using EF Core.

### Step 1: Install NuGet Packages

Run this in the terminal:

```
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
```

These packages provide the core library, the SQL Server provider, and tooling support.

### Step 2: Define the Data Model

Create a `Product` entity:

```csharp
public class Product
{
    public int Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
}
```

### Step 3: Create the DbContext

```csharp
using Microsoft.EntityFrameworkCore;

public class AppDbContext : DbContext
{
    public DbSet<Product> Products { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
        => options.UseSqlServer("Server=localhost;Database=MyAppDb;Trusted_Connection=True;");
}
```

This context class bridges your entities and the database.

---

## Performing CRUD Operations

### Create (Insert)

```csharp
using var db = new AppDbContext();
db.Products.Add(new Product { Name = "Laptop", Price = 1500 });
db.SaveChanges();
```

### Read (Query)

```csharp
var products = db.Products.Where(p => p.Price > 1000).ToList();
foreach (var product in products)
{
    Console.WriteLine($"{product.Name} - {product.Price}");
}
```

### Update

```csharp
var product = db.Products.First();
product.Price = 1200;
db.SaveChanges();
```

### Delete

```csharp
var product = db.Products.First();
db.Products.Remove(product);
db.SaveChanges();
```

---

## Using Migrations

EF Core can generate database schemas using migrations.

### Add Initial Migration

```
dotnet ef migrations add InitialCreate
```

### Apply Migration

```
dotnet ef database update
```

This creates tables in the database automatically.

---

## Advanced Topics

### Relationships

Define one-to-many, many-to-many, and one-to-one relationships using navigation properties and Fluent API.

```csharp
public class Category
{
    public int Id { get; set; }
    public string Name { get; set; }
    public List<Product> Products { get; set; }
}
```

### Lazy Loading vs Eager Loading

```csharp
// Eager loading
var products = db.Products.Include(p => p.Category).ToList();

// Lazy loading (requires setup)
var categoryName = product.Category.Name;
```

### Asynchronous Operations

```csharp
var products = await db.Products.ToListAsync();
```

Async queries help avoid blocking the main thread, especially in web apps.

---

## Best Practices

✅ Use migrations to manage schema changes  
✅ Write unit tests using in-memory providers (e.g., InMemoryDatabase)  
✅ Avoid N+1 query problems by using `Include()`  
✅ Keep `DbContext` usage short-lived (scoped per request)  
✅ Use value converters for custom types (like enums)

---

## Real-World Scenario: ASP.NET Core Integration

In an ASP.NET Core API:

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly AppDbContext _context;
    public ProductsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IEnumerable<Product>> Get()
    {
        return await _context.Products.ToListAsync();
    }

    [HttpPost]
    public async Task<IActionResult> Post(Product product)
    {
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(Get), new { id = product.Id }, product);
    }
}
```

---

## Summary

Entity Framework Core simplifies data access in .NET applications, allowing developers to work with databases efficiently using familiar C# constructs. By mastering EF Core, you unlock the ability to build data-driven applications with less effort and fewer bugs.

In tomorrow’s article, we’ll explore **LINQ queries** — how to filter, project, and manipulate data elegantly in C#.

Stay tuned for more advanced .NET insights!
