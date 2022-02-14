Ext.Require("Server/Skills/LXS_DuelistLeadership.lua")
Ext.Require("Server/Skills/LXS_HuntOrBeHunted.lua")
Ext.Require("Server/Skills/LXS_Shove.lua")
Ext.Require("Server/Skills/LXS_Statuses.lua")

--- @param status EsvStatusHit
--- @param instigator EsvCharacter
--- @param target EsvCharacter
--- @param flags Boolean[]
RegisterHitConditionListener("StatusHitEnter", "OnHit", function(statusHit, instigator, target, flags)
    local skill = string.gsub(statusHit.SkillId, "%_%-1", "")
    if skill == "Rush_LX_BashingCharge" then
        Ext.ExecuteSkillPropertiesOnTarget("Projectile_LX_Shove_6", instigator.NetID, target.NetID, instigator.WorldPos, "Target", false)
    end
end)

Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "before", function(character)
    local char = Ext.GetCharacter(character)
    if char:GetStatus("LX_THERMALDUALITY") and char:GetStatus("LX_THERMALDUALITY_AURA") then
        Ext.Print("THERMAL DUALITY")
        if char.Stats.FireSpecialist > char.Stats.WaterSpecialist then
            Ext.Print("THERMAL DUALITY FIRE")
            GameHelpers.ExplodeProjectile(character, character, "Projectile_LX_ThermalDuality_FirePulse", char.Stats.Level, false)
        else
            Ext.Print("THERMAL DUALITY ICE")
            GameHelpers.ExplodeProjectile(character, character, "Projectile_LX_ThermalDuality_WaterPulseEnemy", char.Stats.Level, false)
            GameHelpers.ExplodeProjectile(character, character, "Projectile_LX_ThermalDuality_WaterPulseAlly", char.Stats.Level, false)
        end
    end
end)