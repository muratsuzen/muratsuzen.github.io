---
title: What’s New in C# 12? Exploring the Latest Features
author: Murat Süzen
date: 2025-01-10 09:00:00
categories: [Language Features, C# 12]
tags: [csharp 12, new features, dotnet, language updates, productivity]
math: false
mermaid: false
---

C# 12, released alongside .NET 8, introduces several exciting new features that enhance developer productivity, improve code expressiveness, and simplify common patterns. Whether you’re building enterprise applications or working on smaller projects, these features can help you write cleaner, more maintainable code.

In this article, we’ll walk through the **key highlights of C# 12**, explain when and why to use them, and provide practical examples.

---

## 1️⃣ Primary Constructors for Non-Record Types

Previously, **primary constructors** were available only for record types. With C# 12, they now work on classes and structs.

Example:

```csharp
public class Person(string name, int age)
{
    public void Introduce() => Console.WriteLine($"Hi, I'm {name}, {age} years old.");
}
```

Why it matters:

✅ Less boilerplate code  
✅ Cleaner constructor-based initialization  
✅ Improves readability, especially for simple data holders

---

## 2️⃣ Collection Expressions

C# 12 introduces **collection expressions** (similar to array and collection literals) to simplify collection creation.

Example:

```csharp
var numbers = [1, 2, 3, 4];
var moreNumbers = [..numbers, 5, 6];
```

Why it matters:

✅ Create arrays, lists, and spans using a uniform, concise syntax  
✅ Use the spread operator (`..`) to include elements from other collections

---

## 3️⃣ Default Lambda Parameters

You can now define **default parameter values** in lambda expressions.

Example:

```csharp
Func<int, int, int> add = (x, y = 10) => x + y;

Console.WriteLine(add(5));      // Outputs 15
Console.WriteLine(add(5, 20));  // Outputs 25
```

Why it matters:

✅ More flexible lambdas  
✅ Closer parity with method declarations

---

## 4️⃣ Using Aliases for Any Type

C# 12 expands `using` alias declarations to support **any type**, including tuples and array types.

Example:

```csharp
using MyTuple = (int Id, string Name);
MyTuple person = (1, "Alice");
```

Why it matters:

✅ Makes complex types more readable  
✅ Improves maintainability in large codebases

---

## 5️⃣ Inline Arrays

Inline arrays let you define **fixed-size arrays** inside a struct, improving performance by avoiding heap allocations.

Example:

```csharp
[InlineArray(10)]
public struct SmallBuffer
{
    private int _element0;
}
```

Why it matters:

✅ Avoids allocations on the heap  
✅ Useful in performance-critical scenarios like game development or low-level networking

---

## Additional Improvements

- `nameof` in attributes: Use `nameof` expressions inside attribute arguments.
- Interpolated string handlers: Further performance optimizations.
- Better `params` support: More flexible parameter lists.

---

## Best Practices

✅ Use primary constructors for simple, immutable objects.  
✅ Apply collection expressions to reduce clutter when building lists or arrays.  
✅ Adopt default lambda parameters carefully to maintain code clarity.  
✅ Use type aliases to simplify complex declarations.  
✅ Benchmark inline arrays before using them in performance-sensitive code.

---

## Summary

C# 12 introduces several enhancements that streamline daily coding tasks, improve performance, and reduce boilerplate. By learning and integrating these features, you can make your .NET applications cleaner, faster, and more maintainable.

Make sure to update your SDK and compiler to start experimenting with these features in your projects!
