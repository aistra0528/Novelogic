class_name NovelogicExtension
extends Node

func wait(sec: float):
	return Novelogic.get_tree().create_timer(sec).timeout


func d(to: int) -> int:
	return randi_range(1, to)
