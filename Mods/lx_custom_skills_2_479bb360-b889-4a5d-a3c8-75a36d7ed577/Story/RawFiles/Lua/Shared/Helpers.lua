function ConvertToUUID(guid)
    local result = string.gsub(guid, ".*_", "")
    return result
end

function GetHitDamages(target, handle)
    local dmgList = {}
    for i,dmgType in pairs(damageTypes) do
        local dmg = NRD_HitStatusGetDamage(target, handle, dmgType)
        if dmg ~= 0 then
            dmgList[dmgType] = NRD_HitStatusGetDamage(target, handle, dmgType)
        end
    end
    return dmgList
end

---@param newDamages table
---@param handle number
---@param target EsvCharacter
function ReplaceDamages(newDamages, handle, target)
	NRD_HitStatusClearAllDamage(target, handle)
	for dmgType,amount in pairs(newDamages) do
		NRD_HitStatusAddDamage(target, handle, dmgType, amount)
	end
end

damageTypes = {
    "None",
    "Physical",
    "Piercing",
    "Fire",
    "Air",
    "Water",
    "Earth",
    "Poison",
    "Shadow",
    "Corrosive",
    "Magic"
}

for i,j in pairs(Mods) do
    Ext.Print(i,j)
end
-- Mods.LeaderLib.Import(Mods.LuxensGameplayExpansion)
-- ExplodeSkill = Mods.LeaderLib.ExplodeSkill