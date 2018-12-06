--[[
    Author: Blu
    Reddit: \u\IamLUG
    Github: https://github.com/BjornLuG

    ------------------------------------------------------------

    Tweener.lua
    ~ Tween any number in Rainmeter with Lua
    ~ Supports tweening meter options, measure options, variables and groups!
    ~ Easily tween a value with lesser syntax than manual tweening in Rainmeter
    ~ Credits: https://github.com/kikito/tween.lua for the tweening and easing functions
    ~ License: https://github.com/BjornLuG/LuaTween-for-Rainmeter/blob/master/LICENSE.txt

    -------------------------------------------------------------

    For syntaxes or tutorials:
    Visit https://github.com/BjornLuG/LuaTween-for-Rainmeter/
]]--




--region Rainmeter

function Initialize()
    -- Load the tween.lua file (The file must be in the same folder as this script)
    dofile(GetAbsoluteFolderPath() .. "tween.lua")

    tweenGroup = SELF:GetOption("TweenGroup")

    dt = 0
    prevTime = os.clock()

    -- All tweens are kept here!
    tweensTable = {}
    
    -- Whether redraw is needed, if any tween is playing.
    redraw = false
    -- How many times to redraw (One frame redraws only once, 
    -- so the number will be how many frames needed to redraw)
    redrawTimes = 2
    redrawsLeft = 0

    -- Populate tweensTable
    InitAllTweens()
end

function Update()
    dt = (os.clock() - prevTime) * 1000
    prevTime = os.clock()
    
    -- Iterate all tweens
    for _,v in pairs(tweensTable) do
        UpdateTween(v)
    end
 
    if redraw then 
        redrawsLeft = redrawTimes
        redraw = false
    end

    if redrawsLeft > 0 then
        redrawsLeft = redrawsLeft - 1
        
        -- Updates and redraws group
        UpdateAndRedraw()
    end
end

--endregion



--region Public functions

-- Plays the tween forwards
function Start(index)
    if IndexInRange(tweensTable, index, "tweensTable") then
        tweensTable[index].state = 1
    end
end

-- Plays the tween backwards
function Reverse(index)
    if IndexInRange(tweensTable, index, "tweensTable") then
        tweensTable[index].state = -1
    end
end

-- Pauses the tween from playing
function Pause(index)
    if IndexInRange(tweensTable, index, "tweensTable") then
        tweensTable[index].state = 0
    end
end

-- Sets the tween clock = duration, value is the EndValue
function Finish(index)
    if IndexInRange(tweensTable, index, "tweensTable") then
        tweensTable[index].tween:finish()
        tweensTable[index].state = 1

        if tweensTable[index].tweenType == "Chain" then
            for _,vi in pairs(tweensTable[index].tweens) do
                vi.tween:finish()
            end
        end

        UpdateTween(tweensTable[index])
    end
end

-- Sets the tween clock = 0, , value is the StartValue
function Reset(index)
    if IndexInRange(tweensTable, index, "tweensTable") then
        tweensTable[index].tween:reset()
        tweensTable[index].state = -1

        if tweensTable[index].tweenType == "Chain" then
            for _,vi in pairs(tweensTable[index].tweens) do
                vi.tween:reset()
            end
        end

        UpdateTween(tweensTable[index])
    end
end

-- Combine Reset and Start
function Restart(index)
    Reset(index)
    Start(index)
end

-- Combine Finish and Reverse
function Rewind(index)
    Finish(index)
    Reverse(index)
end

-- Reinitializes the tween and gets the new values
function Reinit(index)
    ReinitTween(index)
end
--endregion



--region Private functions

-- Populate all the tweens defined
function InitAllTweens()
    local i = 0
    while true do
        if not ReinitTween(i) then break end
        i = i + 1
    end
end

-- Initializes the tween (Returns true if succeed)
function ReinitTween(index)
    -- Gets the string form TweenN
    local opt = SELF:GetOption("Tween" .. index)

    if opt == "" then return false end

    -- Get type to preform different parameters checks
    local tweenType = GetTweenDefinition(opt)

    if tweenType == "single" then
        local sectionName, optionName, startValue, endValue, duration, easing = ProcessTweenParameters(opt)

        local subject = 
        {
            tweenType = tweenType,
            sectionType = GetSectionType(sectionName),
            sectionName = sectionName,
            optionName = optionName,
            -- State will be used to play tweens (Values: -1, 0, 1 (aka Reverse, Pause, Play))
            state = 0,
            value = ToNumberTable(split(startValue, ","))
        }

        local target =
        {
            value = ToNumberTable(split(endValue, ","))
        }

        -- Create tween from tween.lua
        subject.tween = tween.new(duration, subject, target, easing)

        tweensTable[index] = subject

    elseif tweenType == "chain" then
        -- Chain works by having a parent tween that tweens its clock,
        -- child tweens will be part of parent and will played if the clock reaches the child's startTime.
        -- all of the child will be chained together by a parent
        -- For reversing parent, clock will be reversed and now child's endTime will be played if the clock reaches the child's endTime. (instead of startTime)
        local sectionName, optionName, startValue, endValue, duration, interval, tweenCount, easing = ProcessTweenChainParameters(opt)

        -- The total time needed to tween all
        local totalTime = (tweenCount - 1) * interval + duration

        local parentSubject = 
        {
            tweenType = tweenType,
            sectionType = GetSectionType(DoSub(sectionName, 0)),
            optionName = optionName,
            -- State will be used to play tweens (Values: -1, 0, 1 (aka Reverse, Pause, Play))
            state = 0,
            -- The while chains clock, this will be used to trigger child tweens
            clock = 0,
            tweens = {}
        }

        local parentTarget = 
        {
            clock = totalTime
        }

        parentSubject.tween = tween.new(totalTime, parentSubject, parentTarget, 'linear')

        -- Create child tweens
        for j=0, tweenCount-1 do
            local subject = 
            {
                sectionName = DoSub(sectionName, j),
                startTime = interval * j,
                endTime = interval * j + duration,
                -- this in charge of whether a clock has passed the time so itl only trigger the state once after passed
                passed = false,
                state = 0,
                value = ToNumberTable(split(startValue, ","), j)
            }

            local target =
            {
                value = ToNumberTable(split(endValue, ","), j)
            }

            subject.tween = tween.new(duration, subject, target, easing)

            parentSubject.tweens[j] = subject
        end

        tweensTable[index] = parentSubject
    end

    return true
end

-- return SIngle or Chain
function GetTweenDefinition(option)
    local result = split(option, "|", 1)

    assert(#result >= 1, "Parameters insufficent for \"" .. option .. "\"")

    return result[1]:lower()
end

--  return SectionName, OptionName, StartValue, EndValue, Duration, Easing
function ProcessTweenParameters(option)
    local result = split(option, "|", 7)
    
    assert(#result >= 6, "Parameters insufficent for \"" .. option .. "\"")
    assert(type(result[6] == "number"), "Duration is not a number. Its " .. result[6])

    if result[7] == nil or result[7] == "" then result[7] = 'linear' end

    return result[2], result[3], result[4], result[5], tonumber(result[6]), result[7]
end

--  return SectionName, OptionName, StartValue, EndValue, Duration, Interval, SectionCount, Easing
function ProcessTweenChainParameters(option)
    local result = split(option, "|", 9)
    
    assert(#result >= 8, "Parameters insufficent for \"" .. option .. "\"")
    assert(type(result[6] == "number"), "Duration is not a number. Its " .. result[6])
    assert(type(result[7] == "number"), "Interval is not a number. Its " .. result[7])
    assert(type(result[8] == "number"), "SectionCount is not a number. Its " .. result[8])

    if result[9] == nil or result[9] == "" then result[9] = 'linear' end
    
    return result[2], result[3], result[4], result[5], tonumber(result[6]), tonumber(result[7]), tonumber(result[8]), result[9]
end

-- whether the section supplied is a meter, measure, variable or group
function GetSectionType(sectionName)
    if sectionName:lower() == "variable" then
        return "variable"
    elseif SKIN:GetMeter(sectionName) ~= nil then
        return "meter"
    elseif SKIN:GetMeasure(sectionName) ~= nil then
        return "measure"
    else
        return "group"
    end
end

-- Updates the tween and apply the changes in RM (UpdateAndRedraw not called)
function UpdateTween(v)
    if v.tweenType == "single" then
        -- If state not equal 0, its either playing forwards or backwards
        if v.state ~= 0 then
            -- Updates the tween value and return whether tweening is done, if so set state to 0 so no more updates
            if v.tween:update(dt * v.state) then v.state = 0 end
            
            -- Apply changes in the skin
            DoTweenBang(v.sectionType, v.sectionName, v.optionName, table.concat(v.value, ","))
            
            -- Needs redraw
            redraw = true
        end

    elseif v.tweenType == "chain" then 
        -- If state not equal 0, its either playing forwards or backwards
        if v.state ~= 0 then
            -- Updates the tween value and return whether tweening is done (Cache since v.state be used below again, will set state at the end)
            local tweenDone = v.tween:update(dt * v.state)
        
            -- Iterate through all the tweens of the tweenChain
            for _,vi in pairs(v.tweens) do
                -- Check if a trigger is needed to set the tween state (The set will only occur once)
                if ChainNeedTrigger(v, vi) then 
                    -- Set the state to the parent state (play forwards or backwards)
                    vi.state = v.state
                    -- Set passed true if playing forwards, false if playing backwards
                    vi.passed = (v.state >= 1)
                end
            
                -- If state not equal 0, its either playing forwards or backwards
                if vi.state ~= 0 then
                    -- Updates the tween value and return whether tweening is done, if so set state to 0 so no more updates
                    if vi.tween:update(dt * vi.state) then vi.state = 0 end
                    
                    -- Apply changes in the skin
                    DoTweenBang(v.sectionType, vi.sectionName, v.optionName, table.concat(vi.value, ","))
                    
                    -- Needs redraw
                    redraw = true
                end
            end

              -- Set state to 0 so no more updates
              if tweenDone then v.state = 0 end
        end
    end
end

-- Apply the changes in RM (Used by UpdateTween(v))
function DoTweenBang(type, sectionName, optionName, value)
    if type == "meter" or type == 'measure' then
        SKIN:Bang('!SetOption', sectionName, optionName, value)

    elseif type == "variable" then 
        SKIN:Bang('!SetVariable', optionName, value)
        
    elseif type == "group" then
        SKIN:Bang('!SetOptionGroup', sectionName, optionName, value)
    end
end

-- Update and Redraw group in RM
function UpdateAndRedraw()
    SKIN:Bang('!UpdateMeterGroup', tweenGroup)
    SKIN:Bang('!UpdateMeasureGroup', tweenGroup)
    SKIN:Bang('!RedrawGroup', tweenGroup)
end

-- Whether the chain(parent) needs to trigger the child to play (Used by UpdateTween(v))
function ChainNeedTrigger(parent, child)
    -- If playing forward, return true if clock passed the startTime but passed is not marked true
    if      parent.state >= 1  then return parent.clock >= child.startTime and not child.passed
    -- If playing forward, return true if clock passed the endTime but passed is marked true (Should be not passed)
    elseif  parent.state <= -1 then return parent.clock <= child.endTime   and     child.passed
    end
end

-- Gets the folder path containg this script
function GetAbsoluteFolderPath()
    return SELF:GetOption("ScriptFile"):match("(.*[/\\])")
end

-- Copied from https://www.lua-users.org/wiki/SplitJoin
function split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end

    if maxNb == nil or maxNb < 1 then 
        maxNb = 0 -- No limit
    end

    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos = 0

    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        result[nb] = part:gsub(" ", "")
        lastPos = pos

        if(nb == maxNb) then 
            break 
        end
    end

    if nb ~= maxNb then
        result[nb + 1] = str.sub(str, lastPos):gsub(" ", "")
    end

    return result
end

-- Substitue %% into i (a number)
function DoSub(value, i)
	return value:gsub("%%%%", i):gsub("%(.+%)", ParseFormula)
end

-- Parse string to RM to be calculated
function ParseFormula(formula)
	return SKIN:ParseFormula(formula)
end

-- String table to number table, and also call DoSub(value, i) when converting
function ToNumberTable(table, optionIndex)
    optionIndex = optionIndex or 0
    for i in pairs(table) do 
        local value = DoSub(table[i], optionIndex)
        table[i] = tonumber(value) 
    end
    return table
end

-- whether index is in table range (Param: tableName refers to the variable name of the table, used for debugging)
function IndexInRange(table, index, tableName)
    if table[index] == nil then
        error("Index out of range exception,  ".. tableName .. " doesnt contains " .. index)
        return false
    end

    return true
end

--endregion
