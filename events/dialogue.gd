class_name ScenarioDialogue
extends ScenarioEvent

var who := ""
var what := ""
var mark := ""
var dialogue := ""


func process():
	for i in lines.size():
		if i == 0:
			var reg := RegEx.new()
			reg.compile(REGEX.DIALOGUE.format(CAPTURE))
			var result := reg.search(lines[i])
			if result:
				who = result.get_string("name")
				what = result.get_string("what")
				mark = result.get_string("mark")
				dialogue = result.get_string("expression")
		else:
			dialogue += "\n"
			if indent == 0:
				dialogue += lines[i]
			else:
				dialogue += lines[i].right(-4 * indent)
	processed = true


func execute():
	Novelogic.dialogue_started.emit(dialogue, who, what, mark)
