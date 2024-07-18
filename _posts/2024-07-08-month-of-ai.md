---
layout: post
title:  "Month of AI"
date:   2024-07-08 08:39:00 -0700
categories: post
---

## Introduction

Generative AI models have been on fire lately. Proponents peddle it as the
next "internet" like revolution. Startups and big tech companies can't resist
the urge to throw more money at it. Most of this has given me FOMO over
AI. Perhaps there is something I don't understand. In the latest attempt, I
plugged in models from Huggingface, which reminded me of a more modern but janky
`scikit-learn`.

### Background

Round 1: In college (around 2015~2016) I messed around with some basic machine
learning. I implemented neural networks inference and training in
C++/Python/Julia. I plugged in several models from `scikit-learn`. I bred
feature-selectors using genetic algorithms. I submitted mediocre models to
Kaggle, an online machine learning contest platform. I even skimmed the top
placement's creative solutions. It was fun and all, but it was mostly the end of
my machine learning explorations.

Round 2: Over the years I didn't use much machine learning. If anything, I've
been looking on how to reduce technological distractions around me. When GitHub
Copilot came out for technical preview around Mid 2021, I signed up
immediately. My expectations were low, but I was impressed by the technology and
curious to see how well it would do. As expected, I was impressed with GitHub
Copilot's technical achievement. As a tool though, I found the code generation
somewhat distracting (expected), but it was great and generating docstrings on
all my public `structs` and `functions`, an unexpected surprise.

## Round 3: What I Did

I delved into AI for a month or so.

I used Huggingface's inference API to run some models. The inference API
([documentation](https://huggingface.co/docs/api-inference/en/detailed_parameters))
makes it fast and easy to run models, even on potato hardware. However, not all
model types are available using the inference API, I especially wanted to try
the text to vector models. After reading the docs for downloading and running
models locally, I managed to slap together a half-baked search engine. The final
result of vector search was unimpressive.

The next stop was running LLMs. I `sudo pacman -S ollama` my way into running
the Phi-3 mini model. The model ran quickly and with a small memory footprint
due to the Q4 quantization cramming by cramming 16 bits information into just 4
bits. This breakthrough allowed me to even run Phi-3 mini on a Raspberry
Pi 5. The next step from this, I ran `sudo pacman -S ollama-rocm` and the models
ran faster on my GPU. I really did not expect this to work at all. At the
largest, I was able to run a variant of the Codestral 22B model.

## Takeaways

### LLMs Can Run On Lots of Hardware

I purchased an AMD card last year expecting to do no ML work on it. When models
were able to run on the GPU, they ran pretty well. I was able to run a Q4
quantized Llama 3 8B model as 80 tokens/second; this is plenty fast.

I was also able to run Phi-3 mini on the Raspberry Pi 5. Although the speeds
were not acceptable for interactable use cases, the Pi 5 is usable for some
small scale offline processing.

### Running Models is Easyish

Although some of the APIs are ugly, HuggingFace has succeeded at democratizing
models. It's easy to find models and use them out of the box. If even that's too
hard, plenty of companies provide an API endpoint that offers ML as a service.

### Model Documentation is Trash

> MumboJumbo uses FooBar and Baz to reach SOTA performance on FizzBuzz > eval
> and reaches a Big O(3.14) on Wumpus.

Most HuggingFace model pages are terrible, especially if you aren't constantly
following the ML space. At the very least, HuggingFace forces a category on
models, such as text-to-speech or text-generation, but my wishlist for a card:

- Performance characteristics
- Model size
- Demo
- Brief description
- Caveats
- Special tokens (like FIM_PREFIX)

### Text Vectorization Alone is Crap

Listen to any layman interview and you will hear someone jump to the brilliant
idea that ML must just produce the best search. In practice, my search engine
fell short with just sentence-to-vec. I got good improvements by adding keyword
search + classical natural language processing techniques such as synonyms and
stemming. A more insightful discussion on vector embeddings for Search can be
found in Lex Fridman's
[interview](https://youtu.be/e-gwvmhyU7A?si=znZM8TD-9O28t0v2) with Perplexity's
CEO.
