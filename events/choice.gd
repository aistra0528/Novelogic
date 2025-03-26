class_name TimelineChoice extends TimelineEvent

var choice := ""
var expression := ""
var is_first := true
var choices := PackedInt32Array()


func process():
	var reg := RegEx.new()
	reg.compile(Regex.CHOICE.format(Capture))
	var result := reg.search(lines[0])
	if result:
		choice = result.get_string("expr")
		expression = result.get_string("expression")
	processed = true


func process_choices():
	var i := Novelogic.current_index
	choices.append(i)
	i += 1
	while i < Novelogic.current_timeline.events.size():
		var event := Novelogic.current_timeline.events[i]
		if indent < event.indent:
			pass
		elif indent > event.indent or not event is TimelineChoice:
			break
		else:
			event.is_first = false
			if not event.processed:
				event.process()
			choices.append(i)
		i += 1


func available_choices() -> PackedStringArray:
	if choices.is_empty():
		process_choices()
	var available_choices := PackedStringArray()
	for i in choices:
		var event: TimelineChoice = Novelogic.current_timeline.events[i]
		if event.expression.is_empty() or is_same(Novelogic.extension.execute_expression(event.expression, event.start_line), true):
			available_choices.append(event.choice)
	return available_choices


func _to_string() -> String:
	if expression.is_empty():
		return str("L", start_line + 1, " Choices: ", choice)
	return str("L", start_line + 1, " Choices: ", choice, " when ", expression)
