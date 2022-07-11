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
---@param target String
function ReplaceDamages(newDamages, handle, target)
	NRD_HitStatusClearAllDamage(target, handle)
	for i,tab in pairs(newDamages) do
		NRD_HitStatusAddDamage(target, handle, tab.DamageType, tab.Amount)
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

surfaceFlags = {
	MovementBlock = 0x1,
	ProjectileBlock = 0x4,
	HasCharacter = 0x10,
	HasItem = 0x80,
	HasInteractableObject = 0x100,
	GroundSurfaceBlock = 0x200,
	CloudSurfaceBlock = 0x400,
	Occupied = 0x1000,
	SurfaceExclude = 0x10000,
	Fire = 0x1000000,
	Water = 0x2000000,
	Blood = 0x4000000,
	Poison = 0x8000000,
	Oil = 0x10000000,
	Lava = 0x20000000,
	Source = 0x40000000,
	Web = 0x80000000,
	Deepwater = 0x100000000,
	Sulfurium = 0x200000000,
	FireCloud = 0x800000000,
	WaterCloud = 0x1000000000,
	BloodCloud = 0x2000000000,
	PoisonCloud = 0x4000000000,
	SmokeCloud = 0x8000000000,
	ExplosionCloud = 0x10000000000,
	FrostCloud = 0x20000000000,
	Deathfog = 0x40000000000,
	ShockwaveCloud = 0x80000000000,
	Blessed = 0x400000000000,
	Cursed = 0x800000000000,
	Purified = 0x1000000000000,
	CloudBlessed = 0x4000000000000,
	CloudCursed = 0x8000000000000,
	CloudPurified = 0x10000000000000,
	Electrified = 0x40000000000000,
	Frozen = 0x80000000000000,
	CloudElectrified = 0x100000000000000,
	ElectrifiedDecay = 0x200000000000000,
	SomeDecay = 0x400000000000000,
	Irreplaceable = 0x4000000000000000,
	IrreplaceableCloud = 0x800000000000000,
}

damageTypes = {
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

magicDamageTypes = {
    "Fire",
    "Air",
    "Water",
    "Earth",
    "Poison",
    "Magic"
}

physicalDamageTypes = {
    "Physical",
    "Corrosive"
}

--- @param hit HitRequest
function HitGetMagicDamage(hit)
    local total = 0
    for i,dmgType in pairs(magicDamageTypes) do
        total = total + hit.DamageList:GetByType(dmgType)
    end
    return total
end

--- @param hit HitRequest
function HitGetPhysicalDamage(hit)
    local total = 0
    for i,dmgType in pairs(physicalDamageTypes) do
        total = total + hit.DamageList:GetByType(dmgType)
    end
    return total
end

--- @param hit HitRequest
function HitGetTotalDamage(hit)
    local total = 0
    for i,dmgType in pairs(damageTypes) do
        total = total + hit.DamageList:GetByType(dmgType)
    end
    return total
end

--- @param hit HitRequest
--- @param target EsvCharacter
function HitRecalculateAbsorb(hit, target)
    if getmetatable(target) == "esv::Character" then
        local physDmg = HitGetPhysicalDamage(hit)
        local magicDmg = HitGetMagicDamage(hit)
        local pArmourAbsorb = math.min(target.Stats.CurrentArmor, physDmg)
        local mArmourAbsorb = math.min(target.Stats.CurrentMagicArmor, magicDmg)
        hit.ArmorAbsorption = math.min(pArmourAbsorb + mArmourAbsorb, hit.TotalDamageDone)
    end
end

--- @param hit HitRequest
--- @param target EsvCharacter
--- @param instigator EsvCharacter
function HitRecalculateLifesteal(hit, instigator)
    if (hit.EffectFlags & Game.Math.HitFlag.DoT) == Game.Math.HitFlag.DoT or (hit.EffectFlags & Game.Math.HitFlag.Surface) == Game.Math.HitFlag.Surface then return end
    hit.LifeSteal = math.floor(Ext.Round((instigator.Stats.LifeSteal / 100) * (hit.TotalDamageDone - hit.ArmorAbsorption)))
end

--- @param hit HitRequest
--- @param target EsvCharacter
--- @param instigator EsvCharacter
--- @param damageType string
--- @param amount integer
function HitAddDamage(hit, target, instigator, damageType, amount)
    hit.TotalDamageDone = math.ceil(hit.TotalDamageDone + amount)
    hit.DamageList:Add(damageType, amount)
    HitRecalculateAbsorb(hit, target)
    if instigator ~= nil then
        HitRecalculateLifesteal(hit, instigator)
    end
end

--- @param hit HitRequest
--- @param target EsvCharacter
function HitMultiplyDamage(hit, target, instigator, multiplier)
    hit.DamageList:Multiply(multiplier)
    hit.TotalDamageDone = HitGetTotalDamage(hit)
    HitRecalculateAbsorb(hit, target)
    if instigator ~= nil then
        HitRecalculateLifesteal(hit, instigator)
    end
end
