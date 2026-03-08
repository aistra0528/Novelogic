# Novelogic
Create interactive fictions and visual novels in your Godot game.

[VSC Extension](https://github.com/aistra0528/novelogic-vsc-extension)

## Get Started

Enable Novelogic in Project Settings > Plugins.

```gdscript
func _ready():
    # Novelogic.signal_name.connect(...)
    var timeline := Novelogic.load_timeline("/path/to/timeline.ntl")
    Novelogic.start_timeline(timeline)

func _on_button_pressed():
    if Novelogic.current_event is TimelineText or Novelogic.current_event is TimelineDialogue:
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

alice:voice_01: Can you hear me?

alice:1godotresuid: It also works!

alice:smile: How to use marks is up to you!
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
GameState.good_ending = true
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

when:
    case roll == 6:
        ...
    case roll == 1:
        ...
    else:
        ...

when d(7):
    case 1:
        Monday...
    case 2, 3, 4, 5:
        Tuesday, Wednesday, Thursday, Friday.
    else:
        Saturday, Sunday!
```

### Choice
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
- THE MAIN ROAD ?: flag.left and flag.right
    ...
```

### Input
```gdscript
signal input_started(prompt: String)

func handle_input(input: Variant)
```

```novelogic
answer ?? The Answer to the Ultimate Question of Life, the Universe, and Everything

player: The answer is {answer}.

if answer == "42":
    ...
else:
    ...
```

```gdscript
func _on_dialogue_started(dialogue: String, who: String, mark: String):
    dialogue = dialogue.format(Novelogic.timeline_variables)
    ...
```

### Call
```gdscript
class_name MyExtension
extends NovelogicExtension # Optional

func _init():
    Novelogic.extension = self

func _get(property: StringName) -> Variant:
    # Autoload
    if super._get(property):
        return super._get(property)
    ...
    return null

func do_something(...):
    # (Novelogic.current_event as TimelineCall).auto_next = false
    ...

func wait_something(...) -> Signal:
    var tween := ...
    ...
    return tween.finished
```

```novelogic
do_something(...)
# await is not required
wait_something(...)

SoundManager.play_music(...)
```

## Example

[Ren'Py Script of _The Question_](https://www.renpy.org/doc/html/thequestion.html) ported to Novelogic.

```novelogic
# Declare characters used by this game.
s = Character.new("Sylvie").color("#c8ffc8").image("sylvie")
m = Character.new("Me").color("#c8c8ff")

# This is a variable that is true if you've compared a VN to a book, and false otherwise.
book = false

# The game starts here.
@start

# Start by playing some music.
play_music("illurock")

scene("bg_lecturehall", "fade")

It's only when I hear the sounds of shuffling feet and supplies being put away that I realize that the lecture's over.

Professor Eileen's lectures are usually interesting, but today I just couldn't concentrate on it.

I've had a lot of other thoughts on my mind...thoughts that culminate in a question.

It's a question that I've been meaning to ask a certain someone.

scene("bg_uni", "fade")

When we come out of the university, I spot her right away.

s.show("green_normal", "dissolve")

I've known Sylvie since we were kids. She's got a big heart and she's always been a good friend to me.

But recently... I've felt that I want something more.

More than just talking, more than just walking home together when our classes end.

As soon as she catches my eye, I decide...

- To ask her right away.
    -> rightaway

- To ask her later.
    -> later


@rightaway

s.show("green_smile")

s: Hi there! How was class?

m: Good...

I can't bring myself to admit that it all went in one ear and out the other.

m: Are you going home now? Wanna walk back with me?

s: Sure!

scene("bg_meadow", "fade")

After a short while, we reach the meadows just outside the neighborhood where we both live.

It's a scenic view I've grown used to. Autumn is especially beautiful here.

When we were children, we played in these meadows a lot, so they're full of memories.

m: Hey... Umm...

s.show("green_smile", "dissolve")

She turns to me and smiles. She looks so welcoming that I feel my nervousness melt away.

I'll ask her...!

m: Ummm... Will you...

m: Will you be my artist for a visual novel?

s.show("green_surprised")

Silence.

She looks so shocked that I begin to fear the worst. But then...

s.show("green_smile")

s: Sure, but what's a "visual novel?"

- It's a videogame.
    -> game

- It's an interactive book.
    -> book


@game

m: It's a kind of videogame you can play on your computer or a console.

m: Visual novels tell a story with pictures and music.

m: Sometimes, you also get to make choices that affect the outcome of the story.

s: So it's like those choose-your-adventure books?

m: Exactly! I've got lots of different ideas that I think would work.

m: And I thought maybe you could help me...since I know how you like to draw.

m: It'd be hard for me to make a visual novel alone.

s.show("green_normal")

s: Well, sure! I can try. I just hope I don't disappoint you.

m: You know you could never disappoint me, Sylvie.

-> marry


@book

book = true

m: It's like an interactive book that you can read on a computer or a console.

s.show("green_surprised")

s: Interactive?

m: You can make choices that lead to different events and endings in the story.

s: So where does the "visual" part come in?

m: Visual novels have pictures and even music, sound effects, and sometimes voice acting to go along with the text.

s.show("green_smile")

s: I see! That certainly sounds like fun. I actually used to make webcomics way back when, so I've got lots of story ideas.

m: That's great! So...would you be interested in working with me as an artist?

s: I'd love to!

-> marry


@marry

scene("#000", "dissolve")

And so, we become a visual novel creating duo.

scene("bg_club", "dissolve")

Over the years, we make lots of games and have a lot of fun making them.

if book:

    Our first game is based on one of Sylvie's ideas, but afterwards I get to come up with stories of my own, too.

We take turns coming up with stories and characters and support each other to make some great games!

And one day...

s.show("blue_normal", "dissolve")

s: Hey...

m: Yes?

s.show("blue_giggle")

s: Will you marry me?

m: What? Where did this come from?

s.show("blue_surprised")

s: Come on, how long have we been dating?

m: A while...

s.show("blue_smile")

s: These last few years we've been making visual novels together, spending time together, helping each other...

s: I've gotten to know you and care about you better than anyone else. And I think the same goes for you, right?

m: Sylvie...

s.show("blue_giggle")

s: But I know you're the indecisive type. If I held back, who knows when you'd propose?

s.show("blue_normal")

s: So will you marry me?

m: Of course I will! I've actually been meaning to propose, honest!

s: I know, I know.

m: I guess... I was too worried about timing. I wanted to ask the right question at the right time.

s.show("blue_giggle")

s: You worry too much. If only this were a visual novel and I could pick an option to give you more courage!

scene("#000", "dissolve")

We get married shortly after that.

Our visual novel duo lives on even after we're married...and I try my best to be more decisive.

Together, we live happily ever after even now.

[b]Good Ending[/b].

-> END


@later

I can't get up the nerve to ask right now. With a gulp, I decide to ask her later.

scene("#000", "dissolve")

But I'm an indecisive person.

I couldn't ask her that day and I end up never being able to ask her.

I guess I'll never know the answer to my question now...

[b]Bad Ending[/b].

-> END

```
