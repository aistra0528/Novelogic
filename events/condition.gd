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
	if branch == "else" or expression and Novelogic.execute_expression(expression, start_line):
		Novelogic.current_indent += 1
	Novelogic.handle_next_event()
