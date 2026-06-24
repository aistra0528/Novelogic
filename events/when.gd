class_name ScenarioWhen
extends ScenarioEvent

var expression := ""
var conditions := PackedInt32Array()


func process():
	var reg := RegEx.new()
	reg.compile(REGEX.WHEN.format(CAPTURE))
	var result := reg.search(lines[0])
	if result:
		expression = result.get_string("expression")
	processed = true


func process_conditions():
	var condition_indent := indent + 1
	for i in range(Novelogic.current_index + 1, Novelogic.current_scenario.events.size()):
		var event := Novelogic.current_scenario.events[i]
		if condition_indent < event.indent:
			continue
		if condition_indent > event.indent or event is not ScenarioCondition:
			break
		if event.require_branch().ends_with(ScenarioCondition.BRANCH.IF):
			break
		conditions.append(i)
		if event.branch == ScenarioCondition.BRANCH.ELSE:
			break


func execute():
	if conditions.is_empty():
		process_conditions()
	var what := Novelogic.eval(expression, start_line) if expression else null
	if Novelogic.error:
		return
	Novelogic.scenario_variables.case = what
	for i in conditions:
		var event: ScenarioCondition = Novelogic.current_scenario.events[i]
		var case: Variant = event.branch == ScenarioCondition.BRANCH.ELSE
		if not case:
			if expression:
				if (
						event.expression.begins_with("==")
						or event.expression.begins_with("!=")
						or event.expression.begins_with("<") # <, <=
						or event.expression.begins_with(">") # >, >=
				):
					var match: bool = Novelogic.eval("case " + event.expression, event.start_line)
					if Novelogic.error:
						return
					case = match
				elif "," in event.expression:
					var matches: Array = Novelogic.eval("[%s]" % event.expression, event.start_line)
					if Novelogic.error:
						return
					case = what in matches
				else:
					var match := Novelogic.eval(event.expression, event.start_line)
					if Novelogic.error:
						return
					case = what == match
			else:
				var match := Novelogic.eval(event.expression, event.start_line)
				if Novelogic.error:
					return
				case = match
		if case:
			Novelogic.scenario_variables.erase("case")
			Novelogic.current_indent = event.indent + 1
			Novelogic.handle_event(i + 1)
			return
	Novelogic.scenario_variables.erase("case")
	Novelogic.next_event()
