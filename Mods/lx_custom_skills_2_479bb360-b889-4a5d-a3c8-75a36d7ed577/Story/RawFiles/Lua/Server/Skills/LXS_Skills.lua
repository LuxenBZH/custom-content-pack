Ext.Require("Server/Skills/LXS_DuelistLeadership.lua")
Ext.Require("Server/Skills/LXS_HuntOrBeHunted.lua")
Ext.Require("Server/Skills/LXS_Shove.lua")
Ext.Require("Server/Skills/LXS_Statuses.lua")

if not PersistentVars.MechanicsData then
    PersistentVars.MechanicsData = {
        Spikes = {}
    }
end

--- @param status EsvStatusHit
--- @param instigator EsvCharacter
--- @param target EsvCharacter
--- @param flags Boolean[]
RegisterHitConditionListener("StatusHitEnter", "OnHit", function(statusHit, instigator, target, flags)
    local skill = string.gsub(statusHit.SkillId, "%_%-1", "")
    if skill == "Rush_LX_BashingCharge" then
        Ext.ExecuteSkillPropertiesOnTarget("Projectile_LX_Shove_6", instigator.NetID, target.NetID, instigator.WorldPos, "Target", false)
    elseif skill == "Projectile_LX_GrapplingArrow" then
        local pos = instigator.WorldPos
        local pole = TemporaryCharacterCreateAtPosition(pos[1], pos[2], pos[3], "903f0c6c-5ed6-49b9-a838-d2f98ac5cb1e", 0)
        ApplyStatus(target.MyGuid, "LX_GRAPPLING_BIND", -1, 1, pole)
        ApplyStatus(target.MyGuid, "LX_GRAPPLING_ROPE_EFFECT", -1, 1, pole)
        ApplyStatus(pole, "LX_TEMPORARY_CHARACTER", -1, 1, pole)
    elseif skill == "Projectile_LX_Special_Spike" then
        if target:GetStatus("LX_KAMLAN_SHIELD") then
            Osi.RemoveStatus(target.MyGuid, "LX_KAMLAN_SHIELD")
            Osi.CharacterUseSkill(target.MyGuid, "Shout_LX_KamlanShieldExplosion", target.MyGuid, 1, 1, 1)
        else
            Osi.ApplyStatus(target.MyGuid, "KNOCKED_DOWN", -1, 1, instigator.MyGuid)
            local spike = Osi.CreateItemTemplateAtPosition("cf999124-100c-492a-8488-804a8d8d3fb0", target.WorldPos[1], target.WorldPos[2], target.WorldPos[3])
            PersistentVars.MechanicsData.Spikes[spike] = target.MyGuid
            Osi.ItemRotateY(spike, 90, 999)
        end
    end
    if flags.IsWeaponAttack then
        if instigator:GetStatus("LX_SE_BARBEDSWORD") then
            if math.random(1,100) <= 35 and not instigator:GetStatus("BLEEDING") then
                ApplyStatus(instigator.MyGuid, "BLEEDING", 6.0, 0, instigator.MyGuid)
            end
        end
    end
end)

Ext.Osiris.RegisterListener("CharacterUsedItem", 2, "before", function(character, item)
    item = Osi.GetUUID(item)
    _P(item, PersistentVars.MechanicsData.Spikes[Osi.GetUUID(item)])
    if PersistentVars.MechanicsData.Spikes[Osi.GetUUID(item)] then
        RemoveStatus(PersistentVars.MechanicsData.Spikes[item], "KNOCKED_DOWN")
        PersistentVars.MechanicsData.Spikes[item] = nil
    end
end)

Ext.Osiris.RegisterListener("ItemMoved", 1, "before", function(item)
    item = Osi.GetUUID(item)
    _P(item, PersistentVars.MechanicsData.Spikes[Osi.GetUUID(item)])
    if PersistentVars.MechanicsData.Spikes[item] then
        RemoveStatus(PersistentVars.MechanicsData.Spikes[item], "KNOCKED_DOWN")
        PersistentVars.MechanicsData.Spikes[item] = nil
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
        local cooldown = NRD_SkillGetCooldown(char, "Summon_LX_SpiritDeer")
        GameHelpers.Skill.Swap(char, "Summon_LX_SpiritDeer", "Summon_LX_SpiritCoyote", true, false)
        GameHelpers.Skill.SetCooldown(char, "Summon_LX_SpiritCoyote", cooldown)
    elseif skill == "Summon_LX_SpiritCoyote" then
        local cooldown = NRD_SkillGetCooldown(char, "Summon_LX_SpiritCoyote")
        GameHelpers.Skill.Swap(char, "Summon_LX_SpiritCoyote", "Summon_LX_SpiritDeer", true, false)
        GameHelpers.Skill.SetCooldown(char, "Summon_LX_SpiritDeer", cooldown)
    elseif skill == "Shout_LX_SwitchShieldArmor" then
        if HasActiveStatus(char, "LX_SHAPESHIELD_PHYSICAL") == 1 then
            ApplyStatus(char, "LX_SHAPESHIELD_MAGICAL", -1, 1, char)
        else
            ApplyStatus(char, "LX_SHAPESHIELD_PHYSICAL", -1, 1, char)
        end
    end
end)

Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "before", function(character, skill, type, element)
    if skill == "Shout_LX_Collect_Frost" then
        local surfaces = {
            "WaterFrozen", "BloodFrozen", "WaterFrozenCursed", "WaterFrozenBlessed", "BloodFrozenCursed", "BloodFrozenBlessed"
        }
        local char = Ext.GetCharacter(character)
        local x = char.WorldPos[1]
        local y = char.WorldPos[3]
        local radius = Ext.GetStat(skill).AreaRadius
        local grid = Ext.GetAiGrid()
        local scale = grid.GridScale / 0.125
        local tiles = 0
        local scale = 0.5
        for i = x-radius,x+radius, scale do
            for j = y-radius,y+radius, scale do
                local info = grid:GetCellInfo(i,j)
                if ((i-x)*(i-x) + (j-y)*(j-y)) <= radius*radius then
                    for i, surfaceType in pairs(surfaces) do
                        if info ~= nil then
                            local rawType = string.gsub(surfaceType, "Blessed", "")
                            rawType = string.gsub(rawType, "Cursed", "")
                            rawType = string.gsub(rawType, "Frozen", "")
                            if (info.Flags & surfaceFlags[rawType]) == surfaceFlags[rawType] then
                                if string.match(surfaceType, "Frozen") then
                                    if (info.Flags & surfaceFlags["Frozen"]) == surfaceFlags["Frozen"] then
                                        tiles = tiles + 1
                                    end
                                    tiles = tiles + 1
                                end
                            end
                        end
                    end
                end
            end
        end
        local collected = char:GetStatus("LX_COLLECT_FROST")
        if collected then
            tiles = tiles + collected.CurrentLifeTime
        end
        _P(collected)
        ApplyStatus(character, "LX_COLLECT_FROST", tiles, 1, character)
    end
end)

Ext.RegisterOsirisListener("CharacterUsedSkillOnTarget", 5, "before", function(character, target, skill, type, element)
    if skill == "Target_LX_CollectDeliver" then
        local char = Ext.GetCharacter(character)
        local target = Ext.GetCharacter(target)
        local collected = char:GetStatus("LX_COLLECT_FROST")
        local finalCharge = target:GetStatus("LX_COLLECT_FROST")
        if collected then
            if finalCharge then
                finalCharge = finalCharge.CurrentLifeTime + collected.CurrentLifeTime
            else
                finalCharge = collected.CurrentLifeTime
            end
        end
        if finalCharge then
            ApplyStatus(target.MyGuid, "LX_COLLECT_FROST", finalCharge, 1, character)
        end
        RemoveStatus(character, "LX_COLLECT_FROST")
    end
end)