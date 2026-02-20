class_name NovelogicExtension

func _get(property: StringName) -> Variant:
	if Novelogic.get_tree().root.has_node(NodePath(property)):
		return Novelogic.get_tree().root.get_node(NodePath(property))
	return null


func wait(sec: float) -> Signal:
	return Novelogic.get_tree().create_timer(sec).timeout


func d(sides: int) -> int:
	return randi_range(1, sides)
