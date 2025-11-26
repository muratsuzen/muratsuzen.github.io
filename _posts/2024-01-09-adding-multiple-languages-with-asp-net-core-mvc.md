---
title: Adding Multiple Languages ​​with ASP.NET Core MVC
author: Murat Süzen
date: 2024-01-09 05:33:00 -500
categories: [ASP.NET Core, Web Development]
tags: [asp.net core, web api, middleware, net 6.0]
math: true
mermaid: true
image:
  path: /assets/img/stocks/stefan-kunze.jpg
  width: 800
  height: 500
  alt: CMallorca, Llubí, Spain - Stefan Kunze
---

Hello, in this article we will examine how we can add multiple language support to ASP.NET Core MVC application. First of all, since we will keep the language definitions in resource files, we will create the Resources folder in the application’s directory. Then we will add two Resource files named SharedResource.tr-TR.resx and SharedResource.en-US.resx.

![Test Postman](/assets/img/posts/multiple_lang_1.png)
_Resources File_

We will create a class named SharedResource in the application directory.We were creating the Languages ​​class, which we created in the application directory in previous versions, into the Resources folder.

```csharp
namespace MultiLanguage
{
    public class SharedResource
    {
    }
}
```

We will create the Utilities folder in the application directory and add the SharedViewLocalizer class.

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

We will add Localization settings to the ConfigureServices and Configure methods in the Startup.cs file.

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

After completing the service settings, we will create the ExtensionMethods folder and the HtmlHelperExtensionMethods extension class in the application directory in order to extend the IHtmlHelper that we will use in the Views.

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

Then, we add a list of CultureInfo values ​​that we can use in the services settings as ViewData to the Index method in the HomeController class.

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

We fill a section with the CultureInfo list we send with ViewData and add an Action to change the Cookie structure according to the selected Culture value.

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

Then we modify the Index.cshtml file.

![Index.cshtml](/assets/img/posts/multiple_lang_2.png)
_Index.cshtml_

We add LB_WELCOME name values ​​to the resource files. In this way, we can use any tag we add to the resource files like @Html.Translate(“LB_WELCOME”).

![SharedResource.tr-TR.resx](/assets/img/posts/multiple_lang_3.png)
_SharedResource.tr-TR.resx_

![SharedResource.en-US.resx](/assets/img/posts/multiple_lang_4.png)
_SharedResource.en-US.resx_

![Index Page](/assets/img/posts/multiple_lang_5.png)
_Index Page_

You can [**download**](https://github.com/muratsuzen/dotnetcore-samples/tree/main/MultiLanguage) the project here. Please let me know if there are typos in my post.
