@tool
extends EditorPlugin

const PLUGIN_NAME := "Novelogic"
const AUTOLOAD_PATH := "res://addons/novelogic/core/novelogic.gd"


func _enable_plugin():
	add_autoload_singleton(PLUGIN_NAME, AUTOLOAD_PATH)


func _disable_plugin():
	remove_autoload_singleton(PLUGIN_NAME)
