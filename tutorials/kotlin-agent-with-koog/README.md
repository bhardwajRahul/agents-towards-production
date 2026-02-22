![](https://europe-west1-atp-views-tracker.cloudfunctions.net/working-analytics?notebook=tutorials--kotlin-agent-with-koog--readme)

# Building AI Agents in Kotlin with Koog

Build your first AI agent in Kotlin using JetBrains' Koog framework, progressing from a basic prompt-response agent through tool calling and structured output.

## What You'll Learn

- **Koog Fundamentals**: Set up a Kotlin project with Koog and create a minimal AI agent that sends prompts to an LLM
- **Tool Calling**: Define custom tools that the agent can invoke autonomously using the ReAct pattern (Reason, Act, Observe)
- **Structured Output**: Get typed Kotlin data classes back from the LLM instead of free-form text
- **Kotlin-Native AI**: Leverage Kotlin coroutines, serialization, and type safety for AI agent development

## Quick Start

```bash
git clone https://github.com/NirDiamant/agents-towards-production.git
cd agents-towards-production/tutorials/kotlin-agent-with-koog

export OPENAI_API_KEY="sk-..."

./run.sh   # Interactive guided runner (recommended for first time)
```

Or run each step directly:

```bash
./gradlew step1   # Basic agent
./gradlew step2   # Agent with tools
./gradlew step3   # Structured output
```

The Gradle wrapper is included -- no need to install Gradle separately. The first run downloads dependencies automatically (takes about a minute).

## Tutorial

[Full Tutorial Walkthrough](tutorial.md)

## Requirements

- **JDK 17+** installed ([Adoptium](https://adoptium.net/) or `brew install openjdk@17`)
- **OpenAI API Key** (with billing enabled)

## What You'll Build

A smart assistant that answers questions using custom tools (weather lookup, calculations, fact retrieval) and returns typed, structured responses as Kotlin data classes.

**Total Tutorial Time**: ~25-30 minutes
**Difficulty**: Beginner-Intermediate (Kotlin basics, Gradle)
