---
title: Using API Key Authorization with Middleware and Attribute on ASP.NET Core Web API
author: Murat Süzen
date: 2024-01-08 11:33:00 -500
categories: [ASP.NET Core, Middlewares]
tags:
  [asp.net core, web api, repository pattern, dbcontext, net 6.0, middleware]
math: true
mermaid: true
---

Hello, in this article, we will API Key authorization on ASP.NET Core Web API with middleware and attribute. We will create an ASP.NET Core Web API project named ApiKeyAuthentication.

## Using Middleware

We add a Middlewares folder to the project and add a class called ApiKeyMiddleware.

```csharp
namespace ApiKeyAuthentication.Middlewares
{
    public class ApiKeyMiddleware
    {
        private readonly RequestDelegate _requestDelegate;
        private const string ApiKey = "X-API-KEY";

        public ApiKeyMiddleware(RequestDelegate requestDelegate)
        {
            _requestDelegate = requestDelegate;
        }

        public async Task Invoke(HttpContext context)
        {
            if (!context.Request.Headers.TryGetValue(ApiKey, out var apiKeyVal))
            {
                context.Response.StatusCode = 401;
                await context.Response.WriteAsync("Api Key not found!");
            }

            var appSettings = context.RequestServices.GetRequiredService<IConfiguration>();
            var apiKey = appSettings.GetValue<string>(ApiKey);
            if (!apiKey.Equals(apiKeyVal))
            {
                context.Response.StatusCode = 401;
                await context.Response.WriteAsync("Unauthorized client");
            }

            await _requestDelegate(context);
        }
    }
}
```

ApiKeyMiddleware.cs

When we examine the code, we check the X-API-KEY in HttpContext Headers. If there is a value, we compare it with the X-API-KEY value in appsettings. If the value is true, we continue the process.

```csharp
using ApiKeyAuthentication.Middlewares;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(x =>
{
    x.AddSecurityDefinition("X-API-KEY",new OpenApiSecurityScheme
    {
        Name = "X-API-KEY",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "ApiKeyScheme",
        In = ParameterLocation.Header,
        Description = "ApiKey must appear in header"
    });
    x.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "X-API-KEY"
                },
                In = ParameterLocation.Header
            },
            new string[]{}
        }
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseMiddleware<ApiKeyMiddleware>();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
```

Program.cs

Here we should pay attention to the swagger configuration. If we want to send api key with Swagger, we configure AddSecurityDefinition and AddSecurityRequirement in the AddSwaggerGen method.

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "X-API-KEY": "QXBpS2V5TWlkZGxld2FyZQ=="
}
```

appsettings.json

## Using Atrribute

We create a folder named Attributes and create a class called ApiKey Attribute.

```csharp
using Microsoft.AspNetCore.Mvc.Filters;

namespace ApiKeyAuthentication.Attributes
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class ApiKeyAttribute : Attribute, IAsyncActionFilter
    {
        private const string ApiKey = "X-API-KEY";
        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            if (!context.HttpContext.Request.Headers.TryGetValue(ApiKey, out var apiKeyVal))
            {
                context.HttpContext.Response.StatusCode = 401;
                await context.HttpContext.Response.WriteAsync("Api Key not found!");
            }

            var appSettings = context.HttpContext.RequestServices.GetRequiredService<IConfiguration>();
            var apiKey = appSettings.GetValue<string>(ApiKey);
            if (!apiKey.Equals(apiKeyVal))
            {
                context.HttpContext.Response.StatusCode = 401;
                await context.HttpContext.Response.WriteAsync("Unauthorized client");
            }

        }
    }
}
```

ApiKeyAttribute.cs

As we did in the Middleware class, we continue the process after reaching the api key value in the HttpContext Header and verifying it.**[AttributeUsage]** is the part we should pay attention to here. With this attribute, we set in which parts of the class our class can be used.

```csharp
using ApiKeyAuthentication.Attributes;
using Microsoft.AspNetCore.Mvc;

namespace ApiKeyAuthentication.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ApiKey]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetWeatherForecast")]
        public IEnumerable<WeatherForecast> Get()
        {
            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateTime.Now.AddDays(index),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
            .ToArray();
        }
    }
}
```

WeatherForecastController.cs

_Test Postman_
![Test Postman](/assets/img/posts/apikey-middleware1.png)
_Test Postman_

_Test Postman_
![Test Postman](/assets/img/posts/apikey-middleware2.png)
_Test Postman_

_Test Postman_
![Test Postman](/assets/img/posts/apikey-middleware3.png)
_Test Postman_

You can [**download**](https://github.com/muratsuzen/ApiKeyAuthentication.git) the project here. Please let me know if there are typos in my post.
