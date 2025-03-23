class_name TimelineInput extends TimelineEvent

var section := ""
var key := ""
var prompt := ""


func process():
	var reg := RegEx.new()
	reg.compile(Regex.INPUT.format(Capture))
	var result := reg.search(lines[0])
	if result:
		section = result.get_string("section")
		key = result.get_string("key")
		prompt = result.get_string("expression")

	processed = true


func _to_string() -> String:
	return str("L", start_line + 1, " Input: ", prompt)
