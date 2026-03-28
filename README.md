# cinnabar

**cinnabar** is a [Typst](https://typst.app) library of composable primitives and utilities for typesetting Chinese formal documents — thesis covers, abstracts, originality statements, acknowledgements, and more.

The name comes from 朱砂 (zhūshā), the red cinnabar pigment used on Chinese official seals and the ruled grids of traditional manuscript paper.

## Features

- `field-theme` — factory that returns configurable label/value cell builders for structured form layouts
- `cover` — Chinese undergraduate/graduate thesis cover page
- `abstract-zh` — Chinese abstract page with metadata fields and keyword list
- `abstract-en` — English abstract page
- `originality` — 原创性声明 (statement of originality) with signature lines
- `acknowledgements` — 致谢 section
- `double-underline`, `hidden-heading` — atomic layout primitives
- `format-date`, `mask-field`, `join-by-sep` — pure utility functions

## Usage

```shell
git clone <repo> <path>
# or
git submodule add <path> <repo>
```

```typst
#import "<path>/lib.typ": *
```

Once published to Typst Universe:

```typst
#import "@preview/cinnabar:0.1.0": *
```

## Anonymous / blind-review mode

Pass `anonymous: true` to any component to replace all identifying fields (author, student ID, supervisor) with block-character masks.

## License

[MIT License](LICENCE)
