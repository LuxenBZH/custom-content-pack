local slotRune = {
    Amulet = "RuneEffectAmulet",
    Belt = "RuneEffectUpperbody",
    Boots = "RuneEffectUpperbody",
    Breast = "RuneEffectUpperbody",
    Gloves = "RuneEffectUpperbody",
    Helmet = "RuneEffectUpperbody",
    Horns = "RuneEffectUpperbody",
    Leggings = "RuneEffectUpperbody",
    Overhead = "RuneEffectUpperbody",
    Ring = "RuneEffectAmulet",
    Shield = "RuneEffectUpperbody",
    Weapon = "RuneEffectWeapon",
    Wings = "RuneEffectUpperbody",
}

local runeTagDescription = {
    LX_RUNE_CLEAR_MIND = "Set Clear Minded for 2 turns at the beginning of combat.",
    LX_RUNE_DARLAN = "When you cast a Geomancy skill, your physical armour is restored by 5% + 1% per Geomancy point.",
    LX_RUNE_FIRSTBLOOD = "During your turn, the first direct attack will have its damage increased by 25%, but the following attacks will do 20% less damage.",
    LX_RUNE_STOICISM = "If Walk it Off is active, at the end of your turn you are granted 1 turn of a random status in the following list: Fortified, Magic Shell, Mend Metal, Soothing Cold, Hasted, Clear Minded, Breathing Bubble or Vampiric Hunger.",
    LX_RUNE_KAMLAN = "When you cast a Hydrosophist skill, your magic armour is restored by 5% + 1% per Hydrosophist point.",
    LX_RUNE_SCRYER = "Increase the effects of Clear Minded by 50% when you apply it.",
    LX_RUNE_LOSTVISION = "Double the effects of Blind when you apply it.",
    LX_RUNE_DEGENERATION = "Increase the Corrosive and Magic damage dealt by 25%.",
    LX_RUNE_PUTREFACTION = "Corpse Explosion impacts now also apply Diseased for 1 turn."
}

local customRunes = {
    "LX_LOOT_Rune_Special_Clear_Mind",
    "LX_LOOT_Rune_Special_Darlan",
    "LX_LOOT_Rune_Special_FirstBlood",
    "LX_LOOT_Rune_Special_Stoicism",
    "LX_LOOT_Rune_Special_Kamlan",
    "LX_LOOT_Rune_Special_Scryer",
    "LX_LOOT_Rune_Special_LostVision",
    "LX_LOOT_Rune_Special_Degeneration",
    "LX_LOOT_Rune_Special_Putrefaction",
}

local tooltipRuneSlots = {
    Rune1 = "RuneEffectWeapon",
    Rune2 = "RuneEffectUpperbody",
    Rune3 = "RuneEffectAmulet",
}


local function GetRunesRestrictions(runes)
    local boosts = {}
    for i,rune in pairs(runes) do

    end
end

---@param item EsvItem
---@param tooltip TooltipData
local function RuneChangeTooltipsSlot(item, tooltip, ...)
    local slots = tooltip:GetElements("RuneSlot")
    for i,slot in pairs(slots) do
        local statsId = item.Stats.DynamicStats[i+2].BoostName
        local tag = Ext.GetStat(Ext.GetStat(statsId)[slotRune[item.Stats.Slot]]).Tags
        if tag ~= "" then
            slot.Value = runeTagDescription[tag].."\n"..slot.Value
        end
    end
    local effects = tooltip:GetElements("RuneEffect")
    for i, effect in pairs(effects) do
        for tooltipSlot,statSlot in pairs(tooltipRuneSlots) do
            local tag = Ext.GetStat(Ext.GetStat(item.StatsId)[statSlot]).Tags
            if tag ~= "" then
                effect[tooltipSlot] = runeTagDescription[tag].."\n"..effect[tooltipSlot]
            elseif effect[tooltipSlot] == "" then
                effect[tooltipSlot] = "-"
            end
        end
    end
end

-- ---@param item EsvItem
-- ---@param tooltip TooltipData
-- local function RuneChangeTooltipsEffect(item, tooltip, ...)
--     Ext.Print(item, tooltip)
    
-- end

local function RuneRegisterTooltips()
    Game.Tooltip.RegisterListener("Item", nil, RuneChangeTooltipsSlot)
end

Ext.RegisterListener("SessionLoaded", RuneRegisterTooltips)