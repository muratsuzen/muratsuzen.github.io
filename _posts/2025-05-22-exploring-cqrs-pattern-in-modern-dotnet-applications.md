---
title: "Exploring CQRS Pattern in Modern .NET Applications"
author: Murat Süzen
date: 2025-05-22 21:49:23 +0300
categories: [ASP.NET Core, CQRS]
tags: [cqrs, dotnet, clean architecture, csharp]
math: false
mermaid: false
---

Command Query Responsibility Segregation (CQRS) is a powerful architectural pattern that helps in separating read and write responsibilities in modern software applications. In .NET, CQRS is often used with MediatR, Entity Framework, and clean architecture to build scalable, maintainable systems.

## 🔍 What is CQRS?

CQRS splits application logic into two parts:

- **Commands** – for write operations (Create, Update, Delete)
- **Queries** – for read operations (Get, List)

This separation improves scalability, optimizes performance, and simplifies code.

## 📦 Sample Use Case

Imagine a system where users can register and admins can list all users. With CQRS:

- `RegisterUserCommand` handles user creation
- `GetAllUsersQuery` handles data retrieval

### Command Example

```csharp
public record RegisterUserCommand(string Name, string Email) : IRequest<Guid>;

public class RegisterUserHandler : IRequestHandler<RegisterUserCommand, Guid>
{
    private readonly AppDbContext _context;

    public RegisterUserHandler(AppDbContext context)
    {
        _context = context;
    }

    public async Task<Guid> Handle(RegisterUserCommand request, CancellationToken cancellationToken)
    {
        var user = new User { Name = request.Name, Email = request.Email };
        _context.Users.Add(user);
        await _context.SaveChangesAsync(cancellationToken);
        return user.Id;
    }
}
```

### Query Example

```csharp
public record GetAllUsersQuery() : IRequest<List<User>>;

public class GetAllUsersHandler : IRequestHandler<GetAllUsersQuery, List<User>>
{
    private readonly AppDbContext _context;

    public GetAllUsersHandler(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<User>> Handle(GetAllUsersQuery request, CancellationToken cancellationToken)
    {
        return await _context.Users.ToListAsync(cancellationToken);
    }
}
```

## 🧠 Benefits of CQRS

- Better separation of concerns
- Easier to maintain and test
- Read and write models optimized independently

## ⚠️ When Not to Use CQRS

- Overkill for small apps
- Adds complexity if read/write difference is minimal

## ✅ Conclusion

CQRS empowers developers to write clean, focused logic for different operations. In complex .NET systems, applying CQRS with MediatR and EF Core can significantly improve structure and scalability.
