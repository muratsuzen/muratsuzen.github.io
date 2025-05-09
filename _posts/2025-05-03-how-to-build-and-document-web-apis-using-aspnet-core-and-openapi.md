---
title: How to Build and Document Web APIs Using ASP.NET Core and OpenAPI
author: Murat Süzen
date: 2025-05-03 09:00:00
categories: [ASP.NET Core, Web API, Documentation]
tags: [aspnet core, web api, openapi, swagger, dotnet, api documentation]
math: false
mermaid: false
---

Building Web APIs is a central task in modern software development. ASP.NET Core provides a robust framework for creating APIs, and with **OpenAPI (Swagger)**, you can automatically generate interactive documentation, making your APIs easier to consume and test.

In this article, we’ll explore **how to create Web APIs using ASP.NET Core** and **integrate OpenAPI/Swagger** for seamless documentation.

---

## What Is OpenAPI?

OpenAPI (formerly known as Swagger) is a specification for describing RESTful APIs. It defines how your API endpoints, request/response models, and authentication work, making it easier for developers and tools to understand and interact with your API.

Swagger UI uses OpenAPI definitions to provide a **live, interactive web page** where you can test API calls directly.

---

## Setting Up an ASP.NET Core Web API

### Step 1: Create a New Project

```
dotnet new webapi -o MyApiApp
cd MyApiApp
```

This scaffolds a minimal API project with a sample `WeatherForecast` controller.

### Step 2: Explore the Structure

- `Program.cs` — main app configuration  
- `Controllers/WeatherForecastController.cs` — sample API controller  
- `appsettings.json` — configuration file

---

## Understanding Minimal APIs (Optional)

Starting with .NET 6, you can create APIs without controllers, using **Minimal APIs**:

```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/hello", () => "Hello, world!");

app.Run();
```

For more complex APIs, use controllers and proper routing.

---

## Adding Swagger / OpenAPI Support

ASP.NET Core Web API templates come with Swagger by default.

In `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

When you run the app and navigate to `/swagger`, you’ll see the Swagger UI.

---

## Customizing API Documentation

You can customize Swagger with attributes and XML comments.

### Adding XML Comments

1️⃣ Enable XML comments in `.csproj`:

```xml
<PropertyGroup>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <NoWarn>$(NoWarn);1591</NoWarn>
</PropertyGroup>
```

2️⃣ In `Program.cs`:

```csharp
builder.Services.AddSwaggerGen(c =>
{
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    c.IncludeXmlComments(xmlPath);
});
```

3️⃣ Document controllers and actions:

```csharp
/// <summary>
/// Gets all products.
/// </summary>
[HttpGet]
public IEnumerable<Product> Get() { ... }
```

---

## Securing the API with Authentication

Swagger can be configured to handle authentication headers:

```csharp
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Please insert JWT with Bearer into field",
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement {
    {
        new OpenApiSecurityScheme
        {
            Reference = new OpenApiReference
            {
                Type = ReferenceType.SecurityScheme,
                Id = "Bearer"
            }
        },
        new string[] { }
    }});
});
```

This allows you to test protected endpoints directly from the Swagger UI.

---

## Best Practices

✅ Use `ApiController` attribute for consistent routing and validation.  
✅ Validate input using `[FromBody]`, `[FromQuery]`, and data annotations.  
✅ Return proper status codes (`Ok()`, `NotFound()`, `BadRequest()`).  
✅ Version your APIs (`/api/v1/products`).  
✅ Keep OpenAPI specs up-to-date to improve developer experience.

---

## Real-World Example: Products API

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private static readonly List<Product> _products = new();

    [HttpGet]
    public ActionResult<IEnumerable<Product>> Get() => Ok(_products);

    [HttpPost]
    public ActionResult<Product> Post(Product product)
    {
        _products.Add(product);
        return CreatedAtAction(nameof(Get), new { id = product.Id }, product);
    }
}
```

---

## Summary

By combining ASP.NET Core Web APIs with OpenAPI/Swagger, you make your APIs **discoverable, testable, and easier to integrate**. This boosts team productivity, reduces integration errors, and enhances the developer experience.
