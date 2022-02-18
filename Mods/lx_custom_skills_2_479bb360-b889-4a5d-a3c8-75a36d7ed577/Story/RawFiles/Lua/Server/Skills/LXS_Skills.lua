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
    if flags.IsWeaponAttack then
        if instigator:GetStatus("LX_SE_BARBEDSWORD") then
            if math.random(1,100) <= 35 and not instigator:GetStatus("BLEEDING") then
                ApplyStatus(instigator.MyGuid, "BLEEDING", 6.0, 0, instigator.MyGuid)
            end
        end
    end
end)

RegisterTurnTrueStartListener(function(character)
    local char = Ext.GetCharacter(character)
    if char:GetStatus("LX_THERMALDUALITY") and char:GetStatus("LX_THERMALDUALITY_AURA") then
        if char.Stats.FireSpecialist > char.Stats.WaterSpecialist then
            GameHelpers.ExplodeProjectile(character, character, "Projectile_LX_ThermalDuality_FirePulse", char.Stats.Level, false)
        else
            GameHelpers.ExplodeProjectile(character, character, "Projectile_LX_ThermalDuality_WaterPulseEnemy", char.Stats.Level, false)
            GameHelpers.ExplodeProjectile(character, character, "Projectile_LX_ThermalDuality_WaterPulseAlly", char.Stats.Level, false)
        end
    end
end)

Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "before", function(char, skill, type, element)
    if skill == "Summon_LX_SpiritDeer" then
        GameHelpers.Skill.Swap(char, "Summon_LX_SpiritDeer", "Summon_LX_SpiritCoyote", true, false)
        GameHelpers.Skill.SetCooldown(char, "Summon_LX_SpiritCoyote", NRD_SkillGetCooldown(char, "Summon_LX_SpiritDeer"))
    elseif skill == "Summon_LX_SpiritCoyote" then
        GameHelpers.Skill.Swap(char, "Summon_LX_SpiritCoyote", "Summon_LX_SpiritDeer", true, false)
        GameHelpers.Skill.SetCooldown(char, "Summon_LX_SpiritDeer", NRD_SkillGetCooldown(char, "Summon_LX_SpiritCoyote"))
    end
end)