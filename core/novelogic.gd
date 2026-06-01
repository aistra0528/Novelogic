extends Node

signal scenario_started
signal scenario_ended
signal error_occurred(message: String, title: String)
signal text_started(text: String)
signal dialogue_started(dialogue: String, who: String, mark: String)
signal choice_started(choices: PackedStringArray)
signal input_started(prompt: String, default: String)

var current_scenario: NovelogicScenario = null
var extension: Object = null
var current_index := 0
var current_indent := 0
var current_event: ScenarioEvent:
	get:
		return current_scenario.events[current_index] if current_scenario else null
var scenario_variables: Dictionary:
	get:
		return current_scenario.variables if current_scenario else { }
var stack: Array[NovelogicScenario] = []
var error := OK


func load_scenario(path: String, include_type: Array = []) -> NovelogicScenario:
	return NovelogicScenario.from_file(path, include_type)


func start_scenario(scenario: NovelogicScenario, index_or_label: Variant = 0):
	if not scenario:
		return
	current_scenario = scenario
	scenario_started.emit()
	current_index = 0
	current_indent = 0
	if not is_same(current_index, index_or_label):
		if index_or_label is String:
			handle_jump(index_or_label)
			return
		if index_or_label is int and index_or_label < scenario.events.size():
			handle_event(index_or_label, true)
			return
	handle_event(current_index)


func next_event(ignore_indent: bool = false):
	handle_event(current_index + 1, ignore_indent)


func handle_event(index: int, ignore_indent: bool = false):
	if not current_scenario:
		return
	if index < 0:
		index = 0
	elif index >= current_scenario.events.size():
		end_scenario()
		return
	current_index = index

	if ignore_indent:
		current_indent = current_event.indent
	elif current_indent < current_event.indent:
		next_event()
		return
	elif current_indent > current_event.indent:
		current_indent = current_event.indent
		if current_event is ScenarioCondition and (current_event as ScenarioCondition).require_branch() != ScenarioCondition.BRANCH.IF:
			while true:
				index += 1
				if index >= current_scenario.events.size():
					end_scenario()
					return

				var event := current_scenario.events[index]
				if current_indent < event.indent:
					continue
				elif current_indent > event.indent:
					current_indent = event.indent

				if event is not ScenarioCondition or (event as ScenarioCondition).require_branch() == ScenarioCondition.BRANCH.IF:
					current_index = index
					break

	if not current_event.processed:
		current_event.process()
	current_event.execute()


func handle_choice(choice: String):
	if current_event is not ScenarioChoice:
		return
	for i in current_event.choices:
		if choice == (current_scenario.events[i] as ScenarioChoice).choice:
			current_indent += 1
			handle_event(i + 1)
			return


func handle_jump(label: String):
	if label == "START":
		handle_event(0, true)
		return
	if label == "END":
		end_scenario()
		return
	for i in current_scenario.events.size():
		if current_scenario.events[i] is ScenarioLabel and label == (current_scenario.events[i] as ScenarioLabel).require_label():
			handle_event(i, true)
			return
	error = ERR_DOES_NOT_EXIST
	error_occurred.emit(current_scenario.path + "@" + label, "Label not found")


func handle_input(input: Variant):
	var event := current_event as ScenarioInput
	if not event:
		return
	var obj := eval(event.section, event.start_line) if event.section else extension if event.key in extension else scenario_variables
	if error:
		return
	obj.set(event.key, input)
	next_event()


func end_scenario():
	current_scenario = null
	stack.clear()
	scenario_ended.emit()


func eval(expression: String, from_line: int) -> Variant:
	var expr := Expression.new()
	error = expr.parse(expression, scenario_variables.keys())
	if error:
		error_occurred.emit(str(current_scenario.path, ":", from_line, ": ", expression), "Bad expression")
		return null
	var result := expr.execute(scenario_variables.values(), extension)
	if expr.has_execute_failed():
		error = FAILED
		error_occurred.emit(str(current_scenario.path, ":", from_line, ": ", expression), "Execute failed")
		return null
	return result
