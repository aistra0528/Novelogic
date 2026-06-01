class_name ScenarioReturn
extends ScenarioEvent

func process():
	processed = true


func execute():
	if Novelogic.current_scenario.stack.is_empty():
		if Novelogic.stack.is_empty():
			Novelogic.end_scenario()
			return
		var scenario: NovelogicScenario = Novelogic.stack.pop_back()
		scenario.variables = Novelogic.scenario_variables
		Novelogic.current_scenario = scenario
	var i := Novelogic.current_scenario.stack[-1]
	Novelogic.current_scenario.stack.resize(Novelogic.current_scenario.stack.size() - 1)
	var event := Novelogic.current_scenario.events[i]
	if event is ScenarioJump and event.require_trace():
		Novelogic.current_indent = event.indent
		Novelogic.handle_event(i + 1)
