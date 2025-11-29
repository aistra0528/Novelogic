class_name TimelineDialogue extends TimelineEvent

var who := ""
var id := ""
var dialogue := ""


func process():
	for i in lines.size():
		if i == 0:
			var reg := RegEx.new()
			reg.compile(REGEX.DIALOGUE.format(CAPTURE))
			var result := reg.search(lines[i])
			if result:
				who = result.get_string("name")
				id = result.get_string("id")
				dialogue = result.get_string("expression")
		else:
			dialogue += "\n"
			if indent == 0:
				dialogue += lines[i]
			else:
				dialogue += lines[i].right(-4 * indent)

	processed = true
