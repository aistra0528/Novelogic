@tool
extends EditorPlugin

const PLUGIN_NAME := "Novelogic"
const AUTOLOAD_PATH := "res://addons/novelogic/core/novelogic.gd"

var panel: Control


func _enable_plugin():
	add_autoload_singleton(PLUGIN_NAME, AUTOLOAD_PATH)


func _disable_plugin():
	remove_autoload_singleton(PLUGIN_NAME)


func _enter_tree():
	panel = preload("res://addons/novelogic/panel.tscn").instantiate()
	EditorInterface.get_editor_main_screen().add_child(panel)
	_make_visible(false)


func _exit_tree():
	if panel:
		panel.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if panel:
		panel.visible = visible


func _get_plugin_name():
	return PLUGIN_NAME


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Translation", "EditorIcons")
