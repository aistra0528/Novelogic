class_name TimelineCondition extends TimelineEvent

var branch := ""
var expression := ""


func process():
	var reg := RegEx.new()
	reg.compile(REGEX.CONDITION.format(CAPTURE))
	var result := reg.search(lines[0])
	if result:
		branch = result.get_string("branch")
		expression = result.get_string("expression")

	processed = true


func is_if_branch() -> bool:
	if not processed:
		process()
	return branch == "if"


func execute():
	var handled := branch == "else"
	if branch != "else" and not expression.is_empty():
		var result := Novelogic.execute_expression(expression, start_line)
		if Novelogic.execute_error == OK and result is bool:
			handled = result

	if handled:
		Novelogic.current_indent += 1
	Novelogic.handle_next_event()


func _to_string() -> String:
	if branch == "else":
		return str("L", start_line + 1, " Conditions: ", branch)
	return str("L", start_line + 1, " Conditions: ", branch, " ", expression)
