# Tutorial
This tutorial will show you the most basic way of creating a tween. We will be creating a skin in this tutorial. A little Rainmeter coding knowledge is needed to understand to Rainmeter syntax used, though I'll explain as much as I can :)

## Falling Block 
Yep, a falling block. But not just any block, it's a bouncy block!

A finished version of the tutorial can be found in the repo under *Skins* > *LuaTween* > *FallingBlock*

### Get Ready
1. Create a skin(If you already know how to create one skip to step 3). Open *Manage Rainmeter*, click on the folder with plus icon located near the *Active skins*, a *Create new skin* window should appear.

2. Click *Add folder*, name it whatever you want. Then, click *@Resources* and *Add skin*, name it whatever you want. Close the window.

3. Clone this repository and unzip it. Go to *Skins* > *LuaTween* > *@Resources* folder, copy both ***Tweener.lua*** and ***tween.lua*** into the *@Resources* file of your skin. (Credits to [tween.lua](https://github.com/kikito/tween.lua) that provided the tween functions)

4. Edit the skin! Locate the created skin and click *Edit*.

### Coding
Let's consider some stuff before we actually type. When tweening anything, it's always a good idea to have a high update rate for the script, but not all meters or measures need the high update rate though. To remedy this, in the `[Rainmeter]`, let's set the `Update` to 16 and `DefaultUpdateDivider` to -1. More info on *Updates* can be found [here](https://docs.rainmeter.net/manual/skins/rainmeter-section/)

~~~~
[Rainmeter]
Update=16
DefaultUpdateDivider=-1
AccurateText=1
~~~~

We also need variables. In the `[Variables]` section, let's define `BlockSize` as the size of the block and `Height` as the total height that the block will be falling. Set the value to any number you like

~~~~
[Variables]
BlockSize=20
Height=200
~~~~

Alright, now everything's set up. We can now create a block. We'll create a `[Block]` meter to make the square block.

~~~~
[Block]
Meter=Image
W=#BlockSize#
H=#BlockSize#
SolidColor=130,130,100
~~~~

I've set the block's color to a nice gray (`130,130,100`), you can change it to your desired color. Oh, and we need a sky too! (I like nature) Let's create a `[Sky]` meter for our sky.

~~~~
[Sky]
Meter=Image
W=#BlockSize#
H=#Height#
SolidColor=0,120,255
~~~~

The sky's width and height is set to fit the whole skin. (That's what skies are) Again, you can change the color if you want, but I dont see why you need to change a nice blue sky...

Cool, now we make the block fall. This is where the `Tweener.lua` script shines. We'll create a Script Measure pointing towards it.

~~~~
[LuaTweener]
Measure=Script
ScriptFile=#@#Tweener.lua
TweenGroup=Tweenable
UpdateDivider=1
~~~~

(Note: If `Tweener.lua` is not located in *@Resources*, change `ScriptFile` to the path containing the script)

Notice the `TweenGroup` option, this will be the group name that will be updated and redraw everytime this script tweens something (Name it whatever you like). `UpdateDivider` is also set to 1 so it'll we run at `Update=16`.

To create a tween, in the `[LuaTweener]` section, we'll declare a single-type tween. More info on types can be found [here](https://github.com/BjornLuG/LuaTween-for-Rainmeter/Syntax.md).

The single-type tween's parameters looks like this:
> *Single* | SectionName | OptionName | StartValue | EndValue | Duration | Easing(optional)

The `[LuaTweener]` section will then look something like this:
~~~~
[LuaTweener]
Measure=Script
ScriptFile=#@#Tweener.lua
TweenGroup=Tweenable
Tween0=Single | Block | Y | 0 | (#Height# - #BlockSize#) | 500 | outBounce
UpdateDivider=1
~~~~

and you read the `Tween0` as:
> A single-type tween which tweens `Block`'s `Y` option from 0 to `(#Height# - #BlockSize#)` for a duration of 500 milliseconds with easing of `outBounce`

Hmm, did the parameters make sense now? :) So we just declared the tween, now we need to call it. In the `[Sky]` section, let's add 2 more options

~~~~
[Sky]
Meter=Image
W=#BlockSize#
H=#Height#
SolidColor=0,120,255
MouseOverAction=[!CommandMeasure LuaTweener "Start(0)"]
MouseLeaveAction=[!CommandMeasure LuaTweener "Reverse(0)"]
~~~~

`MouseOverAction` and `MouseLeaveAction` will call when the mouse is over the sky or leaving the sky, which will start or reverse the tween respectively. More info on the bangs that can be called can be found [here](https://github.com/BjornLuG/LuaTween-for-Rainmeter/Syntax.md).

Yay we're done!! Woohoo.. or are we? One last step before everything works (A common mistake that even I made often), the `Block` needs to be in the group of `TweenGroup` defined in `[LuaTweener]`

~~~~
[Block]
Meter=Image
Group=Tweenable
W=#BlockSize#
H=#BlockSize#
SolidColor=130,130,100
~~~~

And now we're done!! Save the skin and load it. Hover your mouse on the sky, and the block will fall. PS the block reverse back up when you leave the sky.

## What to do next
This is just a small part of what LuaTween can do. Go check the Welcome.ini skin in this repo, it demonstrates LuaTween's fullest potential :)

Happy Tweening!