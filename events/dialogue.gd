class_name TimelineDialogue extends TimelineEvent

var who := ""
var dialogue := ""


func process():
	for i in lines.size():
		if i == 0:
			var reg := RegEx.new()
			reg.compile(Regex.DIALOGUE.format(Capture))
			var result := reg.search(lines[i])
			if result:
				who = result.get_string("name")
				dialogue = result.get_string("expression")
		else:
			dialogue += "\n"
			if indent == 0:
				dialogue += lines[i]
			else:
				dialogue += lines[i].right(-4 * indent)

	processed = true


func _to_string() -> String:
	return str("L", start_line + 1, "-", line_range()[-1] + 1, " Dialogue by ", who, ": ", dialogue)
