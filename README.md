# Novelogic
Create interactive fictions in your Godot games.

[VSC Extension](https://github.com/aistra0528/novelogic-vsc-extension)

## Get Started

Enable Novelogic in Project Settings > Plugins.

```gdscript
func _ready():
    # Novelogic.signal_name.connect(...)
    var timeline = Novelogic.load_timeline("/path/to/file")
    Novelogic.start_timeline(timeline)

func _on_button_pressed():
    Novelogic.handle_next_event()
```

Novelogic uses four spaces for indentation. Don't use tabs.

### Text

```gdscript
signal text_started(text: String)
```

```
Hello!

Hi,
{player}!
```

### Dialogue

```gdscript
signal dialogue_started(dialogue: String, who: String)
```

```
Player: Hello!

Npc: Hi,
{player}!
```

### Label
```
@label
...
<> label_call
...
-> label_jump

@label_call
# Return where label called, or end the timeline.
<-

@label_jump
-> timeline_jump

@timeline_jump
-> timeline@label

@timeline_jump_with_variables
<> timeline@label
```

### Assignment
```
# Timeline variables
hp = 42
hp -= 3 * d(12) + 6
game_over = hp <= 0
log = "HP: {hp}"
```

### Condition
```
d = d(6)
if d == 1:
    Huh?
elif d == 6:
    Nice!
else:
    It's {d}.
```

### Choice
```gdscript
signal choice_started(choices: PackedStringArray)
...
func handle_choice(choice: String):
```

```
- Buy something ?: Player.money > 0
    ...
- Leave
    ...
...
```

### Input
```gdscript
signal input_started(prompt: String)
...
func handle_input(input: Variant):
```

```
answer ?? The Answer to the Ultimate Question of Life, the Universe, and Everything

Player.birthday ?? res://date_picker.tscn
```

### Call
```gdscript
class_name MyExtension extends NovelogicExtension
...
func _get(property: StringName) -> Variant:
    if property == Autoload.name:
        return Autoload
    return null

func do_something(...):
    # (Novelogic.current_event as TimelineCall).handle_next = false
    ...
```

```gdscript
func _ready():
    Novelogic.extension = MyExtension.new()
```

```
do_something(...)

Autoload.do_something(...)
```
