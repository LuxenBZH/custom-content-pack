

----- Oceans Trident
---@param weaponHandle int
---@param character EsvCharacter
---@param context EsvStatusHit
---@param target EsvCharacter
function OceansTridentCheck(weaponHandle, character, statusHit, target, dodged, missed)
    Ext.Dump(statusHit)
    if weaponHandle ~= nil and HasActiveStatus(character.MyGuid, "LX_SE_OCEANFIGHTER") == 1 then
        local grid = Ext.GetAiGrid()
        local pos = target.WorldPos
        local infos = grid:GetCellInfo(pos[1], pos[3])
        if (infos.Flags & surfaceFlags["Water"]) == surfaceFlags["Water"] or (infos.Flags & surfaceFlags["WaterCloud"] == surfaceFlags["WaterCloud"]) and not (dodged or missed) then
            local totalDamage = statusHit.Hit.TotalDamageDone
            local damages = statusHit.Hit.DamageList
            damages:Add("Water", math.floor(totalDamage*0.15))
            ReplaceDamages(damages:ToTable(), statusHit.StatusHandle, target.MyGuid)
            -- statusHit.Hit.DamageList = damages
            ApplyStatus(target.MyGuid, "WET", 12.0)
        end
    end
end

SpecialEffects.OceansTrident = OceansTridentCheck