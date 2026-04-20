## Introduction

Microsoft Foundry offers a powerful managed platform for building AI applications and agents. That said, there are situations where it introduces practical constraints, such as:

- model availability limited by region or subscription  
- quota limits  
- pricing complexity  
- limited control over low‑level inference behavior  

When you need tighter control over the model runtime—or want to use open‑source models that aren’t available in Foundry—it can make sense to run your own LLM inference stack directly on Azure infrastructure.

This guide walks through **deploying and running a self‑hosted LLM service using Azure Container Apps**. The goal is not only to run a model, but also to better understand how LLM inference works in practice—and to have a bit of fun experimenting with it.

## Theory

Large Language Models (LLMs) are neural networks trained to understand and generate human language. They learn by processing very large text datasets and discovering statistical patterns in how words and phrases appear together.

At their core, most modern LLMs are based on the **transformer architecture**. Instead of reading text word‑by‑word like older models, transformers process tokens in parallel and use a mechanism called **attention** to determine which parts of the input are most relevant when generating the next token.

### Tokens and Text Generation

LLMs do not operate directly on words. Text is first converted into **tokens**, which are small pieces of text such as words, sub‑words, or characters.

For example:

```
"Azure runs AI models"
```

might become something like:

```
["Azure", " runs", " AI", " models"]
```

The model receives these tokens and predicts the **most probable next token** based on everything that came before it. This process repeats token by token until a full response is produced.

In other words, an LLM is essentially a system that repeatedly answers the question:

> “Given this text so far, what token is most likely to come next?”

Despite the simplicity of this mechanism, the scale of training data and model parameters allows LLMs to produce surprisingly coherent and useful responses.

### Inference vs Training

There are two major phases in the life of an LLM.

**Training**

During training the model learns from massive datasets using large GPU clusters. This stage adjusts billions of internal parameters so the model can predict tokens accurately.

**Inference**

Inference is the stage where the trained model is used to generate responses. Instead of learning, the model simply performs forward passes through the neural network to produce tokens.

Running inference is still computationally heavy, but it is much cheaper than training and can often be done on CPUs or smaller GPU instances depending on the model size.

The system described in this guide focuses entirely on **inference**, using an already trained model.

### Quantization and Model Formats

Raw models are often extremely large and designed for high‑end GPU systems. To run them on smaller machines, the weights can be **quantized**, meaning their numerical precision is reduced.

Common benefits of quantization include:

- smaller model size
- lower memory usage
- faster inference
- ability to run on CPUs

Many open models are distributed in the **GGUF format**, which is optimized for efficient loading and execution in lightweight inference runtimes.

### llama.cpp

`llama.cpp` is a lightweight open‑source inference engine designed to run LLMs locally.

Despite the name, it supports many models beyond the original LLaMA family, including models like **Gemma, Mistral, and others**, as long as they are provided in **GGUF format**.

Its main responsibilities are:

- loading the model weights into memory  
- managing tokenization and sampling  
- running the transformer inference computations  
- generating tokens one at a time  
- exposing an API that other services can call

Internally, llama.cpp is written in C/C++ and focuses heavily on performance optimizations such as:

- CPU vectorization  
- efficient memory mapping of model files  
- optional GPU acceleration  
- support for quantized models

Because of these optimizations, llama.cpp can run reasonably capable models even on machines without GPUs.

### Token Streaming

When generating text, the model produces tokens sequentially. Instead of waiting for the full response, systems often **stream tokens as they are generated**.

This provides two advantages:

- users see the response appear gradually in real time  
- latency feels much lower for interactive chat

In the architecture used in this guide, the browser receives these streamed tokens through **Server‑Sent Events (SSE)** while `llama.cpp` is generating the response.

### Putting It Together

All materials stored in one repository - https://github.com/groovy-sky/local-ai . The repository contains everything needed to run the stack:

- **llama.cpp** runs the model and performs inference  
- **NGINX** acts as a lightweight gateway and serves the UI  
- **the browser client** sends prompts and renders streamed responses  

For easier setup all dependencies stored as a Docker image. You can build it yourself, or use ready-to-use image - https://hub.docker.com/repository/docker/gr00vysky/gemma4-e2b

The result is a small, self‑contained system capable of running an LLM and exposing it through a simple web interface.

While it is much simpler than large production AI platforms, it demonstrates the core mechanics of how modern language models generate text.

## Why Gemma‑4 E2B Works Well Here

The **Gemma‑4 E2B** model fits this setup well because it’s designed to run efficiently on modest hardware.

Key characteristics:

- **Compact model tier** — The E2B variant belongs to the lightweight Gemma model family and can run on CPU‑based infrastructure without requiring GPU instances.  
- **GGUF compatibility** — When converted to **GGUF format**, Gemma models run directly with `llama.cpp`, which simplifies deployment and reduces runtime dependencies.  
- **Predictable resource usage** — The model fits within the CPU and memory limits typically available in **Azure Container Apps**, allowing containerized inference without specialized infrastructure.  
- **Good fit for small workloads** — With conservative container sizing and some llama.cpp runtime tuning, a single instance can reliably support a small internal user base.

This makes the model a practical option for deploying a **self‑hosted chat assistant or internal AI tool**.

## Prerequisites

To run the deployment, you will need an active Azure subscription  

## Deployment Guide

Use the following **Deploy to Azure** link to deploy the ARM template directly from GitHub:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgroovy-sky%2Flocal-ai%2Frefs%2Fheads%2Fmain%2Farm.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a> 

Once the deployment finishes, you’ll have a publicly reachable endpoint for the web UI and the proxied inference endpoint, ready for validation.

![alt text](image.png)

## Result

After completing the deployment, you’ll have:

![alt text](image-1.png)

- a self‑hosted **Gemma‑4 E2B inference service** running on Azure Container Apps  
- a browser‑based chat interface served by NGINX  
- direct model inference endpoints exposed through NGINX proxy rules  

This setup provides a straightforward way to run open‑weight LLMs on Azure infrastructure without relying on a managed AI platform.

## Summary

Microsoft Foundry is a strong managed platform for enterprise AI workloads, but some scenarios benefit from greater control over model selection and runtime behavior.

By combining **Azure Container Apps**, **llama.cpp**, and NGINX, you can deploy a compact self‑hosted LLM stack capable of supporting internal applications and small teams.

This guide shows how to run a **Gemma‑4 E2B model on Azure Container Apps**, offering a flexible and lightweight alternative when a fully managed platform isn’t the right fit.