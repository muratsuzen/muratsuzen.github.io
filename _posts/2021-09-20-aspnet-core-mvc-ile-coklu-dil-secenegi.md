---
title: ASP.NET Core MVC ile Çoklu Dil Seçeneği Ekleme
author: Murat Süzen
date: 2021-09-20 11:33:00 -500
categories: [ASP.NET Core]
tags: [asp.net core, mvc]
math: true
mermaid: true
---

Merhabalar bu makalede ASP.NET Core MVC uygulamasına nasıl çoklu dil desteği ekleyebileceğimizi inceleyeceğim. Öncelikle destekleyeceğimiz dil tanımlarını resource dosyalarında tutacağım için uygulamanın dizinine `Resources` klasörünü oluşturuyorum. Daha sonra içerisine `SharedResource.tr-TR.resx` ve `SharedResource.en-US.resx` isminde iki Resource dosyası ekliyorum. Burada dikkat etmeniz gereken yer Languages. ifadesinden sonra Culture isimleri olmalı. Farklı dilleri de bu şekilde ekleyerek çoğaltabilirsiniz.

![Resource Files](/assets/img/posts/resource-files.jpg)
_Resource Files_

Uygulama dizinine SharedResource isminde bir sınıf oluşturuyorum. Önceki versiyonlarda uygulama dizinine oluşturduğumuz Languages sınıfını `Resources` klasörüne oluşturuyorduk.

```csharp
namespace MultiLanguage
{
    public class SharedResource
    {
    }
}
```

Uygulama dizinine Utilities klasörü oluşturup IStringLocalizer yapısını ayağa kaldıracak SharedViewLocalizer sınıfını geliştirelim.

```csharp
using System.Reflection;
using Microsoft.Extensions.Localization;

namespace MultiLanguage.Utilities
{
    public class SharedViewLocalizer
    {
        private readonly IStringLocalizer _localizer;

        public SharedViewLocalizer(IStringLocalizerFactory factory)
        {
            var type = typeof(SharedResource);
            var assemblyName = new AssemblyName(type.GetTypeInfo().Assembly.FullName);
            _localizer = factory.Create("SharedResource", assemblyName.Name);
        }

        public LocalizedString this[string key] => _localizer[key];

        public LocalizedString GetLocalizedString(string key)
        {
            return _localizer[key];
        }
    }
}
```

Startup.cs dosyasında ConfigureServices ve Configure metodlarına Localization ayarlarını ekliyorum.

```csharp
public void ConfigureServices(IServiceCollection services)
    {
        services.AddLocalization(opts => { opts.ResourcesPath = "Resources"; });

        services.Configure(options =>
        {
            var supportedCultures = new List()
            {
                new CultureInfo("tr-TR"),
                new CultureInfo("en-US"),
            };

            options.DefaultRequestCulture = new RequestCulture(supportedCultures.First());
            options.SupportedCultures = supportedCultures;
            options.SupportedUICultures = supportedCultures;
        });
        services.AddSingleton();
    }
```

```csharp
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        var locOptions = app.ApplicationServices.GetService>();
        app.UseRequestLocalization(locOptions.Value);
    }
```

Servis ayarlarını tamamladıktan sonra View lerde kullanacağım IHtmlHelper genişletmesini yapabilmek için uygulama dizinine ExtensionMethods klasörü ve HtmlHelperExtensionMethods genişletme sınıfını oluşturuyorum.

```csharp
namespace MultiLanguage.ExtensionMethods
{
    public static class HtmlHelperExtensionMethods
    {
        public static string Translate(this IHtmlHelper helper, string key)
        {
            IServiceProvider services = helper.ViewContext.HttpContext.RequestServices;
            SharedViewLocalizer localizer = services.GetRequiredService();
            string result = localizer[key];
            return result;
        }
    }
}
```

Daha sonra HomeController sınıfında Index metoduna services ayarlarında tanımladığım kullanabileceğim CultureInfo değerlerinden oluşan bir listeyi `ViewData` olarak set ediyorum.

```csharp
public IActionResult Index()
    {
        var defaultCultures = new List()
        {
            new CultureInfo("tr-TR"),
            new CultureInfo("en-US"),
        };

        CultureInfo[] cinfo = CultureInfo.GetCultures(CultureTypes.AllCultures);
        var cultureItems = cinfo.Where(x => defaultCultures.Contains(x))
            .Select(c => new SelectListItem { Value = c.Name, Text = c.DisplayName })
            .ToList();
        ViewData["Cultures"] = cultureItems;

        return View();
    }
```

ViewData ile gönderdiğim CultureInfo listesi ile bir section doldurup seçili Culture değerine göre Cookie yapısını değiştireceğim bir Action ekliyorum

```csharp
[HttpPost]
public IActionResult SetLanguage(string culture, string returnUrl)
{
    Response.Cookies.Append(
        CookieRequestCultureProvider.DefaultCookieName,
        CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(culture)),
        new CookieOptions { Expires = DateTimeOffset.UtcNow.AddYears(1) }
    );

    return LocalRedirect(returnUrl);
}
```

Daha sonra Index.cshtml dosyasını aşağıdaki değişikliği yapıyorum.

![Index](/assets/img/posts/index.jpg)
_Index_

Resource dosyalarına `LB_WELCOME` name value değerlerini ekliyorum. Bu şekilde @Html.Translate("LB_WELCOME") gibi resource dosyalarına eklediğimiz her etiketi kullanabiliriz.

![TR-Resource](/assets/img/posts/tr_resource.jpg)
_TR-Resource_

![EN-Resource](/assets/img/posts/en_resource.jpg)
_EN-Resource_

![Index-Page](/assets/img/posts/index-page.jpg)
_Index-Page_

Projeyi [**buradan**](https://github.com/muratsuzen/dotnetcore-samples/tree/main/MultiLanguage) indirebilirsiniz. Bir sonraki makalede görüşmek üzere.

Kaynaklar :

<https://docs.microsoft.com/tr-tr/aspnet/core/fundamentals/localization?view=aspnetcore-5.0/>
<https://medium.com/@flouss/asp-net-core-localization-one-resx-to-rule-them-all-de5c07692fa4/>
