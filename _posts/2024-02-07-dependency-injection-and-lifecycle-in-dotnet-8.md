---
title: Dependency Injection and Lifecycle in .NET 8
author: Murat Süzen
date: 2024-02-07 05:33:00
categories: [ASP.NET CORE, Dependency Injection]
tags:
  [
    dependency injection,
    .NET 8,
    service lifetime,
    inversion of control,
    DI Container,
  ]
math: true
mermaid: true
image:
  path: /assets/img/stocks/dependency-injection-and-lifecycle-in-dotnet-8.jpg
  width: 800
  height: 500
  alt:
---

Hello, in this article I will examine the Dependency Injection (DI) technique, which is a software design pattern that provides Inversion of Control (IoC) between classes and dependencies in .NET 8. First, let's examine what Inversion of Control (IoC) is.

## What is Inversion of Control (IoC)?

IoC is a software design principle. This principle aims to make the code more flexible, manageable and easier to maintain by regulating the configuration and operation of a software application.
With IoC, the management and dependencies of objects within the application are done by the framework. IoC application method Dependency Injection (DI) is the most important part of .NET 8.

.NET 8 offers many features for the Dependency Injection (DI) mechanism. Let's examine these features by adding new classes.

```csharp
namespace DependencyExample
{
    public interface IMyService
    {
        void Run();
    }

    public class MyService : IMyService
    {
        public void Run()
        {
            Console.WriteLine("MyService ......");
        }
    }

    public class OtherMyService : IMyService
    {
        public void Run()
        {
            Console.WriteLine("OtherMyService ......");
        }
    }
}
```

## What is the difference between the GetRequiredService<T> and GetService<T> methods?

The IServiceProvider interface has GetRequiredService<T> and GetService<T> methods. The most important difference between these two methods is that the GetRequriedService method throws an error when the service is not found, but the GetService method returns null value.

```csharp
//builder.Services.AddSingleton<IMyService, MyService>();
```

![](/assets/img/posts/dependency-injection-and-lifecycle-in-dotnet-8_1.png)

## What is the difference between the GetKeyedService<T> and GetRequiredKeyedService<T> methods?

GetKeyedService and GetRequiredKeyedService are two methods added to the IServiceProvider interface to use the keyed service feature, which is a new feature that comes with .NET 8. These methods allow you to define and resolve services not only by service type, but also by a key. The key to be defined can be of string or enum type. However, we can also define any object as a key. Thanks to the key definitions, we can distinguish different services with the same service type according to their keys and get the service we want. The GetKeyedService method returns null value if the keyed service is not found. The GetRequiredKeyedService method gives an InvalidOperationException error if the keyed service is not found.

```csharp
builder.Services.AddKeyedSingleton<IMyService, MyService>("GETKEY");
//builder.Services.AddKeyedSingleton<IMyService, OtherMyService>("GETREQKEY");
```

![](/assets/img/posts/dependency-injection-and-lifecycle-in-dotnet-8_2.png)

## What is Dependency Injection (DI)?

Dependency injection (DI) is a software design pattern that is used to access configured services. This pattern delegates the creation and management of a class’s dependencies to an external entity, known as an IoC (Inversion of Control) container. This way, loose coupling is achieved between classes and the code becomes more modular, easy to maintain and testable.

It uses an interface or a base class to abstract the dependency implementation.
It registers the dependency in a service container. .NET 8 provides a service container named IServiceProvider. Services are usually added to the IServiceCollection at the start of the application.
It injects the dependency into the constructor of the class that uses it. The framework takes the responsibility of creating and disposing of an instance of the dependency when it is no longer needed.

## Advantages of dependency injection

- Classes do not need to know how their dependencies are created or configured.
- Classes are not dependent on the concrete implementations of their dependencies, which increases testability and flexibility.
- Classes require minimal code changes to change or reuse their dependencies.
- Dependencies are managed in a single place throughout the application’s lifetime and are disposed of when needed.

## What are DI life cycles?

- Transient: It creates a new service instance for each request. This ensures that the service is different for each user or each operation. Transient services are registered with the AddTransient method.
- Scoped: It creates a new service instance for each scope. A scope is usually a web request or a unit of work. Scoped services share the same instance when they are requested repeatedly in the same scope. Scoped services are registered with the AddScoped method.
- Singleton: It creates a single service instance throughout the application and uses it everywhere. Singleton services are created when the application starts or on the first request. Singleton services are registered with the AddSingleton method.

```csharp
builder.Services.AddTransient<TransientService>();
builder.Services.AddScoped<ScopedService>();
builder.Services.AddSingleton<SingletonService>();
```

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;

namespace DependencyExample.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private readonly IMyService _transientService;
        private readonly IMyService _scopedService;
        private readonly IMyService _singletonService;

        public WeatherForecastController(IServiceProvider serviceProvider)
        {
            _transientService = serviceProvider.GetRequiredService<TransientService>();
            _scopedService = serviceProvider.GetRequiredService<ScopedService>();
            _singletonService = serviceProvider.GetRequiredService<SingletonService>();
        }
        [HttpGet]
        public ActionResult<IEnumerable<string>> Get()
        {
            // Servislerin ID'lerini döndür
            return new string[] {
                $"Transient: {_transientService.Id}",
                $"Scoped: {_scopedService.Id}",
                $"Singleton: {_singletonService.Id}"
            };
        }
    }
}

```

![](/assets/img/posts/dependency-injection-and-lifecycle-in-dotnet-8_3.png)
![](/assets/img/posts/dependency-injection-and-lifecycle-in-dotnet-8_4.png)

As we can see when we test it on Swagger, Transient service creates a new instance for each request. Therefore, it has a different ID value for each page refresh. Scoped service creates a new instance for each scope. A scope is usually a web request or a unit of work. Scoped services share the same ID value for the requests in the same scope. Therefore, it has the same ID value for the same page refresh. Singleton service creates a single instance throughout the application and uses it everywhere. Therefore, it has the same ID value for each page refresh.
See you in the next article.
