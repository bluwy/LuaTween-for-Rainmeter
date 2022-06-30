# Documentation

> **NOTE**: In the following examples, the **_LuaTween_** folder is located under _@Resources_.

## Script Setup

Here's the generic format for the script measure:

```ini
[LuaTween]
Measure=Script
ScriptFile=#@#LuaTween/Main.lua
TweenGroup=
; (Default: "Tweenable")
TweenN=
; (where N is an ordered number from 0)
OptionalN=
; (where N is an ordered number from 0)
```

### TweenGroup

The group that will be updated and redraw. Set measures' and meters' group to this name to receive updates from tweens. (Default: "Tweenable")

### TweenN

The tween declaration. There's **3 types** of tween: Single, Chain and Multiple.

> **NOTE**:
>
> - All time parameters for the syntax uses **milliseconds**, NOT seconds.
> - **ALWAYS** use ( ) when doing calculations, LuaTween will parse the string and calculate it automatically.

#### Single

Only tweens one section's option or one group's option. It's the simplest form of tween.

Syntax:
_Single_ | SectionName | OptionName | StartValue | EndValue | Duration

e.g. Valid Syntax for (1) **Meter**, (2) **Measure**, (3) **Variable**, (4) **Group** tweens:

```ini
; (1)
TweenN=Single | MeterPopcorn | SolidColor | 0,0,0,100 | 50,50,180,255 | 100

; (2)
TweenN=Single | MeasureCakeSize | Formula | 10 | #MaxCakeSize# | 60

; (3)
TweenN=Single | Variable | Money | 0 | 10000 | 500

; (4)
TweenN=Single | BarGroup | X | 0 | 50 | 100
```

#### Chain

Creates multiple tweens at once and call them in intervals

Syntax: _Chain_ | SectionName | OptionName | StartValue | EndValue | Duration | Interval | SectionCount

> **Note**: Interval refers to time between the start of child tweens. The first tween will run immediately.

e.g. Valid Syntax for (1) **Meter**, (2) **Measure**, (3) **Variable**, (4) **Group** tweens:

```ini
; (1)
TweenN=Chain | MeterLine%% | H | 0 | (#Size# * 100) | 100 | 50 | 100

; (2)
TweenN=Chain | MeasureBalloonSqueak(%%+1) | Formula | 10 | 1000 | 500 | 100 | 80

; (3)
TweenN=Chain | Variable | BankAccount%% | 1000000 | 0.02 | 10 | 1000 | 10

; (4)
TweenN=Chain | BoxGroup(%%) | Y | 0 | 5 | 300 | 50 | 10
```

> **NOTE**: Use **%%** and it'll be replaced incrementally, from 0 to (SectionCount-1)

#### Multiple

Creates multiple Single type tweens and allows calling them independantly. This has a slightly different call method that will be discussed in the [Public Functions](#public-functions) section below.

Syntax: _Multiple_ | SectionName | OptionName | StartValue | EndValue | Duration | SectionCount

e.g. Valid Syntax for (1) **Meter**, (2) **Measure**, (3) **Variable**, (4) **Group** tweens:

```ini
; (1)
TweenN=Multiple | MeterLine%% | H | 0 | (#Size# * 100) | 100 | 100

; (2)
TweenN=Multiple | MeasureBalloonSqueak(%%+1) | Formula | 10 | 1000 | 500 | 80

; (3)
TweenN=Multiple | Variable | BankAccount%% | 1000000 | 0.02 | 10 | 10

; (4)
TweenN=Multiple | BoxGroup(%%) | Y | 0 | 5 | 300 | 10
```

> **NOTE**: Use **%%** and it'll be replaced incrementally, from 0 to (SectionCount-1)

### OptionalN

Contains optional parameters for each tween. All the tween types have the same options. Use "`|`" (Pipe character) to separate multiple optionals:

#### Easing

The easing used (Case insensitive) (Default: "linear")

> **Note:**
>
> - For the full list of easings, visit https://easings.net. There, if you want to use, say 'easeInQuint', type 'inQuint' (without quotes) instead into the tween parameter).
> - You can also check the **_tween.lua_** script and search for the _tween.easing_ table. It lists all the easings supported

e.g.

```ini
OptionN=Easing OutQuad
```

#### Group

The group the tween belongs to. With this specified, you can call a function which affects a group rather than individually calling them one by one. (Case insensitive) (Default: `nil`)

**Note:**\
The group name does not relate to Rainmeter's `Group` in any way. The name will live internally to be used with the public functions.

e.g.

```ini
Optional0=Easing OutQuad | Group TitleGroup
```

#### Loop

The loop of the tween. Choices: `None`, `Restart` or `Yoyo`. (Case insensitive) (Default: `None`)

> **Note:**: `Restart` and `Yoyo` will cause the tween to animate infinitely, if you wish to pause it later on, call `Pause`, `Reset` or `Finish` to stop it (See the [Public Functions](#public-functions) section below)

e.g.

```ini
Optional0=Easing OutQuad | Group TitleGroup | Loop yoyo
```

## Advanced

### Path-like Tween

For all the tween types' `StartValue` and `EndValue` parameters, you can insert more values in between to create a path-like tween. There's two ways to trigger this mechanic (Don't mix):

1. Insert the values as usual between `StartValue` and `EndValue`, this path will then be separated evenly.

```ini
; Tweens a color producing a rainbow effect
TweenN=Single | MeterImage | SolidColor | 255,0,0 | 0,0,255 | 0,255,255 | 0,255,0 | 255,255,0 | 255,0,0 | 1000
```

2. Insert the values between `StartValue` and `EndValue` and explicitly write its percentual value (0 to 1).

```ini
; Tweens a color producing a rainbow effect (uneven)
Tween0=Single | MeterImage | SolidColor | 255,0,0 ; 0.0 | 0,0,255 ; 0.4 | 0,255,255 ; 0.5 | 0,255,0 ; 0.7 | 255,255,0 ; 0.8 | 255,0,0 ; 0.85 | 1000
```

## Public Functions

Public functions are called with the [CommandMeasure](https://docs.rainmeter.net/manual/bangs/#CommandMeasure) bang.

e.g.

```
[!CommandMeasure LuaTweener "Start(0)"]

[!CommandMeasure LuaTweener "Start('tweenGroup')"]
```

### Start(index)

Plays the tween forward

### Reverse(index)

Plays the tween backwards

### Pause(index)

Pauses the tween from playing

### Finish(index)

Sets the value to the EndValue

### Reset(index)

Sets the value to the Startalue

### Restart(index)

Calls Reset then Start together

### Rewind(index)

Calls Finish then Reverse together

### SetOptional(index, optionName, value)

Sets the optional values of a tween

### Reinit(index)

Reinitializes the tween and gets the new values (Will reset tween)

### Extra Notes

- `index` can also be a group name to apply a function on the tweens in that group. It's worth noting that different tween types have slightly different call methods (e.g. 'Multiple` type tweens) and so you have to be careful when dealing with groups that consist of multiple tween types.

- Tip: Lua automatically resizes the amount of parameters you pass in into functions. Say you pass 3 parameters into a function that accepts only one, Lua will only use the first parameter, same goes when you lack parameters for a function, Lua will fill the rest as `nil`.

#### Note on Multiple Type Tween

Multiple type tween uses a slightly differrent syntax because it consist of more individual tweens called subTweens. **Except** for `Reinit(index)`, after the `index` parameter, specify the `subIndex` too to refer to the independant subTween. If not, it'll call all the subTweens in batch instead.

e.g. Assuming that Tween0 is a _Multiple_ tween:

```ini
; Starts the subTween of `subIndex` 0, which is the first subTween
Start(0, 0)

; Finishes and play the subTween of `subIndex` 2 backwards, which is the third subTween
Rewind(0, 3)

; Sets the sixth subtween's easing to InOutExpo
SetOptional(0, 5, 'easing', 'inoutexpo')

; Sets all of the subtween's loop type to Yoyo
SetOptional(0, 'Loop', 'Yoyo')
```
