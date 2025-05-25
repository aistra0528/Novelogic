class_name TimelineJump extends TimelineEvent

var timeline := ""
var label := ""
var trace := false


func process():
	var reg := RegEx.new()
	reg.compile(REGEX.JUMP.format(CAPTURE))
	var result := reg.search(lines[0])
	if result:
		timeline = result.get_string("timeline")
		label = result.get_string("label")
		trace = result.get_string("goto") == "<>"

	processed = true


func require_trace() -> bool:
	if not processed:
		process()
	return trace


func _to_string() -> String:
	return str("L", start_line, " Jump with trace: " if trace else " Jump: ", timeline, "@", label)
