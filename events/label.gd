class_name TimelineLabel extends TimelineEvent

var label := ""


func process():
	var reg := RegEx.new()
	reg.compile(REGEX.LABEL.format(CAPTURE))
	var result := reg.search(lines[0])
	if result:
		label = result.get_string("name")

	processed = true


func require_label() -> String:
	if not processed:
		process()
	return label
