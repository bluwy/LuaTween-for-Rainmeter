--[[
    Helper.lua
    - A handy tool for logic computation with the Modern UI: Launcher
--]]

function GetTitleX(titleAlign, skinPadding, skinWidth)
    titleAlign = titleAlign:lower()
    skinPadding = SKIN:ParseFormula(skinPadding)
    skinWidth = SKIN:ParseFormula(skinWidth)
    
    if titleAlign == "left" then
        return skinPadding
    elseif titleAlign == "center" then
        return skinWidth / 2
    elseif titleAlign == "right" then
        return skinWidth - skinPadding
    else 
        error("Variable TitleAlign is invalid")
    end
end

function GetIconIndex(animAlign, iconCount, index)
    animAlign = animAlign:lower()

    if animAlign == "left" then
        return index + 1

    elseif animAlign == "center" then
        local idx, start = 0, math.floor(iconCount / 2)
        local f = function(j)
            if j % 2 == 0 then return 1 else return -1 end
        end
        for i=0, index do
            start = start + idx * f(idx)
            idx = idx + 1
        end
        return start + 1
        
    elseif animAlign == "right" then
        return iconCount - index
    else
        error("Variable AnimAlign is invalid")
    end        
end