---
title: ASP.NET Core Middleware Nedir? Nasıl Kullanılır?
author: Murat Süzen
date: 2022-06-05 11:33:00 -500
categories: [ASP.NET Core, Middlewares]
tags: [asp.net core, net 6.0, middleware]
math: true
mermaid: true
---

Merhabalar, bu makalede ASP.NET Core'da ara katman (Middleware) yapısını inceleceğiz. ASP.NET Core'da ara katman (Middleware) yapısı, uygulama çalıştığında bir istemciden (Client) gelen taleplerin (Request) istemciye geri döndürülmesi (Response) sürecindeki işlemleri gerçekleştirmek ve sürece yön vermek için kullanılmaktadır.

![Request Delegate Pipeline](/assets/img/posts/request-delegate-pipeline.png){: .shadow width="800" height="400" }
_Request Delegate Pipeline_

Yukarıdaki resimde görüldüğü üzere, istemciden (Client) gelen bir istek üzerine (Request) Middleware 1 işlemleri yapılmaktadır. Middleware 1 next() metodu bir sonraki katman olan Middleware 2 çalıştırmaktadır. Middleware 2 de işlemlerini tamamlayıp next() metodu ile Middleware 3 çalıştırılmaktadır. Middleware 3 işlemlerini tamamladığında çalıştıracak bir başka Middleware olmadığı için işlem sonucunu Middleware 2 katmanına, Middleware 2 de Middleware 1 katmanına döndürmektedir. Middleware 1 ara katmanı da tüm gelen sonuçlara göre istemciye istek sonucunu (Response) döndürmektedir.

Burada dikkat edilecek olan kısım her ara katman (Middleware) işlemini tamamladığında next() metodu ile sonraki katmanı çağırırken kendi işlemini bitirmeyip bir sonraki katmandan cevap beklemesidir. İşte bu sarmal yapıya boru hattı `(Pipeline)` denilmektedir. Tüm pipeline tamamlanana kadar ara katmanlar işlemlerini bitirip geriye bir istek (Response) döndürmelidir. Bu nedenle kullanacağımız yada müdahale edeceğimiz ara katmanlarda çalışma sıralamasına dikkat etmeliyiz.

![Middleware Pipeline](/assets/img/posts/middleware-pipeline.png){: .shadow width="800" height="400" }
_Middleware Pipeline_

Middleware konusunu örnek bir ASP.NET Core Web API (.NET 6) projesi oluşturarak inceleyelim.

```bash
dotnet new webapi -o SampleMW
```

Projeyi oluşturduğumuzda Program.cs içerisinde bazı servis ve ara katmanlar (Middleware) standart olarak eklenmiştir. Bu kodları incelediğimizde WebApplication tipinde eklenen app değişkeni ile çalışma zamanına eklenebilecek ara katmanları görebiliriz.

![app-use-middlewares](/assets/img/posts/app-use-middlewares.jpg)

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
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

Hazır ara katmanları bu şekilde ekleyebiliriz. Ayrıca çalışma zamanında devreye girebilecek kendi ara katmanlarımızı da yazabiliriz. Bu şekilde ekleyebileceğimiz ara katmanları çalıştırabilmemiz için eklenmiş metodlar bulunmaktadır.

## UseMiddleware Metodu

---

Öncelikle projede CustomMiddleware isminde bir sınıf oluşturalım. Bu sınıfta Constructor içerisinde inject yaptığımız RequestDelegate tipinde `_next` nesnesi tetiklendikten sonra ilgili işlemler tamamlandığında Invoke metodu ile sıradaki ara katman çağrılmaktadır.

```csharp
namespace SampleMW
{
    public class CustomMiddleware
    {
        private readonly RequestDelegate _next;

        public CustomMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task Invoke(HttpContext context)
        {
            //logic

            await _next.Invoke(context);
        }
    }
}
```

Kendi yazdığımız ara katmanı UseMiddleware metodu ile kullanabiliriz.

```csharp
app.UseMiddleware<CustomMiddleware>();
```

## Use Metodu

---

Devreye girdikten sonra işlemleri tamamlandığında sıradaki ara katmanı çağırmaktadır. Sıradaki ara katmanın işlemleri bittiğinde geriye dönüp işleme devam edebilmektedir.

```csharp
app.Use(async (context, next) =>
{
    await context.Response.WriteAsync("|USE|");
    await next.Invoke();
    await context.Response.WriteAsync("|USE-RETURN|");
});

app.Use(async (context, next) =>
{
    await context.Response.WriteAsync("|USE-NEXT|");
    await next.Invoke();
});
```

![app-use-middlewares-result](/assets/img/posts/app-use-middlewares-result.jpg)
_Use Result_

## Run Metodu

---

Kendisinden sonra gelen ara katmanın çalışmasını engellemektedir. Bu durumda pipeline sonlanmış olacaktır. Bu şekilde kesilme işlemine kısa devre `(Short Circuit)` denilmektedir. Yukarıdaki kod bloğuna Run metodunu ekleyip çalıştıralım.

```csharp
app.Use(async (context, next) =>
{
    await context.Response.WriteAsync("|USE|");
    await next.Invoke();
    await context.Response.WriteAsync("|USE-RETURN|");
});

app.Run(async c =>
{
    c.Response.WriteAsync("|RUN|");
});

app.Use(async (context, next) =>
{
    await context.Response.WriteAsync("|USE-NEXT|");
    await next.Invoke();
});
```

![app-use-run-middlewares-result](/assets/img/posts/app-use-run-middlewares-result.jpg)
_Run Result_

Görüldüğü gibi Use-Next yazısını içeren Use metodu çalıştırılmadan geri dönüş yapılmış.

## Map Metodu

---

İstemciden gelen isteğin (Request) path'e göre bir filtreleme yaparak farklı ara katmanlar çalıştırmak istediğimizde kullanırız.

```csharp
app.Map("/weatherforecast", builder =>
{
    builder.Run(async x=> await x.Response.WriteAsync("|RUN MAP - WEATHERFORECAST|"));
});

app.Map("/home", builder =>
{
    builder.Use(async (context, next) =>
    {
        await context.Response.WriteAsync("|USE MAP - HOME|");
        await next.Invoke();
        await context.Response.WriteAsync("|USE MAP RETURN - HOME|");
    });
});
```

![app-map-middlewares-result](/assets/img/posts/app-map-middlewares-1.jpg)
_Get /weatherforecast_

![app-map-middlewares-result](/assets/img/posts/app-map-middlewares-2.jpg)
_Get /home_

## MapWhen Metodu

---

Map metodu istemciden gelen isteğin path'i ile bir yönlendirme yapıyorduk. MapWhen metoduyla ise istemciden gelen isteğin (Request) herhangi bir özelliğine göre filtreleme yapılabilmektedir.

```csharp
app.MapWhen(x => x.Request.Path.Equals("/home") && x.Request.Method.Equals("GET"), builder =>
{
    builder.Run(async x => await x.Response.WriteAsync("|RUN MAPWHEN - HOME|"));
});
```

![Get /home](/assets/img/posts/app-mapwhen-middlewares.jpg)
_Get /home_

Bir sonraki makalede görüşmek üzere.
