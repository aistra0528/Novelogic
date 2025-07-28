class_name NovelogicTimeline extends RefCounted

var path := ""
var events: Array[TimelineEvent] = []
var stack: PackedInt32Array = []
var variables := {}


static func from_file(path: String, include_type: Array = []) -> NovelogicTimeline:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return null

	var lines := PackedStringArray()
	while file.get_position() < file.get_length():
		lines.append(file.get_line())

	var events: Array[TimelineEvent] = []
	var i := 0
	while i < lines.size():
		var event := TimelineEvent.create(lines[i], include_type)
		if not event:
			i += 1
			continue
		event.start_line = i + 1
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
