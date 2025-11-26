---
title: What’s New in C# 13? Official Features and Practical Examples
author: Murat Süzen
date: 2025-05-10 01:00:00
categories: [Language Features, C# 13]
tags: [csharp 13, new features, dotnet, official release, language updates]
math: false
mermaid: false
---

C# 13 is officially here! Released alongside .NET 9, this version continues the evolution of the language with new capabilities designed to improve expressiveness, developer productivity, and performance.

In this article, we’ll explore the **confirmed features of C# 13**, explain their purpose, and provide practical code examples so you can start using them right away.

---

## 1️⃣ Default Interface Struct Implementations

C# 13 allows **default struct implementations** in interfaces, improving the flexibility of interfaces when working with value types.

Example:

```csharp
public interface IPoint
{
    int X { get; set; }
    int Y { get; set; }

    void Move(int dx, int dy) => X += dx; Y += dy;
}
```

Why it matters:

✅ Allows interfaces to evolve without breaking implementations  
✅ Provides reusable logic even for structs

---

## 2️⃣ Extended Collection Patterns

C# 13 expands pattern matching with **extended collection patterns**, enabling you to match the head, tail, and middle of lists more elegantly.

Example:

```csharp
if (data is [1, 2, .. var middle, 9])
{
    Console.WriteLine($"Middle section: {string.Join(",", middle)}");
}
```

Why it matters:

✅ Cleaner data deconstruction  
✅ Simplifies working with arrays and lists

---

## 3️⃣ Parameter Null Checking with `!!`

Instead of writing manual null checks, C# 13 introduces **parameter null checking** with the `!!` operator.

Example:

```csharp
void PrintName(string name!!)
{
    Console.WriteLine(name);
}
```

This automatically throws `ArgumentNullException` if `name` is null.

Why it matters:

✅ Less boilerplate  
✅ Enforces parameter integrity consistently

---

## 4️⃣ Lambda Enhancements

C# 13 further enhances lambdas with:

- Capturing `ref` variables
- Allowing attributes on lambdas
- Improved target-typing for lambdas

Example:

```csharp
var add = [MyAttribute] (int a, int b) => a + b;
```

Why it matters:

✅ More powerful functional constructs  
✅ Fine-grained control over lambda behavior

---

## 5️⃣ Improvements to Raw String Literals

Introduced in C# 11, **raw string literals** are further refined in C# 13, including:

- Better escape handling
- Multiline formatting improvements

Example:

```csharp
var json =
```
