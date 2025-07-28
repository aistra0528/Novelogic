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
