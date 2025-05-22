extends Node

signal timeline_ended
signal timeline_started
signal text_started(text: String)
signal dialogue_started(who: String, dialogue: String)
signal choice_started(choices: PackedStringArray)
signal input_started(prompt: String)

var current_timeline: NovelogicTimeline = null
var current_index := 0
var current_indent := 0
var current_event: TimelineEvent:
	get:
		return current_timeline.events[current_index] if current_timeline else null
var timeline_variables: Dictionary:
	get:
		return current_timeline.variables if current_timeline else {}
var execute_error := FAILED
var extension := NovelogicExtension.new()
var slot := 0

var data: Dictionary:
	get:
		return {
			"timeline_path": current_timeline.path if current_timeline else "",
			"timeline_trace": current_timeline.trace if current_timeline else [],
			"timeline_variables": timeline_variables,
			"timeline_index": current_index if current_timeline else 0,
			"extension_data": extension.data,
		}


func load_timeline(path: String) -> NovelogicTimeline:
	return NovelogicTimeline.from_file(path)


func start_timeline(timeline: NovelogicTimeline, index_or_label: Variant = 0):
	current_timeline = timeline
	timeline_started.emit()
	current_index = 0
	current_indent = 0
	extension.clear()
	if not is_same(current_index, index_or_label):
		if typeof(index_or_label) == TYPE_STRING:
			handle_jump(index_or_label)
			return
		elif typeof(index_or_label) == TYPE_INT and index_or_label < timeline.events.size():
			handle_event(index_or_label, true)
			return

	handle_event(current_index)


func handle_next_event(ignore_indent: bool = false):
	handle_event(current_index + 1, ignore_indent)


func handle_event(index: int, ignore_indent: bool = false):
	if not current_timeline:
		return

	if index < 0:
		index = 0
	elif index >= current_timeline.events.size():
		end_timeline()
		return

	current_index = index

	if ignore_indent:
		current_indent = current_event.indent
	elif current_indent < current_event.indent:
		handle_next_event()
		return
	elif current_indent > current_event.indent:
		current_indent = current_event.indent
		if current_event is TimelineCondition and not (current_event as TimelineCondition).is_if_branch():
			while true:
				index += 1
				if index >= current_timeline.events.size():
					end_timeline()
					return

				var event := current_timeline.events[index]
				if current_indent < event.indent:
					continue
				elif current_indent > event.indent:
					current_indent = event.indent

				if not event is TimelineCondition or (event as TimelineCondition).is_if_branch():
					current_index = index
					break

	if not current_event.processed:
		current_event.process()

	match current_event.type:
		TimelineEvent.TEXT:
			text_started.emit((current_event as TimelineText).text)
		TimelineEvent.DIALOGUE:
			var event := current_event as TimelineDialogue
			dialogue_started.emit(event.who, event.dialogue)
		TimelineEvent.CHOICE:
			var event := current_event as TimelineChoice
			if event.is_first:
				choice_started.emit(event.available_choices())
			else:
				handle_next_event()
		TimelineEvent.JUMP:
			var event := current_event as TimelineJump
			if event.timeline.is_empty():
				if event.trace:
					current_timeline.trace.append(current_index)
				elif not current_timeline.trace.is_empty():
					current_timeline.trace.clear()
				handle_jump(event.label)
			else:
				var path := current_timeline.path
				if path.get_extension().is_empty():
					path = path.get_base_dir() + "/" + event.timeline
				else:
					path = path.get_base_dir() + "/" + event.timeline + "." + path.get_extension()
				var timeline := load_timeline(path)
				if timeline.path.is_empty():
					text_started.emit("Timeline not found: " + path)
					return
				if event.trace:
					timeline.variables = timeline_variables
				start_timeline(timeline, event.label)
		TimelineEvent.LABEL:
			handle_next_event()
		TimelineEvent.RETURN:
			if not current_timeline.trace.is_empty():
				index = current_timeline.trace.pop_back()
				var event := current_timeline.events[index] as TimelineJump
				if event and event.require_trace():
					current_indent = event.indent
					handle_event(index + 1)
					return
			end_timeline()
		TimelineEvent.INPUT:
			input_started.emit((current_event as TimelineInput).prompt)
		TimelineEvent.ASSIGN:
			(current_event as TimelineAssign).execute()
		TimelineEvent.CONDITION:
			(current_event as TimelineCondition).execute()
		TimelineEvent.CALL:
			(current_event as TimelineCall).execute()


func handle_choice(choice: String):
	if not current_event is TimelineChoice:
		return
	for i in current_event.choices:
		if choice == (current_timeline.events[i] as TimelineChoice).choice:
			current_indent += 1
			handle_event(i + 1)
			return


func handle_jump(label: String):
	for i in current_timeline.events.size():
		if current_timeline.events[i] is TimelineLabel and label == (current_timeline.events[i] as TimelineLabel).require_label():
			handle_event(i, true)
			return
	text_started.emit("Label not found: @" + label)


func handle_input(input: Variant):
	var event := current_event as TimelineInput
	if not event:
		return
	if event.section.is_empty():
		timeline_variables[event.key] = input
	else:
		extension.get_autoload(event.section).set(event.key, input)
	handle_next_event()


func end_timeline():
	current_timeline = null
	timeline_ended.emit()


func execute_expression(expression: String, line: int) -> Variant:
	execute_error = FAILED

	for name in get_tree().root.get_children().map(func(node: Node): return node.name):
		expression = expression.replace(name, 'get_autoload("%s")' % name)

	var expr := Expression.new()
	if expr.parse(expression, timeline_variables.keys()) != OK:
		push_error("L", line + 1, " Bad expression: ", expression)
		return
	var result := expr.execute(timeline_variables.values(), extension)
	if expr.has_execute_failed():
		push_error("L", line + 1, " Execute failed: ", expression)
		return

	execute_error = OK
	return result


func save_slot(index: int = slot) -> bool:
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_recursive_absolute("user://saves")
	var save := FileAccess.open("user://saves/slot_%02d" % index, FileAccess.WRITE)
	if not save:
		return false
	save.store_var(data)
	slot = index
	return true


func load_slot(index: int = slot) -> bool:
	var save := FileAccess.open("user://saves/slot_%02d" % index, FileAccess.READ)
	if not save:
		return false
	var savedata := save.get_var()
	extension.load_data(savedata["extension_data"])
	var path: String = savedata["timeline_path"]
	var timeline := current_timeline if current_timeline and current_timeline.path == path else load_timeline(path)
	timeline.trace = savedata["timeline_trace"]
	timeline.variables = savedata["timeline_variables"]
	start_timeline(timeline, savedata["timeline_index"])
	slot = index
	return true


func has_slot(index: int = slot) -> bool:
	return FileAccess.file_exists("user://saves/slot_%02d" % index)
