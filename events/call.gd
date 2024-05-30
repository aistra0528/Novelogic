class_name TimelineCall extends TimelineEvent

var expression := ""


func process():
	if indent > 0:
		expression = lines[0].right(indent * -4)
	else:
		expression = lines[0]

	processed = true


func execute():
	Novelogic.ext.execute_expression(expression, start_line)
	if Novelogic.ext.execute_error != OK:
		return
	if Novelogic.current_event == self:
		Novelogic.handle_next_event()


func _to_string() -> String:
	return str("L", start_line + 1, " Call: ", expression)
