class_name ExprExtension extends RandomNumberGenerator

var _array_fresh := {}
var _item_fresh := {}
var execute_error := FAILED


func _init():
	randomize()


func clear():
	_array_fresh.clear()
	_item_fresh.clear()


func d(to: int) -> int:
	return dice(0, to)


func dice(from: int, to: int) -> int:
	return randi_range(from, to)


func fresh(array: Array) -> Variant:
	var hash := array.hash()
	if not hash in _array_fresh.keys():
		array.shuffle()
		_array_fresh[hash] = array
		_item_fresh[hash] = array.back()
	if _array_fresh[hash].is_empty():
		array.shuffle()
		while is_same(_item_fresh[hash], array.front()):
			array.shuffle()
		_array_fresh[hash] = array
		_item_fresh[hash] = array.back()
	return _array_fresh[hash].pop_front()


func execute_expression(expression: String, line: int) -> Variant:
	execute_error = FAILED

	var keys := Novelogic.variables.keys()
	var str := expression
	for i in keys.size():
		var key: String = keys[i]
		keys[i] = key.replace(".", "__")
		if key in str:
			str = str.replace(key, keys[i])

	var expr := Expression.new()
	if expr.parse(str, keys + Novelogic.timeline_variables.keys()) != OK:
		push_error("L", line + 1, " Bad expression: ", expression)
		return
	var result := expr.execute(Novelogic.variables.values() + Novelogic.timeline_variables.values(), self)
	if expr.has_execute_failed():
		push_error("L", line + 1, " Execute failed: ", expression)
		return

	execute_error = OK
	return result
