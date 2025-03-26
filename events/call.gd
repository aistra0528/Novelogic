class_name TimelineCall extends TimelineEvent

var autoload := ""
var expression := ""


func process():
	if indent > 0:
		expression = lines[0].right(indent * -4)
	else:
		expression = lines[0]
	var reg := RegEx.new()
	reg.compile(Capture.VARIABLE)
	var result := reg.search(expression)
	if result:
		var section = result.get_string("section")
		if not section.is_empty() and Novelogic.has_node("/root/%s" % section):
			autoload = section
			expression = expression.right(-len(autoload) - 1)
	processed = true


func execute():
	Novelogic.extension.execute_expression(expression, start_line, Novelogic.extension if autoload.is_empty() else Novelogic.get_node("/root/%s" % autoload))
	if Novelogic.extension.execute_error != OK:
		return
	if Novelogic.current_event == self:
		Novelogic.handle_next_event()


func _to_string() -> String:
	return str("L", start_line + 1, " Call: ", expression)
