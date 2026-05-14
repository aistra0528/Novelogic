class_name NovelogicTimeline

var path := ""
var events: Array[TimelineEvent] = []
var stack: PackedInt32Array = []
var variables := { }


static func from_array(array: PackedStringArray, path: String, include_type: Array = []) -> NovelogicTimeline:
	var events: Array[TimelineEvent] = []
	var i := 0
	while i < array.size():
		var event := TimelineEvent.create(array[i], include_type)
		if not event:
			i += 1
			continue
		event.start_line = i + 1
		event.lines.append(array[i])
		i += 1
		while i < array.size() and event.is_multiline(array[i]):
			event.lines.append(array[i])
			i += 1
		events.append(event)
	var timeline := NovelogicTimeline.new()
	timeline.path = path
	timeline.events = events
	return timeline


static func from_file(path: String, include_type: Array = []) -> NovelogicTimeline:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	var array := PackedStringArray()
	while file.get_position() < file.get_length():
		array.append(file.get_line())
	return from_array(array, path, include_type)
