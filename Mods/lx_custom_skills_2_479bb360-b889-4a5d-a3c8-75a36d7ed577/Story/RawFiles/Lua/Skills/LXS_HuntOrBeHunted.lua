-- Hunt or be Hunted
-- local function HuntOrBeHunted_CatchAttack(target, instigator, damage, statushandle)
--     if ObjectIsCharacter(instigator) == 0 then return end
--     if HasActiveStatus(instigator, "LX_HUNTHUNTED") == 1 then
--         SetVarInteger(instigator, "LXS_UsedHuntHunted", 1)
--         ApplyStatus(instigator, "LX_ONTHEHUNT", 6.0, 1)
--     end
-- end

-- Ext.RegisterOsirisListener("NRD_OnHit", 4, "after", HuntOrBeHunted_CatchAttack)

local function HuntOrBeHunted_CatchFlee(character, status, causee)
if status ~= "LX_HUNTHUNTED" then return end
    if GetVarInteger(character, "LXS_UsedHuntHunted") ~= 1 then
        ApplyStatus(character, "LX_HUNTISHUNTED", 6.0, 1)
    end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", HuntOrBeHunted_CatchFlee)

local function HuntOrBeHunted_Reset(character, status, causee)
    if status ~= "LX_ONTHEHUNT" then return end
        SetVarInteger(character, "LXS_UsedHuntHunted", 0)
    end
Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", HuntOrBeHunted_Reset)