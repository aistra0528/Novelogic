class_name TimelineDialogue extends TimelineEvent

var dialogue := ""
var who := ""


func process():
	var reg := RegEx.new()
	reg.compile(Regex.DIALOGUE.format(Capture))
	var result := reg.search(lines[0])
	if result:
		dialogue = result.get_string("string")
		who = result.get_string("name")

	processed = true


func _to_string() -> String:
	if who.is_empty():
		return str("L", start_line + 1, ' Dialogue: "', dialogue, '"')
	return str("L", start_line + 1, " Dialogue by ", who, ': "', dialogue, '"')
