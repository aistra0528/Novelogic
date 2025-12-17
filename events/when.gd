class_name TimelineWhen
extends TimelineEvent

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
	for i in range(Novelogic.current_index + 1, Novelogic.current_timeline.events.size()):
		var event := Novelogic.current_timeline.events[i]
		if condition_indent < event.indent:
			continue
		if condition_indent > event.indent or event is not TimelineCondition:
			break
		if event.require_branch().ends_with(TimelineCondition.BRANCH.IF):
			break
		conditions.append(i)
		if event.branch == TimelineCondition.BRANCH.ELSE:
			break


func execute():
	if conditions.is_empty():
		process_conditions()
	var value := Novelogic.execute_expression(expression, start_line) if expression else true
	if Novelogic.error:
		return
	for i in conditions:
		var event: TimelineCondition = Novelogic.current_timeline.events[i]
		var flag := event.branch == TimelineCondition.BRANCH.ELSE
		if not flag:
			var cases := Novelogic.execute_expression("[%s]" % event.expression, event.start_line)
			if Novelogic.error:
				return
			flag = (cases as Array).any(func(case): return case == value)
		if flag:
			Novelogic.current_indent = event.indent + 1
			Novelogic.handle_event(i + 1)
			return
