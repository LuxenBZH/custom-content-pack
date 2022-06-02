
--- @param status EsvStatusHit
--- @param instigator EsvCharacter
--- @param target EsvCharacter
--- @param flags Boolean[]
RegisterHitConditionListener("StatusHitEnter", "OnHit", function(statusHit, instigator, target, flags)
    -- BARBED SWORD
    if instigator:GetStatus("LX_BARBEDSWORD") then
        local roll = math.random(1, 100)
        if roll < 51 then
            local bleeding = Ext.PrepareStatus(instigator, "BLEEDING", 12.0)
            bleeding.StatusSourceHandle = instigator.Handle
            Ext.ApplyStatus(bleeding)
        end
    end
    -- OCEAN TRIDENT
    local weaponHandle = statusHit.WeaponHandle
    if weaponHandle ~= nil and instigator:GetStatus("LX_SE_OCEANFIGHTER") then
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
end)


---- SHAPESHIELD
Ext.RegisterOsirisListener("ItemTemplateEquipped", 2, "before", function(item, character)
    if item =="8ea9b1d5-8fe3-44c0-8729-ab092f3f297f" then
        ApplyStatus(character, "LX_SHAPESHIELD_PHYSICAL", -1.0, 1)
    end
end)

Ext.RegisterOsirisListener("ItemTemplateUnEquipped", 2, "before", function(item, character)
    if item =="8ea9b1d5-8fe3-44c0-8729-ab092f3f297f" then
        RemoveStatus(character, "LX_SHAPESHIELD_PHYSICAL")
        RemoveStatus(character, "LX_SHAPESHIELD_MAGICAL")
    end
end)