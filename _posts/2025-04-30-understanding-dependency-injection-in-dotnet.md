---
title: Understanding Dependency Injection in .NET
author: Murat Süzen
date: 2025-04-30 09:00:00
categories: [ASP.NET Core, Design Patterns, .NET]
tags: [dependency injection, dotnet, ioc, services, design patterns]
math: false
mermaid: false
---

Dependency Injection (DI) is a fundamental design pattern in modern .NET development. It allows you to **write loosely coupled, maintainable, and testable code** by providing dependencies to classes from an external source rather than having them create or manage those dependencies themselves.

In this article, we’ll explore **what DI is**, **why it’s important**, **how it works in .NET**, and walk through hands-on examples and best practices.

---

## What Is Dependency Injection?

Dependency Injection is a technique where a class receives the services or objects it depends on (its *dependencies*) from an external system, instead of instantiating them directly.

For example, rather than doing this:

```csharp
public class OrderService
{
    private readonly PaymentService _paymentService = new PaymentService();
}
```

You do this:

```csharp
public class OrderService
{
    private readonly PaymentService _paymentService;

    public OrderService(PaymentService paymentService)
    {
        _paymentService = paymentService;
    }
}
```

Now `OrderService` depends on an *injected* `PaymentService`.

---

## Why Use DI?

✅ **Loose coupling** — classes are not tightly bound to specific implementations.  
✅ **Easier testing** — inject mock or stub services in unit tests.  
✅ **Better maintainability** — replace implementations without changing dependent code.  
✅ **Centralized configuration** — control lifetimes and setups in one place.

---

## DI in .NET

ASP.NET Core has built-in dependency injection support via the **built-in IoC (Inversion of Control) container**.

You register services in `Program.cs`:

```csharp
builder.Services.AddTransient<IMyService, MyService>();
```

And inject them where needed:

```csharp
public class MyController : ControllerBase
{
    private readonly IMyService _service;

    public MyController(IMyService service)
    {
        _service = service;
    }
}
```

---

## Service Lifetimes

| Lifetime      | Description                                          |
|---------------|------------------------------------------------------|
| Transient     | New instance every time requested                    |
| Scoped        | One instance per request (for web apps)              |
| Singleton     | Single instance shared for the lifetime of the app   |

Example:

```csharp
builder.Services.AddSingleton<ISingletonService, SingletonService>();
builder.Services.AddScoped<IScopedService, ScopedService>();
builder.Services.AddTransient<ITransientService, TransientService>();
```

---

## Hands-On Example

### Step 1: Define an Interface

```csharp
public interface IMessageService
{
    string GetMessage();
}
```

### Step 2: Implement the Service

```csharp
public class HelloWorldMessageService : IMessageService
{
    public string GetMessage() => "Hello, Dependency Injection!";
}
```

### Step 3: Register and Inject

```csharp
builder.Services.AddScoped<IMessageService, HelloWorldMessageService>();
```

In a controller or Razor Page:

```csharp
public class HomeController : Controller
{
    private readonly IMessageService _messageService;

    public HomeController(IMessageService messageService)
    {
        _messageService = messageService;
    }

    public IActionResult Index()
    {
        ViewBag.Message = _messageService.GetMessage();
        return View();
    }
}
```

---

## Constructor Injection vs. Alternatives

✅ **Constructor injection** — most common and recommended.  
✅ Property injection — for optional dependencies.  
✅ Method injection — pass dependencies via method parameters.

Example of property injection:

```csharp
public IOptionalService OptionalService { get; set; }
```

---

## Testing with Dependency Injection

DI makes testing easier by allowing you to inject mocks.

Example with Moq:

```csharp
var mock = new Mock<IMessageService>();
mock.Setup(s => s.GetMessage()).Returns("Test Message");

var controller = new HomeController(mock.Object);
```

Now you can test without touching the real implementation.

---

## Best Practices

✅ Always program against interfaces, not concrete classes.  
✅ Keep services stateless unless they are singletons.  
✅ Register services at the correct lifetime.  
✅ Avoid service locator anti-pattern (i.e., avoid pulling services manually from IServiceProvider).  
✅ Use DI even in non-ASP.NET Core apps by wiring up `IServiceCollection` manually.

---

## Summary

Dependency Injection is a cornerstone of modern .NET application design, promoting loose coupling, testability, and maintainability. By mastering DI, you set the foundation for building scalable and robust applications that are easy to evolve and maintain over time.
