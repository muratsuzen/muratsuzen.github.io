---
title: ASP.NET Core Http Security Header
author: Murat Süzen
date: 2024-01-09 05:33:00 -500
categories: [ASP.NET CORE]
tags: [asp.net core,web api,middleware,net 6.0]
math: true
mermaid: true
---
Let’s examine how the Http Security Header structure is used on .NET Core in a sample ASP.NET Core project. First we will create a blank web project.

```bash
dotnet new web -o httpsecurityheader
```

After creating the project, let’s examine the security headers.

## X-Frame-Options
The X-Frame-Options header option is used to call your web page, called Clickjacking, on another web page with the iframe method and prevent any action.

**DENY:** It completely prevents the page from being called in an iframe.

**SAMEORIGIN:** It prevents the page from being called in an iframe outside of its domain.

**ALLOW-FROM uri :** Allows calling from a specific url in an iframe.

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    await next();
});
```
**Note:** According to the information here, X-Frame-Options header information is created as SAMEORIGIN by default.
To remove the X-Frame-Options header information, the AddAntiforgery method should be done as follows.

```csharp
builder.Services.AddAntiforgery(x =>
{
    x.SuppressXFrameOptionsHeader = true;
});
```

## Strict-Transport-Security
It is used to prevent man-in-the-middle (MITM) attacks and automatically convert HTTP requests made by the client to HTTPS. It is used with the UseHsts middleware structure in .NET Core projects.

```csharp
app.UseHsts();
```
The use of HSTS is not recommended in development environments due to browser caching.

We can use the AddHSTS method for HSTS configuration.

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

**Preload:** The default value should be set to “true” in order to inform the browser that a secure connection will be established with the loading of the list of websites containing HSTS in the first connection of the website.
IncludeSubDomains: Used to specify whether or not to be valid for subdomains.
MaxAge: Sets how long the HSTS header is valid.
ExcludedHosts: Addresses that will invalidate headers are added.

UseHttpsRedirection middleware is used for mandatory redirection of all HTTP requests from clients to the HTTPS address. When using this middleware, attention should be paid to HTTPS configuration.

```csharp
app.UseHttpsRedirection();
```

We can use AddHttpsRedirection method to configure HttpsRedirection.

```csharp
builder.Services.AddHttpsRedirection(x =>
{
    x.HttpsPort = 7047;
    x.RedirectStatusCode = (int)HttpStatusCode.TemporaryRedirect;
});
```
## X-Permitted-Cross-Domain-Policies
If you are using Flash on your website, you can prevent clients from making cross-site requests by using the X-Permission-Cross-Domain-Policies header.

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Permitted-Cross-Domain-Policies","none");
    await next();
});
```

## X-XSS-Protection
The X-XSS-Protection header causes browsers to stop loading the web page when they detect a cross-site scripting attack.

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Xss-Protection", "1; mode=block");
    await next();
});
```
## X-Content-Type-Options
It is used to prevent browsers from determining the MIME type sent with the Content Type header in requests sent from the client.

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    await next();
});
```

## Referrer-Policy
When a site accesses a different site, it sends its own address with a referrer. In some cases, the Referrer-Policy header is used when it is not desired to send the source address explicitly.

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Referrer-Policy", "no-referrer");
    await next();
});
```

## Feature-Policy
The app’s camera, microphone, usb etc. It is the title that we determine whether or not it will need such requirements.

```csharp
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("Permissions-Policy", "camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), usb=()");
    await next();
});
```

## Content-Security-Policy
Content-Security-Policy is a security policy used to control data injection attacks that may occur due to a web page’s style and script files.

```csharp
app.Use(async (ctx, next) =>
{
    ctx.Response.Headers.Add("Content-Security-Policy",
        "default-src 'self'");
    await next();
});
```

I have prepared a sample middleware containing all these headers.

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

You can [**download**](https://github.com/muratsuzen/HttpSecurityHeader) the project here. Please let me know if there are typos in my post.