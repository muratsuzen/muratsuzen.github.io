---
title: What is Rate Limit? How to use in .NET 8?
author: Murat Süzen
date: 2024-03-04 05:33:00
categories: [ASP.NET Core, Rate Limit]
tags: [rate limit, .NET 8]
math: true
mermaid: true
image:
  path: /assets/img/stocks/api_rate_limit.jpg
  width: 800
  height: 500
  alt:
---

Rate limiting restricts the number of requests a client can make to an API endpoint. By doing so, it prevents abuse, protects resources, and maintains system stability. There are various rate limiting algorithms, but we’ll focus on two common ones: Fixed Window and Sliding Window.

## Fixed Window Rate Limiting

In .NET 8, the Rate Limiter middleware provides a way to control the rate at which requests are processed by your application. One of the rate limiting algorithms available is the Fixed Window Limiter. Let’s dive into the details:

- This algorithm uses a fixed time window to limit requests.
- When the time window expires, a new window starts, and the request limit is reset.
- Here’s an example of how to configure it in your ASP.NET Core app:

```csharp
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRateLimiter(_ => _.AddFixedWindowLimiter(policyName: "fixed", options =>
{
    options.PermitLimit = 4; // Maximum 4 requests per 12-second window
    options.Window = TimeSpan.FromSeconds(12);
    options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
    options.QueueLimit = 2;
}));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseRateLimiter();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers().RequireRateLimiting("fixed");

app.Run();

```

In this example:

- We add a rate limiting service using AddRateLimiter.
- The fixed window limiter is configured with a policy name of `fixed`.
- It allows a maximum of 4 requests per 12-second window.
- The queue processing order is set to oldest first, and the queue limit is 2.

## Sliding Window Rate Limiting

In .NET 8, the Rate Limiter middleware offers several algorithms to control the rate at which requests are processed by your application. One of these algorithms is the Sliding Window Limiter. Let’s explore its details:

- This algorithm is similar to the fixed window limiter but with a twist.
- Instead of resetting the request limit at the end of a fixed time window, the sliding window limiter slides the maximum allowed requests through defined segments.
- It provides more flexibility by allowing requests to be distributed across the entire time window.
- Here’s an example of how to configure it in your ASP.NET Core app:

```csharp
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRateLimiter(_ => _.AddSlidingWindowLimiter(policyName: "sliding", options =>
{
    options.PermitLimit = 10; // Maximum 10 requests per sliding window
    options.Window = TimeSpan.FromMinutes(1); // 1-minute sliding window
    options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
    options.QueueLimit = 5;
}));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseRateLimiter();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers().RequireRateLimiting("sliding");

app.Run();


```

In this example:

- We add a rate limiting service using AddRateLimiter.
- The sliding window limiter is configured with a policy name of `sliding`.
- It allows a maximum of 10 requests per 1-minute sliding window.
- The queue processing order is set to oldest first, and the queue limit is 5.
