@tool
extends Control

enum Format {
	CSV,
	POT,
}

var dialog_edit: LineEdit

@onready var input_edit: LineEdit = %InputEdit
@onready var output_edit: LineEdit = %OutputEdit
@onready var locale_edit: LineEdit = %LocaleEdit
@onready var placeholder_edit: LineEdit = %PlaceholderEdit
@onready var mark_box: CheckBox = %MarkBox
@onready var dialog := EditorFileDialog.new()


func _ready():
	locale_edit.text = ProjectSettings.get_setting("internationalization/locale/fallback")
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.dir_selected.connect(func(dir: String): dialog_edit.text = dir)
	add_child(dialog)


func _on_input_button_pressed():
	dialog_edit = input_edit
	dialog.popup_centered_clamped()


func _on_output_button_pressed():
	dialog_edit = output_edit
	dialog.popup_centered_clamped()


func _on_generate_button_pressed(format: Format):
	var input := input_edit.text
	var output := output_edit.text
	var extension := ".csv" if format == Format.CSV else ".pot"
	var locale := locale_edit.text
	var placeholder := placeholder_edit.text
	var mark_in_context := mark_box.button_pressed
	if not DirAccess.dir_exists_absolute(input) or not DirAccess.dir_exists_absolute(output):
		return
	for file in DirAccess.get_files_at(input):
		if file.get_extension() == "ntl":
			generate_file(input.path_join(file), output.path_join(file.get_basename() + extension), locale, placeholder, mark_in_context, format)


func _on_generate_csv_pressed():
	_on_generate_button_pressed(Format.CSV)


func _on_generate_pot_pressed():
	_on_generate_button_pressed(Format.POT)


func generate_file(input: String, output: String, locale: String, placeholder: String, mark_in_context: bool, format: Format):
	var output_file := FileAccess.open(output, FileAccess.WRITE)
	if not output_file:
		return
	match format:
		Format.CSV:
			for line in generate_csv(input, locale, placeholder, mark_in_context, format):
				output_file.store_csv_line(line)
		Format.POT:
			for line in generate_pot(input, locale, placeholder, mark_in_context, format):
				output_file.store_line(line)


func generate_array(path: String, placeholder: String, mark_in_context: bool, format: Format) -> Array[PackedStringArray]:
	var timeline := NovelogicTimeline.from_file(path, [TimelineEvent.TEXT, TimelineEvent.DIALOGUE, TimelineEvent.CHOICE, TimelineEvent.INPUT])
	if not timeline:
		return []
	var array: Array[PackedStringArray]
	var keys := PackedStringArray()
	for event in timeline.events:
		if not event.processed:
			event.process()
		var text: String
		var context: String
		match event.type:
			TimelineEvent.TEXT:
				text = (event as TimelineText).text
			TimelineEvent.DIALOGUE:
				text = (event as TimelineDialogue).dialogue
				context = (event.who + ":" + event.mark) if event.mark and mark_in_context else event.who
			TimelineEvent.CHOICE:
				text = (event as TimelineChoice).choice
				context = "CHOICE"
			TimelineEvent.INPUT:
				text = (event as TimelineInput).prompt
				context = "PROMPT"
		var key := text + context
		var i := keys.find(key)
		if i != -1:
			array[i][2] += str("\n" if format == Format.CSV else " ", path, ":", event.start_line)
		else:
			keys.append(key)
			array.append(PackedStringArray([text, context, str(path, ":", event.start_line)]))
	return array


func generate_csv(path: String, locale: String, placeholder: String, mark_in_context: bool, format: Format) -> Array[PackedStringArray]:
	var array: Array[PackedStringArray]
	var plural_rules := TranslationServer.get_plural_rules(locale)
	var plural_n := int(plural_rules.get_slice(";", 0))
	array.append(PackedStringArray(["keys", "?context", "?plural", "_locations", locale]))
	array.append(PackedStringArray(["?pluralrule", "", "", "", plural_rules]))
	for a in generate_array(path, placeholder, mark_in_context, format):
		var plural_msg := a[0] if a[0].contains(placeholder) else ""
		array.append(PackedStringArray([a[0], a[1], plural_msg, a[2], a[0]]))
		if plural_msg and plural_n > 1:
			for i in plural_n - 1:
				array.append(PackedStringArray(["", "", "", "", plural_msg]))
	return array


func generate_pot(path: String, locale: String, placeholder: String, mark_in_context: bool, format: Format) -> PackedStringArray:
	var array := PackedStringArray()
	var project_info := str(ProjectSettings.get_setting("application/config/name"), " ", ProjectSettings.get_setting("application/config/version"))
	var plural_rules := TranslationServer.get_plural_rules(locale)
	var plural_n := int(plural_rules.get_slice(";", 0))
	array.append('msgid ""')
	array.append('msgstr ""')
	array.append('"Project-Id-Version: %s\\n"' % project_info)
	array.append('"Language: %s\\n"' % locale)
	array.append('"MIME-Version: 1.0\\n"')
	array.append('"Content-Type: text/plain; charset=UTF-8\\n"')
	array.append('"Content-Transfer-Encoding: 8-bit\\n"')
	array.append('"Plural-Forms: %s\\n"' % plural_rules)
	for a: PackedStringArray in generate_array(path, placeholder, mark_in_context, format):
		array.append("")
		array.append("#: " + a[2])
		var id := a[0].c_escape().replace("\\'", "'")
		if a[1]:
			array.append('msgctxt "%s"' % a[1])
		array.append('msgid "%s"' % id)
		if id.contains(placeholder):
			array.append('msgid_plural "%s"' % id)
			for i in plural_n:
				array.append('msgstr[%d] ""' % i)
		else:
			array.append('msgstr ""')
	return array
