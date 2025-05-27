class_name NovelogicExtension extends RefCounted

var _sections := {}
var _decks := {}
var _last_cards := {}


func clear():
	_decks.clear()
	_last_cards.clear()


func get_sections() -> Dictionary:
	return _sections


func get_data() -> Dictionary:
	return {
		"_decks": _decks,
		"_last_cards": _last_cards,
	}


func load_data(data: Dictionary):
	_decks = data["_decks"]
	_last_cards = data["_last_cards"]


func has_var(key: Variant) -> bool:
	return Novelogic.timeline_variables.has(key)


func get_var(key: Variant, default: Variant = null) -> Variant:
	return Novelogic.timeline_variables.get(key, default)


func set_var(key: Variant, value: Variant) -> bool:
	return Novelogic.timeline_variables.set(key, value)


func d(to: int) -> int:
	return randi_range(1, to)


func draw(deck: Array) -> Variant:
	var key := deck.duplicate()
	if key not in _decks:
		deck.shuffle()
		_decks[key] = deck
		_last_cards[key] = deck.back()
	if _decks[key].is_empty():
		deck.shuffle()
		while is_same(_last_cards[key], deck.front()):
			deck.shuffle()
		_decks[key] = deck
		_last_cards[key] = deck.back()
	return _decks[key].pop_front()


func drawi(n: int) -> int:
	return draw(range(n))
