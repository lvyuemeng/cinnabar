#import "../lib.typ": *

// ==========================================================
// primitives.typ — Atomic brick showcase
// All cinnabar primitives demonstrated on a single page.
// field-theme · section-header · meta-field · sig-row
// double-underline · justify-text · fill-lines · 字号 · 字体
// ==========================================================

#set page(paper: "a4", margin: (x: 3cm, top: 3cm, bottom: 2.5cm))

// ----------------------------------------------------------
// 1. field-theme — label / value / row / rows factory
// ----------------------------------------------------------

#section-header("1. field-theme", font: 字体.黑体, size: 字号.三号, underline: false)

#let theme = field-theme(
  font-label: 字体.楷体,
  font-value: 字体.宋体,
  size-label: 字号.小四,
  size-value: 字号.小四,
)

#grid(
  columns: (72pt, 1fr, 72pt, 1fr),
  column-gutter: 0pt,
  row-gutter: 10pt,
  ..(theme.row)("姓　　名", "张三"),
  ..(theme.row)("学　　号", "20210001"),
  ..(theme.rows)("题　　目", ("基于 Typst 的", "模块化论文系统"), col-val: 3),
)

#v(2em)

// ----------------------------------------------------------
// 2. section-header — centred page title brick
// ----------------------------------------------------------

#section-header("2. section-header (plain)", font: 字体.黑体, size: 字号.三号, underline: false)
#section-header("2b. section-header (double-underline)", font: 字体.楷体, size: 字号.小二, underline: true)

#v(1em)

// ----------------------------------------------------------
// 3. meta-field — bold label + body paragraph
// ----------------------------------------------------------

#section-header("3. meta-field", font: 字体.黑体, size: 字号.三号, underline: false)

#meta-field("题目：", "基于 Typst 的模块化论文排版系统设计与实现", body-font: 字体.宋体)
#meta-field("院系：", "计算机科学与技术学院", body-font: 字体.宋体)
#meta-field("关键词：", "Typst；排版系统；模块化；论文模板", body-font: 字体.宋体)

#v(2em)

// ----------------------------------------------------------
// 4. sig-row — signature line with underline and date
// ----------------------------------------------------------

#section-header("4. sig-row", font: 字体.黑体, size: 字号.三号, underline: false)

#sig-row("论文作者签名：", "2025年06月01日")
#v(1.5em)
#sig-row("导师签名：", "　　年　　月　　日")

#v(2em)

// ----------------------------------------------------------
// 5. double-underline — standalone heading primitive
// ----------------------------------------------------------

#section-header("5. double-underline", font: 字体.黑体, size: 字号.三号, underline: false)

#align(center)[
  #text(font: 字体.楷体, size: 字号.小二, weight: "bold")[
    #double-underline[南京大学本科生毕业论文中文摘要]
  ]
]

#v(2em)

// ----------------------------------------------------------
// 6. justify-text — character-distributed CJK label
// ----------------------------------------------------------

#section-header("6. justify-text", font: 字体.黑体, size: 字号.三号, underline: false)

// tail defaults to "：" — no flag needed
#grid(
  columns: (80pt, 1fr),
  gutter: 10pt,
  row-gutter: 8pt,
  text(font: 字体.楷体, size: 字号.小四)[#justify-text("姓名")],
  text(font: 字体.宋体, size: 字号.小四)[张三],
  text(font: 字体.楷体, size: 字号.小四)[#justify-text("指导教师")],
  text(font: 字体.宋体, size: 字号.小四)[李四 教授],
  text(font: 字体.楷体, size: 字号.小四)[#justify-text("所在院系")],
  text(font: 字体.宋体, size: 字号.小四)[计算机科学与技术学院],
)

// tail: none — no suffix, just distributed characters
#grid(
  columns: (80pt, 1fr),
  gutter:	10pt,
  row-gutter: 8pt,
  text(font: 字体.楷体, size: 字号.小四)[#justify-text("姓名", tail: none)],
  text(font: 字体.宋体, size: 字号.小四)[张三（无尾缀）],
)

#v(2em)

// ----------------------------------------------------------
// 7. fill-lines — pad title array for grid rows
// ----------------------------------------------------------

#section-header("7. fill-lines — pad title array for grid rows", font: 字体.黑体, size: 字号.三号, underline: false)

// fill-lines pads a string or array to min-lines entries with ideographic spaces.
// Use .. to spread the result directly into a grid as multiple row cells.

// String input — split on "\n", padded to 3 lines
#let lines-from-str = fill-lines("第一行\n第二行", min-lines: 3)
// Array input — padded to 3 lines
#let lines-from-arr = fill-lines(("第一行", "第二行"), min-lines: 3)

// Without fill-lines: title array used as-is in one cell
#text(font: 字体.楷体, size: 字号.小四)[Without (2 items, joined):] \
#grid(
  columns: (120pt, 1fr),
  row-gutter: 6pt,
  text(font: 字体.楷体, size: 字号.小四)[题　　目],
  text(font: 字体.宋体, size: 字号.小四)[第一行 第二行（joined）],
)

#v(0.8em)

// With fill-lines: spread into 3 separate grid rows
#text(font: 字体.楷体, size: 字号.小四)[With fill-lines (string → 3 rows, ..spread):] \
#grid(
  columns: (120pt, 1fr),
  row-gutter: 6pt,
  text(font: 字体.楷体, size: 字号.小四)[题　　目], ..lines-from-str,
)

#v(0.8em)

// Array input also padded to 3 rows
#text(font: 字体.楷体, size: 字号.小四)[With fill-lines (array → 3 rows, ..spread):] \
#grid(
  columns: (120pt, 1fr),
  row-gutter: 6pt,
  text(font: 字体.楷体, size: 字号.小四)[题　　目], ..lines-from-arr,
)

#v(2em)

// ----------------------------------------------------------
// 8. 字号 / 字体 — style constants
// ----------------------------------------------------------

#section-header("8. 字号 / 字体 constants", font: 字体.黑体, size: 字号.三号, underline: false)

#for (name, size) in (
  ("小二 (18pt)", 字号.小二),
  ("三号 (16pt)", 字号.三号),
  ("四号 (14pt)", 字号.四号),
  ("小四 (12pt)", 字号.小四),
  ("五号 (10.5pt)", 字号.五号),
) {
  par(text(font: 字体.宋体, size: size)[#name — The quick brown fox 快速的棕色狐狸])
}
