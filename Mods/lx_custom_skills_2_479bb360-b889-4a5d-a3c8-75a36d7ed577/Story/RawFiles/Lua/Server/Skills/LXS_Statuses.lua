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
        ApplyStatus(character, "DEACTIVATED", -1.0, 1)
        ApplyStatus(character, "SRP_VLOCK", -1.0, 1)
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

--- @param status EsvStatusHit
--- @param instigator EsvCharacter
--- @param target EsvCharacter
--- @param flags Boolean[]
RegisterHitConditionListener("StatusHitEnter", "OnHit", function(statusHit, instigator, target, flags)
    if target:GetStatus("LX_SE_SPIRITUALDEFENSE") and flags.IsDirectAttack then
        if math.roll(1, 100) <= 20 then
            GameHelpers.Skill.SetCooldown(target, "Summon_LX_SpiritDeer", math.max(NRD_SkillGetCooldown(target, "Summon_LX_SpiritDeer") - 6.0))
            GameHelpers.Skill.SetCooldown(target, "Summon_LX_SpiritCoyote", math.max(NRD_SkillGetCooldown(target, "Summon_LX_SpiritCoyote") - 6.0))
        end
    end
end)

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "before", function(char, status, source)
    if status == "LX_SE_TWINSCONFIDENCE" and HasActiveStatus(char, "LX_SE_TWINSCONFIDENCE_AURA") == 1  or
     status == "LX_SE_TWINSCONFIDENCE_AURA" and HasActiveStatus(char, "LX_SE_TWINSCONFIDENCE") == 1 then
        ApplyStatus(char, "LX_SE_TWINSCONFIDENCE_EFFECT", -1.0, 1, source)
    end
    if status == "LX_TAMEDBEAST" and HasActiveStatus(char, "LX_TAMEDBEAST_UNIT") == 1 then
        RemoveStatus(char, "ENRAGED")
    end
end)

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", function(char, status, source)
    if status == "LX_SE_TWINSCONFIDENCE" then
        RemoveStatus(char, "LX_SE_TWINSCONFIDENCE_EFFECT")
    end
    if status == "LX_TAMEDBEAST" and HasActiveStatus(char, "LX_TAMEDBEAST_UNIT") == 1 and CharacterIsInCombat(char) == 1 then
        ApplyStatus(char, "ENRAGED", -1, 1, char)
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
