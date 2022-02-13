HitHooks = {
    StatusHitEnter = {
        OnMelee = {},
        OnRanged = {},
        OnWeaponHit = {},
        OnHit = {},
    },
    ComputeCharacterHit = {},
}

--- @param hook string StatusHitEnter | ComputeCharacterHit
--- @param event string OnMelee | OnRanged | OnWeaponHit| OnHit
--- @param func function callback
function RegisterHitConditionListener(hook, event, func)
    table.insert(HitHook[hook][event], {
        Name = "",
        Handle = func
    })
end

function TriggerHooks(hook, event, ...)
    local params = {...}
    for i,j in pairs(HitHooks[hook][event]) do
        j.Handle(table.unpack(params))
    end
end


---@param status EsvStatusHit
---@param context HitContext
Ext.RegisterListener("StatusHitEnter", function(status, context)
    local pass, target = pcall(Ext.GetCharacter, status.TargetHandle) ---@type EsvCharacter
    if not pass then return end
    local pass, instigator = pcall(Ext.GetCharacter, status.StatusSourceHandle) ---@type EsvCharacter
    if not pass then return end
    if instigator == nil then return end
    local multiplier = 1.0
    local flags = {
        Dodged = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Dodged"),
        Missed = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Missed"),
        Critical = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "CriticalHit"),
        Backstab = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Backstab"),
        DamageSourceType = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "DamageSourceType"),
        Blocked = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Blocked")
    }
    
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
    TriggerHooks("StatusHitEnter", "OnHit", status, instigator, target, flags)
    SpecialEffects.OceansTrident(status.WeaponHandle, instigator, status, target, dodged, missed)
end)