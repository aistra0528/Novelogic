class_name NovelogicScenario

var path := ""
var events: Array[ScenarioEvent] = []
var stack: PackedInt32Array = []
var variables := { }


static func from_array(array: PackedStringArray, path: String, include_type: Array = []) -> NovelogicScenario:
	var events: Array[ScenarioEvent] = []
	var i := 0
	while i < array.size():
		var event := ScenarioEvent.create(array[i], include_type)
		if not event:
			i += 1
			continue
		event.start_line = i + 1
		event.lines.append(array[i])
		i += 1
		while i < array.size() and event.is_multiline(array[i]):
			event.lines.append(array[i])
			i += 1
		event.end_line = event.start_line + event.lines.size() - 1
		events.append(event)
	var scenario := NovelogicScenario.new()
	scenario.path = path
	scenario.events = events
	return scenario


static func from_file(path: String, include_type: Array = []) -> NovelogicScenario:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	var array := PackedStringArray()
	while file.get_position() < file.get_length():
		array.append(file.get_line())
	return from_array(array, path, include_type)
