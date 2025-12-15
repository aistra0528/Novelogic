# Novelogic
Create interactive fictions in your Godot games.

[VSC Extension](https://github.com/aistra0528/novelogic-vsc-extension)

## Get Started

Enable Novelogic in Project Settings > Plugins.

```gdscript
func _ready():
    # Novelogic.signal_name.connect(...)
    var timeline = Novelogic.load_timeline("/path/to/timeline.ntl")
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
signal dialogue_started(dialogue: String, who: String, mark: String)
```

```novelogic
bob: This is a single line dialogue.
bob: This is a
multiline
dialogue.
alice:TRANSLATION_ID: Bonjour !
alice:voice001: Can you hear me?
alice:1godotresuid: It also works!
alice:happy: How to use marks is up to you!
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

@label_jump_if_condition
-> timeline_jump ?: 1 + 1 == 2

@timeline_jump
-> timeline@label

@timeline_call_with_variables
<> timeline@label

@jump_to_beginning
-> START

@end_timeline
-> END

```

### Assignment
```novelogic
# Timeline variables
health = 42
health -= 3 * d(12) + 6
game_over = health <= 0

# Extension variables
Game.player_name = "You"
```

### Condition
```novelogic
roll = d(6)
if roll == 6:
    ...
elif roll == 1:
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
- THE LEFT BRANCH
    flag.left = true
    ...
- THE RIGHT BRANCH
    flag.right = true
    ...
- THE MAIN ROAD ?: flag.left and flag.right
    ...
```

### Input
```gdscript
signal input_started(prompt: String)

func handle_input(input: Variant):
```

```novelogic
answer ?? The Answer to the Ultimate Question of Life, the Universe, and Everything
player: The answer is {answer}.

# Custom input scene
Player.birthday ?? "res://date_picker.tscn"
player: My birthday is on ${Date.human_readable(Player.birthday)}.
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
    # (Novelogic.current_event as TimelineCall).auto_next = false
    ...
```

```novelogic
do_something(...)

Autoload.do_something(...)
```
