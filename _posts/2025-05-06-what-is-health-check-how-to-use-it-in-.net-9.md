---
title: What is Health Check? How to Use It in .NET 9?
author: Murat Süzen
date: 2025-05-06 09:00:00
categories: [ASP.NET Core, Monitoring]
tags: [health check, .NET 9, system monitoring, liveness, readiness]
math: false
mermaid: false
---


Health checks are essential for **monitoring the health and availability of your application and its dependencies**. They allow automated systems (like Kubernetes, Azure, or AWS) to detect when your app is down or degraded.

## Why Use Health Checks?

Modern applications rely on many external systems:
- Databases
- Message queues
- Third-party APIs

If any of these fail, you want your orchestration system to know **immediately** and respond (like restarting the container or redirecting traffic).

## Types of Health Checks

- **Liveness probes** → Is the app running at all?
- **Readiness probes** → Is the app ready to serve requests?

## Example in .NET 9

### Step 1: Add NuGet Package

```bash
dotnet add package Microsoft.Extensions.Diagnostics.HealthChecks
```

### Step 2: Configure Health Checks in `Program.cs`

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks()
    .AddSqlServer(builder.Configuration["ConnectionStrings:DefaultConnection"])
    .AddRedis(builder.Configuration["Redis:ConnectionString"]);

var app = builder.Build();

app.MapHealthChecks("/health");

app.Run();
```

### Step 3: Access the Health Endpoint

Visit `https://yourapp.com/health` and you’ll see a JSON summary of system status.

## Example Output

```json
{
    "status": "Healthy",
    "results": {
        "SqlServer": { "status": "Healthy" },
        "Redis": { "status": "Healthy" }
    }
}
```

## Best Practices

- Separate liveness and readiness checks
- Protect health endpoints (avoid leaking internal details)
- Integrate with your hosting platform’s monitoring tools

Health checks help ensure your .NET 9 apps stay **resilient** and **self-healing** in production.

