---
layout: default
title: ".NET 10 and Angular Signals Powered 'Local-First' Enterprise RAG (Vector Memory) Architecture (Phase 3)"
author: Murat Süzen
date: 2026-05-20 16:00:00 +0300
categories: [AI, .NET]
---

# .NET 10 and Angular Signals Powered 'Local-First' Enterprise RAG (Vector Memory) Architecture

During Phase 3 of my **.NET AI Architect Laboratory** project development, I completely disabled external and costly cloud-based vector database dependencies (Vendor Lock-in). Instead, I established a **Local-First Enterprise RAG** infrastructure operating on **.NET 10 core**, a local **SQLite layer**, and **Angular Signals**.

The operations I have performed are as follows:

### 1. Cleaning Up Experimental Preview Package Dependencies

I completely eliminated the experimental `SemanticKernel.Connectors` and `VectorData.Abstractions` preview packages from the project, which constantly caused version mismatches, unstable structures, and contained vulnerability warnings such as `NU1904`. I anchored the architecture to the framework's own native, stable, and long-term supported enterprise packages.

### 2. Provider-Agnostic Embedding Substrate

I wrote a pure C# wrapper called **`GoogleEmbeddingGenerator`**, abstracting Microsoft's new enterprise AI standards (`Microsoft.Extensions.AI`) alongside Google's official GenAI SDK.

- I dynamically cast the high-dimensional `double[]` arrays produced by the Gemini `text-embedding-004` model down to the `float[]` vectors expected by .NET interfaces.
- **Architectural Gain:** I provided the full flexibility to transition to OpenAI or a completely local LLM model (Ollama/Llama, etc.) in the upcoming stages by simply changing the IoC (DI) registry inside `Program.cs`, without touching a single line of the core endpoint architecture.

### 3. Zero-Dependency Pure C# Cosine Similarity Engine

To calculate the semantic proximity between vectors, I created zero dependencies on any heavy external mathematical libraries or third-party Python services. I coded a memory-friendly and high-performance cosine similarity matrix running directly on .NET core:

```csharp
public static float CosineSimilarity(float[] vectorA, float[] vectorB)
{
   if (vectorA.Length != vectorB.Length)
       throw new ArgumentException("Vectors must have the same identical dimensions.");

   float dotProduct = 0.0f, normA = 0.0f, normB = 0.0f;
   for (int i = 0; i < vectorA.Length; i++)
   {
       dotProduct += vectorA[i] * vectorB[i];
       normA += vectorA[i] * vectorA[i];
       normB += vectorB[i] * vectorB[i];
   }
   return (normA == 0.0f || normB == 0.0f) ? 0.0f : dotProduct / ((float)Math.Sqrt(normA) * (float)Math.Sqrt(normB));
}
```

### 4. Deterministic Deduplication Against Data Inflation

To prevent the SQLite table from inflating in case identical code blocks or files are added back-to-back into the system, I established a deterministic Base64 path-hashing mechanism inside the Angular frontend layer (`memory-dashboard.component.ts`) based on the file path. By ensuring a strictly unique and definite `Id` is generated for each file content, I triggered the SQLite native `ON CONFLICT(Id) DO UPDATE` constraint and completely zeroed out the duplicate row inflation within the database.

### 5. Knowledge-Augmented Agency Flow

I integrated this created local vector memory with our autonomous multi-tool agent (`/api/architect/inspect-autonomous`). When the agent receives an architectural analysis task, it fires a query to this local SQLite vector layer in the background before directly scanning physical files on the disk. For example, when a user gives a general objective like _"review frontend access ports,"_ our semantic search engine fetches the unmentioned CORS configuration code snippet from local memory and injects it into the agent's real-time system context (Prompt). The agent generates decisions fully armed with localized enterprise domain experience.

## 🖥️ Dashboard RAG Panel Preview

The live screen artifact of the integrated RAG panel functions as follows:

![.NET AI Architect Laboratory Cyber Dashboard](https://raw.githubusercontent.com/muratsuzen/dotnet-ai-lab/main/src/frontend/ai-architect-ui/src/assets/rag-preview.png)

### 6. Reactive Management Board: Angular Signals & Tailwind UI

I visualized this entire local vector stream using Angular's reactive **Signals** architecture and a dark-themed **Tailwind CSS v3** interface. Driven by a single reactive state flag, the system seamlessly toggles between the _Code Analyzer_ room and the _Knowledge RAG_ room with zero latency, converting the entire control flow into a single cockpit.

---

### 🔗 Explore the Code

The next step following the completion of Phase 3:
Developing the **Automatic Code Ingestion Pipeline (Phase 4)**, which will automatically track modified code in the background and update local memory on the fly.

👉 **GitHub Repository:** [github.com/muratsuzen/dotnet-ai-lab](https://github.com/muratsuzen/dotnet-ai-lab)

---

_The models themselves are just engines we rent; the true value lies in the architectural substrate, the context, and the documentation we build around them. This lab is my permanent digital logbook of that journey._

---
