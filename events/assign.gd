class_name TimelineAssign extends TimelineEvent

var section := ""
var key := ""
var assignment := ""
var expression := ""


func process():
	var reg := RegEx.new()
	reg.compile(REGEX.ASSIGN.format(CAPTURE))
	var result := reg.search(lines[0])
	if result:
		section = result.get_string("section")
		key = result.get_string("key")
		assignment = result.get_string("assignment")
		expression = result.get_string("expression")

	processed = true


func execute():
	var result := Novelogic.execute_expression(expression, start_line)
	if Novelogic.error:
		return
	var obj := (
		Novelogic.execute_expression(section, start_line) if section else Novelogic.extension if key in Novelogic.extension else Novelogic.timeline_variables
	)
	if Novelogic.error:
		return
	match assignment:
		"=":
			obj.set(key, result)
		"+=":
			obj.set(key, obj.get(key) + result)
		"-=":
			obj.set(key, obj.get(key) - result)
		"*=":
			obj.set(key, obj.get(key) * result)
		"/=":
			obj.set(key, obj.get(key) / result)
		"^=":
			obj.set(key, obj.get(key) ^ result)
	Novelogic.handle_next_event()
