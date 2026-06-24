简体中文 | [English](README_EN.md)

# Novelogic
为你的 Godot 游戏编写互动小说和视觉小说剧本。

[VSC 扩展](https://github.com/aistra0528/novelogic-vsc-extension)

## 快速开始

在 **项目设置** > **插件** 中启用 Novelogic。

```gdscript
func _ready():
    # Novelogic.signal_name.connect(...)
    var scenario := Novelogic.load_scenario("res://path/to/剧本.nvs")
    Novelogic.start_scenario(scenario)

func _on_button_pressed():
    if Novelogic.current_event is ScenarioText or Novelogic.current_event is ScenarioDialogue:
        Novelogic.next_event()
```

Novelogic剧本 `*.nvs` 文件使用4个空格缩进，不支持制表符。

导出项目时，请在 **资源** 中导出 Novelogic剧本 `*.nvs` 文件。


### 文本

```gdscript
signal text_started(text: String)
```

```novelogic
这是一行文本。

这是
多行
文本。
```

### 对话

```gdscript
signal dialogue_started(dialogue: String, who: String, mark: String)
```

```novelogic
爱丽丝: 这是一行对话。

爱丽丝: 这是
多行
对话。

爱丽丝:语音_01: 能听见吗？

爱丽丝:1godotresuid: 这样也行！

爱丽丝:微笑: 爱怎么用就怎么用！
```

### 标签
```novelogic
@标签
<> 调用标签
-> 跳转标签

@调用标签
# 返回标签或剧本调用处，否则结束剧本
<-

@跳转标签
-> 跳转剧本

@满足条件时跳转
-> 跳转剧本 :: 1 + 1 == 2

@跳转剧本
-> 剧本@标签

@调用剧本附带变量
<> 剧本@标签

@跳转开头
-> START

@结束剧本
-> END

```

### 赋值
```novelogic
# 剧本变量
health = 42
health -= 3 * d(12) + 6
game_over = health <= 0

# 扩展变量
GameState.good_ending = true
```

支持 `=` `+=` `-=` `*=` `/=` `**=` `%=` `&=` `|=` `^=` `<<=` `>>=`。

### 条件
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
        有哪里不对……
    case 1:
        是星期一……
    case 2, 3, 4, 5:
        是星期二、星期三、星期四或星期五。
    else:
        是星期六或星期天！
```

`when` 带参数时，以 `==` `!=` `<` `<=` `>` `>=` 开头的 `case` 被视为表达式。

### 选项
```gdscript
signal choice_started(choices: PackedStringArray)

func handle_choice(choice: String)
```

```novelogic
- 走左边的路
    flag.left = true
    ...
- 走右边的路
    flag.right = true
    ...
- 走中间的路 :: flag.left and flag.right
    ...

- 我没得选
- 我没得选
- 我没得选
...
```

`choices` 为可用的选项。如需获取全部选项，请使用 `(Novelogic.current_event as ScenarioChoice).all_choices()`。

### 输入
```gdscript
signal input_started(prompt: String, default: String)

func handle_input(input: Variant)
```

```novelogic
who ?? 请输入你的名字 :: 爱丽丝

玩家: 我的名字是{who}。

answer ?? 生命、宇宙和万物的终极答案

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

`input` 的类型为 `Variant`，不限于文本。

### 函数与指令
```gdscript
class_name CommandExtension
extends NovelogicExtension # 访问全局自动加载节点（可选）

func _init():
    Novelogic.extension = self

func d(sides: int) -> int:
    return randi_range(1, sides)

func wait_time(time: float) -> Signal:
    return Novelogic.get_tree().create_timer(time).timeout


func 等待结束(tween: Tween) -> Signal:
    return tween.finished
```

```novelogic
i = d(6)
# 无需 await
wait_time(0.5)

AudioManager.play_music("夜晚")

# 支持 Unicode 标识符、命名与可选参数
:背景音乐: "夜晚" 淡入时间=0.5 音量=0.6 循环=true
```

#### `:指令:` 提示

- 指令调用 `snake_case` 的函数。如 `:WaitTime: 0.5` 等价于 `wait_time(0.5)`。

- 支持变量与函数。如 `:等待结束: tween` 等价于 `等待结束(tween)`。

- 最后一个匿名参数将作为函数的首个参数。如 `:背景音乐: "白天" 淡入时间=0.5 "夜晚"` 等价于 `背景音乐("夜晚", 0.5)`。
