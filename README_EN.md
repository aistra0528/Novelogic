[简体中文](README.md) | English

# Novelogic
Create interactive fictions and visual novels in your Godot game.

[VSC Extension](https://github.com/aistra0528/novelogic-vsc-extension)

## Get Started

Enable Novelogic in **Project Settings** > **Plugins**.

```gdscript
func _ready():
    # Novelogic.signal_name.connect(...)
    var scenario := Novelogic.load_scenario("res://path/to/scenario.nvs")
    Novelogic.start_scenario(scenario)

func _on_button_pressed():
    if Novelogic.current_event is ScenarioText or Novelogic.current_event is ScenarioDialogue:
        Novelogic.next_event()
```

NovelogicScenario `*.nvs` files uses four spaces for indentation. DO NOT use tabs.

Export NovelogicScenario `*.nvs` files in **Resources** before you export your project.

### Texts

```gdscript
signal text_started(text: String)
```

```novelogic
This is a single line text.

This is a
multiline
text.
```

### Dialogues

```gdscript
signal dialogue_started(dialogue: String, who: String, mark: String)
```

```novelogic
Alice: This is a single line dialogue.

Alice: This is a
multiline
dialogue.

Alice:voice_01: Can you hear me?

Alice:1godotresuid: It also works!

Alice:smile: How to use marks is up to you!
```

### Labels
```novelogic
@Label
<> CallLabel
-> JumpToLabel

@CallLabel
# Return where label/scenario called, or end the scenario.
<-

@JumpToLabel
-> JumpToScenario

@JumpIfCondition
-> JumpToScenario :: 1 + 1 == 2

@JumpToScenario
-> scenario@Label

@CallScenarioWithVariables
<> scenario@Label

@JumpToBeginning
-> START

@EndScenario
-> END

```

### Assignments
```novelogic
# Scenario variables
health = 42
health -= 3 * d(12) + 6
game_over = health <= 0

# Extension variables
GameState.good_ending = true
```

Support `=` `+=` `-=` `*=` `/=` `**=` `%=` `&=` `|=` `^=` `<<=` `>>=`.

### Conditions
```novelogic
roll = d(6)
if roll == 6:
    ...
elif roll == 1:
    ...
else:
    ...

when:
    case roll == 6:
        ...
    case roll == 1:
        ...
    else:
        ...

when d(7):
    case < 1 or case > 7:
        Something went wrong...
    case 1:
        Monday...
    case 2, 3, 4, 5:
        Tuesday, Wednesday, Thursday, Friday.
    else:
        Saturday, Sunday!
```

When `when` has an argument, `case`s that start with `==` `!=` `<` `<=` `>` `>=` are treated as expressions.

### Choices
```gdscript
signal choice_started(choices: PackedStringArray)

func handle_choice(choice: String)
```

```novelogic
- THE LEFT BRANCH
    flag.left = true
    ...
- THE RIGHT BRANCH
    flag.right = true
    ...
- THE MAIN ROAD :: flag.left and flag.right
    ...

- I have no choice
- I have no choice
- I have no choice
...
```

`choices` are the available choices. To get all choices, use `(Novelogic.current_event as ScenarioChoice).all_choices()`.

### Inputs
```gdscript
signal input_started(prompt: String, default: String)

func handle_input(input: Variant)
```

```novelogic
who ?? Input your name :: Alice

Player: My name is {who}.

answer ?? The Answer to the Ultimate Question of Life, the Universe, and Everything

if answer == "42":
    ...
else:
    ...
```

```gdscript
func _on_dialogue_started(dialogue: String, who: String, mark: String):
    dialogue = dialogue.format(Novelogic.scenario_variables)
    ...
```

`input` type is `Variant`, not limited to texts.

### Functions and Commands
```gdscript
class_name CommandExtension
extends NovelogicExtension # (Optional) Access autoloads

func _init():
    Novelogic.extension = self

func d(sides: int) -> int:
    return randi_range(1, sides)

func wait_time(time: float) -> Signal:
    return Novelogic.get_tree().create_timer(time).timeout

func wait_finish(tween: Tween) -> Signal:
    return tween.finished
```

```novelogic
i = d(6)
# await is not required
wait_time(0.5)

AudioManager.play_music("night")

# Support Unicode identifiers, named and optional arguments
:Bgm: "night" fade_time=0.5 volume=0.6 loop=true
```

#### `:Command:` Tips

- The command calls the `snake_case` function. e.g. `:WaitTime: 0.5` means `wait_time(0.5)`.

- Support variables and functions. e.g. `:WaitFinish: tween` means `wait_finish(tween)`.

- The last unnamed argument will be the first argument of the function. e.g. `:Bgm: "day" fade_time=0.5 "night"` means `bgm("night", 0.5)`.
