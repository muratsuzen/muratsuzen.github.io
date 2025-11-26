---
title: What is ASP.NET Core Middleware? How to use?
author: Murat Süzen
date: 2024-01-08 11:33:00 -500
categories: [ASP.NET Core, Middlewares]
tags: [asp.net core, web api, middleware, net 6.0]
math: true
mermaid: true
---

Hello, in this article we will examine the middleware structure in ASP.NET Core. Middleware is used to perform the operations between the request and response process and to guide the process when the application runs.

![Test Postman](/assets/img/posts/netcore-middleware1.png)
_Request Delegate Pipeline_

As seen in the image above, the Middleware 1 next() method runs the next layer, Middleware 2. Middleware 2 completes its operations and Middleware 3 is executed with the next() method. When Middleware 3 completes its operations, since there is no other Middleware to run, it returns the result of the operation to Middleware 2 layer and Middleware 2 to Middleware 1 layer.

When each middleware completes its own process, it calls the next layer with the next() method and waits for a response from the next layer without finishing its own process. This spiral structure is called a pipeline. The middleware should finish processing and send a request until the entire pipeline is complete.

![Test Postman](/assets/img/posts/netcore-middleware2.png)
_Middleware Pipeline_

Let’s examine the Middleware issue by creating a sample ASP.NET Core Web API (.NET 6) project.

```bash
dotnet new webapi -o SampleMW
```

When we created the project, some services and middleware were added as standard in Program.cs. When we examine these codes, we can see the middleware that can be added to the runtime with the app variable added in the WebApplication type.

![Test Postman](/assets/img/posts/netcore-middleware3.png)
_app intellisense_

```csharp
using SampleMW;

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

This is how we can add middleware. We can also create our own middleware that can kick in at runtime. There are methods added so that we can run middleware that we can add in this way.

## UseMiddleware Method

Let’s create a class called CustomMiddleware. In this class, after the \_next object of RequestDelegate type that we inject in the Constructor is triggered, the next middleware is called with the Invoke method when the related operations are completed.

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
            await context.Response.WriteAsync("|CustomMiddleware|");

            await _next.Invoke(context);
        }
    }
}
```

```bash
app.UseMiddleware<CustomMiddleware>();
```

## Use Method

When the operations are completed, it calls the next middleware. When the processes of the next middleware are completed, the process continues.

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

![Test Postman](/assets/img/posts/netcore-middleware4.png)
_Use Result_

## Run Method

It prevents the next intermediate layer from working. In this case, the pipeline will be terminated. This interruption is called a short circuit. Let’s add the Run method to the above code block and run it.

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

![Test Postman](/assets/img/posts/netcore-middleware5.png)
_Run Result_

As you can see, the return was made without running the Use method containing the Use-Next text.

## Map Method

We use it when we want to run different middleware by filtering according to the path of the request from the client.

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

![Get /weatherforecast](/assets/img/posts/netcore-middleware6.png)
_Get /weatherforecast_

![Get /home](/assets/img/posts/netcore-middleware6.png)
_Get /home_

## MapWhen Method

With the MapWhen method, filtering can be done according to any feature of the request from the client.

```csharp
app.MapWhen(x => x.Request.Path.Equals("/home") && x.Request.Method.Equals("GET"), builder =>
{
    builder.Run(async x => await x.Response.WriteAsync("|RUN MAPWHEN - HOME|"));
});   app.MapWhen(x => x.Request.Path.Equals("/home") && x.Request.Method.Equals("GET"), builder =>
{
    builder.Run(async x => await x.Response.WriteAsync("|RUN MAPWHEN - HOME|"));
});app.MapWhen(x => x.Request.Path.Equals("/home") && x.Request.Method.Equals("GET"), builder =>
{
    builder.Run(async x => await x.Response.WriteAsync("|RUN MAPWHEN - HOME|"));
});
```

![Get /home](/assets/img/posts/netcore-middleware7.png)
_Get /home_
