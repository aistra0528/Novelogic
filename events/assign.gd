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
	if Novelogic.execute_error != OK:
		return
	if section.is_empty():
		match assignment:
			"=":
				Novelogic.timeline_variables[key] = result
			"?=":
				if not Novelogic.timeline_variables.has(key):
					Novelogic.timeline_variables[key] = result
			"+=":
				Novelogic.timeline_variables[key] += result
			"-=":
				Novelogic.timeline_variables[key] -= result
			"*=":
				Novelogic.timeline_variables[key] *= result
			"/=":
				Novelogic.timeline_variables[key] /= result
	else:
		var value: Variant = Novelogic.extension.get_section()[section].get(key)
		match assignment:
			"=":
				value = result
			"?=":
				if not value:
					value = result
			"+=":
				value += result
			"-=":
				value -= result
			"*=":
				value *= result
			"/=":
				value /= result
		Novelogic.extension.get_section()[section].set(key, value)
	Novelogic.handle_next_event()


func _to_string() -> String:
	if section.is_empty():
		return str("L", start_line + 1, " Assign: ", key, " ", assignment, " ", expression)
	return str("L", start_line + 1, " Assign: ", section, ".", key, " ", assignment, " ", expression)
