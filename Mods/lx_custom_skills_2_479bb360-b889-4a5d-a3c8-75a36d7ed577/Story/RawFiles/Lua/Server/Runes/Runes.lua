Ext.Require("Server/Runes/RunesHelpers.lua")

local customRunes = {
    ["f683ef30-97a1-48df-af3a-af13130bfa3b"] = true,
    ["3edd65ad-1aa4-43e1-9d27-be764987263b"] = true,
    ["07c61b74-b2b4-4cc2-810f-0b92e75a116f"] = true,
    ["c66c7a04-759d-4c9c-8590-771140da01bb"] = true,
    ["d9a0e3f7-ff50-433c-a03d-e43ff85d5ed0"] = true
}

---- Set special runes only in amulet slot
local function CheckRuneSlotSocket(character, item, runeTemplate, slot)
    local itemSlot = Ext.GetItem(item).Stats.Slot
    if itemSlot ~= "Amulet"  then
        if customRunes[ConvertToUUID(runeTemplate)] then
            ItemRemoveRune(character, item, slot)
            OpenMessageBox(character, "You can only insert this rune in an amulet socket.")
        end
    end
end

Ext.RegisterOsirisListener("RuneInserted", 4, "before", CheckRuneSlotSocket)

-------- Rune effects
---- Rune of Clear Mind
Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(character, ...)
    if ObjectIsCharacter(character) ~= 1 then return end
    if LookRunesForTag(character, "LX_RUNE_CLEAR_MIND") then
        ApplyStatus(character, "CLEAR_MINDED", 12.0, 1)
    end
end)

---- Rune of Darlan and Kamlan
Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", function(character, skill, skillType, skillElement)
    if skillElement == "Earth" then
        if LookRunesForTag(character, "LX_RUNE_DARLAN") then
            ApplyStatus(character, "LX_DARLAN_BLESSING", 0.0, 1)
            ApplyStatus(character, "LX_DARLAN_BLESSING_BONUS", 0.0, 1)
        end
    end
    if skillElement == "Water" then
        if LookRunesForTag(character, "LX_RUNE_KAMLAN") then
            ApplyStatus(character, "LX_KAMLAN_BLESSING", 0.0, 1)
            ApplyStatus(character, "LX_KAMLAN_BLESSING_BONUS", 0.0, 1)
        end
    end
end)

---- Rune of First Blood
Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "after", function(object)
    if ObjectIsCharacter(object) == 1 and LookRunesForTag(object, "LX_RUNE_FIRSTBLOOD") then
        ApplyStatus(object, "LX_FIRSTBLOOD", 3.0, 1.0)
    end
end)

Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "after", function(object)
    if ObjectIsCharacter(object) == 1 and LookRunesForTag(object, "LX_RUNE_FIRSTBLOOD") then
        RemoveStatus(object, "LX_FIRSTBLOOD")
        RemoveStatus(object, "LX_FIRSTBLOOD_WEAKENED")
    end
end)

---- Rune of Stoicism
local stoicismList = {
    "CLEAR_MINDED",
    "MEND_METAL",
    "MEND_METAL",
    "FORTIFIED",
    "MAGIC_SHELL",
    "FROST_AURA",
    "FROST_AURA",
    "HASTED",
    "BREATHING_BUBBLE",
    "BREATHING_BUBBLE",
    "VAMPIRISM"
}

Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "after", function(object)
    if ObjectIsCharacter(object) == 1 and Ext.GetCharacter(object).Stats.TALENT_WalkItOff and LookRunesForTag(object, "LX_RUNE_STOICISM") then
        local roll = math.random(1, #stoicismList)
        if HasActiveStatus(object, stoicismList[roll]) == 0 or GetStatusTurn(object, stoicismList[roll]) < 2 then
            ApplyStatus(object, stoicismList[roll], 6.0, 1.0)
        end
    end
end)