# SPDX-License-Identifier: MIT
# SCRIPT

# Set environment variables
ENV["RCALL_ENABLE_REPL"] = "false"
ENV["R_HOME"] = "/opt/homebrew/Cellar/r/4.4.3_1/lib/R"

# Import Census module (exports all necessary functions but may have limitations)
using Census

# IMPORTANT: Due to Julia limitations with complex reexports, directly import
# DataFrames and DataFramesMeta for more reliable operation in scripts
using DataFrames, DataFramesMeta

hl_alternating = HtmlHighlighter(
	(data, i, j) -> isodd(i), # Apply to odd rows
	HtmlDecoration(background = "#d4ffcc", color = "white")
)

# Create an HtmlHighlighter to make the last row bold
hl_last_row_bold = HtmlHighlighter(
	(data, i, j) -> i == size(data, 1), # Condition: if it's the last row
	HtmlDecoration(font_weight = "bold") # Apply bold formatting
)


