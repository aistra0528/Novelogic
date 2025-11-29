class_name TimelineChoice extends TimelineEvent

var choice := ""
var expression := ""
var choices := PackedInt32Array()

var is_first: bool = true:
	get:
		if is_first and choices.is_empty():
			for i in range(Novelogic.current_index - 1, -1, -1):
				var event := Novelogic.current_timeline.events[i]
				if indent < event.indent:
					continue
				if indent > event.indent or event is not TimelineChoice:
					break
				is_first = false
				break
		return is_first


func process():
	var reg := RegEx.new()
	reg.compile(REGEX.CHOICE.format(CAPTURE))
	var result := reg.search(lines[0])
	if result:
		choice = result.get_string("expr")
		expression = result.get_string("expression")
	processed = true


func process_choices():
	choices.append(Novelogic.current_index)
	for i in range(Novelogic.current_index + 1, Novelogic.current_timeline.events.size()):
		var event := Novelogic.current_timeline.events[i]
		if indent < event.indent:
			continue
		if indent > event.indent or event is not TimelineChoice:
			break
		event.is_first = false
		if not event.processed:
			event.process()
		choices.append(i)


func available_choices() -> PackedStringArray:
	if choices.is_empty():
		process_choices()
	var available_choices := PackedStringArray()
	for i in choices:
		var event: TimelineChoice = Novelogic.current_timeline.events[i]
		if event.expression.is_empty() or Novelogic.execute_expression(event.expression, event.start_line):
			available_choices.append(event.choice)
	return available_choices
