#import "../lib.typ": *

// ==========================================================
// thesis.typ — Full thesis front/back matter in document order
//
// Demonstrates all page components with a shared data block.
// Compile: typst compile example/thesis.typ
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

#set page(paper: "a4", margin: (x: 3cm, top: 3cm, bottom: 2.5cm))
#set heading(numbering: "1.1")

// ----------------------------------------------------------
// 1. Cover page (normal)
// ----------------------------------------------------------

#cover(
  title:        info.title-zh,
  author:       info.author-zh,
  student-id:   info.student-id,
  grade:        info.grade,
  department:   info.department-zh,
  major:        info.major-zh,
  supervisor:   info.supervisor,
  supervisor-ii: info.supervisor-ii,
  submit-date:  info.submit-date,
)

// ----------------------------------------------------------
// 2. Cover page (anonymous / blind-review mode)
// ----------------------------------------------------------

#cover(
  title:        info.title-zh,
  author:       info.author-zh,
  student-id:   info.student-id,
  grade:        info.grade,
  department:   info.department-zh,
  major:        info.major-zh,
  supervisor:   info.supervisor,
  supervisor-ii: none,
  submit-date:  info.submit-date,
  anonymous:    true,
)

// ----------------------------------------------------------
// 3. Statement of originality — pre-filled dates
// ----------------------------------------------------------

#originality(
  title:      info.title-zh,
  author:     info.author-zh,
  supervisor: info.supervisor.at(0) + " " + info.supervisor.at(1),
  sign-date:            info.submit-date,
  supervisor-sign-date: datetime(year: 2025, month: 6, day: 3),
)

// ----------------------------------------------------------
// 4. Statement of originality — blank (print-and-sign)
// ----------------------------------------------------------

#originality(
  title:      info.title-zh,
  author:     info.author-zh,
  supervisor: info.supervisor.at(0) + " " + info.supervisor.at(1),
)

// ----------------------------------------------------------
// 5. Chinese abstract
// ----------------------------------------------------------

#abstract-zh(
  title:        info.title-zh,
  author:       info.author-zh,
  department:   info.department-zh,
  major:        info.major-zh,
  supervisor:   info.supervisor,
  supervisor-ii: info.supervisor-ii,
  keywords:     info.keywords-zh,
)[
  本文介绍了一种基于 Typst 的学位论文排版系统的设计与实现。针对传统 LaTeX
  模板难以维护、编译速度慢等问题，本文提出了一套模块化的组件设计方案。

  通过解耦样式与内容，利用 Typst 强大的脚本能力，实现了封面、摘要、正文等
  部分的灵活配置。实验结果表明，该系统能够显著提高论文撰写的效率，同时保证
  了排版的规范性与美观度。

  这是第三段，用于验证首行缩进在多段落场景下的一致性表现。Typst 的段落处理
  非常现代化，能够很好地处理中文排版中的各种边缘情况。
]

// ----------------------------------------------------------
// 6. Chinese abstract (anonymous mode)
// ----------------------------------------------------------

#abstract-zh(
  title:        info.title-zh,
  author:       info.author-zh,
  department:   info.department-zh,
  major:        info.major-zh,
  supervisor:   info.supervisor,
  supervisor-ii: info.supervisor-ii,
  keywords:     info.keywords-zh,
  anonymous:    true,
)[
  本文介绍了一种基于 Typst 的学位论文排版系统的设计与实现，演示匿名模式下
  作者和导师信息被遮蔽的效果。
]

// ----------------------------------------------------------
// 7. English abstract
// ----------------------------------------------------------

#abstract-en(
  title:        info.title-en,
  author:       info.author-en,
  department:   info.department-en,
  major:        info.major-en,
  supervisor:   info.supervisor-en,
  supervisor-ii: info.supervisor-ii-en,
  keywords:     info.keywords-en,
)[
  This paper presents the design and implementation of a modular thesis
  typesetting system based on Typst. Targeting the limitations of traditional
  LaTeX templates — high maintenance cost and slow compilation — a
  component-oriented architecture is proposed.

  By decoupling content from presentation and leveraging Typst scripting
  capabilities, the system enables flexible configuration of cover pages,
  abstracts, and body chapters. Evaluation results demonstrate significant
  improvement in authoring efficiency while preserving typographic correctness.

  This third paragraph validates consistent first-line indentation across
  multiple paragraphs in an English-language context.
]

// ----------------------------------------------------------
// 8. Table of contents
// ----------------------------------------------------------

#outline-page()

// ----------------------------------------------------------
// 9. Body (sample headings for TOC population)
// ----------------------------------------------------------

= 绪论

== 研究背景与意义

== 国内外研究现状

== 本文主要工作

= 系统设计

== 整体架构

== 核心组件设计

=== 封面模块

=== 摘要模块

== 工具函数设计

= 实验与分析

== 实验环境

== 实验结果

= 结论与展望

// ----------------------------------------------------------
// 10. Acknowledgements
// ----------------------------------------------------------

#acknowledgements()[
  本文的完成离不开许多人的支持与帮助。

  首先，衷心感谢我的导师李四教授在研究过程中给予的悉心指导与耐心帮助。李教授严谨的治学态度和深厚的学术造诣令我受益匪浅，在论文的选题、撰写与修改过程中倾注了大量心血。

  其次，感谢实验室的各位同学在日常学习和研究中的相互支持与交流探讨，正是这种良好的学术氛围使得本文得以顺利完成。

  此外，感谢家人长期以来对我学业的理解与支持，他们的鼓励是我前行的动力。

  最后，感谢所有在本文写作过程中提供帮助的老师和同学，谨在此表示最诚挚的谢意。
]
