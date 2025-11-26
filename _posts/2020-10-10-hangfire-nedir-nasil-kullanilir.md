---
title: Asp.NET Core Web API - Hangfire Kullanımı
author: Murat Süzen
date: 2020-10-10 11:33:00 -500
categories: [ASP.NET Core, Hangfire]
tags: [asp.net core, web api, hangfire]
math: true
mermaid: true
---

## Hangfire Nedir?

Hangfire, uygulamalarımızda arka planda çalıştırmak istediğimiz işleri ( background jobs) yönetebildiğimiz açık kaynaklı bir kütüphanedir. Peki neden böyle bir kütüphaneye gereksinim duyuyoruz. Bunu bir örnek ile açıklayayım. Örnek olarak bir tedarik firmasında ürünlerinizin fiyatlarının yeni ayda değiştiğini düşünelim. Bu değişikliği sizden ürün tedarik eden yüzlerce müşterinize mail göndererek bildirmeniz gerekiyor. Mail gönderim ekranında tüm müşterilerinizi seçip mail göndermeyi başlattığınızda bu yüzlerce mail gönderim işleminin bitmesini beklemek zorunda kalacaksınız. İşte bu ve buna benzer bir iş parçacığının tek bir thread üzerinde yapmak yerine Hangfire ile farklı threat larda ve istediğimiz zamanlarda gönderimini sağlayabiliriz.

ASP.NET Core uygulamalarını yerel olarak geliştirmek ve çalıştırmak için aşağıdakileri indirip yükleyin:

- [Visual Studio Code](https://code.visualstudio.com/) adresinden Windows, Mac ve Linux işletim sistemlerinde çalışabilen Microsoft tarafından geliştirilip açık kaynak olarak sunulan kod editörünü indiriniz.
- [C# extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.csharp) adresinden yada VS Code içersinideki eklentiler bölümünden .NET Core uygulamaları geliştirirken kolaylıklar getiren eklentiyi indiriniz.
- [.NET Core SDK](https://www.microsoft.com/net/download/core) adresinden .NET Core 3.1 runtime SDK dosyasını indirip kurmalısınız.

## Projeye Hangfire Paketlerinin Eklenmesi

```xml
<ItemGroup>
  <PackageReference Include="Microsoft.AspNetCore.App" />
  <PackageReference Include="Microsoft.AspNetCore.Razor.Design" Version="2.2.0" PrivateAssets="All" />
  <PackageReference Include="Hangfire.Core" Version="1.7.*"></PackageReference>
  <PackageReference Include="Hangfire.SqlServer" Version="1.7.*"></PackageReference>
  <PackageReference Include="Hangfire.AspNetCore" Version="1.7.*"></PackageReference>
</ItemGroup>
```

Yazının detayına girmeden önce .Net Core ile ilgili en son yazdığım ASP.NET Core 3.1 Web API – Swagger Kullanımı yazımı okuyabilirsiniz. Hangfire kütüphanesini nuget paket yönetiminden aşağıdaki gibi yükleyebiliriz.

```shell
dotnet add package Hangfire.AspNetCore --version 1.7.12
```

## Hangfire için Veritabanı Oluşturma

Hangfire yapısı veri ve ayarları saklamak için Redis yada SQL veritabanına ihtiyaç duymaktadır. Bu makalede SQL veritabanı oluşturarak Hangfire kullanımına değineceğim. Öncelikle Hangfire için bir veritabanı oluşturalım.

```sql
CREATE DATABASE [Hangfire]GO
```

## Hangfire Veritabanı Yapılandırılması

Oluşturduğumuz veritabanı için bir bağlantı bilgisi eklememiz gerekmektedir. Bu bağlantı bilgisini appsettings.json içerisinde aşağıdaki şekilde ekliyorum.

```json
"ConnectionStrings":
    {
        "HangfireConnection": "Server=.\\sqlexpress;Database=Hangfire;Integrated Security=SSPI;"
    }
```

Hangfire uyarı mesajlarını farklı bir türde göstermek için aşağıdaki şekilde Logging alanını düzenleyebilirsiniz.

```json
"Logging": {
    "LogLevel": {
        "Default": "Warning", "Hangfire": "Information"
    }
}
```

## Hangfire Yapılandırılması

Projemizde Hangfire yapılandırma kodlarını yazacağımız `Startup.cs` dosyasında aşağıdaki ayarlamaları yapmamız gerekmektedir.

```csharp
public void ConfigureServices(IServiceCollection services)
 {
     services.AddHangfire(hf => hf.UseSqlServerStorage(Configuration.GetConnectionString("HangfireConnection")));
     services.AddHangfireServer();
 }
```

Hangfire dashboard kullanımı için ApplicationBuilder ayarlarında UseHangfireDashboard() tanımını yapmalıyız.

```csharp
public void Configure(IApplicationBuilder app, IHostingEnvironment env)
{
    app.UseHangfireDashboard();
}
```

Yapılandırma sonrasında projemizi çalıştırdığımızda <http://localhost:57992/hangfire/> yolundan Hangfire Dashboard sayfasına erişebiliriz.

## Hangfire Background Job Tipleri

- `Fire and forget jobs :` Yapılacak işin belirli bir zamana programlanmadan hemen yapılması ve tekrar etmeden tek bir defa çalıştırılmasını sağlayan background job tipidir.

```csharp
BackgroundJob.Enqueue(() => Console.WriteLine("Hello, world!"));
```

- `Delayed jobs :` Yapılacak işin belirli bir zaman bitiminde ve bir defa çalışmasını sağlayan background job tipidir.

```csharp
var jobId = BackgroundJob.Schedule(() => Console.WriteLine("Delayed!"), TimeSpan.FromDays(7));
```

- `Recurring jobs :` Yapılacak işin bir zaman programına uygun olarak bir çok kez yapılmasını sağlayan background job tipidir. Bu zamanlama işlemlerini CRON sürecinde (saatlik,günlük,haftalık,aylık, yıllık yada CRON expression vb.) tanımlayabiliriz.

```csharp
RecurringJob.AddOrUpdate(() => Console.WriteLine("Recurring!"),    Cron.Daily);
```

- `Continuations job:` Daha önceden tanımlanan bir işin tamamlanmasından sonra çalışan background job tipidir. Örnekte görüldüğü üzere jobId tamanlanması gereken öncelikli iş tanımıdır. Bu ana iş tamamlandıktan sonra `Console.WriteLine(“Continuation!”)` işi yerine getirilecektir.

```csharp
BackgroundJob.ContinueJobWith(jobId,() => Console.WriteLine("Continuation!"));
```

Hangfire kütüphanesinin ücretli bölümünde bulunan `Batch (PRO)` ve `Batch Continuations (PRO)` job türlerini inceleyelim.

- `Batch (PRO) :` Tanımlanan birden fazla işi tek bir grup şeklinde çalıştıran background job türüdür.

```csharp
var batchId = BatchJob.StartNew(x => { x.Enqueue(() => Console.WriteLine("Job 1"));
    x.Enqueue(() => Console.WriteLine("Job 2")); });
```

- `Batch Continuations (PRO) :` Grup halinde tanımlanan Batch iş tanımlarının tamamlanmasından sonra çalışacak olan background job türüdür.

```csharp
BatchJob.ContinueBatchWith(batchId, x =>{x.Enqueue(() => Console.WriteLine("Last Job"));});
```

Detaylı döküman bilgisine [buradan](https://docs.hangfire.io/en/latest/) ulaşabilirsiniz.
