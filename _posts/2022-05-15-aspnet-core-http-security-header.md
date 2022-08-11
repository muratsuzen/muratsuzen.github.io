---
title: ASP.NET Core Http Security Header
author: Murat Süzen
date: 2022-05-15 11:33:00 -500
categories: [NET CORE]
tags: [.netcore]
math: true
mermaid: true
image:
  path: /assets/posts/20220515/aspnet-core-http-security-header.jpg
  width: 800
  height: 500
  alt: Photo by Qingbao Meng on Unsplash
---

Http Security Header yapısının .NET Core üzerinde nasıl kullanıldığını örnek bir ASP.NET Core projesinde inceleyelim. Öncelikle boş bir web projesi oluşturuyorum. 

```bash
dotnet new web -o httpsecurityheader
```

Projeyi oluşturdurduktan sonra başlık güvenliklerini (security headers) inceleyelim.

## X-Frame-Options
---
X-Frame-Options header seçeneği `Clickjacking` adı verilen web sayfanızı iframe yöntemiyle başka bir web sayfasında çağırıp işlem yapılmasını önlemek için kullanılmaktadır. Kullanılabilecek 3 ayarı bulunmaktadır.

- `DENY:` Sayfanın bir iframe içerisinde çağrılmasını tamamen engellemektedir.
- `SAMEORIGIN:` Sayfanın domaini dışında bir iframe içerisinde çağrılmasını engellemektedir.
- `ALLOW-FROM uri:` Günümüzdeki browserlarda artık çalışmayan ancak belirli bir url den iframe içerisinde çağrılmasına izin vermektedir.

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Frame-Options","DENY");
    await next();
});
```
> Buradaki bilgiye göre varsayılan olarak X-Frame-Options header bilgisi SAMEORIGIN olarak oluşturuluyor. 
{: .prompt-warning }

X-Frame-Options header bilgisini kaldırmak için aşağıdaki gibi `AddAntiforgery` metodunda işlem yapılmaldır.
```csharp
builder.Services.AddAntiforgery(x =>
{
    x.SuppressXFrameOptionsHeader = true;
});
```

## Strict-Transport-Security
---
İstemcinin yapmış olduğu HTTP isteklerini man-in-the-middle (MITM) saldırılarını engellemek için otomatik olarak HTTPS'e döndürmek için kullanılır. .NET Core projelerinde UseHsts middleware yapısı ile kullanılmaktadır.

```csharp
app.UseHsts();
```

 > HSTS kullanımı tarayıcıların önbelleğe almalarından geliştirme (development) ortamlarında kullanılması önerilmemektedir.

 HSTS yapılandırması için AddHSTS metodunu kullanabiliriz.

 ```csharp
builder.Services.AddHsts(x =>
{
    x.Preload = true;
    x.IncludeSubDomains = true;
    x.MaxAge = TimeSpan.FromDays(60);
    x.ExcludedHosts.Add("example.com");
    x.ExcludedHosts.Add("www.example.com");
});
```

- `Preload:` Web sitenin ilk bağlantısında HSTS içeren web sitelerinin bulunduğu listenin yüklenmesiyle birlikte güvenli bağlantı kurulacağını tarayıcıya iletmek için varsayılan değeri "true" yapılmalı.  
- `IncludeSubDomains:` Alt alan adları için geçerli olup/olmayacağını belirtmek için kullanılır.
- `MaxAge:` HSTS üst bilgisinin ne kadar süre geçerli olacağını ayarlar.
- `ExcludedHosts:` Üst bilgilerin geçersiz olacak adresler eklenir.

Ayrıca istemcilerden gelen tüm HTTP isteklerini HTTPS adresine zorunlu yönlendirme işlemi için UseHttpsRedirection middleware kullanılmaktadır. Bu middleware kullanıldığında HTTPS yapılandırması olmasına dikkat edilmelidir.

 ```csharp
app.UseHttpsRedirection();
```
HttpsRedirection yapılandırması için AddHttpsRedirection metodunu kullanabiliriz.

 ```csharp
builder.Services.AddHttpsRedirection(x =>
{
    x.HttpsPort = 7047;
    x.RedirectStatusCode = (int)HttpStatusCode.TemporaryRedirect;
});
```
## X-Permitted-Cross-Domain-Policies
---
Bu başlık, Adobe ürünlerinin web sayfasını sizinkinden farklı bir etki alanından oluşturmasına izin verilip verilmediğini belirtmek için kullanılabilir. Örnek olarak, web sitenizde Flash kullanıyorsanız, X-Permission-Cross-Domain-Policies başlığını kullanarak istemcilerin siteler arası istekte bulunmasını engelleyebilirsiniz.

 ```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Permitted-Cross-Domain-Policies","none");
    await next();
});
```
## X-XSS-Protection
---
X-XSS-Protection başlığı, günümüz tarayıcılarının bir siteler arası komut dosyası çalıştırma saldırısı (XSS) algıladıklarında web sayfasını yüklemeyi durdurmasına neden olur. 

 ```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Xss-Protection", "1; mode=block");
    await next();
});
```

## X-Content-Type-Options
---
Tarayıcıların istemciden gönderilen isteklerde Content Type başlığı ile gönderilen MIME türünün kendisinin belirlemesini engellemek için kullanılır. 

 ```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    await next();
});
```
## Referrer-Policy
---
Bir sitenin farklı bir siteye erişim yaptığında kendi adresinide referrer ile gönderir. Bazı durumlarda kaynak adresin açık şekilde gönderilmesi istenmediğinde Referrer-Policy başlığı kullanılır.

 ```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Referrer-Policy", "no-referrer");
    await next();
});
```
## Feature-Policy
---
Uygulamanın kamera, mikrofon, usb vb. gibi gereksinimlere ihtiyaç duyup/duymayacağını belirlediğimiz başlıktır.

 ```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Permissions-Policy", "camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), usb=()");
    await next();
});
```
## Content-Security-Policy
---
Content-Security-Policy, bir web sayfasının yüklemesine izin verilen kaynakları kontrol etmek için kullanılan bir güvenlik politikasıdır. Bir HTTP yanıtında Content-Security-Policy başlığı aracılığıyla uygulanan ekstra bir güvenlik katmanını temsil eder. Content-Security-Policy, siteler arası komut dosyası çalıştırma saldırıları ve veri enjeksiyon saldırıları gibi belirli saldırı türlerini tespit etmek ve azaltmak için kullanılır. Özellikle style ve script dosyalarında dolayı oluşabilecek veri enjeksiyon saldırıları için kullanılabilir.

 ```csharp
app.Use(async (ctx, next) =>
{
    ctx.Response.Headers.Add("Content-Security-Policy",
        "default-src 'self'");
    await next();
});
```
Tüm bu başlıkları içeren örnek bir middleware hazırladım.

```csharp
namespace httpsecurityheader;

public class CustomSecurityHeader
{
    private readonly RequestDelegate _next;

    public CustomSecurityHeader(RequestDelegate next)
    {
        _next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        context.Response.Headers.Add("X-Frame-Options", "DENY");

        context.Response.Headers.Add("X-Permitted-Cross-Domain-Policies", "none");

        context.Response.Headers.Add("X-Xss-Protection", "1; mode=block");

        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");

        context.Response.Headers.Add("Referrer-Policy", "no-referrer");

        context.Response.Headers.Add("Permissions-Policy", "camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), usb=()");

        context.Response.Headers.Add("Content-Security-Policy",
            "default-src 'self'");

        await _next.Invoke(context);
    }
}
```

Bir sonraki makalede görüşmek üzere. Proje dosyalarını [**buradan**](https://github.com/muratsuzen/HttpSecurityHeader) indirebilirsiniz.