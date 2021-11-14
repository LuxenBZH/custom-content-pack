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