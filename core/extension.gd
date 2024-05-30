class_name ExprExtension extends RandomNumberGenerator

var _decks := {}
var _last_cards := {}
var execute_error := FAILED


func _init():
	randomize()


func clear():
	_decks.clear()
	_last_cards.clear()


func d(to: int) -> int:
	return dice(0, to)


func dice(from: int, to: int) -> int:
	return randi_range(from, to)


func draw(deck: Array) -> Variant:
	var hash := deck.hash()
	if not hash in _decks.keys():
		deck.shuffle()
		_decks[hash] = deck
		_last_cards[hash] = deck.back()
	if _decks[hash].is_empty():
		deck.shuffle()
		while is_same(_last_cards[hash], deck.front()):
			deck.shuffle()
		_decks[hash] = deck
		_last_cards[hash] = deck.back()
	return _decks[hash].pop_front()


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
