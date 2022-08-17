---
title: ASP.NET Core Distributed Redis Cache Kullanımı
author: Murat Süzen
date: 2022-04-17 11:33:00 -500
categories: [ASP.NET CORE,REDIS]
tags: [asp.net core,net 6.0,web api,api key,redis,cache]
math: true
mermaid: true
---

Merhabalar bu makalede ASP.NET Core projesinde Redis ile distributed cache yapısını inceleyeceğiz. Öncelikle Redis hakkında bilgi sahibi olmak isterseniz Redis Nedir? Ne İşe Yarar? Nerelerde Kullanılır? konusunu incelediğim makalemi okuyabilirsiniz. Öncelikle bir netcorerediscache isminde ASP.NET Core Web API projesi oluşturuyorum. Projeye `Microsoft.Extensions.Caching.StackExchangeRedis` paketini ekliyorum. 

```bash
dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis
```
StackExchangeRedis eklendikten sonra Program.cs içerisinde `AddStackExchangeRedisCache` metodunu ekliyorum.

```csharp
  builder.Services.AddStackExchangeRedisCache(options =>
  {
    options.ConfigurationOptions = new ConfigurationOptions
    {
        EndPoints = { "localhost:6379" },
        Password = "msuzen123!",
    };
  });
```
Projeyi oluşturduğumda standart oluşan WeatherForecastController'da cache işlemlerini yapıyorum.

```csharp
    List<string> dataList = new List<string>();
    string serializedCacheData;

    var cacheKey = "summaries";
    var cacheData = _distributedCache.Get(cacheKey);
    if (cacheData != null)
    {
        serializedCacheData = Encoding.UTF8.GetString(cacheData);
        dataList = JsonSerializer.Deserialize<List<string>>(serializedCacheData);  
    }
```
_distributedCache.Get(cacheKey) ile "summaries" anahtarındaki cache değerini alıyorum. Eğer değer null değil ise değer string listesine deserialize yaparak set ediyorum. Eğer null ise aşağıdaki kod bloğu ile bu sefer veritabanından yada örnekteki gibi sabit listeyi byte[] tipinde serialize yaparak cache ekleme işlemi yapıyorum.

```csharp
    else
    {
        dataList = Summaries.ToList();
        serializedCacheData = JsonSerializer.Serialize(dataList);
        cacheData = Encoding.UTF8.GetBytes(serializedCacheData);
        _distributedCache.Set(cacheKey,cacheData,new DistributedCacheEntryOptions()
        {
            AbsoluteExpiration = DateTime.Now.AddMinutes(10),
            SlidingExpiration = TimeSpan.FromMinutes(2),
        });
    }

    return dataList;
```
Burada `DistributedCacheEntryOptions` parametrelerinden iki tanesine değineceğim. 

- `AbsoluteExpiration:` Verilen süre sonunda cachedeki verinin expire olmasını sağlar.
- `SlidingExpiration:` Veri expire olmadan istendiğinde istek sonrasında expire süresine verilen süre eklenir.

Tüm controller kod bloğu aşağıdaki gibidir.

```csharp
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Distributed;

namespace netcorerediscache.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private IDistributedCache _distributedCache;

        private static readonly string[] Summaries = new[]
        {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        
        public WeatherForecastController(IDistributedCache distributedCache)
        {
            _distributedCache = distributedCache;
        }

        [HttpGet(Name = "GetWeatherForecast")]
        public List<string> Get()
        {
            List<string> dataList = new List<string>();
            string serializedCacheData;

            var cacheKey = "summaries";
            var cacheData = _distributedCache.Get(cacheKey);
            if (cacheData != null)
            {
                serializedCacheData = Encoding.UTF8.GetString(cacheData);
                dataList = JsonSerializer.Deserialize<List<string>>(serializedCacheData);  
            }
            else
            {
                dataList = Summaries.ToList();
                serializedCacheData = JsonSerializer.Serialize(dataList);
                cacheData = Encoding.UTF8.GetBytes(serializedCacheData);
                _distributedCache.Set(cacheKey,cacheData,new DistributedCacheEntryOptions()
                {
                    AbsoluteExpiration = DateTime.Now.AddMinutes(10),
                    SlidingExpiration = TimeSpan.FromMinutes(2),
                });
            }

            return dataList;
        }
    }
} 
```

Projeyi çalıştırıp swagger yardımıyla test ettiğimde ilk istekte cache boş olduğu için cache ekleyip statik veriyi geri döndürüyor. İkinci istekte cache verisini geri döndürüyor. Bir sonraki makalede görüşmek üzere.

Kaynaklar

<https://codewithmukesh.com/blog/redis-caching-in-aspnet-core/>

<https://www.c-sharpcorner.com/article/distributed-redis-caching-in-asp-net-core/>