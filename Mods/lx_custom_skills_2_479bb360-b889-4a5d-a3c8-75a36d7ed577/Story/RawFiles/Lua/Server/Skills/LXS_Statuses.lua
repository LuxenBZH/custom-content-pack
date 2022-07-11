---- Neurotoxin
--- @param character string GUID
--- @param status string Status Name
--- @param causee string GUID
Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", function(character, status, causee)
    if status == "LX_NEUROTOXIN" then
        if Ext.GetCharacter(character).Stats.CurrentMagicArmor < 1 then
            ApplyStatus(character, "LX_NEUROTOXIN_APPLY", 6.0, 1)
            ApplyStatus(character, "STUNNED", 6.0, 1)
        end
    end
    if status == "LX_MASSTELEPORT" then
        ApplyStatus(character, "DEACTIVATED", -1.0, 1, character)
        ApplyStatus(character, "SRP_VLOCK", -1.0, 1, character)
        PlayEffect(character, "RS3_FX_GP_Status_Windwalker_01_Reappear", "Dummy_BodyFX")
    end
end)

Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "before", function(character)
    ClearTag(character, "LXS_BloodLustSatisfied")
end)

-- Sinfusion
local function Sinfusion_IncreaseDamage(target, instigator, damage, hitHandle)
if ObjectIsCharacter(instigator) == 0 then return end
if HasActiveStatus(instigator, "LX_SINFUSION_UNKNOWN") == 1 then
    if NRD_HitGetString(hitHandle, "DamageType") ~= "Shadow" then
        local realdmg = damage - NRD_HitGetDamage(hitHandle, "Shadow")
        NRD_HitAddDamage(hitHandle, "Shadow", math.ceil(realdmg*0.3))
    end
end
end

Ext.RegisterOsirisListener("NRD_OnPrepareHit", 4, "after", Sinfusion_IncreaseDamage)

Ext.RegisterOsirisListener("NRD_OnStatusAttempt", 4, "before", function(character, status, handle, causee)
    if HasActiveStatus(character, "LX_DUMMY_NOSHOCKWAVE") == 1 and status == "SHOCKWAVE" then
        NRD_StatusPreventApply(character, handle, 1)
        RemoveStatus(character, "LX_DUMMY_NOSHOCKWAVE")
        -- ChainAnimations(character, "knockdown_fall", "knockdown_getup")
        -- PlayAnimation(character, "knockdown_fall")
        -- CharacterSetAnimationOverride(character, "knockdown_fall")
        -- CharacterSetAnimationOverride(character, "knockdown_getup")
        -- CharacterSetAnimationOverride(character, "still")
    end
end)

RegisterHitConditionListener("StatusHitEnter", "OnHit", function(statusHit, instigator, target, flags)
    if target:GetStatus("LX_SE_SPIRITUALDEFENSE") and flags.IsDirectAttack then
        if math.random(1, 100) <= 20 then
            GameHelpers.Skill.SetCooldown(target, "Summon_LX_SpiritDeer", math.max(NRD_SkillGetCooldown(target, "Summon_LX_SpiritDeer") - 6.0))
            GameHelpers.Skill.SetCooldown(target, "Summon_LX_SpiritCoyote", math.max(NRD_SkillGetCooldown(target, "Summon_LX_SpiritCoyote") - 6.0))
        end
    elseif instigator:GetStatus("LX_BELLYDRUM") and flags.IsDirectAttack then
        RemoveStatus(instigator.MyGuid, "LX_BELLYDRUM")
    end
end, "OnHit", "StatusHitEnter")

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "before", function(char, status, source)
    if status == "LX_SE_TWINSCONFIDENCE" and HasActiveStatus(char, "LX_SE_TWINSCONFIDENCE_AURA") == 1  or
     status == "LX_SE_TWINSCONFIDENCE_AURA" and HasActiveStatus(char, "LX_SE_TWINSCONFIDENCE") == 1 then
        ApplyStatus(char, "LX_SE_TWINSCONFIDENCE_EFFECT", -1.0, 1, source)
    end
    if status == "LX_TAMEDBEAST" and HasActiveStatus(char, "LX_TAMEDBEAST_UNIT") == 1 then
        RemoveStatus(char, "ENRAGED")
    end
    if status == "LX_SHAPESHIELD" then
        ApplyStatus(char, "LX_SHAPESHIELD_PHYSICAL", -1, 1, char)
    end
end)

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", function(char, status, source)
    if status == "LX_SE_TWINSCONFIDENCE" then
        RemoveStatus(char, "LX_SE_TWINSCONFIDENCE_EFFECT")
    end
    if status == "LX_TAMEDBEAST" and HasActiveStatus(char, "LX_TAMEDBEAST_UNIT") == 1 and CharacterIsInCombat(char) == 1 then
        ApplyStatus(char, "ENRAGED", -1, 1, char)
    end
    if status == "LX_SHAPESHIELD" then
        RemoveStatus(char, "LX_SHAPESHIELD_PHYSICAL")
        RemoveStatus(char, "LX_SHAPESHIELD_MAGICAL")
    end
end)

local fireSurfaces = {
    Ground = {
        SurfaceFire = true,
        SurfaceFireCursed = true,
    },
    Cloud = {
        SurfaceFireCloud = true,
        SurfaceFireCloudCursed = true,
    }
}

RegisterTurnTrueEndListener(function(char)
    if HasActiveStatus(char, "LX_SCORCHINGFLAMES") == 1 then
        local character = Ext.GetCharacter(char)
        local position = character.WorldPos
        local grid = Ext.GetAiGrid()
        local scale = grid.GridScale
        local multiplier = 1
        local surface = GetSurfaceGroundAt(char)
        local cloud = GetSurfaceCloudAt(char)
        if fireSurfaces.Ground[surface] or fireSurfaces.Cloud[cloud] then
            local scorch = character:GetStatus("LX_SCORCHED")
            if scorch then
                multiplier = scorch.StatsMultiplier + 1
            end
            local source = Ext.GetCharacter(character:GetStatus("LX_SCORCHINGFLAMES").StatusSourceHandle)
            local new = Ext.PrepareStatus(char, "LX_SCORCHED", 12.0)
            new.StatsMultiplier = multiplier
            new.StatusSourceHandle = source.Handle
            Ext.ApplyStatus(new)
        end
    end
end)

RegisterHitConditionListener("StatusHitEnter", "OnMelee", function(status, instigator, target, flags)
    if (flags.Critical or flags.Dodged or flags.Missed) and not target:HasTag("LX_SE_DuelistBucklerUsed") and target:GetStatus("LX_SE_DUELISTBUCKLER") then
        ApplyStatus(instigator.MyGuid, "LX_DUMMY_NOSHOCKWAVE", 6.0, 1, instigator.MyGuid)
        CharacterUseSkill(target.MyGuid, "Target_LX_DuelistBucklerBash", instigator.MyGuid, 1, 1, 0)
        ApplyStatus(target.MyGuid, "UNSHEATHED", -1, 1, target.MyGuid)
        SetTag(target.MyGuid, "LX_SE_DuelistBucklerUsed")
    end
    if not (flags.Missed or flags.Dodged) and instigator:GetStatus("LX_SE_SCORCHEDMIND") then
        for i,s in pairs(instigator:GetStatuses()) do
            local stat = Ext.GetStat(s).StatsId
            if stat ~= "" and Ext.GetStat(stat).BonusWeapon ~= "" then
                if not target:GetStatus("FIREBLOOD") then
                    ApplyStatus(target.MyGuid, "FIREBLOOD", 6.0, 1, instigator.MyGuid)
                    break
                end
            end
        end
    end
end)

RegisterTurnTrueStartListener(function(character)
    if IsTagged(character, "LX_SE_DuelistBucklerUsed") == 1 then
        ClearTag(character, "LX_SE_DuelistBucklerUsed")
    end
end)

--- @param target EsvItem|EsvCharacter
RegisterHitConditionListener("StatusHitEnter", "OnHit", function(status, instigator, target, flags)
    if target:GetStatus("LX_STURDINESS_LOW") then
        local threshold = Game.Math.GetAverageLevelDamage((target.LevelOverride or target.Stats.Level))*1
        if status.Hit.TotalDamageDone < threshold then
            status.Hit.DamageList:Clear()
        end
    elseif target:GetStatus("LX_STURDINESS") then
        local threshold = Game.Math.GetLevelScaledDamage(target.LevelOverride or target.Stats.Level)*3
        if status.Hit.TotalDamageDone < threshold then
            NRD_HitStatusClearAllDamage(target.MyGuid, status.StatusHandle)
        end
    end
    if target:GetStatus("LX_THIN_ICE") then
        RemoveStatus(target.MyGuid, "LX_THIN_ICE")
    end
end)

-- --- @param target string GUID
-- --- @param instigator string GUID
-- --- @param amount integer
-- --- @param handle double StatusHandle
-- Ext.RegisterOsirisListener("NRD_OnHeal", 4, "before", function(target, instigator, amount, handle)
--     -- Ext.Print(instigator, handle)
--     local heal = Ext.GetStatus(target, handle) ---@type EsvStatusHeal
--     if HasActiveStatus(target, "LX_MECHANIC") == 1 or IsTagged(target, "MECHANIC") then
--         heal.HealAmount = 0
--     end
-- end)

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", function(character, status, causee)
    if status == "LX_TEMPORARY_CHARACTER" then
        RemoveTemporaryCharacter(character)
    end
end)

Ext.RegisterOsirisListener("NRD_OnStatusAttempt", 4, "before", function(target, statusid, handle, instigator)
    if statusid == "LX_TIMEBOMB" then
        if Ext.GetCharacter(target).Stats.Movement <= 100 then
            NRD_StatusPreventApply(target, handle, 1)
        end
    end
end)