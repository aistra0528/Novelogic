# Novelogic
Create interactive fictions in your Godot games.

[VSC Extension](https://github.com/aistra0528/novelogic-vsc-extension)

## Get Started

Enable Novelogic in Project Settings > Plugins.

```gdscript
func _ready():
    # Novelogic.signal_name.connect(...)
    var timeline = Novelogic.load_timeline("/path/to/timeline")
    Novelogic.start_timeline(timeline)

func _on_button_pressed():
    Novelogic.handle_next_event()
```

Novelogic uses four spaces for indentation. Don't use tabs.

### Text

```gdscript
signal text_started(text: String)
```

```novelogic
This is a single line text.

This is a
multiline
text.
```

### Dialogue

```gdscript
signal dialogue_started(dialogue: String, who: String)
```

```novelogic
Player: This is a single line dialogue.

Npc: This is a
multiline
dialogue.
```

### Label
```novelogic
@label
<> label_call
-> label_jump

@label_call
# Return where label/timeline called, or end the timeline.
<-

@label_jump
-> timeline_jump

@timeline_jump
-> timeline@label

@timeline_call_with_variables
<> timeline@label
```

### Assignment
```novelogic
# Timeline variables
health = 42
health -= 3 * d(12) + 6
game_over = health <= 0
```

### Condition
```novelogic
result = d(6)
if result == 6:
    ...
elif result == 1:
    ...
else:
    ...
```

### Choice
```gdscript
signal choice_started(choices: PackedStringArray)

func handle_choice(choice: String):
```

```novelogic
- Buy something ?: gold > 0
    ...
- Leave
    ...
```

### Input
```gdscript
signal input_started(prompt: String)

func handle_input(input: Variant):
```

```novelogic
answer ?? The Answer to the Ultimate Question of Life, the Universe, and Everything
birthday ?? res://date_picker.tscn
```

### Call
```gdscript
class_name MyExtension extends NovelogicExtension

func _ready():
    Novelogic.extension = self

func _get(property: StringName) -> Variant:
    if property == Autoload.name:
        return Autoload
    return null

func do_something(...):
    # (Novelogic.current_event as TimelineCall).handle_next = false
    ...
```

```novelogic
do_something(...)

Autoload.do_something(...)
```
