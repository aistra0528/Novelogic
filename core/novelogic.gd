extends Node

signal timeline_ended
signal timeline_started
signal text_started(text: String)
signal dialogue_started(dialogue: String, who: String)
signal choice_started(choices: PackedStringArray)
signal input_started(prompt: String)

var current_timeline: NovelogicTimeline = null
var extension: NovelogicExtension = null
var current_index := 0
var current_indent := 0
var current_event: TimelineEvent:
	get:
		return current_timeline.events[current_index] if current_timeline else null
var timeline_variables: Dictionary:
	get:
		return current_timeline.variables if current_timeline else {}
var error := OK


func load_timeline(path: String) -> NovelogicTimeline:
	return NovelogicTimeline.from_file(path)


func start_timeline(timeline: NovelogicTimeline, index_or_label: Variant = 0):
	if not timeline:
		return
	current_timeline = timeline
	timeline_started.emit()
	current_index = 0
	current_indent = 0
	if not extension:
		extension = NovelogicExtension.new()
	if not is_same(current_index, index_or_label):
		if index_or_label is String:
			handle_jump(index_or_label)
			return
		elif index_or_label is int and index_or_label < timeline.events.size():
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

				if event is not TimelineCondition or (event as TimelineCondition).is_if_branch():
					current_index = index
					break

	if not current_event.processed:
		current_event.process()

	match current_event.type:
		TimelineEvent.TEXT:
			text_started.emit((current_event as TimelineText).text)
		TimelineEvent.DIALOGUE:
			var event := current_event as TimelineDialogue
			dialogue_started.emit(event.dialogue, event.who)
		TimelineEvent.CHOICE:
			var event := current_event as TimelineChoice
			if event.is_first:
				choice_started.emit(event.available_choices())
			else:
				handle_next_event()
		TimelineEvent.JUMP:
			var event := current_event as TimelineJump
			if event.timeline:
				var path := current_timeline.path
				if path.get_extension():
					path = path.get_base_dir() + "/" + event.timeline + "." + path.get_extension()
				else:
					path = path.get_base_dir() + "/" + event.timeline
				var timeline := load_timeline(path)
				if not timeline:
					OS.alert(path, "Timeline not found")
					return
				if event.trace:
					timeline.variables = timeline_variables
				start_timeline(timeline, event.label)
			else:
				if event.trace:
					current_timeline.stack.append(current_index)
				elif not current_timeline.stack.is_empty():
					current_timeline.stack.clear()
				handle_jump(event.label)
		TimelineEvent.LABEL:
			handle_next_event()
		TimelineEvent.RETURN:
			if current_timeline.stack.is_empty():
				end_timeline()
				return
			index = current_timeline.stack[-1]
			current_timeline.stack.resize(current_timeline.stack.size() - 1)
			var event := current_timeline.events[index] as TimelineJump
			if event and event.require_trace():
				current_indent = event.indent
				handle_event(index + 1)
		TimelineEvent.INPUT:
			input_started.emit((current_event as TimelineInput).prompt)
		TimelineEvent.ASSIGN:
			(current_event as TimelineAssign).execute()
		TimelineEvent.CONDITION:
			(current_event as TimelineCondition).execute()
		TimelineEvent.CALL:
			(current_event as TimelineCall).execute()


func handle_choice(choice: String):
	if current_event is not TimelineChoice:
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
	OS.alert(current_timeline.path + "@" + label, "Label not found")


func handle_input(input: Variant):
	var event := current_event as TimelineInput
	if not event:
		return
	var it := execute_expression(event.section, event.start_line) if event.section else extension if event.key in extension else timeline_variables
	if error:
		return
	it.set(event.key, input)
	handle_next_event()


func end_timeline():
	current_timeline = null
	timeline_ended.emit()


func execute_expression(expression: String, line: int) -> Variant:
	var expr := Expression.new()
	error = expr.parse(expression, timeline_variables.keys())
	if error:
		OS.alert(str(current_timeline.path, ":", line, ": ", expression), "Bad expression")
		return
	var result := expr.execute(timeline_variables.values(), extension)
	if expr.has_execute_failed():
		error = FAILED
		OS.alert(str(current_timeline.path, ":", line, ": ", expression), "Execute failed")
		return
	return result
