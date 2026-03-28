# Publishing to Typst Universe — cinnabar

A concise reference for submitting cinnabar (or any package) to [Typst Universe](https://typst.app/universe/).

---

## Pre-submission Checklist

Before opening a pull request, confirm all of the following:

- [ ] Package is useful to other users and exposes its capabilities clearly
- [ ] Package name follows the naming rules (see below)
- [ ] All `.typ` files and `typst.toml` are free of syntax errors
- [ ] Package imports without errors
- [ ] `README.md` exists, documents the purpose, and includes examples
- [ ] Examples in the README compile and are up to date (version numbers match)
- [ ] `LICENSE` file is present and matches the SPDX expression in `typst.toml`
- [ ] No copyrighted material included without distribution rights
- [ ] Package does not contain unnecessarily large files
- [ ] `docs/` images and PDF files are excluded from the bundle via `typst.toml` `exclude`
- [ ] No attempts to exploit the compiler or exfiltrate user data

---

## Naming Rules

- Do **not** use the obvious/canonical name for the functionality (e.g. `slides` is forbidden; `slitastic` is fine). This prevents unfair name squatting.
- Do **not** include the word `typst` in the name (redundant).
- Use `kebab-case` for multi-word names.
- For **template packages**: name must have a unique non-descriptive part followed by a descriptive part, e.g. `eternal-ajp` for an AJP template. The bare entity name (e.g. `ajp`) is reserved for the official package.

---

## `typst.toml` Requirements

### Required by the compiler

```toml
[package]
name = "cinnabar"
version = "0.1.0"          # full major.minor.patch — follow SemVer
entrypoint = "lib.typ"
```

### Required for Typst Universe submission

```toml
authors = ["Your Name <handle@example.com>"]
license = "MIT"            # valid SPDX-2 expression
description = "Composable primitives for Chinese formal documents."
```

**Description guidelines:**

- 40–60 characters ideally; end with a full stop
- Avoid the word "Typst" and the word "package"
- Use imperative mood: `Draw Venn diagrams.` not `A package for drawing Venn diagrams.`

### Useful optional fields

| Field | Purpose |
|---|---|
| `repository` | Link to source repo (shown on Universe if no `homepage`) |
| `keywords` | Searchable tags |
| `categories` | Up to 3 categories from the Universe category list |
| `disciplines` | Target academic disciplines (omit if generally applicable) |
| `compiler` | Minimum required Typst version (e.g. `"0.14.0"`) |
| `exclude` | Globs for files to omit from the download bundle |

### What to exclude

Use `exclude` to keep the download bundle small. Exclude:

- `example/` — usage examples not needed at import time
- `img/`, `docs/` — README images and documentation PDFs
- Thumbnail images

Do **not** exclude `README.md` or `LICENSE`.

```toml
exclude = ["example/", "img/", "docs/"]
```

---

## Writing Typst Files

- Recommended style: **2-space indent**, **kebab-case** names (this project already follows both).
- In example files, use the full package import — not a relative path:

```typ
#import "@preview/cinnabar:0.1.0": *
```

Relative imports (`../lib.typ`) are acceptable inside the package itself but must not appear in example or template files intended for end users.

### Controlling public API

`lib.typ` should explicitly re-export only the symbols intended to be public. Anything not re-exported remains private to the package. CN-Kit already follows this pattern.

---

## Fonts

Fonts **cannot** be shipped inside a package. If the package requires specific fonts (e.g. KaiTi, SimSun), document how to install them. Users must supply fonts via the Typst web app font uploader or the `--font-path` CLI flag.

---

## Images and Assets

File paths in Typst are resolved relative to the file that calls `image()`, `json()`, etc. — not relative to the user's project. Consequences:

- A template **cannot** let users swap an image by providing a path string. Instead, accept `content` directly:

```typ
// Do this:
#let cover-page(logo: image("logo.png"), title) = { logo; heading(title) }

// Not this:
#let cover-page(logo-path: "logo.png", title) = { image(logo-path); heading(title) }
```

---

## Licensing

- Must use an OSI-approved license or CC-BY / CC-BY-SA / CC0.
- The SPDX expression in `typst.toml` must match the `LICENSE` file.
- The copyright year and author name in `LICENSE` must be correct.
- If template files could be considered derivative works after normal use, consider licensing the `template/` directory under MIT-0 or Zero-Clause BSD (no attribution required) and document the distinction in `README.md`.

CN-Kit currently uses the **MIT** license, which satisfies all requirements.

---

## Submission Process

1. Fork the [typst/packages](https://github.com/typst/packages) repository (sparse checkout recommended).
2. Create the directory `packages/preview/cinnabar/0.x.x/`.
3. Copy all package files (excluding anything listed in `typst.toml` `exclude`).
4. Open a pull request. The submitter must be the same person as the author of the previous version.
5. After the PR is merged and CI completes, the package becomes importable. It may take up to 30 minutes to appear on Typst Universe.

---

## Current Gaps (CN-Kit vs. Requirements)

| Requirement | Status | Action needed |
|---|---|---|
| `README.md` has examples | Partial — no compiled example output shown | Add rendered screenshots or code snippets with output |
| Example files use absolute package import | Not met — examples use `../lib.typ` | Update to `@preview/cinnabar:x.x.x` before submission |
| `repository` field in `typst.toml` | Missing — only a base URL is present | Add full repository URL |
| `categories` / `disciplines` | Not set | Add relevant categories (e.g. `office`, `paper`) |
| Version is `0.0.1` | Fine for now | Bump when ready to publish |
