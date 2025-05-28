class_name NovelogicExtension extends RefCounted

var _decks := {}
var _last_cards := {}


func clear():
	_decks.clear()
	_last_cards.clear()


func get_data() -> Dictionary:
	return {
		"_decks": _decks,
		"_last_cards": _last_cards,
	}


func load_data(data: Dictionary):
	_decks = data["_decks"]
	_last_cards = data["_last_cards"]


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
