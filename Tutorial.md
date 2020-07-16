# Tutorial

This tutorial will show you the most basic way of creating a tween. We will be creating a skin in this tutorial. A little Rainmeter coding knowledge is needed to understand to Rainmeter syntax used, though I'll explain as much as I can :)

## Falling Block

Yep, a falling block. But not just any block, it's a bouncy block!

A finished version of the tutorial can be found in the repo under _Skins_ > _LuaTween - Example_ > _FallingBlock_

### Get Ready

1. Create a skin(If you already know how to create one skip to step 3). Open _Manage Rainmeter_, click on the folder with plus icon located near the _Active skins_, a _Create new skin_ window should appear.

2. Click _Add folder_, name it whatever you want. Then, click _@Resources_ and _Add skin_, name it whatever you want. Close the window.

3. Clone this repository and unzip it. Go to _Skins_ > _LuaTween_ > _@Resources_ folder, copy the _LuaTween_ folder into the _@Resources_ file of your skin.

4. Edit the skin! Locate the created skin and click _Edit_.

### Coding

Let's consider some stuff before we actually type. When tweening anything, it's always a good idea to have a high update rate for the script (since Lua's update thread depends on Rainmeter's), but not all meters or measures need the high update rate though. To remedy this, in the `[Rainmeter]` section, let's set the `Update` to 16 and `DefaultUpdateDivider` to -1. More info on _Updates_ can be found [here](https://docs.rainmeter.net/manual/skins/rainmeter-section/)

```ini
[Rainmeter]
Update=16
DefaultUpdateDivider=-1
AccurateText=1
```

We also need variables. In the `[Variables]` section, let's define `BlockSize` as the size of the block and `Height` as the total height that the block will be falling. Set the value to any number you like

```ini
[Variables]
BlockSize=20
Height=200
```

Alright, now everything's set up. We can now create a block. We'll create a `[Block]` meter to make the square block.

```ini
[Block]
Meter=Image
W=#BlockSize#
H=#BlockSize#
SolidColor=130,130,100
```

I've set the block's color to a nice gray (`130,130,100`), you can change it to your desired color. Oh, and we need a sky too! (I like nature) Let's create a `[Sky]` meter for our sky.

```ini
[Sky]
Meter=Image
W=#BlockSize#
H=#Height#
SolidColor=0,120,255
```

The sky's width and height is set to fit the whole skin. (That's why it's called a sky) Again, you can change the color if you want, but I dont see why you need to change a nice blue sky...

Cool, now we make the block fall. This is where the `LuaTween` shines (_Angel voices intensifies_). We'll create a Script Measure pointing towards it.

```ini
[LuaTween]
Measure=Script
ScriptFile=#@#LuaTween/Main.lua
TweenGroup=Tweenable
UpdateDivider=1
```

(Note: The _Main_ script is the powerhouse of the project, so we point towards that script.

Notice the `TweenGroup` option, this will be the group name that will be updated and redraw everytime this script tweens something (Name it whatever you like). `UpdateDivider` is also set to 1 so it'll run at `Update=16`.

To create a tween, in the `[LuaTween]` section, we'll declare a single-type tween. More info on types can be found [here](https://github.com/bluwy/LuaTween-for-Rainmeter/blob/master/Syntax.md).

The single-type tween's parameters looks like this:

> _Single_ | SectionName | OptionName | StartValue | EndValue | Duration

The `[LuaTween]` section will then look something like this:

```ini
[LuaTween]
Measure=Script
ScriptFile=#@#LuaTween/Main.lua
TweenGroup=Tweenable
Tween0=Single | Block | Y | 0 | (#Height# - #BlockSize#) | 500
Optional0=Easing outBounce
UpdateDivider=1
```

and you read the `Tween0` as:

> A single-type tween which tweens `Block`'s `Y` option from 0 to `(#Height# - #BlockSize#)` for a duration of 500 milliseconds

Hmm, did the parameters make sense now? :)

Notice the `Optional0` option, this will add additional options for the tween. Setting `Easing` to `outBounce` will produce a bouncing effect. ~_Cool_

So we just declared the tween, now we need to call it. In the `[Sky]` section, let's add 2 more options

```ini
[Sky]
Meter=Image
W=#BlockSize#
H=#Height#
SolidColor=0,120,255
MouseOverAction=[!CommandMeasure LuaTween "Start(0)"]
MouseLeaveAction=[!CommandMeasure LuaTween "Reverse(0)"]
```

`MouseOverAction` and `MouseLeaveAction` will call when the mouse is over the sky or leaving the sky, which will start or reverse the tween respectively. More info on the bangs that can be called can be found [here](https://github.com/bluwy/LuaTween-for-Rainmeter/blob/master/Syntax.md).

Yay we're done!! Woohoo.. or are we? One last step before everything works (A common mistake that even I made often), the `Block` needs to be in the group of `TweenGroup` defined in `[LuaTween]`

```ini
[Block]
Meter=Image
Group=Tweenable
W=#BlockSize#
H=#BlockSize#
SolidColor=130,130,100
```

And now we're done!! Save the skin and load it. Hover your mouse on the sky, and the block will fall. Plus the block reverse up when you leave the sky.

### Extra

Here's an extra modification that you can do to have the block falling infinitely.
Only 2 lines modified!

In the `LuaTween` section, modify `Optional0` to this

```ini
Optional0=Easing outBounce | Loop Restart
```

In the `Sky` section, modify `MouseLeaveAction` to this

```ini
MouseLeaveAction=[!CommandMeasure LuaTween "Reset(0)"]
```

Now the animation will always restart when it reaches the end and will reset back to its original position when you leave the sky.

## What to do next

This is just a small part of what LuaTween can do. Go check the Welcome.ini skin in this repo, it demonstrates LuaTween's fullest potential :)

Happy Tweening!
