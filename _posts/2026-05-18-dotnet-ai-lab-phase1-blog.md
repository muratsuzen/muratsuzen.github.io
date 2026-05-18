---
layout: default
title: ".NET AI Architect Laboratory: My Architectural Experiments and Learning Journey in the AI Ecosystem (Phase 1)"
author: Murat Süzen
date: 2026-05-18 13:00:00 +0300
categories: [AI, .NET]
---

# .NET AI Architect Laboratory: My Architectural Experiments and Learning Journey in the AI Ecosystem (Phase 1)

In an era where artificial intelligence technologies are advancing at breakneck speed, the best way to truly grasp new libraries and paradigms is to roll up your sleeves and get into the kitchen. As a software developer, I launched the **.NET AI Architect Laboratory** project to pull back the curtain on the underlying mechanics of integrating LLMs into our applications, and to explore the absolute boundaries of building flexible, modular architectures.

For me, this laboratory is far from a commercial endeavor; it is a personal learning journey where I discover new technologies, document my findings, and build a sandbox grounded in enterprise-grade architectural standards.

---

### 🎯 Why This Lab?

My primary motivation in this project is to look past standard "quick-start" documentation and truly master the engineering philosophy behind AI integration. The core goals I established for this laboratory include:

- **Understanding the Kitchen:** Going beyond basic API calls to deeply comprehend the architectural costs and mechanics of treating LLMs as plug-and-play engines.
- **Forging My Own Standards:** Handcrafting and testing the cleanest, most sustainable design patterns for AI integration within the .NET ecosystem.
- **Preparing for Tomorrow's Tech:** Moving past being a passive consumer of ready-made libraries, and reaching a level of competency where I can design end-to-end AI data flows, orchestration, and security from scratch.

---

### 🧠 How My Learning Journey is Progressing

This process has been an incredibly rewarding, educational, and discovery-filled experience. A few highlights from this journey so far:

- **Adapting to an Evolving Ecosystem:** Experiencing live version upgrades, shifting method names, and breaking changes in highly nascent libraries like `Microsoft.Extensions.AI` and the newest official vendor SDKs (such as `Google.GenAI`) has been a phenomenal learning experience.
- **Marrying the Rigid and the Fluid:** I learned how to build a translation bridge between the strict, type-safe world of .NET and the highly fluid, unpredictable nature of generative AI outputs.
- **Learning through Failure:** Encountering role-matching discrepancies, authentication hurdles, and schema alignment issues during development allowed me to gain a much deeper understanding of how these libraries operate under the hood.

---

### 🛠️ What I Accomplished in Phase 1

The first phase of the lab focused entirely on building a clean "Brain" architecture, completely insulated from external vendor lock-in:

- **Enterprise Setup & Security:** I built the foundation using a .NET 10 Minimal API. Instead of passing brittle API keys through code, I established enterprise security standards by leveraging Google Vertex AI via IAM and Service Account (`vertex-key.json`) mechanics through Application Default Credentials (ADC).
- **Abstraction via the Adapter Pattern:** To prevent the API endpoint from tightly coupling with the native Google SDK, I developed a custom adapter (`GoogleGenAIChatClient`) that implements Microsoft's standard `IChatClient` interface.
- **Type-Safe JSON Management:** To ensure that raw AI outputs could be safely and directly deserialized into C# objects (`ArchitectureReview`), I enforced strict schema controls. By fine-tuning parameters like `Temperature` (down to `0.2f`) and setting the response MIME type, I successfully locked down the model's output format.
- **Dynamic Provider Routing:** I designed an elegant Dependency Injection (DI) structure capable of switching between different underlying AI engines at runtime simply by modifying a single line in `appsettings.json` (e.g., `SelectedProvider: "Gemini"`).

---

### 🚀 What's Next? (Phase 2 and Beyond)

Now that the core infrastructure is completely provider-agnostic, it's time to test more autonomous workflows within the laboratory:

- **Giving the AI Hands and Feet (Orchestration):** I will integrate `Microsoft.SemanticKernel` into the project to present native C# functions (Native Plugins) to the model as tools, opening the door to experimenting with autonomous execution loops.
- **Code Analysis Capability (Function Calling):** The first plugin I develop will test the model's ability to scan real C# source files in the repository and generate autonomous architectural reviews.
- **UI & Visualization:** To visualize the analysis results and track model performance metrics over time, I will build an Architecture Dashboard powered by **Angular 19**.
- **Advanced Memory & Agency (RAG & Agents):** In later stages, I plan to explore vector database integrations (PostgreSQL/pgvector) and step into multi-agent systems via the Model Context Protocol (MCP).

---

### 🔗 Explore the Code

The complete blueprint, architecture blueprints, and step-by-step implementation files for Phase 1 are fully open-source. Feel free to explore, clone, or follow along as the laboratory evolves:

👉 **GitHub Repository:** [github.com/muratsuzen/dotnet-ai-lab](https://github.com/muratsuzen/dotnet-ai-lab)

---

_The models themselves are just engines we rent; the true value lies in the architectural substrate, the context, and the documentation we build around them. This lab is my permanent digital logbook of that journey._

---
