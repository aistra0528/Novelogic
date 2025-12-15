class_name NovelogicExtension
extends Node

var _decks := { }
var _last_cards := { }


func wait(sec: float):
	return Novelogic.get_tree().create_timer(sec).timeout


func d(to: int) -> int:
	return randi_range(1, to)


func draw(...deck: Array) -> Variant:
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
