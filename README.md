# Novelogic
Create interactive fictions in your Godot games.

[VSC Extension](https://github.com/aistra0528/novelogic-vsc-extension)

## Get Started

Enable Novelogic in Project Settings > Plugins.

```gdscript
func _ready():
    ... # Novelogic.signal_name.connect(...)
    var timeline = Novelogic.load_timeline("/path/to/file")
    Novelogic.start_timeline(timeline)
...
func _on_button_pressed():
    Novelogic.handle_next_event()
```

### Label
Novelogic uses four whitespaces at the beginning of a line to create or increase the indentation level.
```
@label
    ...
    @sub_label
        ...
    <> label_call
-> label_jump

@label_call
    ...
# Return where label called.
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
hp_max = 100
# hp = hp_max if hp is not defined
hp ?= hp_max
rate = 150
damage = randi_range(10, 20)
hp -= damage * rate / 100
game_over = hp <= 0
log = "HP: {hp}/{hp_max}"

# Global variables
player.name = "You"
count.game_over = 0
flag.stage_clear = true
```

### Condition
```
if a > 0:
    a is greater than 0.
elif a < 0:
    a is less than 0.
else:
    a is 0.
```

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
signal dialogue_started(who: String, dialogue: String)
```

```
Player: Hello!

Developer: Hi,
{player}!
```

### Choice
```gdscript
signal choice_started(choices: PackedStringArray)
...
func handle_choice(choice: String):
```

```
- I have no choice.
...

- No thanks.
    ...
- Buy it! ?: money >= 10000
    ...
...
```

### Input
```gdscript
signal input_started(prompt: String)
...
func handle_input(text: String, escape: bool = true):
```

```
player.name ?? What's your name?
```

### Call
```gdscript
class_name MyExtension extends ExprExtension
...
func do_something(...):
    ...
```

```gdscript
func _ready():
    Novelogic.ext = MyExtension.new()
```

```
do_something(...)
```
