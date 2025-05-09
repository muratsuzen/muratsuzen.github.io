---
title: What is Rate Limiting? How to Use It in .NET 9?
author: Murat Süzen
date: 2025-05-09 09:00:00
categories: [ASP.NET Core, API Security]
tags: [rate limiting, .NET 9, api throttling, performance, protection]
math: false
mermaid: false
---


Rate limiting is a critical technique in modern web development used to **control how many requests a client can make to a server over a specific period**. This prevents abuse, protects system resources, and ensures fair access across all users.

In .NET 9, rate limiting has been enhanced with built-in middleware that can be easily configured and customized.

## Why Use Rate Limiting?

Without rate limiting, your API could be flooded by excessive requests from:
- Malicious attackers (DDoS attacks)
- Misconfigured client apps making too many calls
- Heavy users consuming disproportionate system resources

Benefits:
- Improves **system stability** under heavy load
- Enhances **security** by stopping brute-force attacks
- Guarantees **fairness** for all users

## How Does It Work?

The server tracks requests from each client, usually by IP or token. If the client exceeds the allowed limit, the server rejects further requests (often with an HTTP 429 Too Many Requests error) until the window resets.

## Example in .NET 9

### Step 1: Install Middleware (if needed)

.NET 9 includes built-in middleware for rate limiting.

### Step 2: Configure in `Program.cs`

```csharp
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("fixed", opt =>
    {
        opt.PermitLimit = 5;
        opt.Window = TimeSpan.FromSeconds(10);
        opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        opt.QueueLimit = 2;
    });
});

var app = builder.Build();

app.UseRateLimiter();

app.MapGet("/", () => "Hello, world!").RequireRateLimiting("fixed");

app.Run();
```

This setup allows each client **5 requests every 10 seconds**. Excess requests get queued (up to 2) or rejected.

## Advanced Patterns

You can use:
- Sliding window or token bucket algorithms for smoother control
- Per-endpoint or per-user limits
- Distributed rate limiting with Redis or cloud services

## Best Practices

- Always test limits under load
- Combine with authentication to apply limits per user, not per IP
- Use meaningful error responses to guide client-side handling

By implementing rate limiting, your .NET 9 applications stay robust, fair, and secure.

