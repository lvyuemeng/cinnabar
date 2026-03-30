# Architecture

## Project Overview

**cinnabar** (朱砂) is a [Typst](https://typst.app) package providing reusable components and utilities for typesetting Chinese formal documents — primarily undergraduate and graduate theses conforming to Chinese university formatting standards.

Current version: `v0.0.1` (pre-publication). Target: [Typst Universe](https://typst.app/universe/).

## Goals

1. **Reduce friction for Chinese thesis authors.** Standard Chinese university thesis formats have rigid layout requirements (grid-based cover pages, specific font usage, CJK alignment quirks). cinnabar encodes these into reusable abstractions.
2. **Remain generally useful.** Components are adaptable for any document that benefits from structured, grid-based form layouts.
3. **Separation of content and style.** Authors supply data as named arguments. The package handles layout, font, sizing, and spacing decisions internally, with overridable defaults.

---

## Layer Model

cinnabar has three layers with a strict dependency direction. **`utils.typ` is never exposed to end users.**

```text
lib.typ  (public entry point — re-exports components + presets)
  │
  ├── components.typ  (public — constants, primitives, functional bricks, factory, composite bricks)
  │     └── utils.typ  (internal — pure helpers)
  │
  └── presets.typ     (public — opinionated whole-page layouts)
        ├── components.typ
        └── utils.typ
```

### `utils.typ` — internal

Pure helpers with no layout side-effects. Not re-exported by `lib.typ`.

| Symbol | Purpose |
|---|---|
| `mask-field(value, anonymous, length:)` | Returns value or block-character mask |
| `fill-lines(title, min-lines:)` | Normalises string/array, pads to minimum rows |

### `components.typ` — public API

Everything an end user needs to build custom layouts. Organized by kind:

**Constants** — shared vocabulary for `set`/`show` rules:

| Symbol | Description |
|---|---|
| `字号` | Chinese point size scale (初号 → 小五) |
| `字体` | Font fallback arrays with `covers: "latin-in-cjk"` |

**Primitives** — pure content functions, no composition:

| Symbol | Description |
|---|---|
| `cjk-strut` | Zero-width CJK baseline strut |
| `line-under` | Single line under content, matched to width |
| `double-underline` | Double-line underline |
| `hidden-heading` | Invisible PDF-outline anchor |
| `distribute-chars` | CJK character distribution with optional tail suffix |

**Functional bricks** — compose primitives or return structured data:

| Symbol | Description |
|---|---|
| `grid-rows` | Flat grid.cell array for caller-owned grids |
| `three-line-table` | Show-rule: auto-converts table to 三线表 |

**Factory** — returns closure dict:

| Symbol | Description |
|---|---|
| `field-theme` | Returns `(label, value, row, rows)` closures. Accepts `decorate` function for value styling |

### `presets.typ` — opinionated layouts

Whole-page thesis components. Institution-specific renderers belong here.

| Export | Description |
|---|---|
| `cover` | Thesis cover page |
| `abstract-zh` / `abstract-en` | Abstract pages with metadata |
| `originality` | Declaration page with signatures |
| `acknowledgements` | Acknowledgements |
| `nomenclature` | Symbol/term list from native `terms` syntax |

Internal: `_page-shell`, `_abstract-page`.

---

## File Structure

```text
cinnabar/
├── lib.typ           # Entry point — re-exports components + presets
├── components.typ    # Constants, primitives, bricks, factory
├── presets.typ       # Whole-page thesis components
├── utils.typ         # Internal pure helpers
├── typst.toml        # Package manifest
├── example/
│   └── example.typ   # Complete showcase (all components + presets)
└── docs/
    ├── AGENT.md      # Contributor philosophy and coding guidance
    └── ARCHITECTURE.md
```

### Import patterns

```typst
// Everything via lib.typ:
#import "@preview/cinnabar:0.1.0": *

// Components only (no presets):
#import "@preview/cinnabar:0.1.0": field-theme, 字号, 字体

// Namespace access:
#import "@preview/cinnabar:0.1.0": components, presets
// → components.field-theme, presets.cover

// Example (relative):
#import "../lib.typ": *
// Compile: typst compile example/example.typ
```

Requires Typst ≥ 0.14.0.

---

## Design Constraints

For detailed contributor guidance see `AGENT.md`. Key principles:

- **Factories over baked components** — `field-theme` is the model: configurable closures, not fixed output.
- **No utils exposure** — `utils.typ` is internal. `mask-field` and `fill-lines` are only used inside presets and components.
- **CJK alignment** — zero-width KaiTi strut in all cell renderers.
- **Anonymization** — `anonymous: bool` is a first-class parameter on presets.
- **Check native first** — don't wrap Typst one-liners (see AGENT.md §8).
- **Zero external dependencies** — the core library imports nothing from Typst Universe.

---

## Roadmap

### Phase 1 — Foundation ✓

`field-theme` factory, `distribute-chars`, `underline-cell`, `double-underline`, `hidden-heading`, `section-header`, `meta-field`, `sig-row`, `label-cells`, `field-pair`, `three-line-table`, cover/abstract/originality/acknowledgements/outline presets, `字号`/`字体` constants.

### Phase 2 — Hardening (v0.1.x)

- [ ] README overhaul with rendered screenshots
- [ ] `typst.toml` categories, disciplines, exclude
- [ ] Typst Universe PR

### Phase 3 — Expansion (v1.0+)

- [ ] `zhnumber(n)` — Chinese numeral conversion (native, no dep)
- [ ] `thesis(anonymous, twoside, fonts, info)` — closure factory for pre-configured presets
- [ ] `typst init` template
