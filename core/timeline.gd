class_name NovelogicTimeline extends RefCounted

var path := ""
var events: Array[TimelineEvent] = []
var trace: Array[int] = []
var variables := {}


static func from_file(path: String) -> NovelogicTimeline:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("Can not access file: ", path)
		return NovelogicTimeline.new()

	var lines := PackedStringArray()
	while file.get_position() < file.get_length():
		lines.append(file.get_line())

	var events: Array[TimelineEvent] = []
	var i := 0
	while i < lines.size():
		var event := TimelineEvent.create(lines[i])
		if not event:
			i += 1
			continue
		event.start_line = i
		event.lines.append(lines[i])
		i += 1

		while i < lines.size() and event.is_multiline(lines[i]):
			event.lines.append(lines[i])
			i += 1

		events.append(event)

	var timeline := NovelogicTimeline.new()
	timeline.path = path
	timeline.events = events
	return timeline
