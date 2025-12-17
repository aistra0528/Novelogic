class_name TimelineCondition
extends TimelineEvent

const BRANCH := {
	IF = "if",
	ELIF = "elif",
	CASE = "case",
	ELSE = "else",
}

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


func require_branch() -> String:
	if not processed:
		process()
	return branch


func execute():
	match branch:
		BRANCH.IF, BRANCH.ELIF:
			if expression and Novelogic.execute_expression(expression, start_line):
				Novelogic.current_indent += 1
		BRANCH.ELSE:
			Novelogic.current_indent += 1
	Novelogic.handle_next_event()
