class_name ScenarioCommand
extends ScenarioEvent

var auto_next := true
var expression := ""


func _split(str: String) -> PackedStringArray:
	var array: PackedStringArray
	var current := ""
	var in_quotes := false
	for ch in str:
		if ch == " " and not in_quotes:
			if current:
				array.append(current)
				current = ""
		else:
			if ch == '"':
				in_quotes = !in_quotes
			current += ch
	if current:
		array.append(current)
	return array


func process():
	if indent > 0:
		expression = lines[0].right(indent * -4)
	else:
		expression = lines[0]
	if expression.begins_with(":"):
		var i := expression.find(" ", 2)
		if i != -1:
			var dict: Dictionary
			for pair in _split(expression.right(-i - 1)):
				var j := pair.find("=")
				if j != -1:
					dict[pair.left(j)] = Value.new(pair.right(-j - 1))
				else:
					dict["value"] = Value.new(pair)
			expression = str(expression.substr(1, i - 2), "(", dict, ")")
		else:
			expression = expression.substr(1, expression.length() - 2) + "()"
	processed = true


func execute():
	await Novelogic.eval(expression, start_line)
	if Novelogic.error:
		return
	if Novelogic.current_event == self and auto_next:
		Novelogic.next_event()


class Value:
	var _value: String


	func _init(value: String):
		_value = value


	func _to_string() -> String:
		return _value
