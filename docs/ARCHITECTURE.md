# Architecture

## Project Overview

**cinnabar** is a [Typst](https://typst.app) package providing reusable components and utilities for typesetting Chinese formal documents — primarily undergraduate and graduate theses conforming to Chinese university formatting standards.

The project is in early development (`v0.0.1`) and is not yet published to Typst Universe. It is intended to grow into a mature, configurable kit that any Chinese-language academic author can drop into their Typst project.

---

## Goals

1. **Reduce friction for Chinese thesis authors.** Standard Chinese university thesis formats have rigid layout requirements (grid-based cover pages, specific font usage, CJK alignment quirks). cinnabar encodes these requirements into reusable abstractions.
2. **Remain generally useful.** While targeting Chinese academic contexts, the components are designed to be adaptable for any document that benefits from structured, grid-based form layouts.
3. **Separation of content and style.** Authors supply data (title, author, department, etc.) as named arguments. The package handles all layout, font, sizing, and spacing decisions internally, with sensible defaults that can be overridden.
4. **Future Typst Universe publication.** The project aims to eventually meet the criteria for publication on [Typst Universe](https://typst.app/universe/).

---

## Design Principles

### Theming over inline styling

Components are configured through a `field-theme` factory (`components.field-theme`) that returns a set of pre-styled rendering functions (`label`, `value`, `row`, `rows`). Callers obtain a theme object and use its methods, rather than passing style arguments to every individual cell. This keeps call sites clean and makes global style changes trivial.

### Named-argument configuration blocks

Every top-level component (e.g. `cover`, `abstract`) separates its arguments into two logical groups:

- **Content arguments** — the actual data: `title`, `author`, `department`, etc.
- **Configuration arguments** — layout and style knobs: `anonymous`, `twoside`, `fonts`, `sizes`, etc.

This makes it immediately clear to users what is "content" and what is "presentation".

### Anonymous mode

The `anonymous: bool` flag is a first-class feature. When enabled, sensitive fields (author name, student ID, supervisor) are replaced with a block-character mask (`█████`) via `utils.mask-field`. This supports blind-review submission workflows without requiring authors to manually redact their documents.

### CJK-aware rendering

Typst's default metrics can misalign CJK and Latin characters vertically. CN-Kit works around this by injecting a zero-width strut character set in a known CJK font (KaiTi) wherever mixed text rendering is needed, ensuring consistent baseline alignment across fonts.

### Utility layer

`utils.typ` provides small, pure helper functions that are format-agnostic:

| Function | Purpose |
|---|---|
| `format-date(date)` | Formats a `datetime` value as `YYYY年MM月DD日` |
| `mask-field(value, anonymous)` | Returns the value or a block-character mask |
| `join-by-sep(content, separator)` | Joins an array of strings into one, or passes a string through unchanged |

These are deliberately kept free of any layout or font concerns.

---

## File Structure

```text
cinnabar/
├── lib.typ              # Package entry point — re-exports components and utils
├── components.typ       # Layout components (field-theme, double-underline, hidden-heading)
├── utils.typ            # Pure utility functions (date, masking, joining)
├── typst.toml           # Package manifest (name, version, compiler requirement)
├── example/
│   ├── cover-zh.typ     # Example: Chinese thesis cover page
│   ├── abstract-zh.typ  # Example: Chinese abstract page
│   └── expr.typ         # Exploratory/experimental usage
├── img/
│   └── handy.png        # Screenshot used in README
└── docs/
    ├── AGENT.md         # Contributor philosophy and coding guidance
    └── ARCHITECTURE.md  # This file
```

---

## Component Catalogue

### `components.field-theme(...)` → theme object

The central component factory. Returns a dictionary of four closures:

- `label(content, ...)` — renders a static label cell
- `value(content, ...)` — renders an editable-style value cell with a bottom border
- `row(key, val, ...)` — produces a `(label-cell, value-cell)` tuple for use inside a `grid`
- `rows(key, val, min-lines, ...)` — like `row`, but spans multiple lines with padding to a minimum row count

**Configuration parameters:**

| Parameter | Default | Description |
|---|---|---|
| `font-label` | `none` | Font for label cells |
| `font-value` | `none` | Font for value cells |
| `size-label` | `12pt` | Font size for labels |
| `size-value` | `12pt` | Font size for values |
| `inset` | `(x: 0pt, bottom: 2pt)` | Cell padding |

### `components.double-underline(body, ...)` → content

Draws two horizontal lines beneath `body`, measured to match its width. Used for styled headings.

### `components.hidden-heading(..args)` → content

Inserts an invisible heading that appears in PDF bookmarks and the document outline without being visible in the rendered output. Used to add outline entries for pages like the abstract.

---

## Dependency Map

```text
lib.typ
  └── components.typ   (layout primitives)
  └── utils.typ        (pure helpers)

example/*.typ
  └── lib.typ          (via relative import)
  └── @preview/pointless-size   (Chinese point-size scale)
  └── @preview/cuti            (fakebold for CJK fonts lacking bold variants)
```

External packages (`pointless-size`, `cuti`) are only used in the examples, not in the library itself. The core library (`lib.typ`, `components.typ`, `utils.typ`) has zero external dependencies.

---

## Working with Examples

Examples under `example/` are excluded from the published package (`typst.toml` `exclude` field). They import from `../lib.typ` using a relative path. To compile an example locally:

```shell
typst compile example/cover-zh.typ
```

Requires Typst ≥ 0.14.0 (see `typst.toml` `compiler` field).

---

## Release Checklist

- [ ] Bump `version` in `typst.toml`
- [ ] Verify `compiler` field matches the minimum required Typst version
- [ ] All examples compile without errors
- [ ] No personal data or system-specific font paths hardcoded
- [ ] `docs/ARCHITECTURE.md` reflects any structural changes

---

## Roadmap

Priorities are driven by two forces simultaneously: the actual section order of Chinese undergraduate/graduate thesis formats, and cinnabar's philosophy (see `AGENT.md`) of building generalized factories and primitives rather than pre-baked institution-specific outputs. Each phase therefore has two concerns: **feature completeness** (what sections exist) and **abstraction quality** (whether existing code follows the factory-first philosophy).

### Phase 1 — Foundation ✓ (v0.0.x)

Core infrastructure and philosophy established.

**Features**

- [x] `field-theme` — parameterisable factory returning `label`, `value`, `row`, `rows` closures
- [x] `double-underline`, `hidden-heading` — atomic layout primitives
- [x] `cover`, `abstract-zh`, `abstract-en`, `originality`, `acknowledgements` — front/back matter components
- [x] Anonymous mode (`mask-field`) for blind-review submission

**Philosophy compliance**

- [x] `utils.typ` contains only pure functions
- [x] `components.typ` uses `field-theme` internally — no inline `info-key`/`info-value` duplication
- [x] `lib.typ` is a thin re-export layer only

---

### Phase 2 — Utility Hardening + TOC (v0.1.x)

Complete the front-matter section set and harden the utility layer against the antipatterns identified in the NJU reference analysis.

**Features**

- [x] English abstract (`abstract-en`)
- [x] Statement of originality (`originality`)
- [x] Acknowledgements (`acknowledgements`)
- [x] **Table of contents** — `outline-page` with per-level font/size/spacing arrays and dot leaders
- [x] **Table of contents** — `outline-page` with per-level font/size/spacing, dot leaders, native `outline.entry.inner()`
- [x] ~~List of figures / list of tables~~ — removed; native one-liner: `outline(target: figure.where(kind: image))`

**Utility hardening** (philosophy: eliminate inline repetition, see AGENT §5)

- [x] `normalise-title(title, min-lines)` — extracts the string→array + padding pattern; used in `cover`
- [x] `justify-text(body, with-tail)` — character-spaced CJK label text with optional trailing colon
- [x] `format-date-en(date)` — English short date variant (`"Jun 1, 2025"`)
- [x] `字号` / `字体` style constants — font fallback arrays with `covers: "latin-in-cjk"` in `utils.typ`
- [ ] Replace bare size literals in `components.typ` with `字号.*` references
- [ ] Replace bare font name strings in `components.typ` with `字体.*` fallback arrays

**Atomic brick refactor** (philosophy: composable primitives, AGENT §6)
- [x] `section-header(title, font, size, underline, vspace-*)` — shared centred heading brick used by all page components
- [x] `meta-field(label-str, value-str, body-font)` — shared bold-label + body paragraph brick; eliminates local `field()` closures in `abstract-zh` and `abstract-en`
- [x] `sig-row(label-str, date-str, date-label)` — shared signature row brick; lifted from inline `originality` definition
- [x] `_abstract-page(...)` — internal shared brick; `abstract-zh` and `abstract-en` are now thin callers with localised label dicts
- [x] `expr.typ` updated to showcase all atomic bricks with `字号`/`字体` constants

---

### Phase 3 — Body Formatting Factories (v0.2.x)

Support the body of the document. Every addition must be a **factory or configurable primitive** (AGENT §6). Reference: NJU `mainmatter.typ`, `custom-numbering.typ`, `custom-heading.typ`.

Before implementing, verify against [https://typst.app/docs/reference/](https://typst.app/docs/reference/) — heading numbering, page counters, and footnotes are all native (AGENT §8).

**Features**
- [ ] **`custom-numbering(first-level, format, depth)`** — maps heading levels to numbering schemes; supports `第一章`, `1.1`, and hybrid patterns. Wraps native `numbering()`.
- [ ] **`active-heading(level, prev)` / `current-heading(level)`** — context query utilities for running headers; thin wrappers over `query(heading.where(level:))`
- [ ] **Layout layers** — `doc(...)`, `preface(...)`, `mainmatter(...)` setup functions; page numbering switches (Roman → Arabic); check native `set page(numbering:)` and `counter(page)` first
- [ ] **`bilingual-bibliography` wrapper** — shim around NJU's GB/T 7714-2015 `utils/bilingual-bibliography.typ`; do not reimplement
- [ ] **Footnote spacing** — `show footnote.entry: set text(...)` set rule; verify native `footnote.entry` parameters cover the need before wrapping

**Philosophy check:** all per-level style config passed as arrays (`heading-font`, `heading-size`, `heading-above`, `heading-below`) — never hardcoded per level inside the function body.

---

### Phase 4 — Style System + Publication Readiness (v0.3.x)

Wire style constants into `components.typ` and prepare for Typst Universe submission.

**Style system** (philosophy: named constants over magic numbers)
- [x] `字号` size dict and `字体` font fallback arrays added to `utils.typ`
- [ ] Replace all bare size literals in `components.typ` with `字号.*` references
- [ ] Replace all bare font name strings in `components.typ` with `字体.*` fallback arrays
- [ ] **`zh-format` integration** — switch example files from `fakebold` (`cuti`) to `show: zh-format`; core library stays dependency-free

**Publication readiness** (resolve gaps in `docs/publish.md`)
- [ ] README overhaul — rendered screenshots for every component
- [ ] All example files use absolute package import (`@preview/cinnabar:x.x.x`)
- [ ] `typst.toml`: add `disciplines`, verify `categories`, complete `exclude`
- [ ] Typst Universe pull request

---

### Phase 5 — Document-Level Factory (v1.0+)

Introduce the `documentclass`-style top-level factory (see NJU reference) that resolves the current pain point of passing `fonts`, `anonymous`, and `twoside` to every component call.

- [ ] **`thesis(doctype, anonymous, twoside, fonts, info)`** — closure factory returning pre-configured `cover`, `abstract`, `originality`, `preface`, `mainmatter`, etc.; single point of global config
- [ ] **Key-list anonymization** — resolve `anonymous-info-keys` once at factory level; remove per-component `mask-field` calls
- [ ] **`typst init` template** — scaffold that produces a ready-to-compile thesis skeleton
- [ ] **Compliance helpers** — utilities that warn when required sections are absent
- [ ] **Broader CJK** — Traditional Chinese and HK/Taiwan thesis format adaptations

---

---

## Reference Inspection Guide

A condensed guide for contributors reading the reference codebases. For full analysis see the sections below.

### When to consult `../ai/modern-nju-thesis/`

| You are working on | Read this file first |
|---|---|
| TOC component | `pages/bachelor-outline-page.typ` |
| Figure/table list | `pages/list-of-figures.typ` |
| Heading numbering | `utils/custom-numbering.typ` |
| Running headers | `utils/custom-heading.typ` |
| Layout layers (doc/preface/mainmatter) | `layouts/doc.typ`, `layouts/preface.typ`, `layouts/mainmatter.typ` |
| Bilingual bibliography | `utils/bilingual-bibliography.typ` |
| Font/size constants | `utils/style.typ` |
| `justify-text` utility | `utils/justify-text.typ` |
| English date formatting | `utils/datetime-display.typ` |

### Antipatterns to actively avoid (from NJU analysis)

| Pattern seen in NJU | cinnabar rule |
|---|---|
| `info-key`/`info-value` redefined per page file | Always use `field-theme(...)` — never define local cell helpers |
| `if anonymous and key in keys { "█████" }` inline | Always use `mask-field(value, anonymous)` |
| Title normalisation (`split`, `pad`) in every page | Extract to `normalise-title(title, min-lines)` in `utils.typ` |
| `fakebold` imported per page | Bold is document-level; use `show: zh-format` in examples only |
| Bare `"SimSun"` / `"KaiTi"` strings | Use fallback arrays with `covers: "latin-in-cjk"` from `utils/style.typ` |
| Magic size literals (`12pt`, `16pt`) everywhere | Use `字号.*` constants from `utils/style.typ` |

### When to consult `zh-format` (`@preview/zh-format`)

## Use as reference for document-level CJK bold/italic/underline activation. The library itself must not depend on it. Key functions: `setup-bold` (stroke-based CJK bold), `setup-emph` (skew-based CJK italic), `u(width:, body)` (fixed-width underline for form fields). Activate in examples with `show: zh-format` at the document root

---

## Reference: modern-nju-thesis

### Code Repetition Analysis — What cinnabar Must NOT Replicate

Studying the NJU codebase reveals systematic duplication that cinnabar's philosophy of **generalized patterns over repetitive style rebuilds** is designed to avoid.

#### 1. `info-key` / `info-value` re-implemented in every page file

Every page file (`bachelor-cover.typ`, `master-cover.typ`, `bachelor-abstract.typ`, `master-abstract.typ`, ...) defines its own local `info-key` and `info-value` helper functions with slightly different font/size/inset parameters. These are structurally identical — a label cell and a value cell with a bottom border — but copied and parameterised independently in each file.

**cinnabar solution:** `field-theme(...)` is the single, parameterisable factory for this pattern. There is never a reason to define a local `info-key`/`info-value` outside it. Any new page component should instantiate `field-theme` with the required fonts/sizes and use the returned closures.

#### 2. Anonymous masking inline in every renderer

NJU checks `if anonymous and (key in anonymous-info-keys) { "█████" }` inside every individual `info-value` call, duplicated across every page file. The `anonymous-info-keys` list is also redeclared per file with slightly different contents.

**cinnabar solution:** `mask-field(value, anonymous)` in `utils.typ` is the single masking primitive. At Phase 5, when the `documentclass`-style factory is introduced, the anonymous key list should be resolved once at factory level and not repeated in every component.

#### 3. Title normalisation repeated in every page

Every NJU page file contains the same two lines:

```typst
if type(info.title) == str { info.title = info.title.split("\n") }
info.title = info.title + range(min-title-lines - info.title.len()).map(_ => "　")
```

**cinnabar solution:** `join-by-sep` handles the string→array unification. A dedicated `normalise-title(title, min-lines)` utility should be added to `utils.typ` to handle the padding step, so no component ever repeats this pattern inline.

#### 4. `double-underline` and `invisible-heading` duplicated between packages

NJU implements these independently in `utils/double-underline.typ` and `utils/invisible-heading.typ`. cinnabar already has both (`double-underline`, `hidden-heading`). These must remain in `components.typ` and be the sole canonical implementations — not re-implemented per page.

#### 5. Bold handling scattered across packages

NJU depends on `@preview/cuti:0.4.0` and wraps it in `utils/custom-cuti.typ` (which is a thin re-export). Multiple page files import `fakebold` directly. The [`zh-format`](https://github.com/KercyDing/zh-format) package (`@preview/zh-format`) provides a more complete and principled replacement:

| Feature | cuti / custom-cuti | zh-format |
|---|---|---|
| CJK bold | stroke via `fakebold` | stroke via `setup-bold` show rule |
| CJK italic | not handled | `skew(-18deg)` via `setup-emph` |
| Underline | not handled | improved underline + `u(width:)` |
| Activation | per-call `fakebold(...)` | `show: zh-format` document-level |

**cinnabar plan:** Replace the per-call `fakebold` dependency with `show: zh-format` activated at the document root in examples. The library itself (`components.typ`, `utils.typ`) should not depend on either package — bold is a document-level concern, not a component-level concern.

#### 6. `justify-text` — a missing utility

NJU's `utils/justify-text.typ` fills a genuine gap: CJK label cells (e.g. "学　　院", "指导教师") traditionally justify their characters to equal width. NJU implements this as:

```typst
stack(dir: ltr, spacing: 1fr, ..body.split("").filter(it => it != ""))
```

This is currently handled in CN-Kit by inserting ideographic spaces manually (`"学　　院"`). A `justify-text(body, with-tail)` utility should be added to `utils.typ` to replace all manual spacing.

#### 7. `datetime-display` — English variant missing

CN-Kit's `format-date` only handles Chinese format. NJU provides both `datetime-display` (Chinese) and `datetime-en-display` (English, `"[month repr:short] [day], [year]"`). The English variant is needed for `abstract-en`. It should be added to `utils.typ`.

---

The repository [`nju-lug/modern-nju-thesis`](https://github.com/nju-lug/modern-nju-thesis) (cloned to `../ai/modern-nju-thesis/`) is the most mature public Typst thesis template for a Chinese university. It serves as the primary reference implementation for cinnabar's Phase 3–5 work. Key insights and anti-patterns are distilled below.

### Overall architecture pattern: `documentclass` closure

NJU thesis uses a single `documentclass(...)` factory function that accepts all global document configuration (doctype, fonts, info dict, anonymous flag, twoside flag) and returns a dictionary of pre-configured page functions. This is the same factory/closure pattern CN-Kit uses for `field-theme`, applied at document scale.

```text
documentclass(doctype: "bachelor", anonymous: false, info: (...))
  → { cover, decl-page, abstract, abstract-en, outline-page,
      list-of-figures, list-of-tables, acknowledgement,
      preface, mainmatter, appendix, bilingual-bibliography, ... }
```

**Implication for cinnabar (Phase 5):** A top-level `thesis(...)` factory should be introduced that wraps individual components into a single coherent document API, removing the need for users to pass `fonts`, `anonymous`, and `twoside` to every component separately.

### Layout layers

NJU thesis separates page-level layout concerns into four `layouts/` files:

| Layout | Purpose |
|---|---|
| `doc.typ` | Global document settings: page margins, lang, PDF metadata |
| `preface.typ` | Resets page counter to 0, sets Roman numeral page numbering |
| `mainmatter.typ` | Switches to Arabic numerals, applies heading styles, headers/footers, figure numbering |
| `appendix.typ` | Appendix-specific heading numbering |

**Implication for cinnabar (Phase 3):** The `thesis-page` setup function should be split into at least `doc`, `preface`, and `mainmatter` layers rather than a single monolithic function.

### Font and size system

NJU thesis defines all fonts and sizes in `utils/style.typ` as named dictionaries (`字体`, `字号`). Fonts are specified as fallback arrays with `covers: "latin-in-cjk"` to prevent Latin glyphs from being rendered in CJK fonts:

```typst
宋体: ((name: "Times New Roman", covers: "latin-in-cjk"), "Source Han Serif SC", "SimSun", ...)
字号: (小四: 12pt, 四号: 14pt, 三号: 16pt, 小二: 18pt, 一号: 26pt, ...)
```

**Implication for cinnabar:** Replace bare font name strings (`"SimSun"`, `"KaiTi"`) with fallback arrays using `covers: "latin-in-cjk"`. Introduce a `utils/style.typ` equivalent for font and size constants.

### Heading system

`utils/custom-numbering.typ` provides a `custom-numbering` function that maps heading levels to different numbering formats:

- Level 1: `第一章` (Chinese ordinal chapter)
- Level 2+: `1.1` (Arabic dotted)

`utils/custom-heading.typ` provides `active-heading` and `current-heading` context queries used to populate running headers with the current chapter and section titles.

**Implication for cinnabar (Phase 3):** The heading numbering system must support at minimum the `第X章` pattern for level 1 and `X.X` for deeper levels, with a `custom-numbering` utility analogous to NJU's.

### Page numbering convention

- `preface` layout: Roman numerals (`I`, `II`, ...), counter reset to 0 before front matter
- `mainmatter` layout: Arabic numerals (`1`, `2`, ...), counter reset to 1

This is the standard convention required by GB/T 7713 and virtually all Chinese universities.

### Table of contents

`pages/bachelor-outline-page.typ` uses `show outline.entry` to style TOC entries per heading level, with:

- Dot leaders via `repeat([.], gap: 0.15em)` filling the space between title and page number
- Per-level font/size (黑体 for level 1, 宋体 for level 2+)
- Per-level vertical spacing (`above`, `below`)
- Indent computed as a cumulative sum of per-level indent values

**Implication for cinnabar (Phase 2):** The TOC component should replicate this `show outline.entry` approach with configurable per-level font, size, and spacing arrays.

### Anonymization design

NJU thesis passes a list of `anonymous-info-keys` (e.g. `("author", "supervisor", "grade")`) and checks membership at render time rather than pre-masking strings. This is more flexible than cinnabar's current `mask-field` call per field — it allows the anonymous key list itself to be overridden by callers.

**Implication for cinnabar:** Consider adopting key-list-based anonymization in the `documentclass`-level factory (Phase 5), while keeping the current `mask-field` utility for standalone component use.

### Bilingual bibliography (GB/T 7714-2015)

`utils/bilingual-bibliography.typ` post-processes rendered bibliography entries using `show grid.cell` rules and regex replacement to translate Chinese volume/edition/translator markers into English equivalents for non-Chinese entries. This allows a single `.bib` file to produce correctly formatted bilingual reference lists.

**Implication for cinnabar (Phase 3):** Rather than reimplementing this, cinnabar should wrap or re-export `bilingual-bibliography` from NJU thesis (or an equivalent package) as a thin compatibility layer.

### Utilities to study or adopt

| NJU utility | CN-Kit relevance |
|---|---|
| `utils/double-underline.typ` | Already implemented; NJU uses `v(3pt)` gap vs CN-Kit's `gap` parameter |
| `utils/invisible-heading.typ` | Equivalent to CN-Kit's `hidden-heading`; NJU uses `place(hide(...))` |
| `utils/datetime-display.typ` | Equivalent to `format-date`; NJU also provides an English variant |
| `utils/custom-cuti.typ` | `fakebold` wrapper — CN-Kit currently depends on the upstream `cuti` package |
| `utils/justify-text.typ` | CJK text justification helper — relevant for Phase 3 body formatting |
| `utils/hline.typ` | Horizontal rule helper used in headers — relevant for Phase 3 |
| `utils/justify-text.typ` | **Should be adopted into `utils.typ`** — replaces manual ideographic space padding in label cells |
| `utils/datetime-display.typ` | **English variant should be added to `utils.typ`** as `format-date-en` |

### Reference: zh-format

[`zh-format`](https://github.com/KercyDing/zh-format) (`@preview/zh-format`) is the preferred replacement for `cuti`'s `fakebold` in CN-Kit examples. It provides document-level `show` rules for CJK bold (stroke), CJK italic (skew), and improved underline — all activated with a single `show: zh-format` at the document root.

Key functions:

- `setup-bold` — `show text.where(weight: "bold")` rule that applies `stroke: 0.02857em` to CJK characters while leaving Latin bold unchanged
- `setup-emph` — `show emph` rule that applies `skew(ax: -18deg)` to CJK characters and native italic to Latin
- `setup-underline` — improved underline with correct CJK descender handling
- `u(width:, offset:, body)` — fixed-width underline with centred content, useful for form fill-in fields
- `zh-format` — composes all three `show` rules; the single entry point for examples

**Usage in CN-Kit examples:**

```typst
#import "@preview/zh-format:0.1.0": zh-format
#show: zh-format
```

The core library (`components.typ`, `utils.typ`, `lib.typ`) must not import `zh-format` — bold/italic treatment is a document-level concern for the end user, not a component concern.

---

*Package name: **cinnabar** (朱砂) — the red pigment of Chinese official seals and manuscript grids. Formerly `zh-draft`.*
