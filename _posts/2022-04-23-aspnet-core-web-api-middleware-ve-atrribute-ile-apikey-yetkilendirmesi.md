---
title: ASP.NET Core Web API Üzerinde Middleware ve Attribute ile API Key Yetkilendirmesi
author: Murat Süzen
date: 2022-04-23 11:33:00 -500
categories: [ASP.NET CORE]
tags: [asp.net core,net 6.0,web api,api key]
math: true
mermaid: true
image:
  path: /assets/img/stocks/carl-bloch-in-a-roman-osteria-1866.jpg
  width: 800
  height: 500
  alt: Carl Bloch, In a Roman Osteria (1866)
---

Merhabalar, bu makalede ASP.NET Core Web API projesinde API Key yetkilendirmesini middleware ve attribute yapılarıyla inceleyeceğiz. ApiKeyAuthentication isminde bir ASP.NET Core Web API projesi oluşturacağız. 

## Middleware Kullanımı
---

Projeye Middlewares klasörü ekleyip içerisinde ApiKeyMiddleware isminde bir sınıf ekliyoruz. 

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

Kod bloğunu incelediğimzide HttContext Headers içerisinde `X-API-KEY` değerini kontrol ediyoruz. Değer var ise appsettings içerisinde `X-API-KEY` değeriyle karşılaştırıyoruz. Eğer eşit bir değere erişirsek işlemi devam ettiriyoruz. Proram.cs içerisinde `app.UseMiddleware<ApiKeyMiddleware>();` şeklinde middleware kullanımını gerçekleştiriyoruz.

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

app.UseMiddleware<ApiKeyMiddleware>();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
```

Burada dikkat edilmesi gereken ikinci nokta swagger yapılandırması. Swagger ile api key gönderimi yapmak istersek AddSwaggerGen metodunda `AddSecurityDefinition` ve `AddSecurityRequirement` yapılandırmasını yapıyoruz.

## appsettings.json

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

## Atrribute Kullanımı

Attributes isimli klasör oluşturup içerisine ApiKeyAttribute isminde bir sınıf ekliyoruz. 

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

Middleware sınıfında yaptığımız gibi Attribute ve IAsyncActionFilter sınıf ve interfacelerden türeyen ApiKeyAttribute isimli sınıfta implement işlemi ile OnActionExecutionAsync metodunda HttpContext Header içerisinde apikey bilgisine erişip işlemi devam ettiriyoruz. `[AttributeUsage]` burada dikkat etmemiz gereken bölümdür. Bu attribute ile sınıfımızın clasın hangi bölümlerinde kullanılabileceğini ayarlıyoruz. ApiKeyAttribute yapılandırmamızı aşağıdaki gibi kullanabiliriz.

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
![ApiKeyAuthentication 401 Error](/assets/img/posts/ApiKeyAuthentication_1.jpg)
_401 Error_

![ApiKeyAuthentication Authorize](/assets/img/posts/ApiKeyAuthentication_2.jpg)
_Authorize_

![ApiKeyAuthentication Success](/assets/img/posts/ApiKeyAuthentication_3.jpg)
_Success_

Proje dosyalarını [**buradan**](https://github.com/muratsuzen/ApiKeyAuthentication.git) indirebilirsiniz. Bir sonraki makalede görüşmek üzere.
