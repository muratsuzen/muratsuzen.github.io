---
title: ASP.NET Core Web API - Swagger Kullanımı
author: Murat Süzen
date: 2021-04-01 11:33:00 -500
categories: [ASP.NET CORE]
tags: [asp.net core,web api]
math: true
mermaid: true
---
Web API projeleri geliştirdiğimizde API uygulamalarımızın nasıl kullanılacağını anlatacağımız dokümantasyonlara ihtiyacımız bulunmaktadır. Bu dokümantasyonlar, API projelerimizin ne işe yaradığını, hangi parametreler ile hangi formatlarda veri gönderip alabileceğinin bilgilerini içermektedir. Bu dokümantasyonların yazılması ve güncel tutulması işlemleri zordur. Bu nedenle Web API projesinin geliştirme aşamasında otomatik olarak oluşturulması gerekmektedir. Bu noktada kullanabileceğimiz API dokümantasyon yazılımı olan Swagger’i ASP.NET Core 3.1 Web API uygulamasında nasıl kullanabileceğimizi inceleyelim. Bir önceki ASP.NET Core 3.1 Web API – Basic Authentication Kullanımı konulu makaleyi inceleyebilirsiniz.

## ASP.NET Core 3.1 Web API – Swagger Örnek Projeyi Yapısı

Örnek olarak yapacağım API projesinin içeriğini şu şekilde oluşturacağım:

- `/item/get :`  Başarılı bir işlem gerçekleşirse 200 Ok durum bilgisinde tüm ürünlerin listesi getirilecek, hatalı bir işlemde 400 BadRequest sonucu döndürülecektir.

- `/item/get/id :` Başarılı bir işlem gerçekleşirse 200 Ok durum bilgisinde, ürünler listesinden gönderdiğimiz id bilgisine göre 1 ürün getirilecektir. Hatalı bir işlemde 400 BadRequest sonucu döndürülecektir.

- `/item/post :` Yeni bir ürün kaydı oluşturulacaktır. Başarılı bir işlem gerçekleşirse 200 Ok, hatalı bir işlemde 400 BadRequest sonucu döndürülecektir.

- `/item/put :` Sistemde kayıtlı olan bir ürün bilgisinin güncellemesi yapılacaktır. Başarılı bir işlem gerçekleşirse 200 Ok, hatalı bir işlemde 400 BadRequest sonucu döndürülecektir.

- `/item/delete :` Sistemde kayıtlı olan bir ürün kaydının silinme işlemi yapılacaktır. Başarılı bir işlem gerçekleşirse 200 Ok, hatalı bir işlemde 400 BadRequest sonucu döndürülecektir.

Uygulama dosyalarını [**aspnetcore-3-1-web-api-swagger**](https://github.com/muratsuzen/dotnetcore-samples/tree/main/aspnetcore-webapi-swagger/WebApi) Github adresinde bulabilirsiniz.

## ASP.NET Core 3.1 Web API – Swagger Örnek Projeyi Çalıştırmak İçin Gereksinimler

ASP.NET Core uygulamalarını yerel olarak geliştirmek ve çalıştırmak için aşağıdakileri indirip yükleyin:

- [**Visual Studio Code**](https://code.visualstudio.com/download) adresinden Windows, Mac ve Linux işletim sistemlerinde çalışabilen Microsoft tarafından geliştirilip açık kaynak olarak sunulan kod editörünü indiriniz.
- [**C# extension**](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp) adresinden yada VS Code içersinideki eklentiler bölümünden .NET Core uygulamaları geliştirirken kolaylıklar getiren eklentiyi indiriniz.
- [**.NET Core SDK**](https://dotnet.microsoft.com/download/dotnet/3.1) adresinden .NET Core 3.1 runtime SDK dosyasını indirip kurmalısınız.

## ASP.NET Core 3.1 Web API – Swagger Örnek Projesi Nasıl Çalıştırılır?

- Proje dosyalarını [**aspnetcore-3-1-web-api-swagger**](https://github.com/muratsuzen/dotnetcore-samples/tree/main/aspnetcore-webapi-swagger/WebApi) Github adresinden indirebilir yada klonlayabilirsiniz.
- WebApi.csproj proje dosyasının bulunduğu klasörde bir terminal ile yada VS Code terminalinde dotnet run komutunu çalıştırın.
- Uygulama çalıştığında <http://localhost:4000/> adresinden istek gönderebilirsiniz.

## ASP.NET Core 3.1 Web API – Swagger Projesini Oluşturma

Proje oluşturmak için `dotnet new webapi` komutunu kullanıyoruz.

## ASP.NET Core Web API – Item Entity

- `Path: /Entities/Item.cs`

Ürün bilgilerini taşıdığımız item sınıfını oluşturuyorum. Entity yapıları uygulamanın farklı bölümlerinde veri iletimi için kullanılır. Ayrıca controller yardımıyla http yanıtlarını döndürmek içinde kullanılabilmektedir. Entities sınıfları Entityframework ile Code First yaklaşımında veritabanı tablolarını oluşturmak için kullandığımız sınıflarıdır. *Not: Entities yapılarında kısıtlı veri döndürmek istendiğinde Models klasöründe ihtiyaca yönelik sınıflar kullanılmalıdır.*

```csharp
namespace WebApi.Entities
{
    public class Item
    {
        public int Id { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public string Image { get; set; }
    }
}
```

## ASP.NET Core Web API Program

- `Path:/Program.cs`

Program sınıfı, uygulamayı başlatmak için kullanılan bir console uygulama dosyasıdır. IHostBuilder ile Web API uygulamasının çalışmasına ihtiyacı olan web sunucusunu yapılandırır ve başlatır. ASP.NET Core uygulamasını şablondan oluşturduğumuzda varsayılan olarak gelmektedir. Builder alt özelliğinde Web API uygulamasının hangi adres ve portta başlatılacağını UseUrls ile değiştiriyorum.

```csharp
namespace WebApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) => Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>().UseUrls("http://localhost:4000");
            });
    }
}
```

## Projeye Swagger Paketlerinin Eklenmesi

Terminalde dotnet `add package Swashbuckle.AspNetCore `satırını ekleyip çalıştırıyoruz yada farklı paket yönetimleri için buradan indirme işlemini yapınız. Bu şekilde Swagger paketlerini projemize eklemiş olmaktayız. Not: Swashbuckle.AspnetCore 5.0 versiyonuyla beraber OpenAPI 3’ü desteklenmeye başlamıştır.

## ASP.NET Core Web API Startup

- `Path:/Startup.cs`

Startup ​​sınıfı, uygulamanın tüm isteklerin nasıl işleneceğini yapılandırdığımız sınıftır.

```csharp
namespace WebApi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();
            services.AddSwaggerGen(s =>
            {
                s.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo {Title = "Web API", Version = "v1"});
            });
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseHttpsRedirection();
            app.UseRouting();
            app.UseSwagger();
            app.UseSwaggerUI(s => { s.SwaggerEndpoint("/swagger/v1/swagger.json", "Swagger"); });
            app.UseAuthorization();
            app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
        }
    }
}
```

## ASP.NET Core Web API – ItemController

- `Path:/Controllers/ItemController.cs`

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using WebApi.Entities;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ItemController : ControllerBase
    {
        private static readonly Item[] Items = new Item[]
        {
            new Item {Id = 1, Code = "X001", Name = "Computer", Image = "/img/computer.jpg"},
            new Item {Id = 2, Code = "X002", Name = "Telephone", Image = "/img/telephone.jpg"},
            new Item {Id = 3, Code = "X003", Name = "Watch", Image = "/img/watch.jpg"},
        };

        [HttpGet("Get")]
        public IEnumerable<Item> Get()
        {
            return Items.ToList();
        }

        [HttpGet("Get/{id:int}")]
        public Item Get(int id)
        {
            return Items.FirstOrDefault(x => x.Id == id);
        }

        [HttpPost]
        public IActionResult Post([FromBody] Item item)
        {
            try
            {
                return Ok("Success!");
            }
            catch (System.Exception exp)
            {
                return BadRequest(exp.Message);
            }
        }

        [HttpPut]
        public IActionResult Put([FromBody] Item item)
        {
            try
            {
                return Ok("Success!");
            }
            catch (System.Exception exp)
            {
                return BadRequest(exp.Message);
            }
        }

        [HttpDelete]
        public IActionResult Delete(int id)
        {
            try
            {
                return Ok("Success!");
            }
            catch (System.Exception exp)
            {
                return BadRequest(exp.Message);
            }
        }
    }
}
```
## ASP.NET Core Web API – WebApi.csproj

- `Path:/WebApi.csproj`

```shell
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>netcoreapp3.1</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Swashbuckle.AspNetCore" Version="5.4.1" />
  </ItemGroup>
</Project>
```
## ASP.NET Core Web API – Swagger Sonuç

Terminalde dotnet run watch komutunu çalıştırıp projemizi <localhost:4000/swagger/> adresine gidiyoruz.

Bir sonraki makalede görüşmek üzere.