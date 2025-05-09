---
title: What Are Minimal APIs in .NET?
author: Murat Süzen
date: 2025-05-02 09:00:00
categories: [ASP.NET Core, Web API, Minimal APIs]
tags: [minimal apis, aspnet core, dotnet, web api, lightweight apis]
math: false
mermaid: false
---

Minimal APIs are a lightweight, fast way to build HTTP APIs in ASP.NET Core with minimal setup and overhead. Introduced in .NET 6, they let you define routes, handlers, and endpoints directly in `Program.cs` without needing controllers, attributes, or complex configuration.

In this article, we’ll explore **what Minimal APIs are**, **why they’re useful**, **how to implement them**, and walk through real examples and best practices.

---

## What Are Minimal APIs?

Minimal APIs provide a simplified approach to building RESTful services:

✅ Write HTTP routes and handlers directly in the app startup file.  
✅ Focus on the essentials — no extra ceremony or layers.  
✅ Perfect for small services, microservices, or serverless apps.

Example:

```csharp
var app = WebApplication.Create(args);
app.MapGet("/hello", () => "Hello, world!");
app.Run();
```

That’s a complete, runnable API!

---

## Why Use Minimal APIs?

✅ **Simplicity** — Less code, fewer files.  
✅ **Performance** — Lower startup overhead.  
✅ **Flexibility** — Combine with DI, middleware, or full MVC when needed.  
✅ **Perfect for microservices** — Small, focused endpoints.

---

## Setting Up a Minimal API

### Step 1: Create a New Project

```
dotnet new web -o MinimalApiApp
cd MinimalApiApp
```

### Step 2: Define Endpoints

In `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/greet", () => "Hello from Minimal API!");

app.Run();
```

Run it:

```
dotnet run
```

Visit `https://localhost:5001/greet`.

---

## Adding Parameters and Routes

### Simple Parameter

```csharp
app.MapGet("/square/{number:int}", (int number) => number * number);
```

Calling `/square/5` returns `25`.

### Query String Parameters

```csharp
app.MapGet("/welcome", (string name) => $"Welcome, {name}!")
    .WithName("WelcomeEndpoint");
```

---

## Working with Dependency Injection

```csharp
builder.Services.AddSingleton<MyService>();

app.MapGet("/service", (MyService service) =>
{
    return service.GetMessage();
});

public class MyService
{
    public string GetMessage() => "Hello from DI service!";
}
```

---

## Handling POST Requests

```csharp
app.MapPost("/products", (Product product) =>
{
    // Save product (mocked)
    return Results.Created($"/products/{product.Id}", product);
});
```

`Product` class:

```csharp
public record Product(int Id, string Name, decimal Price);
```

---

## Adding Middleware

```csharp
app.Use(async (context, next) =>
{
    Console.WriteLine($"Request: {context.Request.Path}");
    await next();
});
```

This runs on every request.

---

## Error Handling and Validation

```csharp
app.MapGet("/divide", (int a, int b) =>
{
    if (b == 0)
        return Results.BadRequest("Cannot divide by zero.");
    return Results.Ok(a / b);
});
```

---

## Best Practices

✅ Use Minimal APIs for small services or prototypes.  
✅ Add authentication and authorization as needed.  
✅ Validate input carefully — fewer layers mean more responsibility.  
✅ Organize routes logically, even without controllers.  
✅ Use OpenAPI/Swagger for documentation (`builder.Services.AddEndpointsApiExplorer()`).

---

## Real-World Example: Health Check

```csharp
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", time = DateTime.UtcNow }));
```

This provides a simple endpoint for monitoring or health checks.

---

## Summary

Minimal APIs in ASP.NET Core offer a fast, efficient way to build lightweight HTTP services with minimal setup. By learning how to use them effectively, you can build focused microservices, APIs, and serverless functions that are easy to maintain and deploy.
