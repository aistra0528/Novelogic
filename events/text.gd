class_name TimelineText extends TimelineEvent

var text := ""


func process():
	for i in lines.size():
		if i > 0:
			text += "\n"
		if indent == 0:
			text += lines[i]
		else:
			text += lines[i].right(-4 * indent)

	processed = true


func _to_string() -> String:
	return str("L", start_line + 1, "-", line_range()[-1] + 1, " Text: \n", text)
