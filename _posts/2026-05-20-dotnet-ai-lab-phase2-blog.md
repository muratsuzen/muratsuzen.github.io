---
layout: default
title: ".NET AI Architect Laboratory: Making AI Work and Execute Tools (Phase 2)"
author: Murat Süzen
date: 2026-05-20 13:00:00 +0300
categories: [AI, .NET]
---

# .NET AI Architect Laboratory: Making AI Work and Execute Tools (Phase 2)

In Phase 1 of this project, we built a type-safe "Brain" using .NET 10 and Google Vertex AI. In Phase 2, we successfully gave hands and feet to our AI substrate. By connecting Microsoft Semantic Kernel, we created an autonomous agent that can read real local project files, think independently, and detect security vulnerabilities or performance bottlenecks.

Here is a quick summary of what I accomplished and the critical technical lessons I learned during Phase 2.

---

## 🛠️ Key Accomplishments

- **Autonomous Tool Execution:** The AI agent now receives a high-level goal (e.g., _"Find architectural patterns and security bugs"_). It automatically runs native C# plugins like `ListProjectFiles` and `ReadCodeFile` to explore and analyze the workspace without manual guidance.
- **Dynamic Provider Routing:** I implemented a dynamic runtime pipeline. The system can switch between **Gemini 2.5 Flash** and **Groq (Llama 3.3 / Llama 3.1)** on the fly based on user selection, completely decoupling the business logic from a single AI vendor.
- **Angular 19 Cyber-Dashboard:** Built a modern interface using **Angular Signals** and **Tailwind CSS v3** to visualize the agent's real-time analysis results, complexity scores, and strategic recommendation logs.

---

## 🧠 Important Technical Lessons Learned

- **The .NET Scope Trap:** Trying to resolve request-scoped Semantic Kernel instances directly from the root `IServiceProvider` container crashes the Kestrel server. I resolved this runtime boundary issue by shifting keyed service lookups to **`HttpContext.RequestServices`** to keep the kernel container safely isolated per HTTP request.
- **Enforcing Deterministic JSON:** Small models like Llama 3.1 8B love to output conversational text or messy "thought chains" instead of clean data. Prompt engineering alone is too brittle. I fixed this by forcing strict **`ChatResponseFormat.Json`** settings at the API gateway level to mechanically guarantee valid JSON parsing.
- **The Token Bleeding Filter:** Forcing an LLM to output rigid JSON payloads while explaining complex source code in Turkish can confuse the token selection matrix, leaking weird characters (like Russian or Chinese letters). Instead of wasting prompt tokens, I added a simple **Whitelist Regex Sanitizer** inside the client-side Angular signal flow to clean them up instantly.

---

## 🖥️ Dashboard Interface Preview

Here is how the live cyber-panel looks when a Llama-driven autonomous agent evaluates local C# source code:

![.NET AI Architect Laboratory Cyber Dashboard](https://raw.githubusercontent.com/muratsuzen/dotnet-ai-lab/main/src/frontend/ai-architect-ui/src/assets/dashboard-preview.png)

## 🚀 What's Next? (Phase 3: Enterprise Memory)

Now that our type-safe brain can execute tools and display results perfectly, the next challenge is context retention. Fitting massive codebases into a single prompt window is expensive and degrades model accuracy.

Next, we start **Phase 3: Enterprise Memory (RAG)**. I will integrate **PostgreSQL/pgvector** into the gateway to give our agent a permanent memory substrate of project histories and engineering standards.

### 🔗 Explore the Code

The complete blueprint, architecture blueprints, and step-by-step implementation files for Phase 2 are fully open-source. Feel free to explore, clone, or follow along as the laboratory evolves:

👉 **GitHub Repository:** [github.com/muratsuzen/dotnet-ai-lab](https://github.com/muratsuzen/dotnet-ai-lab)

---

_The models themselves are just engines we rent; the true value lies in the architectural substrate, the context, and the documentation we build around them. This lab is my permanent digital logbook of that journey._

---
