---
title: What Are Razor Pages in ASP.NET Core?
author: Murat Süzen
date: 2025-05-05 09:00:00
categories: [ASP.NET Core, Web Development]
tags: [razor pages, aspnet core, web apps, csharp, dotnet]
math: false
mermaid: false
---

Razor Pages is a simplified, page-based programming model for building dynamic web applications in ASP.NET Core. It offers a clean separation of concerns and is ideal for scenarios where you need lightweight, fast-to-develop web pages.

In this article, we’ll explore **what Razor Pages are**, **why they’re useful**, **how to set them up**, and walk through real examples and best practices.

---

## What Are Razor Pages?

Razor Pages is part of ASP.NET Core and is designed for building **page-centric web apps**. Unlike MVC (Model-View-Controller), where controllers manage logic separately from views, Razor Pages places the logic and page markup in one unit.

A typical Razor Page has:

✅ A `.cshtml` file for HTML + Razor markup  
✅ A `.cshtml.cs` file (PageModel) for C# code

Example structure:

```
/Pages
    Index.cshtml
    Index.cshtml.cs
```

---

## Why Use Razor Pages?

✅ **Simpler**: Less overhead compared to MVC, great for small-to-medium applications.  
✅ **Separation of concerns**: Keeps markup and code-behind neatly organized.  
✅ **Productive**: Easy to scaffold CRUD operations with built-in tools.  
✅ **Flexible**: Still supports dependency injection, filters, and routing like MVC.

---

## Setting Up Razor Pages

### Step 1: Create a Project

Run:

```
dotnet new webapp -o RazorPagesApp
```

This scaffolds a basic Razor Pages app.

### Step 2: Explore the Structure

Check the `/Pages` folder. You’ll find:

- `Index.cshtml` — the homepage markup  
- `Index.cshtml.cs` — the associated PageModel class

### Step 3: Run the App

```
dotnet run
```

Visit `https://localhost:5001` to see the app.

---

## Anatomy of a Razor Page

### Index.cshtml

```html
@page
@model IndexModel

<h1>Welcome, @Model.Message</h1>
```

### Index.cshtml.cs

```csharp
public class IndexModel : PageModel
{
    public string Message { get; set; }

    public void OnGet()
    {
        Message = "Hello from Razor Pages!";
    }
}
```

The `OnGet()` method handles GET requests.

---

## Handling POST Requests

### HTML Form (Index.cshtml)

```html
<form method="post">
    <input type="text" name="UserInput" />
    <button type="submit">Submit</button>
</form>

<p>You submitted: @Model.Result</p>
```

### PageModel (Index.cshtml.cs)

```csharp
public string Result { get; set; }

public void OnPost(string userInput)
{
    Result = userInput;
}
```

When the form is submitted, the `OnPost()` method handles the request.

---

## Using Dependency Injection

```csharp
public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;

    public IndexModel(ILogger<IndexModel> logger)
    {
        _logger = logger;
    }

    public void OnGet()
    {
        _logger.LogInformation("Page loaded.");
    }
}
```

---

## Routing in Razor Pages

By default, the URL `/Index` maps to `Index.cshtml`. You can customize routing with attributes:

```csharp
[BindProperties]
[Route("custom-route")]
public class CustomModel : PageModel
{
    public void OnGet() { }
}
```

---

## Best Practices

✅ Keep page logic in the PageModel, not in the view.  
✅ Use partial views or components for reusable markup.  
✅ Validate user input with model binding and data annotations.  
✅ Apply filters (like `Authorize`) to protect pages.  
✅ Organize complex pages with areas or folders.

---

## Real-World Example: CRUD Operations

Razor Pages work great for CRUD apps.

### Scaffolding Example

```
dotnet aspnet-codegenerator razorpage Product -m Product -dc AppDbContext -udl -outDir Pages/Products
```

This generates Razor Pages for listing, creating, editing, and deleting products.

### Using EF Core

In your PageModel:

```csharp
public class ProductsModel : PageModel
{
    private readonly AppDbContext _context;

    public ProductsModel(AppDbContext context)
    {
        _context = context;
    }

    public IList<Product> ProductList { get; set; }

    public async Task OnGetAsync()
    {
        ProductList = await _context.Products.ToListAsync();
    }
}
```

---

## Summary

Razor Pages offer a streamlined, productive approach to building web applications with ASP.NET Core. By mastering Razor Pages, you can develop fast, maintainable, and scalable web solutions with less complexity compared to traditional MVC setups.
