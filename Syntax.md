## Syntax
In the following example, ***Tweener.lua*** and ***tween.lua*** are located under *@Resources*. Here's the generic format for the script measure
    
~~~~
[LuaTweener]
Measure=Script
ScriptFile=#@#Tweener.lua
TweenGroup=
TweenN=
; (where N is an ordered number from 0)
~~~~

There is 2 new options introduced here:
- **TweenGroup:** The group that will be updated and redraw (Set measures and meters to this group to receive updates from tweens)

- **TweenN:** The definition of the tween. There's **two types** of tween (as of now):
    - **Single:**\
        Only tweens one section's option or one group's option. It's the simplest tween there is.
        
        Structure: *Single* | SectionName | OptionName | StartValue | EndValue | Duration | Easing(optional)

        e.g. Valid Syntax for (1) **Meter**, (2) **Measure**, (3) **Variable**, (4) **Group** tweens:

        ~~~~            
        (1) Single | MeterPopcorn | SolidColor | 0,0,0,100 | 50,50,180,255 | 100

        (2) Single | MeasureCakeSize | Formula | 10 | #MaxCakeSize# | 60 | outQuad

        (3) Single | Variable | Money | 0 | 10000 | 500 | inOutBounce

        (4) Single | BarGroup | X | 0 | 50 | 100
        ~~~~
        
    - **Chain:**\
        Create multiple tweens(child tweens) at once and call them in intervals
        
        Structure: *Chain* | SectionName | OptionName | StartValue | EndValue | Duration | Interval | SectionCount | Easing(optional)
        
        Note: Interval refers to time between start of child tweens

        e.g. Valid Syntax for (1) **Meter**, (2) **Measure**, (3) **Variable**, (4) **Group** tweens:

        ~~~~
        (1) Chain | MeterLine%% | H | 0 | (#Size# * 100) | 100 | 50 | 100

        (2) Chain | MeasureBalloonSqueak(%%+1) | Formula | 10 | 1000 | 500 | 100 | 80 | inOutExpo

        (3) Chain | Variable | BankAccount%% | 1000000 | 0.02 | 10 | 1000 | 10 | outCubic

        (4) Chain | BoxGroup(%%) | Y | 0 | 5 | 300 | 50 | 10
        ~~~~


Here's a few extra notes when using the syntax:

- *Duration* and *Interval* parameters uses **milliseconds**, NOT seconds

- Extra Syntax:
  - Use **%%** and it'll be replaced incrementally, from 0 to (SectionCount-1)\
  (Valid in Chain tweens only)
  - **ALWAYS** use () when doing calculations, this script will parse the string all calculate it for you
                    
- Easing:
  - For the full list of easings, visit https://easings.net \
  (At the website, if you want to use, say 'easeInQuint', type 'inQuint' (without quotes) instead into the tween parameter)
  - You can also check ***tween.lua*** script and search for the tween.easing table. It lists all the easings supported

## Public functions
Public functions are called by the [CommandMeasure](https://docs.rainmeter.net/manual/bangs/#CommandMeasure) bang

e.g. 
~~~~
[!CommandMeasure LuaTweener "Start(0)"]
~~~~

- **Start(index)**\
  Plays the tween forward

- **Reverse(index)**\
  Plays the tween backwards

- **Pause(index)**\
  Pauses the tween from playing
    
- **Finish(index)**\
  Sets the value to the EndValue

- **Reset(index)**\
  Sets the value to the Startalue

- **Restart(index)**\
  Calls Reset then Start together

- **Rewind(index)**\
  Calls Finish then Reverse together

- **Reinit(index)**\
  Reinitializes the tween and gets the new values (Have to be called manually, for now)

