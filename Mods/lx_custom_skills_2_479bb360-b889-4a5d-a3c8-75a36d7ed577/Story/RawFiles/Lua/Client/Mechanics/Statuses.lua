--- @param character EsvCharacter
--- @param status string
--- @param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
    
end

local function Statuses_Tooltips_Init()
    Game.Tooltip.RegisterListener("StatusDescription", nil, OnStatusTooltip)
end

Ext.RegisterListener("SessionLoaded", Statuses_Tooltips_Init)