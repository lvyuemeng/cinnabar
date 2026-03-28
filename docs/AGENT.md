# AGENT.md — cinnabar Contributor Guide

> For project overview, file structure, component catalogue, and roadmap, see `docs/ARCHITECTURE.md`.

---

## Core Philosophy

### 1. Separation of concerns

- `utils.typ` contains **pure functions** with no rendering side-effects. Every function in it takes plain values and returns plain values or strings.
- `components.typ` contains **rendering primitives** — functions that produce Typst content. They never perform data transformation beyond what is strictly needed for display.
- `lib.typ` is a **thin re-export layer** only. It must not contain logic.

### 2. Theme-based configuration over global state

Components accept explicit font/size/style arguments rather than relying on `set` rules at the module level. The `field-theme` factory pattern is the canonical example: callers instantiate a theme once with their chosen fonts and sizes, then use the returned closure dictionary (`label`, `value`, `row`, `rows`) throughout a document.

### 3. Graceful handling of CJK layout quirks

Typst's default metrics can misalign CJK and Latin glyphs. The invisible strut pattern — `box(width: 0pt, hide(text(font: "KaiTi", ...)[""]))` — is the established fix used throughout `components.typ`. Preserve it whenever adding new cell renderers.

### 4. Anonymization as a first-class concern

Thesis submission often requires blind review. The `mask-field` utility in `utils.typ` must be applied to every user-identifying field (author, student ID, grade, supervisor) before rendering. New components that display personal data must accept an `anonymous: bool` parameter and call `mask-field` internally.

### 5. Generalized patterns over repetitive style rebuilds

Every new page component must be built from existing primitives (`field-theme`, `mask-field`, `hidden-heading`, etc.) rather than reimplementing the same label/value cell, anonymization check, or title-normalisation logic inline. If a pattern appears twice, it belongs in `utils.typ` or `components.typ`. Study the NJU thesis codebase (`../ai/modern-nju-thesis/`) as a cautionary example of what happens without this discipline — the same `info-key`/`info-value` helper is rewritten in every page file.

### 6. Factory and essential functions over pre-given style components

`cinnabar` exposes **factories and primitives**, not a catalogue of fully-baked, opinionated components. `field-theme` is the model: it returns configurable closures, not a fixed visual output. New additions should ask "what is the minimal parameterisable abstraction here?" before adding a new top-level component. Pre-styled, institution-specific components (e.g. an NJU-branded cover) belong in downstream packages or example files, not in the library core.

### 7. Additive, non-breaking additions

The package is pre-1.0. However, treat named parameters with defaults as a public API contract. Adding new optional parameters is fine; removing or renaming existing ones is a breaking change and requires a version bump in `typst.toml`.

### 8. Check native Typst before adding anything

Before implementing a utility or component, verify it is not already provided by Typst's standard library. Wrapping a one-liner in a named function adds API surface without adding value.

Canonical reference: **[https://typst.app/docs/reference/](https://typst.app/docs/reference/)**

Key sections to check:

| Section | URL |
|---|---|
| Layout (`align`, `block`, `box`, `grid`, `stack`, `repeat`, `place`, `hide`, ...) | `/docs/reference/layout/` |
| Model (`outline`, `heading`, `figure`, `par`, `link`, ...) | `/docs/reference/model/` |
| Text (`text`, `underline`, `strike`, `raw`, ...) | `/docs/reference/text/` |
| Foundations (types, `datetime`, `array`, `str`, ...) | `/docs/reference/foundations/` |

**Decision rule:** If the native API requires more than ~3 lines of boilerplate to achieve the cinnabar-specific behaviour (CJK alignment, anonymisation, per-level arrays, etc.), a wrapper is justified. If it is a direct re-export of a one-liner with no added logic, remove it.

**Examples of functions removed for this reason:**

| Removed | Native equivalent |
|---|---|
| `list-of-figures` / `list-of-tables` | `outline(target: figure.where(kind: image))` |
| `format-date` | `date.display("[year]年[month]月[day]日")` |
| `join-by-sep` | `array.join(sep)` / identity for strings |

---

## Coding Conventions

| Concern | Convention |
|---|---|
| Naming | `kebab-case` for all functions, parameters, and local variables |
| Parameter order | Content/data arguments first, then configuration arguments |
| Defaults | Always provide sensible defaults for optional parameters |
| Comments | One-line comment above each exported function explaining its purpose |
| Section headers | Use `// === Section Name ===` banners to delimit logical sections in a file |
| Strut pattern | Always add the KaiTi strut inside `cell-base`-style renderers |

---

## Adding a New Component

1. Implement the rendering function in `components.typ`.
2. If it requires new data-transformation helpers, add them to `utils.typ`.
3. Do **not** modify `lib.typ` — the wildcard re-export picks up everything automatically.
4. Add a minimal usage example under `example/`.
5. Update `docs/ARCHITECTURE.md` if the component introduces a new structural concept.

---

## Adding a New Utility

1. Utilities must be **pure**: no `place`, no `grid`, no Typst layout calls.
2. Write a brief inline comment describing inputs and outputs.
3. Add a demonstration to an existing or new file under `example/`.
