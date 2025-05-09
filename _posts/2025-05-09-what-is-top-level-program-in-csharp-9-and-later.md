---
title: What is Top-Level Program in C# 9 and Later?
author: Murat Süzen
date: 2025-05-09 09:00:00
categories: [C#, .NET]
tags: [csharp 9, top-level program, dotnet, programming, simplification]
math: false
mermaid: false
---

Starting with C# 9, Microsoft introduced **top-level programs** — a new syntax feature that simplifies writing simple applications by eliminating the need for boilerplate code like `Main` methods and class declarations.

This article explains what top-level programs are, why they were introduced, and how you can use them to write cleaner, faster-to-read code.

## What Is a Top-Level Program?

In C# versions prior to 9, every program required at least the following structure:

```csharp
using System;

namespace MyApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello, World!");
        }
    }
}
```

Starting with C# 9, you can skip all that boilerplate and write:

```csharp
using System;

Console.WriteLine("Hello, World!");
```

This is called a **top-level program** — the compiler automatically wraps your code in a class and generates the `Main` method for you.

## Why Was It Introduced?

Top-level programs were added to make C# simpler for:

- Beginners who want to write short programs without extra ceremony
- Scripts and small utilities where you don't need a full project structure
- Tutorials and documentation where concise examples are clearer

It reduces visual noise and makes small programs more approachable.

## How Does It Work?

When you write a top-level program:

✅ Only one file in the project can have top-level statements.  
✅ The compiler generates an implicit `Main` method that wraps your code.  
✅ You can still access command-line arguments using the `args` variable.

Example with arguments:

```csharp
Console.WriteLine($"Number of args: {args.Length}");
foreach (var arg in args)
{
    Console.WriteLine(arg);
}
```

## Best Practices

- Use top-level programs for **small console apps**, **samples**, or **quick tests**.
- For larger or production apps, stick to the classic explicit `Main` structure for clarity and flexibility.
- You can combine top-level statements with functions or methods declared in the same file.

## Example: Mixing Functions

```csharp
SayHello();

void SayHello()
{
    Console.WriteLine("Hello from a local function!");
}
```

## Advanced Usage

You can also work with:

- `async` code: mark the top-level context as `async`.
- Dependency injection: wire up services as usual if using minimal APIs in ASP.NET Core.

Example with async:

```csharp
using System.Net.Http;

using var client = new HttpClient();
var content = await client.GetStringAsync("https://example.com");
Console.WriteLine(content);
```

## Summary

Top-level programs in C# 9+ are a powerful simplification, especially for quick scripts, demos, and educational materials. By removing unnecessary scaffolding, they let you focus on the **core logic**.

In tomorrow’s article, we’ll dive into **async and await** in C# — how to write efficient asynchronous code that doesn’t block your application.

Stay tuned!
