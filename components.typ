// ==================================================
// Style Constants
// ==================================================

#let font-size = (
  h0: 42pt, h0s: 36pt, h1: 26pt, h1s: 24pt,
  h2: 22pt, h2s: 18pt, h3: 16pt, h3s: 15pt,
  h4: 14pt, h4m: 13pt, h4s: 12pt, h5: 10.5pt, h5s: 9pt,
)

#let font-family = (
  serif:  ((name: "Times New Roman", covers: "latin-in-cjk"), "Source Han Serif SC", "Noto Serif CJK SC", "SimSun", "Songti SC"),
  sans:   ((name: "Arial",           covers: "latin-in-cjk"), "Source Han Sans SC",  "Noto Sans CJK SC",  "SimHei", "Heiti SC"),
  kai:    ((name: "Times New Roman", covers: "latin-in-cjk"), "KaiTi", "Kaiti SC", "STKaiti"),
  fang:   ((name: "Times New Roman", covers: "latin-in-cjk"), "FangSong", "FangSong SC", "STFangSong"),
  mono:   ((name: "Courier New",     covers: "latin-in-cjk"), "Source Han Sans HW SC", "Noto Sans Mono CJK SC", "SimHei"),
)

// ==================================================
// Data Helpers
// ==================================================

// Returns block-character mask if anonymous, otherwise returns value.
#let mask-field(value, anonymous, length: 5) = {
  if anonymous { "█" * length } else { value }
}

// Normalises string/array title and pads to minimum rows.
#let fill-lines(title, min-lines: 2) = {
  let lines = if type(title) == str { title.split("\n") } else { title }
  if lines.len() < min-lines {
    lines + range(min-lines - lines.len()).map(_ => "　")
  } else {
    lines
  }
}

// ==================================================
// Primitives
// ==================================================

// Double line under content, measured to content width.
#let double-underline(body, stroke: 0.5pt + black, gap: 2pt) = context {
  let w = measure(body).width
  stack(spacing: gap, body, line(length: w, stroke: stroke), line(length: w, stroke: stroke))
}

// Invisible heading anchor for PDF outlines/bookmarks.
#let hidden-heading(..args) = {
  place(hide(heading(numbering: none, ..args)))
}

// Distributes CJK characters with equal 1fr spacing.
// tail: optional suffix (e.g. "："). Pass none to omit.
#let distribute-chars(body, width: auto, tail: none, ..text-args) = {
  let chars = body.clusters().map(c => text(..text-args, c))
  let inner = block(width: width, stack(dir: ltr, spacing: 1fr, ..chars))
  if tail != none { stack(dir: ltr, inner, tail) } else { inner }
}

#let full_underline(stroke: 0.5pt, ..lines) = {
  for line in lines.pos() {
    block(
      width: 100%,
      stroke: (bottom: stroke),
      inset: (bottom: 4pt), // Distance from text to line
      outset: (bottom: 2pt), // Adjusts line position without moving text
      line
    )
  }
}

// ==================================================
// Functional Bricks
// ==================================================

// Show-rule: auto-converts table to three-line format.
#let three-line-table(it) = {
  if it.children.any(c => c.func() == table.hline) { return it }

  let header = it.children.find(c => c.func() == table.header)
  let cells = it.children.filter(c => c.func() == table.cell)

  if header == none {
    let cols = if type(it.columns) == int { it.columns } else { it.columns.len() }
    header = table.header(..cells.slice(0, cols))
    cells = cells.slice(cols)
  }

  table(
    columns: it.columns,
    stroke: none,
    table.hline(stroke: 1.5pt),
    header,
    table.hline(stroke: 0.75pt),
    ..cells,
    table.hline(stroke: 1.5pt),
  )
}

// ==================================================
// Factory
// ==================================================

// Returns (label, value, row, rows) closure dict for grid-based info layouts.
// decorate-label: styling function applied to label rect.
// decorate-value: styling function applied to value rect.
#let field-theme(
  decorate-label: content => rect(width: 100% ,stroke: none, content),
  decorate-value: content => rect(width: 100% ,stroke: (bottom: 0.5pt + black), content),
) = {
  let label(content) = { decorate-label(content) }

  let value(content) = { decorate-value(content) }

  let row(key, val, col-label: 1, col-val: 1) = {
    (
      grid.cell(colspan: col-label, label(key)),
      grid.cell(colspan: col-val,   value(val)),
    )
  }

  let rows(key, val, min-lines: 2, col-label: 1, col-val: 1) = {
    fill-lines(val, min-lines: min-lines)
      .enumerate()
      .map(((i, line)) => row(
        if i == 0 { key } else { "" },
        line,
        col-label: col-label, col-val: col-val,
      ))
      .flatten()
  }

  (label: label, value: value, row: row, rows: rows)
}
