--- @alias HookEvent string | "StatusHitEnter" | "ComputeCharacterHit"
--- @alias HitEvent string | "OnMelee" | "OnRanged" | "OnWeaponHit" | "OnHit"
--- @alias HitConditionCallback fun(status:EsvStatusHit, instigator:EsvCharacter, target:EsvCharacter, flags:HitFlags):void

--- @class HitHooks
--- @field StatusHitEnter array[]
--- @field ComputeCharacterHit array[]
HitHooks = {
    StatusHitEnter = {
        OnMelee = {},
        OnRanged = {},
        OnWeaponHit = {},
        OnHit = {},
    },
    ComputeCharacterHit = {},
}

--- @param hook HookEvent
--- @param event HitEvent
--- @param func HitConditionCallback
function RegisterHitConditionListener(hook, event, func)
    table.insert(HitHooks[hook][event], {
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

--- @class HitFlags
--- @field Dodged boolean
--- @field Missed boolean
--- @field Critical boolean
--- @field Backstab boolean
--- @field DamageSourceType CauseType
--- @field Blocked boolean
--- @field IsDirectAttack boolean
--- @field IsWeaponAttack boolean
HitFlags = {
    Dodged = false,
    Missed = false,
    Critical = false,
    Backstab = false,
    DamageSourceType = "",
    Blocked = false,
    IsDirectAttack = false,
    IsWeaponAttack = false
}

HitFlags.__index = HitFlags

function HitFlags:Create()
    local this = {}
    setmetatable(this, self)
    return this
end


---@param status EsvStatusHit
---@param context HitContext
Ext.RegisterListener("StatusHitEnter", function(status, context)
    local pass, target = pcall(Ext.GetCharacter, status.TargetHandle) ---@type EsvCharacter
    if not pass then 
        pass, target = pcall(Ext.GetItem, status.TargetHandle) ---@type EsvItem
        if not pass then return end
    end
    local pass, instigator = pcall(Ext.GetCharacter, status.StatusSourceHandle) ---@type EsvCharacter
    if not pass then return end
    if instigator == nil then return end
    local multiplier = 1.0
    local flags = HitFlags:Create()
    flags.Dodged = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Dodged") == 1
    flags.Missed = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Missed") == 1
    flags.Critical = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "CriticalHit") == 1
    flags.Backstab = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Backstab") == 1
    flags.DamageSourceType = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "DamageSourceType") == 1
    flags.Blocked = NRD_StatusGetInt(target.MyGuid, status.StatusHandle, "Blocked") == 1
    flags.IsDirectAttack = status.DamageSourceType == "Attack" or status.SkillId ~= ""
    flags.IsWeaponAttack = status.Hit.HitWithWeapon

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
    if Ext.GetItem(status.WeaponHandle) and not Game.Math.IsRangedWeapon(Ext.GetItem(status.WeaponHandle).Stats) then
        TriggerHooks("StatusHitEnter", "OnMelee", status, instigator, target, flags)
    end
    -- SpecialEffects.OceansTrident(status.WeaponHandle, instigator, status, target, dodged, missed)
end)