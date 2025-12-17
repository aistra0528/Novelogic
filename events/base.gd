class_name TimelineEvent
extends RefCounted

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
	WHEN,
	CALL,
}

const REGEX := {
	INDENT = "^{INDENT}+",
	COMMENT = "^{INDENT}*{COMMENT}$",
	TEXT = "^{INDENT}*.+$",
	DIALOGUE = "^{INDENT}*{NAME}:({MARK}:)? {EXPRESSION}$",
	CHOICE = "^{INDENT}*- {EXPR}( \\?: {EXPRESSION})?$",
	JUMP = "^{INDENT}*{GOTO} {WHERE}( \\?: {EXPRESSION})?$",
	LABEL = "^{INDENT}*@{NAME}$",
	RETURN = "^{INDENT}*<-$",
	INPUT = "^{INDENT}*{VARIABLE} \\?\\? {EXPRESSION}$",
	ASSIGN = "^{INDENT}*{VARIABLE} {ASSIGNMENT} {EXPRESSION}$",
	CONDITION = "^{INDENT}*{BRANCH}( {EXPRESSION})?:$",
	WHEN = "^{INDENT}*when( {EXPRESSION})?:$",
	CALL = "^{INDENT}*{VARIABLE}\\(.*\\)$",
}

const CAPTURE := {
	INDENT = "(    )",
	COMMENT = "(#.*)",
	MARK = "(?<mark>[A-Za-z0-9]\\w*)", # \w = [A-Za-z0-9_]
	NAME = "(?<name>[A-Za-z]\\w*)",
	GOTO = "(?<goto>->|<>)",
	WHERE = "((?<timeline>[A-Za-z]\\w*)@)?(?<label>[A-Za-z]\\w*)",
	VARIABLE = "((?<section>[A-Za-z]\\w*(\\.[A-Za-z_]\\w*)*)\\.)?(?<key>[A-Za-z_]\\w*)",
	ASSIGNMENT = "(?<assignment>(\\+|-|\\*|/|\\*\\*|%|&|\\||\\^|<<|>>)?=)",
	EXPR = "(?<expr>.+?)",
	EXPRESSION = "(?<expression>.+)",
	BRANCH = "(?<branch>if|elif|case|else)",
}

var type := TEXT
var start_line := 1
var end_line: int:
	get:
		return start_line + lines.size() - 1
var indent := 0
var lines := PackedStringArray()
var processed := false


static func create(line: String, include_type: Array = []) -> TimelineEvent:
	var type := match_type(line)
	if type == COMMENT or (include_type and type not in include_type):
		return null
	var event: TimelineEvent
	match type:
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
		WHEN:
			event = TimelineWhen.new()
		CALL:
			event = TimelineCall.new()
		_:
			event = TimelineText.new()
	event.type = type
	event.indent = match_indent(line)
	return event


static func match_type(line: String) -> int:
	var reg := RegEx.new()
	if line.is_empty() or reg.compile(REGEX.COMMENT.format(CAPTURE)) == OK and reg.search(line):
		return COMMENT
	if reg.compile(REGEX.DIALOGUE.format(CAPTURE)) == OK and reg.search(line):
		return DIALOGUE
	if reg.compile(REGEX.CHOICE.format(CAPTURE)) == OK and reg.search(line):
		return CHOICE
	if reg.compile(REGEX.JUMP.format(CAPTURE)) == OK and reg.search(line):
		return JUMP
	if reg.compile(REGEX.LABEL.format(CAPTURE)) == OK and reg.search(line):
		return LABEL
	if reg.compile(REGEX.RETURN.format(CAPTURE)) == OK and reg.search(line):
		return RETURN
	if reg.compile(REGEX.INPUT.format(CAPTURE)) == OK and reg.search(line):
		return INPUT
	if reg.compile(REGEX.ASSIGN.format(CAPTURE)) == OK and reg.search(line):
		return ASSIGN
	if reg.compile(REGEX.CONDITION.format(CAPTURE)) == OK and reg.search(line):
		return CONDITION
	if reg.compile(REGEX.WHEN.format(CAPTURE)) == OK and reg.search(line):
		return WHEN
	if reg.compile(REGEX.CALL.format(CAPTURE)) == OK and reg.search(line):
		return CALL
	return TEXT


static func match_indent(line: String) -> int:
	var reg := RegEx.new()
	reg.compile(REGEX.INDENT.format(CAPTURE))
	var result := reg.search(line)
	if not result:
		return 0
	return len(result.get_string()) / 4


func is_multiline(line: String) -> bool:
	match type:
		DIALOGUE, TEXT:
			return match_indent(line) == indent and match_type(line) == TEXT
		_:
			return false


func process():
	processed = true


func execute():
	assert(false, "Not yet implemented")
