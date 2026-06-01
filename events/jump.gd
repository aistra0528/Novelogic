class_name ScenarioJump
extends ScenarioEvent

var scenario := ""
var label := ""
var trace := false
var expression := ""


func process():
	var reg := RegEx.new()
	reg.compile(REGEX.JUMP.format(CAPTURE))
	var result := reg.search(lines[0])
	if result:
		scenario = result.get_string("scenario")
		label = result.get_string("label")
		trace = result.get_string("goto") == "<>"
		expression = result.get_string("expression")
	processed = true


func require_trace() -> bool:
	if not processed:
		process()
	return trace


func execute():
	if expression:
		var result := Novelogic.eval(expression, start_line)
		if Novelogic.error or not result:
			Novelogic.next_event()
			return
	if scenario:
		var path := Novelogic.current_scenario.path.get_base_dir().path_join(scenario + ".nvs")
		var s := Novelogic.load_scenario(path)
		if not s:
			Novelogic.error = ERR_FILE_NOT_FOUND
			Novelogic.error_occurred.emit(path, "Scenario not found")
			return
		if trace:
			Novelogic.stack.append(Novelogic.current_scenario)
			Novelogic.current_scenario.stack.append(Novelogic.current_index)
			s.variables = Novelogic.scenario_variables
		Novelogic.start_scenario(s, label)
	else:
		if trace:
			Novelogic.current_scenario.stack.append(Novelogic.current_index)
		Novelogic.handle_jump(label)
