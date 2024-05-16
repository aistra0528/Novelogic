class_name TimelineAssign extends TimelineEvent

var section := ""
var key := ""
var assignment := ""
var expression := ""


func process():
	var reg := RegEx.new()
	reg.compile(Regex.ASSIGN.format(Capture))
	var result := reg.search(lines[0])
	if result:
		section = result.get_string("section")
		key = result.get_string("key")
		assignment = result.get_string("assignment")
		expression = result.get_string("expression")

	processed = true


func execute():
	var result := Novelogic.ext.execute_expression(expression, start_line)
	if Novelogic.ext.execute_error != OK:
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
		match assignment:
			"=":
				Novelogic.variables[section + "." + key] = result
			"?=":
				if not Novelogic.variables.has(section + "." + key):
					Novelogic.variables[section + "." + key] = result
			"+=":
				Novelogic.variables[section + "." + key] += result
			"-=":
				Novelogic.variables[section + "." + key] -= result
			"*=":
				Novelogic.variables[section + "." + key] *= result
			"/=":
				Novelogic.variables[section + "." + key] /= result
	Novelogic.handle_next_event()


func _to_string() -> String:
	if section.is_empty():
		return str("L", start_line + 1, " Assign: ", key, " ", assignment, " ", expression)
	return str("L", start_line + 1, " Assign: ", section, ".", key, " ", assignment, " ", expression)
