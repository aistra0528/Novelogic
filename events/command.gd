class_name ScenarioCommand
extends ScenarioEvent

var auto_next := true
var expression := ""


func _split(str: String) -> PackedStringArray:
	var array: PackedStringArray
	var current := ""
	var in_quotes := false
	var escaping := false
	for ch in str:
		if ch == " " and not in_quotes:
			if current:
				array.append(current)
				current = ""
			continue
		elif escaping:
			escaping = false
		elif ch == "\\":
			escaping = true
		elif ch == '"':
			in_quotes = !in_quotes
		current += ch
	if current:
		array.append(current)
	return array


func _unname(method: StringName, named_args: Dictionary) -> PackedStringArray:
	if Novelogic.extension:
		for item in Novelogic.extension.get_method_list():
			if item.name == method:
				var args: Dictionary
				var defaults: Array = item.default_args
				for arg in item.args:
					args[arg.name] = null
				var keys: Array = args.keys()
				for i in range(args.size() - 1, -1, -1):
					if defaults.is_empty():
						break
					args[keys[i]] = defaults.pop_back()
				if named_args.has(0):
					args[keys[0]] = named_args[0]
				for key in named_args:
					if key in args:
						args[key] = named_args[key]
				for key in args:
					if args[key] is not VarString:
						args[key] = var_to_str(args[key])
				return args.values()
	return [str(named_args)]


func process():
	if indent > 0:
		expression = lines[0].right(indent * -4)
	else:
		expression = lines[0]
	if expression.begins_with(":"):
		var i := expression.find(" ", 2)
		if i != -1:
			var method := expression.substr(1, i - 2).to_snake_case()
			var named_args: Dictionary
			for pair in _split(expression.right(-i - 1)):
				var j := pair.find("=")
				if j != -1:
					named_args[pair.left(j)] = VarString.new(pair.right(-j - 1))
				else:
					named_args[0] = VarString.new(pair)
			expression = "%s(%s)" % [method, ", ".join(_unname(method, named_args))]
		else:
			expression = expression.substr(1, expression.length() - 2).to_snake_case() + "()"
	processed = true


func execute():
	await Novelogic.eval(expression, start_line)
	if Novelogic.error:
		return
	if Novelogic.current_event == self and auto_next:
		Novelogic.next_event()


class VarString:
	var _str: String


	func _init(str: String):
		_str = str


	func _to_string() -> String:
		return _str
