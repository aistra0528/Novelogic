class_name NovelogicExtension extends RandomNumberGenerator

var _decks := {}
var _last_cards := {}


func _init():
	randomize()


func clear():
	_decks.clear()
	_last_cards.clear()


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


func get_autoload(name: String) -> Node:
	return Novelogic.get_node("/root/%s" % name)
