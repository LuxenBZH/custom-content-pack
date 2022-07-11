local customRunes = {
    ["f683ef30-97a1-48df-af3a-af13130bfa3b"] = "Amulet",    -- Clear Mind
    ["3edd65ad-1aa4-43e1-9d27-be764987263b"] = "Amulet",    -- Darlan
    ["07c61b74-b2b4-4cc2-810f-0b92e75a116f"] = "Amulet",    -- Kamlan
    ["c66c7a04-759d-4c9c-8590-771140da01bb"] = "Weapon",    -- First Blood
    ["d9a0e3f7-ff50-433c-a03d-e43ff85d5ed0"] = "Amulet",    -- Stoicism
    ["1fef2c84-a778-4fbf-b143-24dd57ba8fb6"] = "Weapon",    -- Degeneration
    ["f01f06f9-2e87-40b9-83cc-3562ab3396d5"] = "Amulet",    -- Lost Vision
    ["01b6f1a3-c024-4ad4-86e2-2503a21a2b98"] = "Weapon",    -- Putrefaction
    ["6bebc80e-38b0-4d2d-b457-31c4be885dc9"] = "Amulet",    -- Scryer
}

---- Set special runes only in amulet slot
local function CheckRuneSlotSocket(character, item, runeTemplate, slot)
    local item = Ext.GetItem(item) -- @type EsvItem
    if customRunes[ConvertToUUID(runeTemplate)] and item.Stats.Slot ~= customRunes[ConvertToUUID(runeTemplate)]  then
        ItemRemoveRune(character, item.MyGuid, slot)
        OpenMessageBox(character, "You can not insert this rune in this equipment socket.")
    end
end

Ext.RegisterOsirisListener("RuneInserted", 4, "before", CheckRuneSlotSocket)

-------- Rune effects
---- Rune of Clear Mind
Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(character, ...)
    if ObjectIsCharacter(character) ~= 1 then return end
    if LookRunesForTag(character, "LX_RUNE_CLEAR_MIND") then
        ApplyStatus(character, "CLEAR_MINDED", 12.0, 1, character)
    end
end)

---- Rune of Darlan and Kamlan
Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", function(character, skill, skillType, skillElement)
    if skillElement == "Earth" then
        if LookRunesForTag(character, "LX_RUNE_DARLAN") then
            ApplyStatus(character, "LX_DARLAN_BLESSING", 0.0, 1, character)
            ApplyStatus(character, "LX_DARLAN_BLESSING_BONUS", 0.0, 1, character)
        end
    end
    if skillElement == "Water" then
        if LookRunesForTag(character, "LX_RUNE_KAMLAN") then
            ApplyStatus(character, "LX_KAMLAN_BLESSING", 0.0, 1, character)
            ApplyStatus(character, "LX_KAMLAN_BLESSING_BONUS", 0.0, 1, character)
        end
    end
end)

---- Rune of First Blood
RegisterTurnTrueStartListener(function(object)
    if ObjectIsCharacter(object) == 1 and LookRunesForTag(object, "LX_RUNE_FIRSTBLOOD") then
        ApplyStatus(object, "LX_FIRSTBLOOD", 3.0, 1.0, object)
    end
end)

RegisterTurnTrueEndListener(function(object)
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

RegisterTurnTrueEndListener(function(object)
    if ObjectIsCharacter(object) == 1 and Ext.GetCharacter(object).Stats.TALENT_WalkItOff and LookRunesForTag(object, "LX_RUNE_STOICISM") then
        local roll = math.random(1, #stoicismList)
        if HasActiveStatus(object, stoicismList[roll]) == 0 or GetStatusTurn(object, stoicismList[roll]) < 2 then
            ApplyStatus(object, stoicismList[roll], 6.0, 1.0, object)
        end
    end
end)


---- Rune of Scryer, Lost Vision
Ext.RegisterOsirisListener("NRD_OnStatusAttempt", 4, "before", function(target, statusID, handle, instigator)
    if statusID == "BLIND" and LookRunesForTag(instigator, "LX_RUNE_LOSTVISION") then
        local status = Ext.GetStatus(target, handle)
        status.StatsMultiplier = 2.0
    elseif statusID == "CLEAR_MINDED" and LookRunesForTag(instigator, "LX_RUNE_SCRYER") then
        local status = Ext.GetStatus(target, handle)
        status.StatsMultiplier = 1.5
    end
end)

---- Rune of Degeneration
RegisterHitConditionListener("StatusHitEnter", "OnHit", function(status, instigator, target, flags)
    if LookRunesForTag(instigator.MyGuid, "LX_RUNE_DEGENERATION") then
        local damages = status.Hit.DamageList
        local corrosive = damages:GetByType("Corrosive")
        local magic = damages:GetByType("Magic")
        Ext.Dump(damages:ToTable())
        HitAddDamage(status.Hit, target, instigator, "Corrosive", Ext.Round(corrosive*0.25))
        HitAddDamage(status.Hit, target, instigator, "Magic", Ext.Round(magic*0.25))
    end
end)

---- Rune of Putrefaction  
RegisterHitConditionListener("StatusHitEnter", "OnHit", function(status, instigator, target, flags)
    if LookRunesForTag(instigator.MyGuid, "LX_RUNE_PUTREFACTION") then
        if status.SkillId == "Projectile_CorpseExplosion_Explosion" then
            if not target:GetStatus("DISEASED") then
                ApplyStatus(target.MyGuid, "DISEASED", 6.0, 0,instigator.MyGuid)
            end
        end
    end
end)