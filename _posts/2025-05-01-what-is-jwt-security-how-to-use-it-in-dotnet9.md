---
title: What is JWT Security? How to Use It in .NET 9 for Secure APIs
author: Murat Süzen
date: 2025-05-01 09:00:00
categories: [ASP.NET Core, Security, JWT]
tags:
  [
    jwt,
    .NET 9,
    api security,
    authentication,
    authorization,
    token-based security
  ]
math: false
mermaid: false
---


In the world of modern web development, **securing your APIs** is no longer optional. One of the most popular and effective methods today is using **JWT (JSON Web Token)** for authentication and authorization. This article explains what JWT is, why it matters, and how you can implement it in your .NET 9 applications.

## What is JWT?

JWT (JSON Web Token) is an open standard (RFC 7519) that defines a compact and self-contained way for securely transmitting information between parties as a JSON object. This information can be verified and trusted because it is digitally signed.

A typical JWT contains:
- Header: Defines the type of the token and signing algorithm
- Payload: Contains the claims (user data, permissions, etc.)
- Signature: Ensures that the token hasn’t been altered

Why use JWT?
- Stateless: No server-side session storage required
- Scalable: Perfect for distributed and microservice architectures
- Compact: Easy to transmit via URL, headers, or inside cookies

## How JWT Works in .NET 9

In a typical flow:
1. A user logs in with valid credentials.
2. The server generates a JWT and sends it back to the client.
3. The client stores the token (usually in local storage or a cookie).
4. The client sends the token with every request (commonly in the Authorization header).
5. The server validates the token and grants or denies access.

## Step-by-Step: Using JWT in .NET 9

### Step 1: Install Required NuGet Packages

```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
```

### Step 2: Configure JWT Authentication in Program.cs

```csharp
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
```

### Step 3: Generate Tokens

Typically, you create a token when the user successfully logs in.

```csharp
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;

public string GenerateJwtToken(string username, string secretKey, string issuer, string audience)
{
    var claims = new[]
    {
        new Claim(JwtRegisteredClaimNames.Sub, username),
        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
    };

    var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
    var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

    var token = new JwtSecurityToken(
        issuer,
        audience,
        claims,
        expires: DateTime.Now.AddHours(1),
        signingCredentials: creds);

    return new JwtSecurityTokenHandler().WriteToken(token);
}
```

### Step 4: Protect API Endpoints

Add the `[Authorize]` attribute to any controller or action you want to secure.

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("[controller]")]
public class SecureDataController : ControllerBase
{
    [HttpGet]
    [Authorize]
    public IActionResult GetSecureInfo()
    {
        return Ok(new { message = "This is a protected endpoint." });
    }
}
```

## Why JWT Security Matters

- Strong API protection without managing server-side sessions
- Easily integrates with third-party systems and microservices
- Supports roles and claims-based access control
- Widely supported by frontend frameworks, mobile apps, and external clients

## Best Practices for JWT in .NET 9

- Keep your signing keys secure and rotate them regularly
- Set appropriate token expiration times
- Use HTTPS to prevent token interception
- Store tokens securely on the client side (avoid local storage if possible; prefer secure cookies)
- Consider using refresh tokens for longer-lived sessions

## Conclusion

JWT is a powerful tool for securing your .NET 9 Web APIs. By following these steps and best practices, you can implement a robust, scalable, and maintainable authentication system for your applications.
