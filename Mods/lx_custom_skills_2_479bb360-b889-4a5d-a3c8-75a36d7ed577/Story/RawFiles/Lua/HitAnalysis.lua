
---@param status EsvStatusHit
---@param context HitContext
Ext.RegisterListener("StatusHitEnter", function(status, context)
    local pass, target = pcall(Ext.GetCharacter, status.TargetHandle) ---@type EsvCharacter
    if not pass then return end
    local pass, instigator = pcall(Ext.GetCharacter, status.StatusSourceHandle) ---@type EsvCharacter
    if not pass then return end
    if instigator == nil then return end
    local multiplier = 1.0
    -- Ext.Print("FirstBlood:",firstBlood,firstBloodWeakened, status.DamageSourceType)
    if (status.DamageSourceType == "Attack" or status.SkillId ~= "") then
        if HasActiveStatus(instigator.MyGuid, "LX_HUNTHUNTED") == 1 then
            SetVarInteger(instigator.MyGuid, "LXS_UsedHuntHunted", 1)
            ApplyStatus(instigator.MyGuid, "LX_ONTHEHUNT", 6.0, 1)
        end
        if CharacterIsInCombat(target.MyGuid) == 1 and HasActiveStatus(instigator.MyGuid, "LX_FIRSTBLOOD") == 1 then
            ApplyStatus(instigator.MyGuid, "LX_FIRSTBLOOD_WEAKENED", 3.0, 1.0)
        end
        if HasActiveStatus(instigator.MyGuid, "LX_BLOODLUST") == 1 and IsTagged(instigator.MyGuid, "LXS_BloodLustSatisfied") == 0 then
            SetTag(instigator.MyGuid, "LXS_BloodLustSatisfied")
            CharacterAddActionPoints(instigator.MyGuid, 1)
        end
    end
    local skill = string.gsub(status.SkillId, "%_%-1", "")
    if skill == "Rush_LX_BashingCharge" then
        -- GameHelpers.ShootProjectile(instigator, target, "Projectile_LX_Shove_4", true, nil, nil, false)
        -- GameHelpers.ExplodeProjectile(instigator, target, "Projectile_LX_Shove_4")
        Ext.ExecuteSkillPropertiesOnTarget("Projectile_LX_Shove_6", instigator.NetID, target.NetID, instigator.WorldPos, "Target", false)
    end
    -- context.Hit.DamageList:Multiply(multiplier)
    -- ReplaceDamages(dmgList, status.StatusHandle, target.MyGuid)
end)