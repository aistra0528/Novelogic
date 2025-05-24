class_name NovelogicExtension extends RandomNumberGenerator

var _decks := {}
var _last_cards := {}


func _init():
	randomize()


func clear():
	_decks.clear()
	_last_cards.clear()


func get_section() -> Dictionary:
	return {
		Novelogic.name: Novelogic,
	}


func get_data() -> Dictionary:
	return {
		"_decks": _decks,
		"_last_cards": _last_cards,
	}


func load_data(savedata: Dictionary):
	_decks = savedata["_decks"]
	_last_cards = savedata["_last_cards"]


func has_var(key: Variant) -> bool:
	return Novelogic.timeline_variables.has(key)


func get_var(key: Variant, default: Variant = null) -> Variant:
	return Novelogic.timeline_variables.get(key, default)


func set_var(key: Variant, value: Variant) -> bool:
	return Novelogic.timeline_variables.set(key, value)


func d(to: int) -> int:
	return randi_range(1, to)


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


func drawi(n: int) -> int:
	return draw(range(n))
