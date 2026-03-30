#import "../lib.typ": *

// ==========================================================
// example.typ — Complete cinnabar showcase
//
// Demonstrates every public export from lib.typ in document order:
//   Part 1: Document setup (page, typography, headings, numbering)
//   Part 2: Atomic bricks (every component in components.typ)
//   Part 3: Preset pages (cover, abstract, originality, TOC, acknowledgements)
//
// Compile: typst compile example/example.typ
// ==========================================================

// ----------------------------------------------------------
// Shared document data
// ----------------------------------------------------------

#let info = (
  title-zh:    ("基于 Typst 的模块化论文排版系统", "设计与实现"),
  title-en:    "Modular Thesis Typesetting System Based on Typst",
  author-zh:   "张三",
  author-en:   "Zhang San",
  student-id:  "20210001",
  grade:       "2021",
  department-zh: "计算机科学与技术学院",
  department-en: "School of Computer Science and Technology",
  major-zh:    "计算机科学与技术",
  major-en:    "Computer Science and Technology",
  supervisor:     ("李四", "教授"),
  supervisor-en:  ("Li Si", "Professor"),
  supervisor-ii:     ("王五", "副教授"),
  supervisor-ii-en:  ("Wang Wu", "Associate Professor"),
  keywords-zh: ("Typst", "排版系统", "模块化", "论文模板"),
  keywords-en: ("Typst", "typesetting", "modular design", "thesis template"),
  submit-date: datetime(year: 2025, month: 6, day: 1),
)

// ==========================================================
// Part 1 — Document Setup
// ==========================================================

// Page geometry — author's responsibility, not cinnabar's
#set page(paper: "a4", margin: (x: 89pt, top: 100pt, bottom: 80pt))

// Body font and size. font-family.serif is a fallback array with
// covers: "latin-in-cjk" so Latin glyphs stay in Times New Roman.
#set text(font: font-family.serif, size: font-size.h4s)

// Paragraph rhythm — GB/T 7713: 1.5x line pitch, 2em first-line indent.
#set par(
  leading:           1.5em,
  spacing:           1.5em,
  justify:           true,
  first-line-indent: (amount: 2em, all: true),
)

// Code blocks — scoped to raw elements only
#show raw: set text(font: "MesloLGLDZ Nerd Font Mono", size: font-size.h5)

// Footnotes
#show footnote.entry: set text(font: font-family.serif, size: font-size.h5)

// Heading styles — per-level arrays, fully author-owned
#let hd-font  = (font-family.sans, font-family.sans, font-family.serif)
#let hd-size  = (font-size.h3, font-size.h4, font-size.h4s)
#let hd-above = (24pt, 18pt, 14pt)
#let hd-below = (18pt, 14pt, 10pt)
#let hd-align = (center, auto, auto)

#show heading: it => {
  let i = calc.min(it.level, hd-font.len()) - 1
  set text(
    font:   hd-font.at(i),
    size:   hd-size.at(i),
    weight: if it.level == 1 { "bold" } else { "regular" },
  )
  set block(above: hd-above.at(i), below: hd-below.at(i))
  let al = hd-align.at(i, default: auto)
  if al != auto { set align(al); it } else { it }
}

// Heading numbering — native lambda
#let chapter-nums = ("一","二","三","四","五","六","七","八","九","十")
#set heading(numbering: (..nums) => {
  let n = nums.pos()
  if n.len() == 1 {
    "第" + chapter-nums.at(n.at(0) - 1, default: str(n.at(0))) + "章　"
  } else {
    n.map(str).join(".") + " "
  }
})

// Three-line table (三线表) — applied to all tables
#show table: three-line-table

// Page numbering — independent from typography above
#set page(numbering: "1")
#counter(page).update(1)

// ==========================================================
// Part 2 — Atomic Bricks (components.typ)
// ==========================================================

= 组件手册

== font-size / font-family 常量

`font-size` 和 `font-family` 是具名常量字典，用作 `set`/`show` 规则的共享词汇表。

#v(1em)

#for (name, size) in (
  ("小二 (18pt)", font-size.h2s),
  ("三号 (16pt)", font-size.h3),
  ("四号 (14pt)", font-size.h4),
  ("小四 (12pt)", font-size.h4s),
  ("五号 (10.5pt)", font-size.h5),
) {
  par(text(font: font-family.serif, size: size)[#name — The quick brown fox 快速的棕色狐狸])
}

== field-theme 工厂

`field-theme` 返回 `(label, value, row, rows)` 闭包字典。
配置一次，复用于任何调用方拥有的 `grid()`。

#let theme-sm = field-theme()

4 列布局 — label 占 1 列，value 占 3 列：

#grid(
  columns: (5em, 1fr, 50pt, 1fr),
  ..(theme-sm.row)("姓　　名", "张三", col-val: 3),
  ..(theme-sm.row)("学　　号", "20210001"),
  ..(theme-sm.row)("年　　级", "2021"),
  ..(theme-sm.rows)("题　　目", ("基于 Typst 的", "模块化论文系统"), col-val: 3),
)

#v(1em)

2 列布局 — label 和 value 各占 1 列：
#grid(
  columns: (3em, 1fr),
  ..(theme-sm.row)("姓名", "张三"),
  ..(theme-sm.row)("学号", "20210001"),
  ..(theme-sm.row)("院系", "计算机科学与技术学院"),
)

== double-underline

独立的双下划线原语。

#align(center)[
  #text(font: font-family.kai, size: font-size.h2s, weight: "bold")[
    #double-underline[南京大学本科生毕业论文中文摘要]
  ]
]

== distribute-chars

CJK 字符等距分布。`tail: '：'` 追加尾缀，`tail: none` 纯分布。

#set par(first-line-indent: 0em)
#grid(
  columns: (5em, 1fr),
  gutter: 10pt,
  row-gutter: 8pt,
  text(font: font-family.kai, size: font-size.h4s)[#distribute-chars("姓名", tail: "：")],
  text(font: font-family.serif, size: font-size.h4s)[张三],
  text(font: font-family.kai, size: font-size.h4s)[#distribute-chars("指导教师", tail: "：")],
  text(font: font-family.serif, size: font-size.h4s)[李四 教授],
  text(font: font-family.kai, size: font-size.h4s)[#distribute-chars("所在院系", tail: "：")],
  text(font: font-family.serif, size: font-size.h4s)[计算机科学与技术学院],
  text(font: font-family.kai, size: font-size.h4s)[#distribute-chars("姓名")],
  text(font: font-family.serif, size: font-size.h4s)[张三（无尾缀）],
)

封面标题栏（固定宽度，无尾缀）：

#align(center)[
  #distribute-chars("本科毕业论文", width: 280pt, tail: none, font: font-family.sans, size: font-size.h1, weight: "bold")
]

== full-underline

#set text(size: font-size.h4s)

#full_underline(
  [本设计（论文）要求学生完成以下工作：],
	[1. 调研国内外相关技术的发展现状。],
  [2. 完成开题报告，确定研究方案。],
  [3. 编写测试用例并进行系统测试。],
  [4. 撰写毕业论文。]
)

== three-line-table

`show table: three-line-table` 自动将表格转为三线表格式。
以下表格自动应用（无需手动设置 hline）。

#figure(
  caption: [NJU 模式 vs. cinnabar 等价写法],
  table(
    columns: (auto, 1fr, 1fr),
    table.header([*NJU 模式*], [*NJU 写法*], [*cinnabar 等价*]),
    [局部辅助函数],
    [`info-key` / `info-value`],
    [`field-theme` 工厂],

    [匿名化判断],
    [`if anonymous and key in keys`],
    [`mask-field(body, anonymous)`],

    [数组拼接],
    [`(("",) + arr).sum()`],
    [`arr.join()`],

    [粗体标签],
    [`fakebold`（外部依赖）],
    [`text(weight: "bold")`（原生）],

    [魔法间距],
    [`v(48pt)` / `v(-12pt)`],
    [`v(1em)` / `v(1.5em)`],
  )
)

== 组合性对比

#figure(
  caption: [NJU mainmatter() vs. cinnabar 方案],
  table(
    columns: (auto, 1fr, 1fr),
    table.header([*关注点*], [*NJU mainmatter()*], [*cinnabar 方案*]),
    [正文font-family], [耦合在 179 行函数中], [独立 `set text` 规则],
    [标题编号], [依赖 custom-numbering], [原生 lambda],
    [页码重置], [与font-family规则耦合], [独立 `counter(page).update`],
    [图表编号], [依赖 i-figured 版本], [用户选择是否引入],
    [可替换性], [需 fork 函数], [直接修改对应规则行],
  )
)

// ----------------------------------------------------------
// Nomenclature — uses native Typst terms syntax
// ----------------------------------------------------------

#align(center)[
	#show terms.item: it => {
		block(
			width:80%,
			grid(
				columns:(auto,1fr),
				it.term,it.description
			)
		)
	}
  / $alpha$: 阿尔法，希腊字母表第一个字母
  / $beta$: 贝塔，希腊字母表第二个字母
  / LLM: Large Language Model，大语言模型
  / Typst: 一种现代排版系统
]

#pagebreak()

= 绪论

== 研究背景与意义

本研究针对 Typst 中文论文模板中大量 `v(..)` 魔法数和单体式排版函数的问题，
提出了基于原子砖块与原生 `set`/`show` 规则的可组合替代方案。

通过将font-size和font-family抽象为具名常量（`font-size`、`font-family`），作者可以在文档顶层
直接书写排版规则，无需了解任何框架内部的分发逻辑。

== 与 NJU 方案的对比

NJU `mainmatter()` 的主要硬编码问题：

+ *魔法间距*：`v(2 * 15.6pt - 0.7em)` 无法从外部覆盖，语义不透明。
+ *关注点耦合*：页码重置与正文font-family规则耦合在同一函数体内，无法分离使用。
+ *版本锁定*：整个正文排版依赖 `@preview/i-figured` 的固定版本。
+ *冗余抽象*：`custom-numbering` 用 25 行包装了等价于单行 lambda 的原生调用。
+ *框架自缠绕*：`acknowledgement` 需要标签来压制自身注入的换页规则。

=== cinnabar 的可组合性

以下场景均无需 fork 任何函数：

- 只需正文font-family，不需要标题编号：去掉 `set heading(numbering:)` 即可。
- 只需页码从 1 开始，不需要目录：去掉 `outline` 调用即可。
- 需要自定义二级标题为楷体：修改 `hd-font` 数组第二个元素即可。
- 需要更紧的行距：修改 `set par(leading:)` 一行即可。

= 系统设计

== 三层架构

/ 数据常量层: `components.typ` 前半部分 — `font-size`/`font-family` 常量，`mask-field`/`fill-lines` 纯函数。

/ 原子砖块层: `components.typ` — 工厂和内容函数。
  包含 `field-theme`、`line-under`、`double-underline`、
  `hidden-heading`、`distribute-chars`、
  `grid-rows`、`three-line-table` 等。

/ 预制整页组件层: `presets.typ` — 基于砖块构建的完整页面。
  包含 `cover`、`abstract-zh`、`abstract-en`、`originality`、
  `acknowledgements`、`nomenclature` 等。

= 用 cinnabar 原子砖块构建 NJU 论文

以下展示如何用 cinnabar 的 primitives 和 presets 构建南京大学本科毕业论文。
与 NJU 的 `documentclass` 工厂模式对比：cinnabar 不提供 monolithic 工厂，
而是让作者用 Typst 原生 `set`/`show` 规则 + cinnabar 原语自行组合。

== 数据模型

NJU 用 `info` 字典聚合所有文档元数据。cinnabar 的 presets 接受直接的
具名参数 —— 但作者可以自行组织数据字典，展开传递：

#let njuthesis-info = (
  title:    ("基于大语言模型的", "代码生成技术研究"),
  title-en: "Code Generation with Large Language Models",
  author:   "李明",
  author-en: "Li Ming",
  student-id:  "20210002",
  grade:       "2021",
  department:  "计算机科学与技术学院",
  department-en: "Department of Computer Science",
  major:       "计算机科学与技术",
  major-en:    "Computer Science and Technology",
  supervisor:     ("王伟", "教授"),
  supervisor-en:  ("Wang Wei", "Professor"),
  keywords-zh: ("大语言模型", "代码生成", "提示工程"),
  keywords-en: ("LLM", "code generation", "prompt engineering"),
  submit-date: datetime(year: 2025, month: 6, day: 15),
)

== 正文排版规则

NJU 的 `mainmatter()` 把font-family、标题、页眉、页码耦合在 179 行函数里。
cinnabar 方案：每个规则独立一行，用 `font-size`/`font-family` 常量，无需包装函数。

```typst
// font-family + 段落
#set text(font: font-family.serif, size: font-size.h4s)
#set par(leading: 1.5em, spacing: 1.5em, justify: true,
         first-line-indent: (amount: 2em, all: true))

// 标题 — per-level 数组
#show heading: it => {
  let i = calc.min(it.level, hd-font.len()) - 1
  set text(font: hd-font.at(i), size: hd-size.at(i))
  set block(above: hd-above.at(i), below: hd-below.at(i))
  it
}

// 编号 — 单行 lambda
#set heading(numbering: (..n) => if n.pos().len() == 1
  { "第" + chapter-nums.at(n.at(0)-1, default: str(n.at(0))) + "章　" }
  else { n.pos().map(str).join(".") + " " })
```

== 页面组装

NJU 的 `documentclass` 返回 dict，每个函数预绑定 `anonymous`/`twoside`/`fonts`。
cinnabar 的 presets 直接传参 —— 功能等价，无 monolithic 工厂：

```typst
// 封面（NJU bachelor-cover 的 cinnabar 等价）
#cover(
  title: njuthesis-info.title,
  author: njuthesis-info.author,
  student-id: njuthesis-info.student-id,
  department: njuthesis-info.department,
  major: njuthesis-info.major,
  supervisor: njuthesis-info.supervisor,
  submit-date: njuthesis-info.submit-date,
)

// 中文摘要（NJU bachelor-abstract 的 cinnabar 等价）
#abstract-zh(
  title: njuthesis-info.title, author: njuthesis-info.author,
  department: njuthesis-info.department, major: njuthesis-info.major,
  supervisor: njuthesis-info.supervisor,
  keywords: njuthesis-info.keywords-zh,
)[论文正文摘要内容]

// 目录
#pagebreak()

// 致谢
#acknowledgements()[致谢内容]
```

== 匿名模式

NJU 的每个页面函数都接受 `anonymous` 参数并内部检查。
cinnabar 的 presets 同样支持 —— 一行切换：

```typst
// 盲审模式：cover 内部自动遮蔽作者/学号/导师
#cover(title: njuthesis-info.title, author: njuthesis-info.author, anonymous: true)
#abstract-zh(title: njuthesis-info.title, keywords: njuthesis-info.keywords-zh, anonymous: true)
```

== 自定义扩展：用原语构建非标准页面

NJU 的 `bachelor-decl-page` 包含校徽图片和固定间距。
用 cinnabar 原语可以一行构建等效布局，无需新组件：

#align(center, text(font: font-family.sans, size: font-size.h2s, weight: "bold")[学术诚信承诺书])
#v(1.5em)
#{
  set par(first-line-indent: 2em, justify: true)
  set text(font: font-family.serif, size: font-size.h4s)
  [本人郑重承诺：所呈交的毕业论文（题目：《#njuthesis-info.title.sum()》）
   是在指导教师的指导下严格按照学校和学院有关规定由本人独立完成的。
   本论文中引用他人观点及参考资源的内容均已标注引用。
   本人承诺不存在抄袭、伪造、篡改等违纪行为。]
}
#v(3em)
#grid(
  columns: (1fr, 180pt),
  [],
  {
    set text(font: font-family.serif, size: font-size.h4s)
    [作者签名：#v(0.8em)学　　号：#v(0.8em)日　　期：]
  },
)

== 6. 对比总结

#figure(
  caption: [NJU documentclass vs. cinnabar],
  table(
    columns: (auto, 1fr, 1fr),
    table.header([*模式*], [*NJU documentclass*], [*cinnabar*]),
    [工厂], [monolithic: 120 行，返回 15 个函数 dict],
           [`field-theme` + 原生 `set`/`show` — 每个规则独立],
    [封面], [`info-key`/`info-value`/`info-long-value` 重写 3 遍],
           [`field-theme` 工厂 — 配置一次，复用],
    [匿名], [每个函数内联 `if anonymous and key in keys`],
           [`mask-field` — 一处定义],
    [正文], [`mainmatter()` 179 行耦合font-family/编号/页眉/图表],
           [原生 `set text`/`set par`/`set heading` — 每行独立可改],
    [致谢], [`<no-auto-pagebreak>` 标签压制自身规则],
           [直接用 `align(center, text(...))` 即可],
    [目录], [`indent: level => 累加求和` + 自定义 `fill`/`gap`],
           [原生 `outline(title: none, indent: auto)` 即可],
  )
)

= 用原语构建任务书页面

以下展示如何用 cinnabar 原语 + 原生 Typst 构建"本科毕业设计任务书"页面。
不提供预设 —— 调用方自行组合 `box(stroke:)` 和 `rect` 构建表单布局。

== 表单原语

`box(width: ..., stroke: (bottom: 0.5pt + black))` 就是下划线输入框。
内容居中用 `align(center, ...)`。这是 Typst 原生能力，无需封装。

#let blank(n) = box(width: n, stroke: (bottom: 0.5pt + black), outset: (bottom: 5pt), [])

签名行 — 标签在左，下划线填满右侧：
#par("学位论文作者签名：" + blank(10em))
#par("日期：" + blank(2.5em) + [年] + blank(1.25em) + [月] + blank(1.25em) + [日])

#v(1em)

日期行 — 预填或留空：

#par("完成期限：" + blank(2.5em) + "2025" + [年] + blank(1.25em) + "6" + [月] + blank(1.25em) + "15" + [日] + [至] + blank(2.5em) + "2025" + [年] + blank(1.25em) + "6" + [月] + blank(1.25em) + "30" + [日])

#v(1em)

表单行 — 标签 + 下划线内联：

#par("学院：" + blank(3cm) + "专业：" + blank(3cm))
#par("学生学号：" + blank(2cm) + "学生姓名：" + blank(2.5cm) + "指导教师：" + blank(2.5cm))
