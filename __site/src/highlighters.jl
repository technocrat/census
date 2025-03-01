hl_alternating = HtmlHighlighter(
	(data, i, j) -> isodd(i), # Apply to odd rows
	HtmlDecoration(background = "green", color = "white")
)

# Create an HtmlHighlighter to make the last row bold
last_row_bold = HtmlHighlighter(
	(data, i, j) -> i == size(data, 1), # Condition: if it's the last row
	HtmlDecoration(font_weight = "bold") # Apply bold formatting
)
