local slots = {
   "Amulet",
   "Belt",
   "Boots",
   "Breast",
   "Gloves",
   "Helmet",
   "Horns",
   "Leggings",
   "Overhead",
   "Ring",
   "Ring2",
   "Shield",
   "Weapon",
   "Wings",
}

local slotRune = {
    Amulet = "RuneEffectAmulet",
    Belt = "RuneEffectUpperbody",
    Boots = "RuneEffectUpperbody",
    Breast = "RuneEffectUpperbody",
    Gloves = "RuneEffectUpperbody",
    Helmet = "RuneEffectUpperbody",
    Horns = "RuneEffectUpperbody",
    Leggings = "RuneEffectUpperbody",
    Overhead = "RuneEffectUpperbody",
    Ring = "RuneEffectAmulet",
    Shield = "RuneEffectUpperbody",
    Weapon = "RuneEffectWeapon",
    Wings = "RuneEffectUpperbody",
}

---@param character string GUID
function GetEquipment(character)
    local equipment = {}
    local character = Ext.GetCharacter(character)
    for i,slot in pairs(slots) do
        if character.Stats:GetItemBySlot(slot) ~= nil then
            equipment[slot] = character.Stats:GetItemBySlot(slot)
        end
    end
    return equipment
end

local function GetMatchingBoost(rune, slot)
    return Ext.GetStat(rune)[slotRune[slot]]
end

---@param character string GUID
---@return boolean[] Each rune is a key to avoid duplicates
function GetRuneStats(character)
    local equipment = GetEquipment(character)
    local runes = {}
    for slot,piece in pairs(equipment) do
        if piece ~= "" and piece ~= nil then
            for i=3,5,1 do
                local boost = piece.DynamicStats[i].BoostName
                if boost ~= "" and boost ~= nil then
                    local rune = GetMatchingBoost(boost, piece.Slot)
                    runes[rune] = true
                end
            end
        end
    end
    return runes
end

---@param runes boolean[] List of rune templates
function LookRunesForTag(character, tag)
    local runes = GetRuneStats(character)
    for rune,bool in pairs(runes) do
        if Ext.GetStat(rune).Tags:find(tag) ~= nil then return true end
    end
    return false
end

