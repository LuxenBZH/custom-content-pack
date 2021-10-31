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