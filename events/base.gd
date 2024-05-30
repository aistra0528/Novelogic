class_name TimelineEvent extends RefCounted

enum {
	COMMENT,
	TEXT,
	DIALOGUE,
	CHOICE,
	JUMP,
	LABEL,
	RETURN,
	INPUT,
	ASSIGN,
	CONDITION,
	CALL,
}

const Regex := {
	INDENT = "^{INDENT}+",
	COMMENT = "^{INDENT}*{COMMENT}$",
	TEXT = "^{INDENT}*.+$",
	DIALOGUE = "^{INDENT}*({NAME}: )?{STRING}$",
	CHOICE = "^{INDENT}*\\* {STR}( when {EXPRESSION})?:$",
	JUMP = "^{INDENT}*{GOTO} {WHERE}$",
	LABEL = "^{INDENT}*@{NAME}$",
	RETURN = "^{INDENT}*<-$",
	INPUT = "^{INDENT}*{VARIABLE} = \\? {STRING}$",
	ASSIGN = "^{INDENT}*{VARIABLE} {ASSIGNMENT} {EXPRESSION}$",
	CONDITION = "^{INDENT}*{BRANCH}( {EXPRESSION})?:$",
	CALL = "^{INDENT}*{NAME}\\(.*\\)$",
}

const Capture := {
	INDENT = "(    )",
	COMMENT = "(#.*)",
	NAME = "(?<name>[A-Za-z]\\w*)",  # \w = [A-Za-z0-9_]
	STR = '"(?<string>.+?)"',
	STRING = '"(?<string>.+)"',
	GOTO = "(?<goto><>|->)",
	WHERE = "((?<timeline>[A-Za-z]\\w*)@)?(?<label>[A-Za-z]\\w*)",
	VARIABLE = "((?<section>[A-Za-z]\\w*)\\.)?(?<key>[A-Za-z_]\\w*)",
	ASSIGNMENT = "(?<assignment>=|\\?=|\\+=|-=|\\*=|/=)",
	EXPRESSION = "(?<expression>.+)",
	BRANCH = "(?<branch>if|elif|else)",
}

var type := TEXT
var start_line := 0
var indent := 0
var lines := PackedStringArray()
var processed := false


static func create(line: String) -> TimelineEvent:
	var event: TimelineEvent = null
	var type := match_type(line)
	match type:
		COMMENT:
			return null
		DIALOGUE:
			event = TimelineDialogue.new()
		CHOICE:
			event = TimelineChoice.new()
		JUMP:
			event = TimelineJump.new()
		LABEL:
			event = TimelineLabel.new()
		RETURN:
			event = TimelineReturn.new()
		INPUT:
			event = TimelineInput.new()
		ASSIGN:
			event = TimelineAssign.new()
		CONDITION:
			event = TimelineCondition.new()
		CALL:
			event = TimelineCall.new()
		_:
			event = TimelineText.new()
	event.type = type
	event.indent = match_indent(line)
	return event


static func match_type(line: String) -> int:
	var reg := RegEx.new()
	if line.is_empty() or reg.compile(Regex.COMMENT.format(Capture)) == OK and reg.search(line):
		return COMMENT
	elif reg.compile(Regex.DIALOGUE.format(Capture)) == OK and reg.search(line):
		return DIALOGUE
	elif reg.compile(Regex.CHOICE.format(Capture)) == OK and reg.search(line):
		return CHOICE
	elif reg.compile(Regex.JUMP.format(Capture)) == OK and reg.search(line):
		return JUMP
	elif reg.compile(Regex.LABEL.format(Capture)) == OK and reg.search(line):
		return LABEL
	elif reg.compile(Regex.RETURN.format(Capture)) == OK and reg.search(line):
		return RETURN
	elif reg.compile(Regex.INPUT.format(Capture)) == OK and reg.search(line):
		return INPUT
	elif reg.compile(Regex.ASSIGN.format(Capture)) == OK and reg.search(line):
		return ASSIGN
	elif reg.compile(Regex.CONDITION.format(Capture)) == OK and reg.search(line):
		return CONDITION
	elif reg.compile(Regex.CALL.format(Capture)) == OK and reg.search(line):
		return CALL
	else:
		return TEXT


static func match_indent(line: String) -> int:
	var reg := RegEx.new()
	reg.compile(Regex.INDENT.format(Capture))
	var result := reg.search(line)
	if not result:
		return 0
	return len(result.get_string()) / 4


func is_multiline(line: String) -> bool:
	match type:
		TEXT:
			return match_type(line) == type and match_indent(line) == indent
		_:
			return false


func process():
	push_error("Unimplemented event type: ", "L", start_line + 1, "-", line_range()[-1] + 1)
	processed = true


func line_range() -> Array:
	return range(start_line, start_line + lines.size())
