// ==================================================
// Style Constants
// ==================================================

// Standard Chinese font size scale.
#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
)

// Standard Chinese font families as fallback arrays.
// covers: "latin-in-cjk" prevents Latin glyphs from rendering in CJK fonts.
#let 字体 = (
  宋体: ((name: "Times New Roman", covers: "latin-in-cjk"), "Source Han Serif SC", "Noto Serif CJK SC", "SimSun", "Songti SC"),
  黑体: ((name: "Arial", covers: "latin-in-cjk"), "Source Han Sans SC", "Noto Sans CJK SC", "SimHei", "Heiti SC"),
  楷体: ((name: "Times New Roman", covers: "latin-in-cjk"), "KaiTi", "Kaiti SC", "STKaiti"),
  仿宋: ((name: "Times New Roman", covers: "latin-in-cjk"), "FangSong", "FangSong SC", "STFangSong"),
  等宽: ((name: "Courier New", covers: "latin-in-cjk"), "Source Han Sans HW SC", "Noto Sans Mono CJK SC", "SimHei"),
)

// ==================================================
// Date Utilities
// ==================================================

// Formats a datetime as Chinese date string: YYYY年MM月DD日.
// Falls through non-datetime values unchanged.
#let format-date(date) = {
  if type(date) == datetime {
    date.display("[year]年[month]月[day]日")
  } else {
    date
  }
}

// Formats a datetime as English short date: "Jun 1, 2025".
// Falls through non-datetime values unchanged.
#let format-date-en(date) = {
  if type(date) == datetime {
    date.display("[month repr:short] [day], [year]")
  } else {
    date
  }
}

// ==================================================
// Field Utilities
// ==================================================

// Returns a block-character mask if anonymous is true, otherwise returns value.
// length controls the number of block characters in the mask.
#let mask-field(value, anonymous, length: 5) = {
  if anonymous {
    "█" * length
  } else {
    value
  }
}

// Joins an array of strings into one with separator, or passes a string through.
// Used to normalise title arguments that may be either a string or an array.
#let join-by-sep(content, separator: " ") = {
  if type(content) == array {
    content.join(separator)
  } else {
    content
  }
}

// Normalises a title argument to an array padded to at least min-lines entries.
// Accepts either a string (split on newline) or an array.
// Pads short arrays with ideographic spaces to reach min-lines.
#let normalise-title(title, min-lines: 2) = {
  let lines = if type(title) == str { title.split("\n") } else { title }
  if lines.len() < min-lines {
    lines = lines + range(min-lines - lines.len()).map(_ => "　")
  }
  lines
}

// ==================================================
// Layout Utilities
// ==================================================

// Justifies short CJK text by distributing characters with equal spacing.
// tail: set to none to suppress the trailing suffix; defaults to "：".
// The tail is included as the final item in the stack so it stays on the
// same line as the distributed characters.
#let justify-text(body, tail: "：") = {
  let chars = body.clusters().filter(c => c != "")
  // Inner stack distributes 1fr spacing only between characters.
  // Outer stack places the tail flush after the inner block with no extra spacing.
  let inner = stack(dir: ltr, spacing: 1fr, ..chars)
  if tail != none {
    stack(dir: ltr, inner, tail)
  } else {
    inner
  }
}
