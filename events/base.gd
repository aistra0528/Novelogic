@abstract
class_name ScenarioEvent

enum Type {
	COMMENT,
	DIALOGUE,
	CHOICE,
	JUMP,
	LABEL,
	RETURN,
	INPUT,
	ASSIGNMENT,
	CONDITION,
	WHEN,
	COMMAND,
	TEXT,
}

const REGEX := {
	COMMENT = "^{INDENT}*{COMMENT}$",
	DIALOGUE = "^{INDENT}*{NAME}(@{WHAT})?:({MARK}:)? {EXPRESSION}$",
	CHOICE = "^{INDENT}*- {EXPR}( :: {EXPRESSION})?$",
	JUMP = "^{INDENT}*{GOTO} {WHERE}( :: {EXPRESSION})?$",
	LABEL = "^{INDENT}*@{NAME}$",
	RETURN = "^{INDENT}*<-$",
	INPUT = "^{INDENT}*{VARIABLE} \\?\\? {EXPR}( :: {EXPRESSION})?$",
	ASSIGNMENT = "^{INDENT}*{VARIABLE} {ASSIGNMENT} {EXPRESSION}$",
	CONDITION = "^{INDENT}*{BRANCH}( {EXPRESSION})?:$",
	WHEN = "^{INDENT}*when( {EXPRESSION})?:$",
	COMMAND = "^{INDENT}*({VARIABLE}\\(.*\\)|:{NAME}:( {EXPRESSION})?)$",
	TEXT = "^{INDENT}*.+$",
	INDENT = "^{INDENT}+",
}

const CAPTURE := {
	INDENT = "(    )",
	COMMENT = "(#.*)",
	WHAT = "(?<what>([A-Za-z0-9]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*)",
	MARK = "(?<mark>([A-Za-z0-9]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*)",
	NAME = "(?<name>([A-Za-z]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*)",
	GOTO = "(?<goto>->|<>)",
	WHERE = "((?<scenario>([A-Za-z]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*)@)?(?<label>([A-Za-z]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*)",
	VARIABLE = "((?<section>([A-Za-z]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*(\\.([A-Za-z_]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*)*)\\.)?(?<key>([A-Za-z_]|[^\\x00-\\x7F])(\\w|[^\\x00-\\x7F])*)",
	ASSIGNMENT = "(?<assignment>(\\+|-|\\*|/|\\*\\*|%|&|\\||\\^|<<|>>)?=)",
	EXPR = "(?<expr>.+?)",
	EXPRESSION = "(?<expression>.+)",
	BRANCH = "(?<branch>if|elif|case|else)",
}

var type: Type
var start_line: int
var end_line: int
var indent := 0
var lines := PackedStringArray()
var processed: bool:
	set(value):
		if value:
			lines.clear()
		processed = value


static func create(line: String, include_type: Array = []) -> ScenarioEvent:
	var type := match_type(line)
	if type == Type.COMMENT or (include_type and type not in include_type):
		return null
	var event: ScenarioEvent
	match type:
		Type.DIALOGUE:
			event = ScenarioDialogue.new()
		Type.CHOICE:
			event = ScenarioChoice.new()
		Type.JUMP:
			event = ScenarioJump.new()
		Type.LABEL:
			event = ScenarioLabel.new()
		Type.RETURN:
			event = ScenarioReturn.new()
		Type.INPUT:
			event = ScenarioInput.new()
		Type.ASSIGNMENT:
			event = ScenarioAssignment.new()
		Type.CONDITION:
			event = ScenarioCondition.new()
		Type.WHEN:
			event = ScenarioWhen.new()
		Type.COMMAND:
			event = ScenarioCommand.new()
		_:
			event = ScenarioText.new()
	event.type = type
	event.indent = match_indent(line)
	return event


static func match_type(line: String) -> int:
	var reg := RegEx.new()
	if line.is_empty():
		return Type.COMMENT
	for t in Type.TEXT:
		if reg.compile(REGEX.values().get(t).format(CAPTURE)) == OK and reg.search(line):
			return t
	return Type.TEXT


static func match_indent(line: String) -> int:
	var reg := RegEx.new()
	reg.compile(REGEX.INDENT.format(CAPTURE))
	var result := reg.search(line)
	if not result:
		return 0
	return len(result.get_string()) / 4


func is_multiline(line: String) -> bool:
	match type:
		Type.DIALOGUE, Type.TEXT:
			return match_indent(line) == indent and match_type(line) == Type.TEXT
		_:
			return false


@abstract func process()


@abstract func execute()
