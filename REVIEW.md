# Blog Post Review

**Total Posts:** 9 (2024: 4, 2025: 1, 2026: 4)

---

## 2024

### GitHub or GitLab for Hobby Projects
**File:** `content/post/2024/05/13/github-gitlab.org`

**Summary:** Compares GitHub and GitLab for solo hobby projects. Concludes GitHub is preferable due to larger community and faster page load times (~1.0s vs ~2.5s).

**Quality:** Clear structure, logical sections, accurate platform descriptions.

**Issues:**
- Line 30: `~2.5s~` strikethrough markup may not render correctly
- Performance comparisons are anecdotal, not data-driven

---

### Month of AI
**File:** `content/post/2024/07/08/month-of-ai.org`

**Summary:** Documents a month-long exploration of generative AI — running LLMs locally on GPU and Raspberry Pi 5, using Huggingface, and experimenting with vector embeddings.

**Quality:** Engaging conversational tone, accurate technical descriptions (quantization, specific models like Phi-3, Llama 3, Codestral 22B).

**Issues:**
- Only one specific benchmark number mentioned (80 tokens/second); more would strengthen the post
- Vector embedding models tested are not named

---

### Zigging Out
**File:** `content/post/2024/08/22/zigging-out.org`

**Summary:** Deep dive into Zig as a Rust alternative. Covers lazy compiler, explicit memory allocation, arena allocators, comptime, C interop, and tooling.

**Quality:** Excellent structure, correct code examples, comprehensive feature coverage.

**Issues:**
- Date inconsistency: YAML header says `2024-08-21`, filename path is `08/22`
- Line 128: "developer unvelocity" is awkward — likely meant "developer velocity" with negative context

---

### New Years Resolution Evaluation - Reading
**File:** `content/post/2024/12/18/news-years-resolution-evaluation-reading.org`

**Summary:** Evaluates a goal to read one book per month (5 books read by mid-December). Reflects on improved reading speed, school's effect on fiction enjoyment, and phone distraction.

**Quality:** Personal, engaging tone with good narrative flow.

**Issues:**
- Filename/title typo: `news-years` should be `new-years`
- No reading list included (only some titles mentioned by name)
- "El Enemigo Returns" section feels tangential and underdeveloped

---

## 2025

### Building a Lisp Interpreter (in Rust) - Part 1
**File:** `content/post/2025/11/15/lisp-1.org`

**Summary:** First in a three-part series. Covers representing Lisp data structures, tokenization, and parsing into an AST. Emphasizes readability over performance.

**Quality:** Excellent pedagogical structure, correct code, appropriate test cases.

**Issues:**
- None significant. Could reference the full implementation repo earlier.

---

## 2026

### 2025 Recap
**File:** `content/post/2026/01/14/2025-recap.org`

**Summary:** Year-end recap covering a Scheme R7RS interpreter in Zig, switching to jj version control, 3D printing (Prusa Mini+), and a new job at Google Fonts.

**Quality:** Easy to scan, accurate tool descriptions.

**Issues:**
- Line 67: Emoji (`🎵New Job🎶`) inconsistent with the rest of the blog's style
- "New Job" section is only ~7 lines — could expand on role or context

---

### Building a Lisp Interpreter (in Rust) - Part 2
**File:** `content/post/2026/01/25/lisp-2.org`

**Summary:** Implements the `eval` function. Covers atoms, symbols, list evaluation as function calls, and special forms (`if`, `define`).

**Quality:** Builds naturally on Part 1, clear explanation of eval semantics with correct code.

**Issues:**
- Line 8: File reference uses `~/src/...` path — may not resolve in all contexts
- Some edge cases not discussed (empty lists, deeply nested structures)

---

### Building a Lisp Interpreter (in Rust) - Part 3
**File:** `content/post/2026/02/21/lisp-3.org`

**Summary:** Final part implementing lambda expressions and closures. Covers lexical vs. dynamic scoping, environment hierarchies, and completes a working interpreter.

**Quality:** Complex topics explained well, correct closure implementation, useful scoping diagrams.

**Issues:**
- Line 8: Inconsistent file reference formats (`~/src/...` vs `file:...`)
- Graphviz diagrams may not render in all contexts
- Optional scoping section is dense — could be a separate post

---

### Functional Dispatch
**File:** `content/post/2026/03/31/function-ptrs.org`

**Summary:** Performance investigation comparing function pointer dispatch vs. enum-based instruction dispatch in bytecode interpreters, motivated by Tiny Skia's design. Enum dispatch wins generally, but function pointers with specialization can compete.

**Quality:** Clear progression from motivation → hypothesis → benchmarks → results. Sound methodology.

**Issues:**
- Line 15: Circular reference to undefined org ID (`:PROPERTIES:` block resolves it later, but may cause issues)
- SVG file references may not be portable depending on deployment

---

## Cross-Cutting Issues

| Issue | Posts Affected |
|-------|---------------|
| Inconsistent file reference paths (`~/` vs relative) | lisp-2, lisp-3 |
| Date mismatch between YAML header and filename | zigging-out |
| Filename typo | news-years-resolution-evaluation-reading |
| Emoji inconsistency | 2025-recap |
| Anecdotal rather than data-backed claims | github-gitlab, month-of-ai |

## Overall Assessment

**Strengths:** Strong technical writing throughout, honest about trade-offs and limitations, practical focus with reproducible examples, good pedagogical progression in the Lisp series.

**Improvements Needed:** Minor — standardize file reference formats, fix the filename typo, remove or standardize emoji usage, add more specifics to benchmark/data claims.
