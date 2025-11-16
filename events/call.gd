class_name TimelineCall extends TimelineEvent

var auto_next := true
var expression := ""


func process():
	if indent > 0:
		expression = lines[0].right(indent * -4)
	else:
		expression = lines[0]
	processed = true


func execute():
	await Novelogic.execute_expression(expression, start_line)
	if Novelogic.error:
		return
	if Novelogic.current_event == self and auto_next:
		Novelogic.handle_next_event()
