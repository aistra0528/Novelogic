class_name TimelineReturn extends TimelineEvent


func process():
	processed = true


func _to_string() -> String:
	return str("L", start_line + 1, " Return")
