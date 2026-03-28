// ==================================================
// Atomic Primitives
// ==================================================

// Draws a double underline below content with configurable stroke and spacing.
#let double-underline(body, stroke: 0.5pt + black, gap: 2pt) = context {
  let size = measure(body)
  stack(
    spacing: gap,
    body,
    line(length: size.width, stroke: stroke),
    line(length: size.width, stroke: stroke),
  )
}

// Creates an invisible heading anchor for PDF outlines/bookmarks without
// occupying any space in the rendered layout.
#let hidden-heading(..args) = {
  place(hide(heading(numbering: none, ..args)))
}

// ==================================================
// Field Theme Factory
// ==================================================

// Returns a dictionary of styled cell builders (label, value, row, rows)
// configured with the provided fonts and dimensions. Instantiate once per
// document section and reuse the returned closures inside grid().
#let field-theme(
  font-label: none,
  font-value: none,
  size-label: 12pt,
  size-value: 12pt,
  inset: (x: 0pt, bottom: 2pt),
) = {
  // Base cell renderer shared by label and value.
  // Injects a zero-width KaiTi strut to normalise CJK/Latin baseline alignment.
  let cell-base(content, font: none, size: 12pt, alignment: center, stroke: none) = {
    let strut = box(width: 0pt, hide(text(font: "KaiTi", size: size)[""]))
    rect(
      width: 100%,
      inset: inset,
      stroke: stroke,
      outset: 0pt,
      align(
        alignment,
        if font == none {
          text(size: size, content) + strut
        } else {
          text(font: font, size: size, content) + strut
        },
      ),
    )
  }

  // Renders a static label cell.
  let label(content, alignment: center, stroke: none) = {
    cell-base(content, font: font-label, size: size-label, alignment: alignment, stroke: stroke)
  }

  // Renders a value cell with a bottom border by default.
  let value(content, alignment: center, stroke: none) = {
    let stroke = if stroke == none { (bottom: 0.5pt + black) } else { stroke }
    cell-base(content, font: font-value, size: size-value, alignment: alignment, stroke: stroke)
  }

  // Produces a (label-cell, value-cell) tuple for a single grid row.
  let row(key, val, col-label: 1, col-val: 1, key-args: (:), val-args: (:)) = {
    (
      grid.cell(colspan: col-label, label(key, ..key-args)),
      grid.cell(colspan: col-val, value(val, ..val-args)),
    )
  }

  // Like row, but accepts an array of values and spans multiple rows,
  // padding to at least min-lines rows with ideographic spaces.
  let rows(key, val, min-lines: 2, col-label: 1, col-val: 1, key-args: (:), val-args: (:)) = {
    let vals = if type(val) == str { val.split("\n") } else { val }

    if vals.len() < min-lines {
      vals = vals + range(min-lines - vals.len()).map(_ => "　")
    }

    vals
      .enumerate()
      .map(((index, line)) => {
        if index == 0 {
          row(key, line, col-label: col-label, col-val: col-val, key-args: key-args, val-args: val-args)
        } else {
          row("", line, col-label: col-label, col-val: col-val, key-args: key-args, val-args: val-args)
        }
      })
      .flatten()
  }

  return (
    label: label,
    value: value,
    row: row,
    rows: rows,
  )
}

// ==================================================
// Atomic Page Bricks
// ==================================================

// Renders a section heading centred on the page, optionally double-underlined.
// Used as the title block for abstract, originality, and acknowledgements pages.
#let section-header(
  title,
  font: "SimHei",
  size: 16pt,
  underline: false,
  vspace-before: 1em,
  vspace-after: 1em,
) = {
  align(center)[
    #v(vspace-before)
    #text(font: font, size: size, weight: "bold")[
      #if underline { double-underline(title) } else { title }
    ]
    #v(vspace-after)
  ]
}

// Renders a single bold-label + body paragraph field.
// Used consistently in abstract-zh and abstract-en metadata sections.
#let meta-field(label-str, value-str, body-font: none) = {
  par({
    text(weight: "bold")[#label-str]
    if body-font != none {
      text(font: body-font, value-str)
    } else {
      value-str
    }
  })
}

// Renders a signature row: label | underline box | 日期： | date string.
// Each row is full-width to prevent squashing between author and supervisor.
#let sig-row(label-str, date-str, date-label: "　日期：") = {
  grid(
    columns: (auto, 80pt, auto, 1fr),
    column-gutter: 4pt,
    align(horizon)[#label-str],
    align(bottom)[#line(length: 100%, stroke: 0.5pt)],
    align(horizon)[#date-label],
    align(horizon)[#date-str],
  )
}

// ==================================================
// Cover Page
// ==================================================

// Renders a Chinese undergraduate/graduate thesis cover page.
// Content arguments come first; configuration arguments follow.
#let cover(
  // --- Content ---
  title: (),
  author: none,
  student-id: none,
  grade: none,
  department: none,
  major: none,
  supervisor: (),
  supervisor-ii: none,
  submit-date: datetime.today(),
  // --- Configuration ---
  anonymous: false,
  twoside: false,
  min-title-lines: 2,
  fonts: (
    title: "SimSun",
    key: "KaiTi",
    value: "SimSun",
  ),
  sizes: (
    title: 26pt,
    key: 16pt,
    value: 16pt,
  ),
) = {
  import "utils.typ": format-date, mask-field, normalise-title

  let title-lines = normalise-title(title, min-lines: min-title-lines)
  let date        = format-date(submit-date)
  let safe-author = mask-field(author, anonymous)
  let safe-id     = mask-field(student-id, anonymous)
  let safe-grade  = mask-field(grade, anonymous)

  let theme = field-theme(
    font-label: fonts.key,
    font-value: fonts.value,
    size-label: sizes.key,
    size-value: sizes.value,
  )

  pagebreak(weak: true, to: if twoside { "odd" })
  set align(center + horizon)

  block(width: 100%, height: 100%)[
    #text(size: sizes.title, font: fonts.title, weight: "bold")[毕 业 论 文]

    #v(60pt)

    #block(width: 320pt)[
      #grid(
        columns: (72pt, 1fr, 72pt, 1fr),
        column-gutter: 0pt,
        row-gutter: 12pt,

        ..(theme.row)("院　　系", department,  col-val: 3),
        ..(theme.row)("专　　业", major,        col-val: 3),
        ..(theme.rows)("题　　目", title-lines, col-val: 3),
        ..(theme.row)("年　　级", safe-grade),
        ..(theme.row)("学　　号", safe-id),
        ..(theme.row)("学生姓名", safe-author,  col-val: 3),
        ..(theme.row)("指导教师", supervisor.at(0)),
        ..(theme.row)("职　　称", supervisor.at(1)),
        ..if supervisor-ii != none {
          (
            (theme.row)("第二导师", supervisor-ii.at(0)),
            (theme.row)("职　　称", supervisor-ii.at(1)),
          ).flatten()
        } else { () },
        ..(theme.row)("提交日期", date, col-val: 3),
      )
    ]
  ]
}

// ==================================================
// Abstract (shared brick)
// ==================================================

// Internal brick: renders the shared structure of any abstract page.
// Both abstract-zh and abstract-en are thin callers of this.
#let _abstract-page(
  // processed strings
  title-str,
  author-str,
  department-str,
  major-str,
  supervisor-str,
  supervisor-ii-str,
  keyword-str,
  body,
  // labels (localised by caller)
  labels: (
    title: "题目：",
    department: "院系：",
    major: "专业：",
    author: "本科生姓名：",
    supervisor: "指导教师（姓名、职称）：",
    abstract: "摘要：",
    keywords: "关键词：",
  ),
  // layout config
  twoside: false,
  outline-title: "摘要",
  outlined: true,
  header-title: "摘要",
  header-underline: true,
  fonts: (
    header: "KaiTi",
    label: "KaiTi",
    body: "SimSun",
  ),
  sizes: (
    header: 18pt,
    body: 12pt,
  ),
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  set text(font: fonts.label, size: sizes.body)
  set par(leading: 1.3em, spacing: 1.2em, justify: true)

  hidden-heading(outline-title, outlined: outlined)

  section-header(
    header-title,
    font: fonts.header,
    size: sizes.header,
    underline: header-underline,
  )

  meta-field(labels.title, title-str, body-font: fonts.body)
  meta-field(labels.department, department-str, body-font: fonts.body)
  meta-field(labels.major, major-str, body-font: fonts.body)
  meta-field(labels.author, author-str, body-font: fonts.body)

  par({
    text(weight: "bold")[#labels.supervisor]
    text(font: fonts.body, {
      supervisor-str
      if supervisor-ii-str != none { h(1em); supervisor-ii-str }
    })
  })

  v(0.5em)
  text(weight: "bold")[#labels.abstract]
  {
    set par(first-line-indent: 2em)
    set text(font: fonts.body)
    body
  }

  v(1em)
  text(weight: "bold")[#labels.keywords]
  text(font: fonts.body)[#keyword-str]
}

// ==================================================
// Chinese Abstract
// ==================================================

// Renders a Chinese-language abstract page (中文摘要).
#let abstract-zh(
  // --- Content ---
  title: none,
  author: none,
  department: none,
  major: none,
  supervisor: (),
  supervisor-ii: none,
  keywords: (),
  body,
  // --- Configuration ---
  anonymous: false,
  twoside: false,
  outline-title: "中文摘要",
  outlined: true,
  fonts: (
    header: "KaiTi",
    label: "KaiTi",
    body: "SimSun",
  ),
  sizes: (
    header: 18pt,
    body: 12pt,
  ),
) = {
  import "utils.typ": join-by-sep, mask-field

  _abstract-page(
    join-by-sep(title),
    mask-field(author, anonymous),
    department,
    major,
    mask-field(supervisor.at(0) + supervisor.at(1), anonymous),
    if supervisor-ii != none { mask-field(supervisor-ii.at(0) + supervisor-ii.at(1), anonymous) } else { none },
    join-by-sep(keywords, separator: "；"),
    body,
    labels: (
      title: "题目：",
      department: "院系：",
      major: "专业：",
      author: "本科生姓名：",
      supervisor: "指导教师（姓名、职称）：",
      abstract: "摘要：",
      keywords: "关键词：",
    ),
    twoside: twoside,
    outline-title: outline-title,
    outlined: outlined,
    header-title: [中文摘要],
    header-underline: true,
    fonts: fonts,
    sizes: sizes,
  )
}

// ==================================================
// English Abstract
// ==================================================

// Renders an English-language abstract page.
#let abstract-en(
  // --- Content ---
  title: none,
  author: none,
  department: none,
  major: none,
  supervisor: (),
  supervisor-ii: none,
  keywords: (),
  body,
  // --- Configuration ---
  anonymous: false,
  twoside: false,
  outline-title: "English Abstract",
  outlined: true,
  fonts: (
    header: "Times New Roman",
    label: "Times New Roman",
    body: "Times New Roman",
  ),
  sizes: (
    header: 18pt,
    body: 12pt,
  ),
) = {
  import "utils.typ": join-by-sep, mask-field

  _abstract-page(
    join-by-sep(title, separator: " "),
    mask-field(author, anonymous),
    department,
    major,
    mask-field(supervisor.at(0) + " (" + supervisor.at(1) + ")", anonymous),
    if supervisor-ii != none { mask-field(supervisor-ii.at(0) + " (" + supervisor-ii.at(1) + ")", anonymous) } else { none },
    join-by-sep(keywords, separator: "; "),
    body,
    labels: (
      title: "Title: ",
      department: "Department: ",
      major: "Major: ",
      author: "Author: ",
      supervisor: "Supervisor: ",
      abstract: "Abstract: ",
      keywords: "Keywords: ",
    ),
    twoside: twoside,
    outline-title: outline-title,
    outlined: outlined,
    header-title: [Abstract],
    header-underline: true,
    fonts: fonts,
    sizes: sizes,
  )
}

// ==================================================
// Originality Statement (声明页)
// ==================================================

// Renders the statement of originality required by most Chinese universities.
// Uses sig-row atomic brick for signature lines.
#let originality(
  // --- Content ---
  author: none,
  title: none,
  sign-date: none,
  supervisor: none,
  supervisor-sign-date: none,
  // --- Configuration ---
  anonymous: false,
  twoside: false,
  outline-title: "原创性声明",
  outlined: true,
  fonts: (
    header: "SimHei",
    body: "SimSun",
  ),
  sizes: (
    header: 16pt,
    body: 12pt,
  ),
) = {
  import "utils.typ": format-date, join-by-sep, mask-field

  let title-str        = join-by-sep(title)
  let safe-author      = mask-field(author, anonymous)
  let safe-sup         = mask-field(supervisor, anonymous)
  let sign-date-str    = if sign-date != none { format-date(sign-date) } else { "　　年　　月　　日" }
  let sup-date-str     = if supervisor-sign-date != none { format-date(supervisor-sign-date) } else { "　　年　　月　　日" }

  pagebreak(weak: true, to: if twoside { "odd" })

  set text(font: fonts.body, size: sizes.body)
  set par(leading: 1.5em, spacing: 1.2em, justify: true)

  hidden-heading(outline-title, outlined: outlined)
  section-header("原创性声明", font: fonts.header, size: sizes.header)

  par(first-line-indent: 2em)[
    本人声明所呈交的学位论文《#title-str》是本人在导师指导下进行的研究工作及取得的研究成果。据我所知，除了文中特别加以标注和致谢的地方外，论文中不包含其他人已经发表或撰写过的研究成果，也不包含为获得其他教育机构的学位或证书而使用过的材料。与我一同工作的同志对本研究所做的任何贡献均已在论文中作了明确的说明并表示谢意。
  ]

  v(1em)
  sig-row("论文作者签名：", sign-date-str)
  v(1.5em)
  sig-row("导师签名：", sup-date-str)
}

// ==================================================
// Acknowledgements (致谢)
// ==================================================

// Renders the acknowledgements section (致谢).
// Uses section-header atomic brick for the centred title.
#let acknowledgements(
  body,
  // --- Configuration ---
  twoside: false,
  outline-title: "致谢",
  outlined: true,
  fonts: (
    header: "SimHei",
    body: "SimSun",
  ),
  sizes: (
    header: 16pt,
    body: 12pt,
  ),
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  set text(font: fonts.body, size: sizes.body)
  set par(leading: 1.5em, spacing: 1.2em, justify: true)

  hidden-heading(outline-title, outlined: outlined)
  section-header("致谢", font: fonts.header, size: sizes.header)

  {
    set par(first-line-indent: 2em)
    body
  }
}

// ==================================================
// Table of Contents
// ==================================================

// Renders a styled table of contents page.
// Per-level arrays control font, size, and vertical spacing.
// Uses section-header atomic brick for the page title.
// Dot leaders and page numbers handled by native outline.entry.inner().
#let outline-page(
  // --- Configuration ---
  twoside: false,
  title: "目　　录",
  outlined: false,
  depth: 4,
  title-vspace: 0pt,
  // Per-level font (index 0 = level 1). Last entry used for deeper levels.
  font: ("SimHei", "SimSun"),
  size: (14pt, 12pt),
  above: (25pt, 14pt),
  below: (14pt, 14pt),
  title-font: "SimSun",
  title-size: 16pt,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  section-header(
    title,
    font: title-font,
    size: title-size,
    underline: false,
    vspace-before: 0pt,
    vspace-after: 0pt,
  )
  hidden-heading(level: 1, outlined: outlined, title)

  v(title-vspace)

  set outline.entry(fill: repeat([.], gap: 0.15em))

  show outline.entry: entry => {
    set block(
      above: above.at(entry.level - 1, default: above.last()),
      below: below.at(entry.level - 1, default: below.last()),
    )
    set text(
      font: font.at(entry.level - 1, default: font.last()),
      size: size.at(entry.level - 1, default: size.last()),
    )
    link(entry.element.location(), entry.indented(entry.prefix(), entry.inner()))
  }

  outline(title: none, depth: depth, indent: auto)
}
